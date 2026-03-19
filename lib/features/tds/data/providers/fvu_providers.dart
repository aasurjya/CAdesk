import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/services/fvu_pre_scrutiny_service.dart';

// ---------------------------------------------------------------------------
// FVU wizard step
// ---------------------------------------------------------------------------

/// Tracks the current step in the FVU generation wizard (0-indexed).
final fvuWizardStepProvider = NotifierProvider<FvuWizardStepNotifier, int>(
  FvuWizardStepNotifier.new,
);

class FvuWizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void next() => state = (state + 1).clamp(0, 4);
  void previous() => state = (state - 1).clamp(0, 4);
  void goTo(int step) => state = step.clamp(0, 4);
  void reset() => state = 0;
}

// ---------------------------------------------------------------------------
// Selection providers
// ---------------------------------------------------------------------------

/// The selected deductor for FVU generation.
final fvuSelectedDeductorProvider =
    NotifierProvider<FvuSelectedDeductorNotifier, TdsDeductor?>(
      FvuSelectedDeductorNotifier.new,
    );

class FvuSelectedDeductorNotifier extends Notifier<TdsDeductor?> {
  @override
  TdsDeductor? build() => null;

  void select(TdsDeductor? deductor) => state = deductor;
}

/// The selected form type (24Q/26Q/27Q/27EQ) for FVU generation.
final fvuFormTypeProvider = NotifierProvider<FvuFormTypeNotifier, TdsFormType>(
  FvuFormTypeNotifier.new,
);

class FvuFormTypeNotifier extends Notifier<TdsFormType> {
  @override
  TdsFormType build() => TdsFormType.form24Q;

  void select(TdsFormType formType) => state = formType;
}

/// The selected quarter for FVU generation.
final fvuQuarterProvider = NotifierProvider<FvuQuarterNotifier, TdsQuarter>(
  FvuQuarterNotifier.new,
);

class FvuQuarterNotifier extends Notifier<TdsQuarter> {
  @override
  TdsQuarter build() => TdsQuarter.q1;

  void select(TdsQuarter quarter) => state = quarter;
}

// ---------------------------------------------------------------------------
// Mock deductee / challan records for FVU
// ---------------------------------------------------------------------------

/// Deductee records for the selected FVU parameters.
final fvuDeducteeRecordsProvider = Provider<List<FvuDeducteeRecord>>((ref) {
  final deductor = ref.watch(fvuSelectedDeductorProvider);
  if (deductor == null) return const [];

  // Return mock deductee records based on the selected deductor.
  return List.unmodifiable(_mockDeducteeRecords);
});

/// Challan records for the selected FVU parameters.
final fvuChallanRecordsProvider = Provider<List<FvuChallanRecord>>((ref) {
  final deductor = ref.watch(fvuSelectedDeductorProvider);
  if (deductor == null) return const [];

  return List.unmodifiable(_mockChallanRecords);
});

// ---------------------------------------------------------------------------
// Validation & generation
// ---------------------------------------------------------------------------

/// Pre-scrutiny validation results for the current FVU data.
final fvuValidationResultProvider = Provider<List<ScrutinyIssue>>((ref) {
  final deductor = ref.watch(fvuSelectedDeductorProvider);
  if (deductor == null) return const [];

  final fvuStructure = ref.watch(fvuFileStructureProvider);
  if (fvuStructure == null) return const [];

  return FvuPreScrutinyService.scrutinize(fvuStructure);
});

/// Assembled FVU file structure from current selections.
final fvuFileStructureProvider = Provider<FvuFileStructure?>((ref) {
  final deductor = ref.watch(fvuSelectedDeductorProvider);
  if (deductor == null) return null;

  final deductees = ref.watch(fvuDeducteeRecordsProvider);
  final challans = ref.watch(fvuChallanRecordsProvider);
  final formType = ref.watch(fvuFormTypeProvider);
  final quarter = ref.watch(fvuQuarterProvider);

  if (deductees.isEmpty || challans.isEmpty) return null;

  return _buildStructure(
    deductor: deductor,
    formType: formType,
    quarter: quarter,
    deductees: deductees,
    challans: challans,
  );
});

/// FVU generation progress status.
enum FvuGenerationStatus { idle, generating, success, error }

final fvuGenerationStatusProvider =
    NotifierProvider<FvuGenerationStatusNotifier, FvuGenerationStatus>(
      FvuGenerationStatusNotifier.new,
    );

class FvuGenerationStatusNotifier extends Notifier<FvuGenerationStatus> {
  @override
  FvuGenerationStatus build() => FvuGenerationStatus.idle;

  void setGenerating() => state = FvuGenerationStatus.generating;
  void setSuccess() => state = FvuGenerationStatus.success;
  void setError() => state = FvuGenerationStatus.error;
  void reset() => state = FvuGenerationStatus.idle;
}

// ---------------------------------------------------------------------------
// Private helpers & mock data
// ---------------------------------------------------------------------------

FvuFileStructure _buildStructure({
  required TdsDeductor deductor,
  required TdsFormType formType,
  required TdsQuarter quarter,
  required List<FvuDeducteeRecord> deductees,
  required List<FvuChallanRecord> challans,
}) {
  final totalTds = deductees.fold(0.0, (sum, d) => sum + d.tdsAmount);

  final batchHeader = FvuBatchHeader(
    tan: deductor.tan,
    pan: deductor.pan,
    deductorName: deductor.deductorName,
    financialYear: '2025-26',
    quarter: quarter,
    formType: formType,
    preparationDate: '17032026',
    totalChallans: challans.length,
    totalDeductees: deductees.length,
    totalTaxDeducted: totalTds,
  );

  final challanGroups = challans.map((challan) {
    final groupDeductees = deductees
        .where((d) => d.sectionCode == challan.sectionCode)
        .toList();
    return FvuChallanWithDeductees(
      challan: challan,
      deductees: groupDeductees.isEmpty ? [deductees.first] : groupDeductees,
    );
  }).toList();

  return FvuFileStructure(batchHeader: batchHeader, challans: challanGroups);
}

const _mockDeducteeRecords = <FvuDeducteeRecord>[
  FvuDeducteeRecord(
    pan: 'ABCPK1234A',
    deducteeName: 'Rajesh Kumar',
    amountPaid: 750000,
    tdsAmount: 75000,
    dateOfPayment: '30062025',
    sectionCode: '192',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  ),
  FvuDeducteeRecord(
    pan: 'DEFPS5678B',
    deducteeName: 'Priya Sharma',
    amountPaid: 620000,
    tdsAmount: 62000,
    dateOfPayment: '30062025',
    sectionCode: '192',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  ),
  FvuDeducteeRecord(
    pan: 'GHIAV9012C',
    deducteeName: 'Amit Verma',
    amountPaid: 480000,
    tdsAmount: 24000,
    dateOfPayment: '15052025',
    sectionCode: '194C',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  ),
  FvuDeducteeRecord(
    pan: 'PANNOTAVBL',
    deducteeName: 'Vikram Traders',
    amountPaid: 350000,
    tdsAmount: 70000,
    dateOfPayment: '20062025',
    sectionCode: '194J',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  ),
  FvuDeducteeRecord(
    pan: 'JKLNP3456D',
    deducteeName: 'Neha Patel',
    amountPaid: 920000,
    tdsAmount: 92000,
    dateOfPayment: '30062025',
    sectionCode: '192',
    deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
  ),
];

const _mockChallanRecords = <FvuChallanRecord>[
  FvuChallanRecord(
    bsrCode: '0002390',
    challanTenderDate: '07072025',
    challanSerialNumber: '0000000101',
    totalTaxDeposited: 250000,
    deducteeCount: 3,
    sectionCode: '192',
  ),
  FvuChallanRecord(
    bsrCode: '0002390',
    challanTenderDate: '07072025',
    challanSerialNumber: '0000000102',
    totalTaxDeposited: 24000,
    deducteeCount: 1,
    sectionCode: '194C',
  ),
  FvuChallanRecord(
    bsrCode: '0002390',
    challanTenderDate: '07072025',
    challanSerialNumber: '0000000103',
    totalTaxDeposited: 70000,
    deducteeCount: 1,
    sectionCode: '194J',
  ),
];

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/data/services/draft_storage_service.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/tds_payment_summary.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';
import 'package:ca_app/features/filing/domain/models/interest_result.dart';
import 'package:ca_app/features/filing/domain/services/tax_computation_engine.dart';
import 'package:ca_app/features/filing/domain/services/interest_computation_service.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

// ---------------------------------------------------------------------------
// Mock seed data
// ---------------------------------------------------------------------------

final _kNow = DateTime(2026, 3, 11);

final _kSampleItr1 = Itr1FormData(
  personalInfo: PersonalInfo(
    firstName: 'Ramesh',
    middleName: '',
    lastName: 'Kumar',
    pan: 'ABCPK1234F',
    aadhaarNumber: '9876 5432 1012',
    dateOfBirth: DateTime(1985, 6, 15),
    email: 'ramesh.kumar@example.com',
    mobile: '9876543210',
    flatDoorBlock: '12-A, Sunrise Apartments',
    street: 'MG Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560001',
    employerName: 'TechCorp India Pvt Ltd',
    employerTan: 'BLRT01234A',
    bankAccountNumber: '50100012345678',
    bankIfsc: 'HDFC0001234',
    bankName: 'HDFC Bank',
  ),
  salaryIncome: const SalaryIncome(
    grossSalary: 2400000,
    allowancesExemptUnderSection10: 120000,
    valueOfPerquisites: 0,
    profitsInLieuOfSalary: 0,
    standardDeduction: 75000,
  ),
  housePropertyIncome: const HousePropertyIncome(
    annualLetableValue: 0,
    municipalTaxesPaid: 0,
    interestOnLoan: 0,
  ),
  otherSourceIncome: const OtherSourceIncome(
    savingsAccountInterest: 18000,
    fixedDepositInterest: 55000,
    dividendIncome: 12000,
    familyPension: 0,
    otherIncome: 0,
  ),
  deductions: const ChapterViaDeductions(
    section80C: 150000,
    section80CCD1B: 50000,
    section80DSelf: 25000,
    section80DParents: 0,
    section80E: 0,
    section80G: 5000,
    section80TTA: 10000,
    section80TTB: 0,
  ),
  selectedRegime: TaxRegime.newRegime,
  tdsPaymentSummary: const TdsPaymentSummary(
    tdsOnSalary: 180000,
    tdsOnOtherIncome: 5500,
    advanceTaxQ1: 0,
    advanceTaxQ2: 0,
    advanceTaxQ3: 0,
    advanceTaxQ4: 0,
    selfAssessmentTax: 0,
  ),
);

final _mockJobs = <FilingJob>[
  FilingJob(
    id: 'job-001',
    clientId: 'client-101',
    clientName: 'Ramesh Kumar',
    pan: 'ABCPK1234F',
    assessmentYear: 'AY 2026-27',
    itrType: ItrType.itr1,
    status: FilingJobStatus.draft,
    createdAt: _kNow.subtract(const Duration(days: 5)),
    updatedAt: _kNow.subtract(const Duration(days: 1)),
    itr1Data: _kSampleItr1,
  ),
  FilingJob(
    id: 'job-002',
    clientId: 'client-102',
    clientName: 'Priya Sharma',
    pan: 'BCDPS5678G',
    assessmentYear: 'AY 2026-27',
    itrType: ItrType.itr1,
    status: FilingJobStatus.review,
    createdAt: _kNow.subtract(const Duration(days: 10)),
    updatedAt: _kNow.subtract(const Duration(days: 2)),
  ),
  FilingJob(
    id: 'job-003',
    clientId: 'client-103',
    clientName: 'Anil Verma',
    pan: 'CDEAV9012H',
    assessmentYear: 'AY 2026-27',
    itrType: ItrType.itr2,
    status: FilingJobStatus.ready,
    createdAt: _kNow.subtract(const Duration(days: 15)),
    updatedAt: _kNow.subtract(const Duration(days: 3)),
  ),
  FilingJob(
    id: 'job-004',
    clientId: 'client-104',
    clientName: 'Sunita Mehta',
    pan: 'DEFSM3456I',
    assessmentYear: 'AY 2025-26',
    itrType: ItrType.itr1,
    status: FilingJobStatus.verified,
    createdAt: _kNow.subtract(const Duration(days: 90)),
    updatedAt: _kNow.subtract(const Duration(days: 30)),
    acknowledgementNumber: 'ACK123456789',
  ),
];

// ---------------------------------------------------------------------------
// Filing jobs notifier
// ---------------------------------------------------------------------------

class FilingJobsNotifier extends Notifier<List<FilingJob>> {
  @override
  List<FilingJob> build() => List.unmodifiable(_mockJobs);

  void add(FilingJob job) {
    state = [...state, job];
  }

  void update(FilingJob updated) {
    state = [
      for (final j in state)
        if (j.id == updated.id) updated else j,
    ];
  }

  void remove(String jobId) {
    state = [
      for (final j in state)
        if (j.id != jobId) j,
    ];
  }
}

final filingJobsProvider =
    NotifierProvider<FilingJobsNotifier, List<FilingJob>>(
      FilingJobsNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active filing job selection
// ---------------------------------------------------------------------------

class _ActiveJobIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void set(String? id) => state = id;
}

/// Currently active filing job ID (set when navigating into a wizard).
final activeFilingJobIdProvider =
    NotifierProvider<_ActiveJobIdNotifier, String?>(_ActiveJobIdNotifier.new);

/// Derived: active filing job resolved from the jobs list.
final activeFilingJobProvider = Provider<FilingJob?>((ref) {
  final id = ref.watch(activeFilingJobIdProvider);
  if (id == null) return null;
  final jobs = ref.watch(filingJobsProvider);
  try {
    return jobs.firstWhere((j) => j.id == id);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// ITR-1 form data notifier
// ---------------------------------------------------------------------------

class Itr1FormDataNotifier extends Notifier<Itr1FormData> {
  Timer? _debounce;

  @override
  Itr1FormData build() => Itr1FormData.empty();

  /// Load a previously saved draft from local storage, falling back to
  /// the in-memory [FilingJob.itr1Data] if no persisted draft exists.
  Future<void> loadDraft(String jobId) async {
    final saved = await DraftStorageService.loadDraft(jobId);
    if (saved != null) {
      state = saved;
      return;
    }
    // Fall back to form data attached to the in-memory job.
    final job = ref.read(activeFilingJobProvider);
    if (job?.itr1Data != null) {
      state = job!.itr1Data!;
    }
  }

  void reset() {
    _debounce?.cancel();
    state = Itr1FormData.empty();
  }

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(personalInfo: info);
    _scheduleSave();
  }

  void updateSalaryIncome(SalaryIncome income) {
    state = state.copyWith(salaryIncome: income);
    _scheduleSave();
  }

  void updateHouseProperty(HousePropertyIncome hp) {
    state = state.copyWith(housePropertyIncome: hp);
    _scheduleSave();
  }

  void updateOtherSources(OtherSourceIncome os) {
    state = state.copyWith(otherSourceIncome: os);
    _scheduleSave();
  }

  void updateDeductions(ChapterViaDeductions d) {
    state = state.copyWith(deductions: d);
    _scheduleSave();
  }

  void updateRegime(TaxRegime regime) {
    state = state.copyWith(selectedRegime: regime);
    _scheduleSave();
  }

  void updateTdsPaymentSummary(TdsPaymentSummary tds) {
    state = state.copyWith(tdsPaymentSummary: tds);
    _scheduleSave();
  }

  /// Debounced auto-save: waits 500ms after last change before persisting.
  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final jobId = ref.read(activeFilingJobIdProvider);
      if (jobId != null) {
        DraftStorageService.saveDraft(jobId, state);
      }
    });
  }
}

final itr1FormDataProvider =
    NotifierProvider<Itr1FormDataNotifier, Itr1FormData>(
      Itr1FormDataNotifier.new,
    );

// ---------------------------------------------------------------------------
// Derived: live tax computation
// ---------------------------------------------------------------------------

/// Recomputes whenever form data changes. Returns full old vs new comparison.
final liveTaxComputationProvider = Provider<TaxRegimeResult>((ref) {
  final formData = ref.watch(itr1FormDataProvider);
  return TaxComputationEngine.compare(formData);
});

// ---------------------------------------------------------------------------
// Derived: live interest computation
// ---------------------------------------------------------------------------

/// Computes Sections 234A/B/C interest based on the selected regime tax and
/// TDS/advance tax actually paid.
final liveInterestProvider = Provider<InterestResult>((ref) {
  final formData = ref.watch(itr1FormDataProvider);
  final taxResult = ref.watch(liveTaxComputationProvider);
  final selectedTax = formData.selectedRegime == TaxRegime.newRegime
      ? taxResult.newRegimeTax
      : taxResult.oldRegimeTax;
  final tds = formData.tdsPaymentSummary;

  return InterestComputationService.compute(
    taxPayable: selectedTax,
    advanceTaxPaid: tds.totalAdvanceTax,
    advanceTaxByQuarter: tds.advanceTaxByQuarter,
    filingDate: DateTime(2026, 7, 31),
    dueDate: DateTime(2026, 7, 31),
    assessmentYearStart: DateTime(2026, 4, 1),
  );
});

// ---------------------------------------------------------------------------
// Wizard step tracking
// ---------------------------------------------------------------------------

class _WizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void reset() => state = 0;

  void goTo(int step) => state = step;
}

/// Zero-based index of the currently visible wizard step (0..7).
final wizardStepProvider = NotifierProvider<_WizardStepNotifier, int>(
  _WizardStepNotifier.new,
);

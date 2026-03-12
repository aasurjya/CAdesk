import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:ca_app/features/tds/domain/services/form16_generation_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _employerTan = 'MUMM12345B';
const _employerPan = 'AABCT1234A';
const _employerName = 'Tata Consultancy Services Ltd';

const _employerAddress = TdsAddress(
  line1: '9th Floor, Nirmal Building',
  line2: 'Nariman Point',
  city: 'Mumbai',
  state: 'Maharashtra',
  pincode: '400021',
);

// ---------------------------------------------------------------------------
// Mock data builder
// ---------------------------------------------------------------------------

Form16QuarterDetail _quarter({
  required TdsQuarter q,
  required double deducted,
  required double deposited,
  required String receipt,
  required DateTime depositDate,
  required String bsr,
  required String challan,
}) {
  return Form16QuarterDetail(
    quarter: q,
    receiptNumbers: [receipt],
    taxDeducted: deducted,
    taxDeposited: deposited,
    dateOfDeposit: depositDate,
    bsrCode: bsr,
    challanSerialNumber: challan,
    status: 'Deposited',
  );
}

Form16Data _buildMock({
  required String certNum,
  required String empPan,
  required String empName,
  required String empLine1,
  required String empCity,
  required String empState,
  required String empPin,
  required List<double> qDeducted,
  required List<double> qDeposited,
  required double grossSalary,
  required double sal17_1,
  required double perquisites,
  required double exemptAllowances,
  required double sec80C,
  required double sec80D,
  required double sec80CCD1B,
  required double taxOnIncome,
  required double rebate87A,
  required double surcharge,
  required double cess,
  required String regime,
}) {
  final quarters = [
    _quarter(
      q: TdsQuarter.q1,
      deducted: qDeducted[0],
      deposited: qDeposited[0],
      receipt: 'REC-$certNum-Q1',
      depositDate: DateTime(2025, 7, 7),
      bsr: '0002390',
      challan: 'ITNS-$certNum-Q1',
    ),
    _quarter(
      q: TdsQuarter.q2,
      deducted: qDeducted[1],
      deposited: qDeposited[1],
      receipt: 'REC-$certNum-Q2',
      depositDate: DateTime(2025, 10, 7),
      bsr: '0002390',
      challan: 'ITNS-$certNum-Q2',
    ),
    _quarter(
      q: TdsQuarter.q3,
      deducted: qDeducted[2],
      deposited: qDeposited[2],
      receipt: 'REC-$certNum-Q3',
      depositDate: DateTime(2026, 1, 7),
      bsr: '0002390',
      challan: 'ITNS-$certNum-Q3',
    ),
    _quarter(
      q: TdsQuarter.q4,
      deducted: qDeducted[3],
      deposited: qDeposited[3],
      receipt: 'REC-$certNum-Q4',
      depositDate: DateTime(2026, 4, 7),
      bsr: '0002390',
      challan: 'ITNS-$certNum-Q4',
    ),
  ];

  final netSalary = grossSalary - exemptAllowances;
  const standardDeduction = 5000000.0; // 50,000 in paise
  final incomeFromSalary = netSalary - standardDeduction;
  final deductionsTotal = sec80C + sec80D + sec80CCD1B;
  final totalIncome = incomeFromSalary - deductionsTotal;
  final netTax = taxOnIncome - rebate87A + surcharge + cess;

  return Form16Data(
    certificateNumber: '$_employerTan/2025-26/Form16/$certNum',
    employerTan: _employerTan,
    employerPan: _employerPan,
    employerName: _employerName,
    employerAddress: _employerAddress,
    employeePan: empPan,
    employeeName: empName,
    employeeAddress: TdsAddress(
      line1: empLine1,
      city: empCity,
      state: empState,
      pincode: empPin,
    ),
    assessmentYear: '2026-27',
    periodFrom: DateTime(2025, 4, 1),
    periodTo: DateTime(2026, 3, 31),
    partA: Form16PartA(quarterlyDetails: quarters),
    partB: Form16PartB(
      salaryBreakup: SalaryBreakup(
        grossSalary: grossSalary,
        salaryAsPerSection17_1: sal17_1,
        valueOfPerquisites17_2: perquisites,
        profitsInLieuOfSalary17_3: 0,
        exemptAllowances: exemptAllowances,
        standardDeduction: standardDeduction,
        entertainmentAllowance: 0,
        professionalTax: 250000, // 2,500 in paise
      ),
      incomeFromHouseProperty: 0,
      incomeFromOtherSources: 0,
      deductions: ChapterVIADeductions(
        section80C: sec80C,
        section80CCC: 0,
        section80CCD1: 0,
        section80CCD1B: sec80CCD1B,
        section80CCD2: 0,
        section80D: sec80D,
        section80DD: 0,
        section80DDB: 0,
        section80E: 0,
        section80EE: 0,
        section80EEA: 0,
        section80G: 0,
        section80GG: 0,
        section80GGA: 0,
        section80GGC: 0,
        section80TTA: 0,
        section80TTB: 0,
        section80U: 0,
      ),
      taxComputation: TaxComputation(
        totalTaxableIncome: totalIncome,
        taxOnTotalIncome: taxOnIncome,
        rebate87A: rebate87A,
        surcharge: surcharge,
        educationCess: cess,
        totalTaxPayable: netTax,
        reliefSection89: 0,
        netTaxPayable: netTax,
        taxRegime: regime,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// 5 mock Form16Data records
// ---------------------------------------------------------------------------

final List<Form16Data> _mockForm16List = List.unmodifiable([
  _buildMock(
    certNum: '001',
    empPan: 'ABCDE1234F',
    empName: 'Rajesh Kumar Sharma',
    empLine1: '12, Andheri West',
    empCity: 'Mumbai',
    empState: 'Maharashtra',
    empPin: '400058',
    qDeducted: [25000, 25000, 25000, 25000],
    qDeposited: [25000, 25000, 25000, 25000],
    grossSalary: 120000000, // 12,00,000
    sal17_1: 120000000,
    perquisites: 0,
    exemptAllowances: 10000000, // 1,00,000
    sec80C: 15000000, // 1,50,000
    sec80D: 2500000, // 25,000
    sec80CCD1B: 5000000, // 50,000
    taxOnIncome: 10400000,
    rebate87A: 0,
    surcharge: 0,
    cess: 416000,
    regime: 'Old',
  ),
  _buildMock(
    certNum: '002',
    empPan: 'BGHPK5678G',
    empName: 'Priya Nair',
    empLine1: '45, Koramangala',
    empCity: 'Bengaluru',
    empState: 'Karnataka',
    empPin: '560034',
    qDeducted: [45000, 45000, 45000, 45000],
    qDeposited: [45000, 45000, 45000, 45000],
    grossSalary: 200000000, // 20,00,000
    sal17_1: 200000000,
    perquisites: 0,
    exemptAllowances: 15000000, // 1,50,000
    sec80C: 15000000,
    sec80D: 5000000,
    sec80CCD1B: 5000000,
    taxOnIncome: 28600000,
    rebate87A: 0,
    surcharge: 0,
    cess: 1144000,
    regime: 'Old',
  ),
  _buildMock(
    certNum: '003',
    empPan: 'CDJRM9012H',
    empName: 'Amit Verma',
    empLine1: '78, Connaught Place',
    empCity: 'New Delhi',
    empState: 'Delhi',
    empPin: '110001',
    qDeducted: [12500, 12500, 12500, 12500],
    qDeposited: [12500, 12500, 12500, 12500],
    grossSalary: 80000000, // 8,00,000
    sal17_1: 80000000,
    perquisites: 0,
    exemptAllowances: 5000000,
    sec80C: 15000000,
    sec80D: 2500000,
    sec80CCD1B: 0,
    taxOnIncome: 4680000,
    rebate87A: 0,
    surcharge: 0,
    cess: 187200,
    regime: 'New',
  ),
  _buildMock(
    certNum: '004',
    empPan: 'DELPN3456J',
    empName: 'Sneha Patel',
    empLine1: '23, Satellite Road',
    empCity: 'Ahmedabad',
    empState: 'Gujarat',
    empPin: '380015',
    qDeducted: [35000, 35000, 35000, 35000],
    qDeposited: [35000, 35000, 35000, 35000],
    grossSalary: 160000000, // 16,00,000
    sal17_1: 160000000,
    perquisites: 0,
    exemptAllowances: 12000000,
    sec80C: 15000000,
    sec80D: 3000000,
    sec80CCD1B: 5000000,
    taxOnIncome: 18200000,
    rebate87A: 0,
    surcharge: 0,
    cess: 728000,
    regime: 'Old',
  ),
  _buildMock(
    certNum: '005',
    empPan: 'EFGRS7890K',
    empName: 'Vikram Iyer',
    empLine1: '5, T. Nagar',
    empCity: 'Chennai',
    empState: 'Tamil Nadu',
    empPin: '600017',
    qDeducted: [18000, 18000, 18000, 18000],
    qDeposited: [18000, 18000, 18000, 18000],
    grossSalary: 100000000, // 10,00,000
    sal17_1: 100000000,
    perquisites: 0,
    exemptAllowances: 8000000,
    sec80C: 15000000,
    sec80D: 2500000,
    sec80CCD1B: 5000000,
    taxOnIncome: 6760000,
    rebate87A: 0,
    surcharge: 0,
    cess: 270400,
    regime: 'Old',
  ),
]);

// ---------------------------------------------------------------------------
// Form16 generation status enum
// ---------------------------------------------------------------------------

/// Status of a Form 16 certificate.
enum Form16Status {
  generated('Generated'),
  pending('Pending'),
  error('Error');

  const Form16Status(this.label);
  final String label;
}

// ---------------------------------------------------------------------------
// Bulk generation progress
// ---------------------------------------------------------------------------

/// Immutable state for bulk Form 16 generation progress.
@immutable
class BulkGenerationProgress {
  const BulkGenerationProgress({
    this.totalCount = 0,
    this.completedCount = 0,
    this.isRunning = false,
  });

  final int totalCount;
  final int completedCount;
  final bool isRunning;

  double get fraction => totalCount > 0 ? completedCount / totalCount : 0.0;

  BulkGenerationProgress copyWith({
    int? totalCount,
    int? completedCount,
    bool? isRunning,
  }) {
    return BulkGenerationProgress(
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifiers
// ---------------------------------------------------------------------------

class Form16ListNotifier extends Notifier<List<Form16Data>> {
  @override
  List<Form16Data> build() => _mockForm16List;
}

class SelectedForm16Notifier extends Notifier<Form16Data?> {
  @override
  Form16Data? build() => null;

  void select(Form16Data? data) => state = data;
}

class BulkGenerationProgressNotifier extends Notifier<BulkGenerationProgress> {
  @override
  BulkGenerationProgress build() => const BulkGenerationProgress();

  void start(int total) {
    state = BulkGenerationProgress(
      totalCount: total,
      completedCount: 0,
      isRunning: true,
    );
  }

  void increment() {
    final next = state.completedCount + 1;
    state = state.copyWith(
      completedCount: next,
      isRunning: next < state.totalCount,
    );
  }

  void reset() {
    state = const BulkGenerationProgress();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All Form 16 records.
final form16ListProvider =
    NotifierProvider<Form16ListNotifier, List<Form16Data>>(
      Form16ListNotifier.new,
    );

/// Currently selected Form 16 for the viewer.
final selectedForm16Provider =
    NotifierProvider<SelectedForm16Notifier, Form16Data?>(
      SelectedForm16Notifier.new,
    );

/// Provides access to the static Form16GenerationService methods.
final form16GenerationServiceProvider =
    Provider<Form16GenerationService Function()>(
      (ref) =>
          () => throw UnsupportedError(
            'Form16GenerationService is a static utility class. '
            'Call Form16GenerationService.generateForm16() directly.',
          ),
    );

/// Tracks bulk generation progress.
final form16BulkProgressProvider =
    NotifierProvider<BulkGenerationProgressNotifier, BulkGenerationProgress>(
      BulkGenerationProgressNotifier.new,
    );

/// FY selector for Form 16 screens.
final form16FinancialYearProvider = NotifierProvider<Form16FYNotifier, String>(
  Form16FYNotifier.new,
);

class Form16FYNotifier extends Notifier<String> {
  @override
  String build() => '2025-26';

  void update(String fy) => state = fy;
}

/// Available financial years for Form 16 screens.
final form16AvailableFYsProvider = Provider<List<String>>((ref) {
  return const ['2024-25', '2025-26'];
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_section_summary.dart';

// ---------------------------------------------------------------------------
// Mock deductors
// ---------------------------------------------------------------------------

final _mockDeductors = <TdsDeductor>[
  const TdsDeductor(
    id: 'ded-001',
    deductorName: 'Tata Consultancy Services Ltd',
    tan: 'MUMS12345A',
    pan: 'AABCT1234A',
    deductorType: DeductorType.company,
    address: '9th Floor, Nirmal Building, Nariman Point, Mumbai 400021',
    email: 'tds@tcs.com',
    phone: '022-67789000',
    responsiblePerson: 'Rajesh Kumar',
  ),
  const TdsDeductor(
    id: 'ded-002',
    deductorName: 'Infosys Ltd',
    tan: 'BLRI98765B',
    pan: 'AABCI5678B',
    deductorType: DeductorType.company,
    address: '44, Electronics City, Hosur Road, Bengaluru 560100',
    email: 'tax@infosys.com',
    phone: '080-28520261',
    responsiblePerson: 'Priya Sharma',
  ),
  const TdsDeductor(
    id: 'ded-003',
    deductorName: 'Ministry of Finance',
    tan: 'DELG00001C',
    pan: 'AAAGM0001C',
    deductorType: DeductorType.government,
    address: 'North Block, New Delhi 110001',
    email: 'tds@finmin.gov.in',
    phone: '011-23092792',
    responsiblePerson: 'Amit Verma',
  ),
  const TdsDeductor(
    id: 'ded-004',
    deductorName: 'Sharma & Associates',
    tan: 'DELP44321D',
    pan: 'ABCFS1234D',
    deductorType: DeductorType.firm,
    address: '12, Connaught Place, New Delhi 110001',
    email: 'ca@sharmaassociates.in',
    phone: '011-23456789',
    responsiblePerson: 'Vikram Sharma',
  ),
  const TdsDeductor(
    id: 'ded-005',
    deductorName: 'Reliance Industries Ltd',
    tan: 'MUMR67890E',
    pan: 'AABCR5678E',
    deductorType: DeductorType.company,
    address: 'Maker Chambers IV, Nariman Point, Mumbai 400021',
    email: 'tds@ril.com',
    phone: '022-35553000',
    responsiblePerson: 'Neha Patel',
  ),
  const TdsDeductor(
    id: 'ded-006',
    deductorName: 'Dr. Suresh Gupta',
    tan: 'CHNS11111F',
    pan: 'ABCPG1234F',
    deductorType: DeductorType.individual,
    address: '34, Anna Salai, Chennai 600002',
    email: 'dr.gupta@clinic.in',
    phone: '044-28221100',
    responsiblePerson: 'Suresh Gupta',
  ),
];

// ---------------------------------------------------------------------------
// Mock returns
// ---------------------------------------------------------------------------

final _mockReturns = <TdsReturn>[
  // TCS — ded-001
  TdsReturn(
    id: 'ret-001',
    deductorId: 'ded-001',
    tan: 'MUMS12345A',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 4500000,
    totalTaxDeducted: 450000,
    totalDeposited: 450000,
    filedDate: DateTime(2025, 7, 15),
    tokenNumber: 'TKN202507001',
  ),
  TdsReturn(
    id: 'ret-002',
    deductorId: 'ded-001',
    tan: 'MUMS12345A',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 4800000,
    totalTaxDeducted: 480000,
    totalDeposited: 480000,
    filedDate: DateTime(2025, 10, 14),
    tokenNumber: 'TKN202510002',
  ),
  TdsReturn(
    id: 'ret-003',
    deductorId: 'ded-001',
    tan: 'MUMS12345A',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q3,
    financialYear: '2025-26',
    status: TdsReturnStatus.prepared,
    totalDeductions: 5100000,
    totalTaxDeducted: 510000,
    totalDeposited: 510000,
  ),
  TdsReturn(
    id: 'ret-004',
    deductorId: 'ded-001',
    tan: 'MUMS12345A',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q4,
    financialYear: '2025-26',
    status: TdsReturnStatus.pending,
    totalDeductions: 0,
    totalTaxDeducted: 0,
    totalDeposited: 0,
  ),
  // 26Q — ded-001
  TdsReturn(
    id: 'ret-005',
    deductorId: 'ded-001',
    tan: 'MUMS12345A',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 2200000,
    totalTaxDeducted: 220000,
    totalDeposited: 220000,
    filedDate: DateTime(2025, 7, 20),
    tokenNumber: 'TKN202507005',
  ),
  TdsReturn(
    id: 'ret-006',
    deductorId: 'ded-001',
    tan: 'MUMS12345A',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.pending,
    totalDeductions: 2500000,
    totalTaxDeducted: 250000,
    totalDeposited: 200000,
  ),
  // ded-002 — Infosys
  TdsReturn(
    id: 'ret-007',
    deductorId: 'ded-002',
    tan: 'BLRI98765B',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 8200000,
    totalTaxDeducted: 820000,
    totalDeposited: 820000,
    filedDate: DateTime(2025, 7, 10),
    tokenNumber: 'TKN202507007',
  ),
  TdsReturn(
    id: 'ret-008',
    deductorId: 'ded-002',
    tan: 'BLRI98765B',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 8500000,
    totalTaxDeducted: 850000,
    totalDeposited: 850000,
    filedDate: DateTime(2025, 10, 12),
    tokenNumber: 'TKN202510008',
  ),
  TdsReturn(
    id: 'ret-009',
    deductorId: 'ded-002',
    tan: 'BLRI98765B',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q3,
    financialYear: '2025-26',
    status: TdsReturnStatus.pending,
    totalDeductions: 8700000,
    totalTaxDeducted: 870000,
    totalDeposited: 650000,
  ),
  TdsReturn(
    id: 'ret-010',
    deductorId: 'ded-002',
    tan: 'BLRI98765B',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.revised,
    totalDeductions: 3500000,
    totalTaxDeducted: 350000,
    totalDeposited: 350000,
    filedDate: DateTime(2025, 8, 5),
    tokenNumber: 'TKN202508010',
  ),
  // ded-003 — Ministry of Finance
  TdsReturn(
    id: 'ret-011',
    deductorId: 'ded-003',
    tan: 'DELG00001C',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 12000000,
    totalTaxDeducted: 1200000,
    totalDeposited: 1200000,
    filedDate: DateTime(2025, 7, 5),
    tokenNumber: 'TKN202507011',
  ),
  TdsReturn(
    id: 'ret-012',
    deductorId: 'ded-003',
    tan: 'DELG00001C',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 12500000,
    totalTaxDeducted: 1250000,
    totalDeposited: 1250000,
    filedDate: DateTime(2025, 10, 8),
    tokenNumber: 'TKN202510012',
  ),
  TdsReturn(
    id: 'ret-013',
    deductorId: 'ded-003',
    tan: 'DELG00001C',
    formType: TdsFormType.form24Q,
    quarter: TdsQuarter.q3,
    financialYear: '2025-26',
    status: TdsReturnStatus.prepared,
    totalDeductions: 13000000,
    totalTaxDeducted: 1300000,
    totalDeposited: 1300000,
  ),
  // ded-004 — Sharma & Associates
  TdsReturn(
    id: 'ret-014',
    deductorId: 'ded-004',
    tan: 'DELP44321D',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 750000,
    totalTaxDeducted: 75000,
    totalDeposited: 75000,
    filedDate: DateTime(2025, 7, 25),
    tokenNumber: 'TKN202507014',
  ),
  TdsReturn(
    id: 'ret-015',
    deductorId: 'ded-004',
    tan: 'DELP44321D',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.pending,
    totalDeductions: 820000,
    totalTaxDeducted: 82000,
    totalDeposited: 60000,
  ),
  // ded-005 — Reliance
  TdsReturn(
    id: 'ret-016',
    deductorId: 'ded-005',
    tan: 'MUMR67890E',
    formType: TdsFormType.form27Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 15000000,
    totalTaxDeducted: 3000000,
    totalDeposited: 3000000,
    filedDate: DateTime(2025, 7, 18),
    tokenNumber: 'TKN202507016',
  ),
  TdsReturn(
    id: 'ret-017',
    deductorId: 'ded-005',
    tan: 'MUMR67890E',
    formType: TdsFormType.form27EQ,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 9500000,
    totalTaxDeducted: 95000,
    totalDeposited: 95000,
    filedDate: DateTime(2025, 7, 22),
    tokenNumber: 'TKN202507017',
  ),
  TdsReturn(
    id: 'ret-018',
    deductorId: 'ded-005',
    tan: 'MUMR67890E',
    formType: TdsFormType.form27EQ,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.pending,
    totalDeductions: 10200000,
    totalTaxDeducted: 102000,
    totalDeposited: 80000,
  ),
  // ded-006 — Dr. Gupta
  TdsReturn(
    id: 'ret-019',
    deductorId: 'ded-006',
    tan: 'CHNS11111F',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q1,
    financialYear: '2025-26',
    status: TdsReturnStatus.filed,
    totalDeductions: 320000,
    totalTaxDeducted: 32000,
    totalDeposited: 32000,
    filedDate: DateTime(2025, 7, 28),
    tokenNumber: 'TKN202507019',
  ),
  TdsReturn(
    id: 'ret-020',
    deductorId: 'ded-006',
    tan: 'CHNS11111F',
    formType: TdsFormType.form26Q,
    quarter: TdsQuarter.q2,
    financialYear: '2025-26',
    status: TdsReturnStatus.prepared,
    totalDeductions: 350000,
    totalTaxDeducted: 35000,
    totalDeposited: 35000,
  ),
];

// ---------------------------------------------------------------------------
// Mock challans
// ---------------------------------------------------------------------------

final _mockChallans = <TdsChallan>[
  // ded-001 TCS — section 192 salary
  const TdsChallan(
    id: 'chl-001',
    deductorId: 'ded-001',
    challanNumber: 'ITNS281-2025-0101',
    bsrCode: '0002390',
    section: '192',
    deducteeCount: 320,
    tdsAmount: 450000,
    surcharge: 0,
    educationCess: 18000,
    interest: 0,
    penalty: 0,
    totalAmount: 468000,
    paymentDate: '07 Jul 2025',
    month: 6,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  const TdsChallan(
    id: 'chl-002',
    deductorId: 'ded-001',
    challanNumber: 'ITNS281-2025-0234',
    bsrCode: '0002390',
    section: '192',
    deducteeCount: 320,
    tdsAmount: 480000,
    surcharge: 0,
    educationCess: 19200,
    interest: 0,
    penalty: 0,
    totalAmount: 499200,
    paymentDate: '07 Oct 2025',
    month: 9,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  // ded-001 — section 194J professional fees
  const TdsChallan(
    id: 'chl-003',
    deductorId: 'ded-001',
    challanNumber: 'ITNS281-2025-0289',
    bsrCode: '0002390',
    section: '194J',
    deducteeCount: 45,
    tdsAmount: 220000,
    surcharge: 0,
    educationCess: 8800,
    interest: 0,
    penalty: 0,
    totalAmount: 228800,
    paymentDate: '07 Aug 2025',
    month: 7,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  // ded-002 Infosys — section 192 salary
  const TdsChallan(
    id: 'chl-004',
    deductorId: 'ded-002',
    challanNumber: 'ITNS281-2025-0310',
    bsrCode: '0004521',
    section: '192',
    deducteeCount: 580,
    tdsAmount: 820000,
    surcharge: 0,
    educationCess: 32800,
    interest: 0,
    penalty: 0,
    totalAmount: 852800,
    paymentDate: '07 Jul 2025',
    month: 6,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  const TdsChallan(
    id: 'chl-005',
    deductorId: 'ded-002',
    challanNumber: 'ITNS281-2025-0455',
    bsrCode: '0004521',
    section: '192',
    deducteeCount: 590,
    tdsAmount: 850000,
    surcharge: 0,
    educationCess: 34000,
    interest: 0,
    penalty: 0,
    totalAmount: 884000,
    paymentDate: '07 Oct 2025',
    month: 9,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  // ded-002 — section 194C contractor — Overdue
  const TdsChallan(
    id: 'chl-006',
    deductorId: 'ded-002',
    challanNumber: 'ITNS281-2025-0512',
    bsrCode: '0004521',
    section: '194C',
    deducteeCount: 18,
    tdsAmount: 35000,
    surcharge: 0,
    educationCess: 1400,
    interest: 1050,
    penalty: 0,
    totalAmount: 37450,
    paymentDate: '22 Nov 2025',
    month: 10,
    financialYear: '2025-26',
    status: 'Overdue',
  ),
  // ded-003 Ministry of Finance — section 192
  const TdsChallan(
    id: 'chl-007',
    deductorId: 'ded-003',
    challanNumber: 'ITNS281-2025-0600',
    bsrCode: '0001001',
    section: '192',
    deducteeCount: 850,
    tdsAmount: 1200000,
    surcharge: 0,
    educationCess: 48000,
    interest: 0,
    penalty: 0,
    totalAmount: 1248000,
    paymentDate: '05 Jul 2025',
    month: 6,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  const TdsChallan(
    id: 'chl-008',
    deductorId: 'ded-003',
    challanNumber: 'ITNS281-2025-0740',
    bsrCode: '0001001',
    section: '192',
    deducteeCount: 860,
    tdsAmount: 1250000,
    surcharge: 0,
    educationCess: 50000,
    interest: 0,
    penalty: 0,
    totalAmount: 1300000,
    paymentDate: '07 Oct 2025',
    month: 9,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  // ded-004 Sharma & Associates — section 194A interest — Overdue
  const TdsChallan(
    id: 'chl-009',
    deductorId: 'ded-004',
    challanNumber: 'ITNS281-2025-0810',
    bsrCode: '0009876',
    section: '194A',
    deducteeCount: 12,
    tdsAmount: 75000,
    surcharge: 0,
    educationCess: 3000,
    interest: 2250,
    penalty: 0,
    totalAmount: 80250,
    paymentDate: '18 Aug 2025',
    month: 7,
    financialYear: '2025-26',
    status: 'Overdue',
  ),
  // ded-005 Reliance — section 195 non-resident
  const TdsChallan(
    id: 'chl-010',
    deductorId: 'ded-005',
    challanNumber: 'ITNS281-2025-0900',
    bsrCode: '0003210',
    section: '195',
    deducteeCount: 8,
    tdsAmount: 3000000,
    surcharge: 300000,
    educationCess: 132000,
    interest: 0,
    penalty: 0,
    totalAmount: 3432000,
    paymentDate: '07 Aug 2025',
    month: 7,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  // ded-006 Dr. Gupta — section 194J professional fees
  const TdsChallan(
    id: 'chl-011',
    deductorId: 'ded-006',
    challanNumber: 'ITNS281-2025-0950',
    bsrCode: '0007654',
    section: '194J',
    deducteeCount: 6,
    tdsAmount: 32000,
    surcharge: 0,
    educationCess: 1280,
    interest: 0,
    penalty: 0,
    totalAmount: 33280,
    paymentDate: '07 Aug 2025',
    month: 7,
    financialYear: '2025-26',
    status: 'Paid',
  ),
  const TdsChallan(
    id: 'chl-012',
    deductorId: 'ded-006',
    challanNumber: 'ITNS281-2025-0988',
    bsrCode: '0007654',
    section: '194C',
    deducteeCount: 3,
    tdsAmount: 8500,
    surcharge: 0,
    educationCess: 340,
    interest: 0,
    penalty: 0,
    totalAmount: 8840,
    paymentDate: '07 Nov 2025',
    month: 10,
    financialYear: '2025-26',
    status: 'Paid',
  ),
];

// ---------------------------------------------------------------------------
// Mock section summaries
// ---------------------------------------------------------------------------

final _mockSectionSummaries = <TdsSectionSummary>[
  const TdsSectionSummary(
    section: '192',
    sectionDescription: 'Salary',
    ratePercent: 10.0,
    totalPayments: 45000000,
    totalTdsDeducted: 4500000,
    totalTdsPaid: 4500000,
    outstandingTds: 0,
    deducteeCount: 1890,
  ),
  const TdsSectionSummary(
    section: '194A',
    sectionDescription: 'Interest (non-bank)',
    ratePercent: 10.0,
    totalPayments: 820000,
    totalTdsDeducted: 82000,
    totalTdsPaid: 60000,
    outstandingTds: 22000,
    deducteeCount: 12,
  ),
  const TdsSectionSummary(
    section: '194C',
    sectionDescription: 'Contractor payments',
    ratePercent: 2.0,
    totalPayments: 2150000,
    totalTdsDeducted: 43000,
    totalTdsPaid: 43000,
    outstandingTds: 0,
    deducteeCount: 21,
  ),
  const TdsSectionSummary(
    section: '194H',
    sectionDescription: 'Commission / brokerage',
    ratePercent: 5.0,
    totalPayments: 1100000,
    totalTdsDeducted: 55000,
    totalTdsPaid: 45000,
    outstandingTds: 10000,
    deducteeCount: 9,
  ),
  const TdsSectionSummary(
    section: '194J',
    sectionDescription: 'Professional / technical fees',
    ratePercent: 10.0,
    totalPayments: 2520000,
    totalTdsDeducted: 252000,
    totalTdsPaid: 252000,
    outstandingTds: 0,
    deducteeCount: 51,
  ),
  const TdsSectionSummary(
    section: '195',
    sectionDescription: 'Non-resident payments',
    ratePercent: 20.0,
    totalPayments: 15000000,
    totalTdsDeducted: 3000000,
    totalTdsPaid: 3000000,
    outstandingTds: 0,
    deducteeCount: 8,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All deductors.
final tdsDeductorsProvider = Provider<List<TdsDeductor>>((ref) {
  return List.unmodifiable(_mockDeductors);
});

/// All TDS returns.
final tdsReturnsProvider = Provider<List<TdsReturn>>((ref) {
  return List.unmodifiable(_mockReturns);
});

/// Currently selected financial year.
final selectedFinancialYearProvider =
    NotifierProvider<SelectedFinancialYearNotifier, String>(
      SelectedFinancialYearNotifier.new,
    );

class SelectedFinancialYearNotifier extends Notifier<String> {
  @override
  String build() => '2025-26';

  void update(String value) => state = value;
}

/// Available financial years for selection.
final financialYearsProvider = Provider<List<String>>((ref) {
  return const ['2023-24', '2024-25', '2025-26'];
});

/// Currently selected quarter filter. Null means all quarters.
final selectedQuarterProvider =
    NotifierProvider<SelectedQuarterNotifier, TdsQuarter?>(
      SelectedQuarterNotifier.new,
    );

class SelectedQuarterNotifier extends Notifier<TdsQuarter?> {
  @override
  TdsQuarter? build() => null;

  void update(TdsQuarter? value) => state = value;
}

/// Currently selected form type tab index.
final selectedFormTabProvider = NotifierProvider<SelectedFormTabNotifier, int>(
  SelectedFormTabNotifier.new,
);

class SelectedFormTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Maps tab index to [TdsFormType].
TdsFormType formTypeForTab(int index) {
  switch (index) {
    case 0:
      return TdsFormType.form24Q;
    case 1:
      return TdsFormType.form26Q;
    case 2:
      return TdsFormType.form27Q;
    case 3:
      return TdsFormType.form27EQ;
    default:
      return TdsFormType.form24Q;
  }
}

/// Returns filtered by FY, form type, and optionally quarter.
final filteredReturnsProvider = Provider<List<TdsReturn>>((ref) {
  final allReturns = ref.watch(tdsReturnsProvider);
  final fy = ref.watch(selectedFinancialYearProvider);
  final tabIndex = ref.watch(selectedFormTabProvider);
  final quarter = ref.watch(selectedQuarterProvider);
  final formType = formTypeForTab(tabIndex);

  return List.unmodifiable(
    allReturns.where((r) {
      final matchesFy = r.financialYear == fy;
      final matchesForm = r.formType == formType;
      final matchesQuarter = quarter == null || r.quarter == quarter;
      return matchesFy && matchesForm && matchesQuarter;
    }),
  );
});

/// Returns for a specific deductor filtered by FY.
final returnsForDeductorProvider = Provider.family<List<TdsReturn>, String>((
  ref,
  deductorId,
) {
  final allReturns = ref.watch(tdsReturnsProvider);
  final fy = ref.watch(selectedFinancialYearProvider);

  return List.unmodifiable(
    allReturns.where(
      (r) => r.deductorId == deductorId && r.financialYear == fy,
    ),
  );
});

/// Deductors that have returns matching the current form type and FY.
final deductorsForCurrentTabProvider = Provider<List<TdsDeductor>>((ref) {
  final returns = ref.watch(filteredReturnsProvider);
  final deductors = ref.watch(tdsDeductorsProvider);

  final deductorIds = returns.map((r) => r.deductorId).toSet();
  return List.unmodifiable(deductors.where((d) => deductorIds.contains(d.id)));
});

/// Summary statistics for the dashboard cards.
final tdsSummaryProvider = Provider<TdsSummary>((ref) {
  final deductors = ref.watch(tdsDeductorsProvider);
  final allReturns = ref.watch(tdsReturnsProvider);
  final fy = ref.watch(selectedFinancialYearProvider);

  final fyReturns = allReturns.where((r) => r.financialYear == fy).toList();

  final filed = fyReturns
      .where((r) => r.status == TdsReturnStatus.filed)
      .length;
  final pending = fyReturns
      .where((r) => r.status == TdsReturnStatus.pending)
      .length;
  final overdue = fyReturns
      .where(
        (r) =>
            r.status == TdsReturnStatus.pending &&
            r.totalTaxDeducted > r.totalDeposited,
      )
      .length;

  return TdsSummary(
    totalDeductors: deductors.length,
    returnsDue: pending,
    returnsFiled: filed,
    returnsOverdue: overdue,
  );
});

/// Immutable summary data for the dashboard cards.
class TdsSummary {
  const TdsSummary({
    required this.totalDeductors,
    required this.returnsDue,
    required this.returnsFiled,
    required this.returnsOverdue,
  });

  final int totalDeductors;
  final int returnsDue;
  final int returnsFiled;
  final int returnsOverdue;
}

// ---------------------------------------------------------------------------
// Challan providers
// ---------------------------------------------------------------------------

/// All challan records.
final allChallanProvider = Provider<List<TdsChallan>>((ref) {
  return List.unmodifiable(_mockChallans);
});

/// All section summaries.
final allSectionSummariesProvider = Provider<List<TdsSectionSummary>>((ref) {
  return List.unmodifiable(_mockSectionSummaries);
});

/// Challans for a specific deductor.
final challanForDeductorProvider = Provider.family<List<TdsChallan>, String>((
  ref,
  deductorId,
) {
  return ref
      .watch(allChallanProvider)
      .where((c) => c.deductorId == deductorId)
      .toList();
});

/// Aggregate challan statistics across all deductors.
final challanSummaryProvider = Provider<ChallanSummary>((ref) {
  final challans = ref.watch(allChallanProvider);
  final totalPaid = challans.fold<double>(0, (sum, c) => sum + c.totalAmount);
  final overdue = challans.where((c) => c.status == 'Overdue').length;
  final due = challans.where((c) => c.status == 'Due').length;
  return ChallanSummary(
    totalPaid: totalPaid,
    overdue: overdue,
    due: due,
    total: challans.length,
  );
});

/// Immutable aggregate challan statistics.
class ChallanSummary {
  const ChallanSummary({
    required this.totalPaid,
    required this.overdue,
    required this.due,
    required this.total,
  });

  final double totalPaid;
  final int overdue;
  final int due;
  final int total;
}

// ---------------------------------------------------------------------------
// TDS interest calculator
// ---------------------------------------------------------------------------

/// Utility class for TDS interest calculations as per Income Tax Act.
class TdsInterestCalculator {
  TdsInterestCalculator._();

  /// Interest for late deduction: 1% per month from date of deductibility.
  ///
  /// Section 201(1A)(i): 1% p.m. from the date tax was deductible
  /// to the date of actual deduction.
  static double lateDeductionInterest({
    required double amount,
    required int monthsLate,
  }) {
    return amount * 0.01 * monthsLate;
  }

  /// Interest for late deposit: 1.5% per month from date of deduction.
  ///
  /// Section 201(1A)(ii): 1.5% p.m. from the date of deduction
  /// to the date of actual payment.
  static double lateDepositInterest({
    required double amount,
    required int monthsLate,
  }) {
    return amount * 0.015 * monthsLate;
  }

  /// Returns the due date for TDS deposit for a given [month] and [year].
  ///
  /// Rule: 7th of the following month, except for March where the due date
  /// is 30th April of the next year.
  static String dueDateForMonth(int month, int year) {
    if (month == 3) {
      return '30 Apr ${year + 1}';
    }
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    const monthNames = <String>[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '07 ${monthNames[nextMonth]} $nextYear';
  }
}

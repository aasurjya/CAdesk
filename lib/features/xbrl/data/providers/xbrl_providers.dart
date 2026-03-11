import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/xbrl_element.dart';
import '../../domain/models/xbrl_filing.dart';

// ---------------------------------------------------------------------------
// Mock filings (6 filings — mix of companies, standalone & consolidated)
// ---------------------------------------------------------------------------

final List<XbrlFiling> _mockFilings = [
  XbrlFiling(
    id: 'xbrl-001',
    companyId: 'co-003',
    companyName: 'Bharat Infrastructure & Projects Limited',
    cin: 'L65910DL1995PLC234567',
    financialYear: '2024-25',
    reportType: XbrlReportType.consolidated,
    taxonomyVersion: '2023',
    status: XbrlFilingStatus.filed,
    startedDate: DateTime(2025, 10, 1),
    filedDate: DateTime(2025, 10, 28),
    totalTags: 420,
    completedTags: 420,
    validationErrors: 0,
    validationWarnings: 2,
    preparedBy: 'CA Dinesh Agrawal',
    reviewedBy: 'CA Suresh Nair',
  ),
  XbrlFiling(
    id: 'xbrl-002',
    companyId: 'co-003',
    companyName: 'Bharat Infrastructure & Projects Limited',
    cin: 'L65910DL1995PLC234567',
    financialYear: '2024-25',
    reportType: XbrlReportType.standalone,
    taxonomyVersion: '2023',
    status: XbrlFilingStatus.filed,
    startedDate: DateTime(2025, 9, 20),
    filedDate: DateTime(2025, 10, 29),
    totalTags: 380,
    completedTags: 380,
    validationErrors: 0,
    validationWarnings: 0,
    preparedBy: 'CA Dinesh Agrawal',
    reviewedBy: 'CA Suresh Nair',
  ),
  XbrlFiling(
    id: 'xbrl-003',
    companyId: 'co-001',
    companyName: 'Meridian Tech Solutions Private Limited',
    cin: 'U74999MH2018PTC312456',
    financialYear: '2024-25',
    reportType: XbrlReportType.standalone,
    taxonomyVersion: '2023',
    status: XbrlFilingStatus.review,
    startedDate: DateTime(2025, 11, 5),
    totalTags: 310,
    completedTags: 295,
    validationErrors: 3,
    validationWarnings: 8,
    preparedBy: 'CA Ramesh Gupta',
  ),
  XbrlFiling(
    id: 'xbrl-004',
    companyId: 'co-006',
    companyName: 'Horizon Media & Entertainment Private Limited',
    cin: 'U74120MH2010PTC345678',
    financialYear: '2024-25',
    reportType: XbrlReportType.standalone,
    taxonomyVersion: '2023',
    status: XbrlFilingStatus.validation,
    startedDate: DateTime(2025, 11, 20),
    totalTags: 285,
    completedTags: 285,
    validationErrors: 7,
    validationWarnings: 12,
    preparedBy: 'CA Vivek Joshi',
  ),
  XbrlFiling(
    id: 'xbrl-005',
    companyId: 'co-004',
    companyName: 'Sunshine Agro Processing Private Limited',
    cin: 'U85100GJ2016PTC789012',
    financialYear: '2024-25',
    reportType: XbrlReportType.standalone,
    taxonomyVersion: '2023',
    status: XbrlFilingStatus.dataEntry,
    startedDate: DateTime(2026, 1, 15),
    totalTags: 260,
    completedTags: 130,
    validationErrors: 0,
    validationWarnings: 5,
    preparedBy: 'CA Sanjay Trivedi',
  ),
  XbrlFiling(
    id: 'xbrl-006',
    companyId: 'co-008',
    companyName: 'Rajputana Foods & Beverages Private Limited',
    cin: 'U85400RJ2022PTC890123',
    financialYear: '2024-25',
    reportType: XbrlReportType.standalone,
    taxonomyVersion: '2023',
    status: XbrlFilingStatus.notStarted,
    totalTags: 240,
    completedTags: 0,
    validationErrors: 0,
    validationWarnings: 0,
    preparedBy: 'CA Pooja Mehta',
  ),
];

// ---------------------------------------------------------------------------
// Mock elements (20 elements for filing xbrl-003 as sample)
// ---------------------------------------------------------------------------

final List<XbrlElement> _mockElements = [
  // Balance Sheet — numeric
  XbrlElement(
    id: 'el-001',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:EquityShareCapital',
    elementType: XbrlElementType.numeric,
    label: 'Equity Share Capital',
    value: '5000000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 10),
  ),
  XbrlElement(
    id: 'el-002',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:ReservesAndSurplus',
    elementType: XbrlElementType.numeric,
    label: 'Reserves and Surplus',
    value: '28450000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 10),
  ),
  XbrlElement(
    id: 'el-003',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:LongTermBorrowings',
    elementType: XbrlElementType.numeric,
    label: 'Long-term Borrowings',
    value: '12000000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 11),
  ),
  XbrlElement(
    id: 'el-004',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:ShortTermBorrowings',
    elementType: XbrlElementType.numeric,
    label: 'Short-term Borrowings',
    value: '4500000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 11),
  ),
  XbrlElement(
    id: 'el-005',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:TradePayables',
    elementType: XbrlElementType.numeric,
    label: 'Trade Payables',
    value: '3200000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 12),
  ),
  XbrlElement(
    id: 'el-006',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:TotalAssets',
    elementType: XbrlElementType.numeric,
    label: 'Total Assets',
    value: '65700000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 12),
  ),
  XbrlElement(
    id: 'el-007',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:Revenue',
    elementType: XbrlElementType.numeric,
    label: 'Revenue from Operations',
    value: '92400000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 13),
  ),
  XbrlElement(
    id: 'el-008',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:ProfitLossAfterTax',
    elementType: XbrlElementType.numeric,
    label: 'Profit / (Loss) After Tax',
    value: '8900000',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 13),
  ),
  XbrlElement(
    id: 'el-009',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:EarningsPerShareBasic',
    elementType: XbrlElementType.numeric,
    label: 'Earnings Per Share — Basic',
    value: '17.80',
    unit: 'INR',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 14),
  ),
  XbrlElement(
    id: 'el-010',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:DeferredTaxLiabilities',
    elementType: XbrlElementType.numeric,
    label: 'Deferred Tax Liabilities (Net)',
    isRequired: false,
    isCompleted: false,
    validationMessage: 'Required when deferred tax balance exists',
    lastUpdated: DateTime(2025, 11, 14),
  ),

  // Textual disclosures — text type
  XbrlElement(
    id: 'el-011',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:NameOfCompany',
    elementType: XbrlElementType.text,
    label: 'Name of Company',
    value: 'Meridian Tech Solutions Private Limited',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 8),
  ),
  XbrlElement(
    id: 'el-012',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:CIN',
    elementType: XbrlElementType.text,
    label: 'CIN',
    value: 'U74999MH2018PTC312456',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 8),
  ),
  XbrlElement(
    id: 'el-013',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:AddressOfRegisteredOffice',
    elementType: XbrlElementType.text,
    label: 'Registered Office Address',
    value: '401, Lotus Corporate Park, Goregaon East, Mumbai 400063',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 9),
  ),
  XbrlElement(
    id: 'el-014',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:NatureOfBusiness',
    elementType: XbrlElementType.text,
    label: 'Nature of Business',
    value: 'Information Technology and Software Services',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 9),
  ),
  XbrlElement(
    id: 'el-015',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:AuditorName',
    elementType: XbrlElementType.text,
    label: 'Name of Statutory Auditor',
    isRequired: true,
    isCompleted: false,
    validationMessage: 'Auditor name cannot be empty',
    lastUpdated: DateTime(2025, 11, 15),
  ),

  // Date elements
  XbrlElement(
    id: 'el-016',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:DateOfIncorporation',
    elementType: XbrlElementType.date,
    label: 'Date of Incorporation',
    value: '2018-06-14',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 8),
  ),
  XbrlElement(
    id: 'el-017',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:DateOfBoardMeetingForAccounts',
    elementType: XbrlElementType.date,
    label: 'Date of Board Meeting (Accounts Approval)',
    value: '2025-08-30',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 10),
  ),
  XbrlElement(
    id: 'el-018',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:DateOfAGM',
    elementType: XbrlElementType.date,
    label: 'Date of Annual General Meeting',
    isRequired: true,
    isCompleted: false,
    validationMessage: 'AGM date must be within 6 months of year-end',
    lastUpdated: DateTime(2025, 11, 15),
  ),

  // Text block elements
  XbrlElement(
    id: 'el-019',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:SignificantAccountingPolicies',
    elementType: XbrlElementType.textBlock,
    label: 'Significant Accounting Policies',
    value:
        'The financial statements are prepared in accordance with Indian '
        'Accounting Standards (Ind AS) notified under the Companies (Indian '
        'Accounting Standards) Rules, 2015...',
    isRequired: true,
    isCompleted: true,
    lastUpdated: DateTime(2025, 11, 13),
  ),
  XbrlElement(
    id: 'el-020',
    filingId: 'xbrl-003',
    elementName: 'in-bfin:DirectorsReport',
    elementType: XbrlElementType.textBlock,
    label: "Directors' Report",
    isRequired: true,
    isCompleted: false,
    validationMessage: "Directors' Report text block is mandatory",
    lastUpdated: DateTime(2025, 11, 15),
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All XBRL filings.
final xbrlFilingsProvider = Provider<List<XbrlFiling>>(
  (_) => List.unmodifiable(_mockFilings),
);

/// All XBRL elements (sample for one filing).
final xbrlElementsProvider = Provider<List<XbrlElement>>(
  (_) => List.unmodifiable(_mockElements),
);

// --- Status filter ---

final xbrlStatusFilterProvider =
    NotifierProvider<XbrlStatusFilterNotifier, XbrlFilingStatus?>(
      XbrlStatusFilterNotifier.new,
    );

class XbrlStatusFilterNotifier extends Notifier<XbrlFilingStatus?> {
  @override
  XbrlFilingStatus? build() => null;

  void update(XbrlFilingStatus? value) => state = value;
}

/// Filings filtered by active status filter.
final xbrlFilteredFilingsProvider = Provider<List<XbrlFiling>>((ref) {
  final filings = ref.watch(xbrlFilingsProvider);
  final statusFilter = ref.watch(xbrlStatusFilterProvider);

  if (statusFilter == null) return filings;
  return filings.where((f) => f.status == statusFilter).toList();
});

/// Elements filtered by a specific filing id.
final xbrlElementsForFilingProvider =
    Provider.family<List<XbrlElement>, String>((ref, filingId) {
      final elements = ref.watch(xbrlElementsProvider);
      return elements.where((e) => e.filingId == filingId).toList();
    });

/// Selected filing id (for elements tab drill-down).
final xbrlSelectedFilingIdProvider =
    NotifierProvider<XbrlSelectedFilingNotifier, String?>(
      XbrlSelectedFilingNotifier.new,
    );

class XbrlSelectedFilingNotifier extends Notifier<String?> {
  @override
  String? build() => 'xbrl-003'; // default to the sample with elements

  void update(String? value) => state = value;
}

/// Elements for the currently selected filing.
final xbrlActiveElementsProvider = Provider<List<XbrlElement>>((ref) {
  final selectedId = ref.watch(xbrlSelectedFilingIdProvider);
  if (selectedId == null) return const [];
  return ref.watch(xbrlElementsForFilingProvider(selectedId));
});

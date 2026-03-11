import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/account_client.dart';
import '../../domain/models/depreciation_entry.dart';
import '../../domain/models/financial_ratio_snapshot.dart';
import '../../domain/models/financial_statement.dart';
import 'ratio_snapshot_mock_data.dart';

// Re-export so existing importers of accounts_providers.dart still find them.
export '../../domain/models/financial_ratio_snapshot.dart';
export '../../domain/services/financial_calculators.dart';

// ---------------------------------------------------------------------------
// Mock data — Account Clients
// ---------------------------------------------------------------------------

const List<AccountClient> _mockClients = [
  AccountClient(
    id: 'acc-001',
    name: 'Mehta Textiles Pvt Ltd',
    pan: 'AABCM4521F',
    businessType: BusinessType.company,
    financialYear: 'FY 2024-25',
    hasAudit: true,
    turnover: 42500000,
    totalAssets: 18700000,
    netProfit: 3200000,
    grossProfit: 6800000,
    currentRatio: 1.85,
    auditorName: 'CA Suresh Agarwal',
    status: AccountClientStatus.finalized,
  ),
  AccountClient(
    id: 'acc-002',
    name: 'Ramesh Kumar & Brothers',
    pan: 'AABPR7834K',
    businessType: BusinessType.partnership,
    financialYear: 'FY 2024-25',
    hasAudit: false,
    turnover: 9800000,
    totalAssets: 4200000,
    netProfit: 820000,
    grossProfit: 1950000,
    currentRatio: 2.10,
    status: AccountClientStatus.underReview,
  ),
  AccountClient(
    id: 'acc-003',
    name: 'Sunita Sharma',
    pan: 'BBNPS4321A',
    businessType: BusinessType.proprietorship,
    financialYear: 'FY 2024-25',
    hasAudit: false,
    turnover: 2400000,
    totalAssets: 980000,
    netProfit: 310000,
    grossProfit: 540000,
    currentRatio: 1.60,
    status: AccountClientStatus.draft,
  ),
  AccountClient(
    id: 'acc-004',
    name: 'Krishnamurthy Family Trust',
    pan: 'AABCK9012T',
    businessType: BusinessType.trust,
    financialYear: 'FY 2024-25',
    hasAudit: true,
    turnover: 6500000,
    totalAssets: 28000000,
    netProfit: 1800000,
    grossProfit: 2900000,
    currentRatio: 3.20,
    auditorName: 'CA Priya Nair',
    status: AccountClientStatus.finalized,
  ),
  AccountClient(
    id: 'acc-005',
    name: 'Patel & Sons HUF',
    pan: 'AAFPH6543H',
    businessType: BusinessType.huf,
    financialYear: 'FY 2024-25',
    hasAudit: false,
    turnover: 5100000,
    totalAssets: 12400000,
    netProfit: 980000,
    grossProfit: 1600000,
    currentRatio: 1.40,
    status: AccountClientStatus.underReview,
  ),
  AccountClient(
    id: 'acc-006',
    name: 'Joshi Electronics Pvt Ltd',
    pan: 'AABCJ2109E',
    businessType: BusinessType.company,
    financialYear: 'FY 2024-25',
    hasAudit: true,
    turnover: 78000000,
    totalAssets: 34500000,
    netProfit: 5600000,
    grossProfit: 12000000,
    currentRatio: 1.95,
    auditorName: 'CA Vikram Desai',
    status: AccountClientStatus.finalized,
  ),
  AccountClient(
    id: 'acc-007',
    name: 'Banerjee Exports LLP',
    pan: 'AABCB3456L',
    businessType: BusinessType.partnership,
    financialYear: 'FY 2024-25',
    hasAudit: false,
    turnover: 31000000,
    totalAssets: 9800000,
    netProfit: 2100000,
    grossProfit: 4400000,
    currentRatio: 2.30,
    status: AccountClientStatus.draft,
  ),
  AccountClient(
    id: 'acc-008',
    name: 'Ananya Cloth Store',
    pan: 'CCOPA7654B',
    businessType: BusinessType.proprietorship,
    financialYear: 'FY 2024-25',
    hasAudit: false,
    turnover: 1800000,
    totalAssets: 650000,
    netProfit: 185000,
    grossProfit: 380000,
    currentRatio: 1.25,
    status: AccountClientStatus.draft,
  ),
  AccountClient(
    id: 'acc-009',
    name: 'Gupta Steel Industries Pvt Ltd',
    pan: 'AACPG8901G',
    businessType: BusinessType.company,
    financialYear: 'FY 2024-25',
    hasAudit: true,
    turnover: 155000000,
    totalAssets: 62000000,
    netProfit: 9800000,
    grossProfit: 22000000,
    currentRatio: 1.70,
    auditorName: 'CA Rajesh Khanna',
    status: AccountClientStatus.finalized,
  ),
  AccountClient(
    id: 'acc-010',
    name: 'Narayanan Charitable Trust',
    pan: 'AAACN5678T',
    businessType: BusinessType.trust,
    financialYear: 'FY 2024-25',
    hasAudit: true,
    turnover: 3200000,
    totalAssets: 45000000,
    netProfit: 420000,
    grossProfit: 890000,
    currentRatio: 4.50,
    auditorName: 'CA Meena Iyer',
    status: AccountClientStatus.underReview,
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Financial Statements
// ---------------------------------------------------------------------------

final List<FinancialStatement> _mockStatements = [
  FinancialStatement(
    id: 'stmt-001',
    clientId: 'acc-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Suresh Agarwal',
    preparedDate: DateTime(2025, 9, 20),
    approvedDate: DateTime(2025, 9, 28),
    status: StatementStatus.filed,
    totalAssets: 18700000,
    totalLiabilities: 10200000,
    netProfit: 3200000,
  ),
  FinancialStatement(
    id: 'stmt-002',
    clientId: 'acc-001',
    clientName: 'Mehta Textiles Pvt Ltd',
    statementType: StatementType.profitLoss,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Suresh Agarwal',
    preparedDate: DateTime(2025, 9, 20),
    approvedDate: DateTime(2025, 9, 28),
    status: StatementStatus.filed,
    totalAssets: 0,
    totalLiabilities: 0,
    netProfit: 3200000,
  ),
  FinancialStatement(
    id: 'stmt-003',
    clientId: 'acc-002',
    clientName: 'Ramesh Kumar & Brothers',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.horizontal,
    preparedBy: 'CA Anand Verma',
    preparedDate: DateTime(2025, 10, 5),
    status: StatementStatus.prepared,
    totalAssets: 4200000,
    totalLiabilities: 2600000,
    netProfit: 820000,
  ),
  FinancialStatement(
    id: 'stmt-004',
    clientId: 'acc-002',
    clientName: 'Ramesh Kumar & Brothers',
    statementType: StatementType.capitalAccount,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Anand Verma',
    preparedDate: DateTime(2025, 10, 5),
    status: StatementStatus.prepared,
    totalAssets: 1600000,
    totalLiabilities: 0,
    netProfit: 820000,
  ),
  FinancialStatement(
    id: 'stmt-005',
    clientId: 'acc-003',
    clientName: 'Sunita Sharma',
    statementType: StatementType.profitLoss,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Priya Nair',
    preparedDate: DateTime(2025, 11, 12),
    status: StatementStatus.draft,
    totalAssets: 0,
    totalLiabilities: 0,
    netProfit: 310000,
  ),
  FinancialStatement(
    id: 'stmt-006',
    clientId: 'acc-004',
    clientName: 'Krishnamurthy Family Trust',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.horizontal,
    preparedBy: 'CA Priya Nair',
    preparedDate: DateTime(2025, 9, 15),
    approvedDate: DateTime(2025, 9, 22),
    status: StatementStatus.approved,
    totalAssets: 28000000,
    totalLiabilities: 4500000,
    netProfit: 1800000,
  ),
  FinancialStatement(
    id: 'stmt-007',
    clientId: 'acc-005',
    clientName: 'Patel & Sons HUF',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Anand Verma',
    preparedDate: DateTime(2025, 10, 20),
    status: StatementStatus.prepared,
    totalAssets: 12400000,
    totalLiabilities: 7200000,
    netProfit: 980000,
  ),
  FinancialStatement(
    id: 'stmt-008',
    clientId: 'acc-006',
    clientName: 'Joshi Electronics Pvt Ltd',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Vikram Desai',
    preparedDate: DateTime(2025, 8, 30),
    approvedDate: DateTime(2025, 9, 10),
    status: StatementStatus.filed,
    totalAssets: 34500000,
    totalLiabilities: 18900000,
    netProfit: 5600000,
  ),
  FinancialStatement(
    id: 'stmt-009',
    clientId: 'acc-006',
    clientName: 'Joshi Electronics Pvt Ltd',
    statementType: StatementType.trialBalance,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Vikram Desai',
    preparedDate: DateTime(2025, 8, 25),
    approvedDate: DateTime(2025, 9, 5),
    status: StatementStatus.approved,
    totalAssets: 34500000,
    totalLiabilities: 34500000,
    netProfit: 0,
  ),
  FinancialStatement(
    id: 'stmt-010',
    clientId: 'acc-007',
    clientName: 'Banerjee Exports LLP',
    statementType: StatementType.profitLoss,
    financialYear: 'FY 2024-25',
    format: StatementFormat.horizontal,
    preparedBy: 'CA Rakesh Sinha',
    preparedDate: DateTime(2025, 11, 1),
    status: StatementStatus.draft,
    totalAssets: 0,
    totalLiabilities: 0,
    netProfit: 2100000,
  ),
  FinancialStatement(
    id: 'stmt-011',
    clientId: 'acc-009',
    clientName: 'Gupta Steel Industries Pvt Ltd',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Rajesh Khanna',
    preparedDate: DateTime(2025, 9, 5),
    approvedDate: DateTime(2025, 9, 18),
    status: StatementStatus.filed,
    totalAssets: 62000000,
    totalLiabilities: 38000000,
    netProfit: 9800000,
  ),
  FinancialStatement(
    id: 'stmt-012',
    clientId: 'acc-009',
    clientName: 'Gupta Steel Industries Pvt Ltd',
    statementType: StatementType.cashFlow,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Rajesh Khanna',
    preparedDate: DateTime(2025, 9, 5),
    approvedDate: DateTime(2025, 9, 18),
    status: StatementStatus.filed,
    totalAssets: 0,
    totalLiabilities: 0,
    netProfit: 9800000,
  ),
  FinancialStatement(
    id: 'stmt-013',
    clientId: 'acc-010',
    clientName: 'Narayanan Charitable Trust',
    statementType: StatementType.balanceSheet,
    financialYear: 'FY 2024-25',
    format: StatementFormat.horizontal,
    preparedBy: 'CA Meena Iyer',
    preparedDate: DateTime(2025, 10, 10),
    status: StatementStatus.prepared,
    totalAssets: 45000000,
    totalLiabilities: 2800000,
    netProfit: 420000,
  ),
  FinancialStatement(
    id: 'stmt-014',
    clientId: 'acc-003',
    clientName: 'Sunita Sharma',
    statementType: StatementType.trialBalance,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Priya Nair',
    preparedDate: DateTime(2025, 11, 10),
    status: StatementStatus.draft,
    totalAssets: 980000,
    totalLiabilities: 980000,
    netProfit: 0,
  ),
  FinancialStatement(
    id: 'stmt-015',
    clientId: 'acc-008',
    clientName: 'Ananya Cloth Store',
    statementType: StatementType.profitLoss,
    financialYear: 'FY 2024-25',
    format: StatementFormat.vertical,
    preparedBy: 'CA Anand Verma',
    preparedDate: DateTime(2025, 11, 20),
    status: StatementStatus.draft,
    totalAssets: 0,
    totalLiabilities: 0,
    netProfit: 185000,
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Depreciation Entries
// ---------------------------------------------------------------------------

const List<DepreciationEntry> _mockDepreciation = [
  DepreciationEntry(
    id: 'dep-001',
    clientId: 'acc-001',
    assetName: 'Factory Building — Surat',
    assetBlock: AssetBlock.building,
    openingWDV: 4500000,
    additions: 0,
    disposals: 0,
    rate: 10.0,
    depreciation: 450000,
    closingWDV: 4050000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-002',
    clientId: 'acc-001',
    assetName: 'Weaving Machines',
    assetBlock: AssetBlock.plant,
    openingWDV: 2800000,
    additions: 650000,
    disposals: 0,
    rate: 15.0,
    depreciation: 517500,
    closingWDV: 2932500,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-003',
    clientId: 'acc-001',
    assetName: 'Office Computers',
    assetBlock: AssetBlock.computer,
    openingWDV: 350000,
    additions: 180000,
    disposals: 0,
    rate: 40.0,
    depreciation: 212000,
    closingWDV: 318000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-004',
    clientId: 'acc-006',
    assetName: 'Showroom Building',
    assetBlock: AssetBlock.building,
    openingWDV: 8200000,
    additions: 0,
    disposals: 0,
    rate: 10.0,
    depreciation: 820000,
    closingWDV: 7380000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-005',
    clientId: 'acc-006',
    assetName: 'Delivery Vehicles',
    assetBlock: AssetBlock.vehicle,
    openingWDV: 1250000,
    additions: 800000,
    disposals: 300000,
    rate: 15.0,
    depreciation: 262500,
    closingWDV: 1487500,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-006',
    clientId: 'acc-006',
    assetName: 'ERP Software License',
    assetBlock: AssetBlock.intangible,
    openingWDV: 420000,
    additions: 0,
    disposals: 0,
    rate: 25.0,
    depreciation: 105000,
    closingWDV: 315000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-007',
    clientId: 'acc-009',
    assetName: 'Steel Plant Building',
    assetBlock: AssetBlock.building,
    openingWDV: 15000000,
    additions: 2500000,
    disposals: 0,
    rate: 10.0,
    depreciation: 1750000,
    closingWDV: 15750000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-008',
    clientId: 'acc-009',
    assetName: 'Rolling Mill Machines',
    assetBlock: AssetBlock.plant,
    openingWDV: 9800000,
    additions: 3200000,
    disposals: 500000,
    rate: 15.0,
    depreciation: 1875000,
    closingWDV: 10625000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-009',
    clientId: 'acc-009',
    assetName: 'Office Furniture & Fixtures',
    assetBlock: AssetBlock.furniture,
    openingWDV: 680000,
    additions: 120000,
    disposals: 0,
    rate: 10.0,
    depreciation: 80000,
    closingWDV: 720000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-010',
    clientId: 'acc-002',
    assetName: 'Shop Building',
    assetBlock: AssetBlock.building,
    openingWDV: 1800000,
    additions: 0,
    disposals: 0,
    rate: 10.0,
    depreciation: 180000,
    closingWDV: 1620000,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-011',
    clientId: 'acc-002',
    assetName: 'Delivery Bike',
    assetBlock: AssetBlock.vehicle,
    openingWDV: 95000,
    additions: 0,
    disposals: 0,
    rate: 15.0,
    depreciation: 14250,
    closingWDV: 80750,
    financialYear: 'FY 2024-25',
  ),
  DepreciationEntry(
    id: 'dep-012',
    clientId: 'acc-005',
    assetName: 'Commercial Property',
    assetBlock: AssetBlock.building,
    openingWDV: 5600000,
    additions: 0,
    disposals: 0,
    rate: 10.0,
    depreciation: 560000,
    closingWDV: 5040000,
    financialYear: 'FY 2024-25',
  ),
];

// Mock ratio snapshot data is in ratio_snapshot_mock_data.dart
// (imported above as mockRatioSnapshots)

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All account clients.
final accountClientsProvider = Provider<List<AccountClient>>(
  (_) => List.unmodifiable(_mockClients),
);

/// All financial statements.
final financialStatementsProvider = Provider<List<FinancialStatement>>(
  (_) => List.unmodifiable(_mockStatements),
);

/// All depreciation entries.
final depreciationEntriesProvider = Provider<List<DepreciationEntry>>(
  (_) => List.unmodifiable(_mockDepreciation),
);

/// All financial ratio snapshots.
final ratioSnapshotsProvider = Provider<List<FinancialRatioSnapshot>>(
  (_) => List.unmodifiable(mockRatioSnapshots),
);

/// Ratio snapshot for a specific client ID. Returns null if not found.
final clientRatioSnapshotProvider =
    Provider.family<FinancialRatioSnapshot?, String>((ref, clientId) {
      final snapshots = ref.watch(ratioSnapshotsProvider);
      try {
        return snapshots.firstWhere((s) => s.clientId == clientId);
      } on StateError {
        return null;
      }
    });

// ---------------------------------------------------------------------------
// Filter notifiers
// ---------------------------------------------------------------------------

/// Filter by client status.
final accountStatusFilterProvider =
    NotifierProvider<_StatusFilterNotifier, AccountClientStatus?>(
      _StatusFilterNotifier.new,
    );

class _StatusFilterNotifier extends Notifier<AccountClientStatus?> {
  @override
  AccountClientStatus? build() => null;

  void update(AccountClientStatus? value) => state = value;
}

/// Filter by business type.
final businessTypeFilterProvider =
    NotifierProvider<_BusinessTypeFilterNotifier, BusinessType?>(
      _BusinessTypeFilterNotifier.new,
    );

class _BusinessTypeFilterNotifier extends Notifier<BusinessType?> {
  @override
  BusinessType? build() => null;

  void update(BusinessType? value) => state = value;
}

/// Filter by financial year (for statements).
final statementYearFilterProvider =
    NotifierProvider<_YearFilterNotifier, String?>(_YearFilterNotifier.new);

class _YearFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

// ---------------------------------------------------------------------------
// Derived / filtered providers
// ---------------------------------------------------------------------------

/// Clients after applying status + businessType filters.
final filteredAccountClientsProvider = Provider<List<AccountClient>>((ref) {
  final clients = ref.watch(accountClientsProvider);
  final statusFilter = ref.watch(accountStatusFilterProvider);
  final typeFilter = ref.watch(businessTypeFilterProvider);

  return clients.where((c) {
    final statusMatch = statusFilter == null || c.status == statusFilter;
    final typeMatch = typeFilter == null || c.businessType == typeFilter;
    return statusMatch && typeMatch;
  }).toList();
});

/// Statements after applying the year filter.
final filteredStatementsProvider = Provider<List<FinancialStatement>>((ref) {
  final statements = ref.watch(financialStatementsProvider);
  final yearFilter = ref.watch(statementYearFilterProvider);

  if (yearFilter == null) return statements;
  return statements.where((s) => s.financialYear == yearFilter).toList();
});

/// High-level summary counts for the header cards.
final accountsSummaryProvider = Provider<AccountsSummary>((ref) {
  final clients = ref.watch(accountClientsProvider);
  final statements = ref.watch(financialStatementsProvider);

  final finalized = clients
      .where((c) => c.status == AccountClientStatus.finalized)
      .length;
  final drafts = clients
      .where((c) => c.status == AccountClientStatus.draft)
      .length;
  final totalAssets = clients.fold<double>(0, (sum, c) => sum + c.totalAssets);
  final pendingApproval = statements
      .where((s) => s.status == StatementStatus.prepared)
      .length;

  return AccountsSummary(
    finalized: finalized,
    drafts: drafts,
    totalAssetsUnderManagement: totalAssets,
    pendingApproval: pendingApproval,
  );
});

/// Simple immutable summary data class.
class AccountsSummary {
  const AccountsSummary({
    required this.finalized,
    required this.drafts,
    required this.totalAssetsUnderManagement,
    required this.pendingApproval,
  });

  final int finalized;
  final int drafts;
  final double totalAssetsUnderManagement;
  final int pendingApproval;
}

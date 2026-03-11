import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fema_filing.dart';
import '../../domain/models/fdi_transaction.dart';

// ---------------------------------------------------------------------------
// Mock data - FEMA Filings
// ---------------------------------------------------------------------------

final List<FemaFiling> _mockFilings = [
  FemaFiling(
    id: 'fema-001',
    clientId: 'cl-101',
    clientName: 'Wipro Technologies Ltd',
    formType: FemaFormType.fcGpr,
    filingDate: DateTime(2026, 2, 15),
    dueDate: DateTime(2026, 3, 15),
    status: FemaFilingStatus.submitted,
    amount: 25000000,
    currency: 'USD',
    referenceNumber: 'FCG/2026/MH/001234',
    adBankName: 'State Bank of India',
    remarks: 'Equity allotment to Singapore entity',
  ),
  FemaFiling(
    id: 'fema-002',
    clientId: 'cl-102',
    clientName: 'Mahindra & Mahindra Financial Services',
    formType: FemaFormType.ecb,
    filingDate: DateTime(2026, 1, 20),
    dueDate: DateTime(2026, 2, 28),
    status: FemaFilingStatus.approved,
    amount: 50000000,
    currency: 'USD',
    referenceNumber: 'ECB/2026/MH/005678',
    adBankName: 'HDFC Bank',
    remarks: 'ECB from Deutsche Bank AG, Frankfurt',
  ),
  FemaFiling(
    id: 'fema-003',
    clientId: 'cl-103',
    clientName: 'Bajaj Auto International Holdings',
    formType: FemaFormType.odi,
    filingDate: DateTime(2026, 3, 1),
    dueDate: DateTime(2026, 3, 31),
    status: FemaFilingStatus.draft,
    amount: 12000000,
    currency: 'EUR',
    adBankName: 'ICICI Bank',
    remarks: 'Investment in Netherlands subsidiary',
  ),
  FemaFiling(
    id: 'fema-004',
    clientId: 'cl-104',
    clientName: 'Tata Steel BSL Ltd',
    formType: FemaFormType.fla,
    filingDate: DateTime(2025, 12, 10),
    dueDate: DateTime(2026, 7, 15),
    status: FemaFilingStatus.pendingClarification,
    amount: 320000000,
    currency: 'USD',
    referenceNumber: 'FLA/2025/MH/009012',
    adBankName: 'Axis Bank',
    remarks: 'RBI seeking clarification on overseas assets valuation',
  ),
  FemaFiling(
    id: 'fema-005',
    clientId: 'cl-105',
    clientName: 'Godrej Properties Ltd',
    formType: FemaFormType.fcTrs,
    filingDate: DateTime(2026, 2, 5),
    dueDate: DateTime(2026, 3, 5),
    status: FemaFilingStatus.rejected,
    amount: 8500000,
    currency: 'USD',
    referenceNumber: 'FCT/2026/MH/003456',
    adBankName: 'Kotak Mahindra Bank',
    remarks: 'Transfer pricing documentation incomplete',
  ),
  FemaFiling(
    id: 'fema-006',
    clientId: 'cl-106',
    clientName: 'Adani Ports & SEZ Ltd',
    formType: FemaFormType.apr,
    filingDate: DateTime(2026, 3, 8),
    dueDate: DateTime(2026, 12, 31),
    status: FemaFilingStatus.draft,
    amount: 175000000,
    currency: 'USD',
    adBankName: 'State Bank of India',
    remarks: 'Annual performance report for overseas JVs',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - FDI Transactions
// ---------------------------------------------------------------------------

final List<FdiTransaction> _mockFdiTransactions = [
  FdiTransaction(
    id: 'fdi-001',
    clientId: 'cl-201',
    entityName: 'Infosys BPM Limited',
    investorName: 'Vanguard International Growth Fund',
    investorCountry: 'United States',
    amount: 45000000,
    currency: 'USD',
    equityPercentage: 3.2,
    sectorCap: 100.0,
    approvalRoute: FdiApprovalRoute.automatic,
    transactionDate: DateTime(2026, 2, 18),
    status: FdiTransactionStatus.completed,
  ),
  FdiTransaction(
    id: 'fdi-002',
    clientId: 'cl-202',
    entityName: 'Paytm Financial Services Ltd',
    investorName: 'SoftBank Vision Fund 2',
    investorCountry: 'Japan',
    amount: 120000000,
    currency: 'USD',
    equityPercentage: 8.5,
    sectorCap: 100.0,
    approvalRoute: FdiApprovalRoute.automatic,
    transactionDate: DateTime(2026, 1, 25),
    status: FdiTransactionStatus.approved,
  ),
  FdiTransaction(
    id: 'fdi-003',
    clientId: 'cl-203',
    entityName: 'Bharti Airtel Defence Systems',
    investorName: 'Singapore Technologies Engineering',
    investorCountry: 'Singapore',
    amount: 30000000,
    currency: 'USD',
    equityPercentage: 26.0,
    sectorCap: 49.0,
    approvalRoute: FdiApprovalRoute.government,
    transactionDate: DateTime(2026, 3, 2),
    status: FdiTransactionStatus.underReview,
  ),
  FdiTransaction(
    id: 'fdi-004',
    clientId: 'cl-204',
    entityName: 'Zomato Media Pvt Ltd',
    investorName: 'Alipay Singapore Holding',
    investorCountry: 'Singapore',
    amount: 75000000,
    currency: 'USD',
    equityPercentage: 5.1,
    sectorCap: 100.0,
    approvalRoute: FdiApprovalRoute.automatic,
    transactionDate: DateTime(2026, 2, 10),
    status: FdiTransactionStatus.initiated,
  ),
  FdiTransaction(
    id: 'fdi-005',
    clientId: 'cl-205',
    entityName: 'Reliance Retail Ventures Ltd',
    investorName: 'Abu Dhabi Investment Authority',
    investorCountry: 'UAE',
    amount: 250000000,
    currency: 'USD',
    equityPercentage: 1.2,
    sectorCap: 100.0,
    approvalRoute: FdiApprovalRoute.automatic,
    transactionDate: DateTime(2025, 12, 20),
    status: FdiTransactionStatus.completed,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All FEMA filings.
final femaFilingsProvider = Provider<List<FemaFiling>>(
  (_) => List.unmodifiable(_mockFilings),
);

/// All FDI transactions.
final fdiTransactionsProvider = Provider<List<FdiTransaction>>(
  (_) => List.unmodifiable(_mockFdiTransactions),
);

/// Selected FEMA filing status filter.
final femaStatusFilterProvider =
    NotifierProvider<FemaStatusFilterNotifier, FemaFilingStatus?>(
        FemaStatusFilterNotifier.new);

class FemaStatusFilterNotifier extends Notifier<FemaFilingStatus?> {
  @override
  FemaFilingStatus? build() => null;

  void update(FemaFilingStatus? value) => state = value;
}

/// Selected FDI status filter.
final fdiStatusFilterProvider =
    NotifierProvider<FdiStatusFilterNotifier, FdiTransactionStatus?>(
        FdiStatusFilterNotifier.new);

class FdiStatusFilterNotifier extends Notifier<FdiTransactionStatus?> {
  @override
  FdiTransactionStatus? build() => null;

  void update(FdiTransactionStatus? value) => state = value;
}

/// FEMA filings filtered by selected status.
final filteredFemaFilingsProvider = Provider<List<FemaFiling>>((ref) {
  final status = ref.watch(femaStatusFilterProvider);
  final allFilings = ref.watch(femaFilingsProvider);
  if (status == null) return allFilings;
  return allFilings.where((f) => f.status == status).toList();
});

/// FDI transactions filtered by selected status.
final filteredFdiTransactionsProvider = Provider<List<FdiTransaction>>((ref) {
  final status = ref.watch(fdiStatusFilterProvider);
  final allTransactions = ref.watch(fdiTransactionsProvider);
  if (status == null) return allTransactions;
  return allTransactions.where((t) => t.status == status).toList();
});

/// FEMA summary statistics.
final femaSummaryProvider = Provider<FemaSummary>((ref) {
  final filings = ref.watch(femaFilingsProvider);
  final fdi = ref.watch(fdiTransactionsProvider);
  final now = DateTime(2026, 3, 10);

  final totalFilings = filings.length;
  final pendingFilings = filings
      .where((f) =>
          f.status == FemaFilingStatus.draft ||
          f.status == FemaFilingStatus.pendingClarification)
      .length;
  final overdueFilings = filings
      .where((f) =>
          f.status != FemaFilingStatus.approved &&
          f.status != FemaFilingStatus.rejected &&
          f.dueDate.isBefore(now))
      .length;
  final activeFdi =
      fdi.where((t) => t.status != FdiTransactionStatus.completed).length;

  return FemaSummary(
    totalFilings: totalFilings,
    pendingFilings: pendingFilings,
    overdueFilings: overdueFilings,
    activeFdiTransactions: activeFdi,
  );
});

/// Simple immutable summary data class.
class FemaSummary {
  const FemaSummary({
    required this.totalFilings,
    required this.pendingFilings,
    required this.overdueFilings,
    required this.activeFdiTransactions,
  });

  final int totalFilings;
  final int pendingFilings;
  final int overdueFilings;
  final int activeFdiTransactions;
}

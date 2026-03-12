import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/reconciliation/domain/models/bank_recon_item.dart';
import 'package:ca_app/features/reconciliation/domain/models/bank_reconciliation.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_variance.dart';
import 'package:ca_app/features/reconciliation/domain/models/three_way_match_result.dart';
import 'package:ca_app/features/reconciliation/domain/services/bank_reconciliation_service.dart';
import 'package:ca_app/features/reconciliation/domain/services/three_way_reconciliation_service.dart';

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

final threeWayReconServiceProvider = Provider<ThreeWayReconciliationService>(
  (_) => ThreeWayReconciliationService.instance,
);

final bankReconServiceProvider = Provider<BankReconciliationService>(
  (_) => BankReconciliationService.instance,
);

// ---------------------------------------------------------------------------
// Recon entry — a single line-item for the dashboard list
// ---------------------------------------------------------------------------

/// Status of a single reconciliation entry across sources.
enum ReconEntryStatus {
  matched('Matched'),
  mismatched('Mismatched'),
  missingIn26as('Missing in 26AS'),
  missingInAis('Missing in AIS'),
  missingInItr('Missing in ITR');

  const ReconEntryStatus(this.label);
  final String label;
}

/// Immutable reconciliation line-item shown on the dashboard.
class ReconEntry {
  const ReconEntry({
    required this.id,
    required this.incomeType,
    required this.source,
    required this.amount26as,
    required this.amountAis,
    required this.amountItr,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String incomeType;
  final String source;

  /// Amount in paise (0 means absent from that source).
  final int amount26as;
  final int amountAis;
  final int amountItr;
  final ReconEntryStatus status;
  final String notes;

  ReconEntry copyWith({
    String? id,
    String? incomeType,
    String? source,
    int? amount26as,
    int? amountAis,
    int? amountItr,
    ReconEntryStatus? status,
    String? notes,
  }) {
    return ReconEntry(
      id: id ?? this.id,
      incomeType: incomeType ?? this.incomeType,
      source: source ?? this.source,
      amount26as: amount26as ?? this.amount26as,
      amountAis: amountAis ?? this.amountAis,
      amountItr: amountItr ?? this.amountItr,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data — 12 entries with realistic Indian tax-source scenarios
// ---------------------------------------------------------------------------

const _mockEntries = <ReconEntry>[
  ReconEntry(
    id: 'r-01',
    incomeType: 'Salary',
    source: 'Infosys Ltd',
    amount26as: 120000000,
    amountAis: 120000000,
    amountItr: 120000000,
    status: ReconEntryStatus.matched,
  ),
  ReconEntry(
    id: 'r-02',
    incomeType: 'Salary',
    source: 'TCS Ltd',
    amount26as: 85000000,
    amountAis: 85050000,
    amountItr: 85000000,
    status: ReconEntryStatus.mismatched,
  ),
  ReconEntry(
    id: 'r-03',
    incomeType: 'Interest',
    source: 'HDFC Bank FD',
    amount26as: 4500000,
    amountAis: 4500000,
    amountItr: 4500000,
    status: ReconEntryStatus.matched,
  ),
  ReconEntry(
    id: 'r-04',
    incomeType: 'Interest',
    source: 'SBI Savings',
    amount26as: 1200000,
    amountAis: 1200000,
    amountItr: 0,
    status: ReconEntryStatus.missingInItr,
  ),
  ReconEntry(
    id: 'r-05',
    incomeType: 'TDS',
    source: 'Infosys Ltd',
    amount26as: 3600000,
    amountAis: 3600000,
    amountItr: 3600000,
    status: ReconEntryStatus.matched,
  ),
  ReconEntry(
    id: 'r-06',
    incomeType: 'TDS',
    source: 'TCS Ltd',
    amount26as: 2550000,
    amountAis: 0,
    amountItr: 2550000,
    status: ReconEntryStatus.missingInAis,
  ),
  ReconEntry(
    id: 'r-07',
    incomeType: 'Capital Gains',
    source: 'Zerodha Broking',
    amount26as: 0,
    amountAis: 7800000,
    amountItr: 7800000,
    status: ReconEntryStatus.missingIn26as,
  ),
  ReconEntry(
    id: 'r-08',
    incomeType: 'Capital Gains',
    source: 'Groww Investments',
    amount26as: 0,
    amountAis: 3200000,
    amountItr: 0,
    status: ReconEntryStatus.missingInItr,
    notes: 'Short-term equity — not declared',
  ),
  ReconEntry(
    id: 'r-09',
    incomeType: 'Dividend',
    source: 'Reliance Industries',
    amount26as: 250000,
    amountAis: 250000,
    amountItr: 250000,
    status: ReconEntryStatus.matched,
  ),
  ReconEntry(
    id: 'r-10',
    incomeType: 'Rent',
    source: 'Property - Andheri',
    amount26as: 0,
    amountAis: 36000000,
    amountItr: 36000000,
    status: ReconEntryStatus.missingIn26as,
  ),
  ReconEntry(
    id: 'r-11',
    incomeType: 'Interest',
    source: 'Post Office NSC',
    amount26as: 0,
    amountAis: 1500000,
    amountItr: 1500000,
    status: ReconEntryStatus.missingIn26as,
  ),
  ReconEntry(
    id: 'r-12',
    incomeType: 'Professional Income',
    source: 'Consulting - Wipro',
    amount26as: 5000000,
    amountAis: 5000000,
    amountItr: 4800000,
    status: ReconEntryStatus.mismatched,
    notes: 'ITR shows lower amount — verify expenses',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All reconciliation entries (mock).
final reconResultsProvider =
    NotifierProvider<ReconResultsNotifier, List<ReconEntry>>(
  ReconResultsNotifier.new,
);

class ReconResultsNotifier extends Notifier<List<ReconEntry>> {
  @override
  List<ReconEntry> build() => List.unmodifiable(_mockEntries);

  void updateEntry(ReconEntry updated) {
    state = List.unmodifiable([
      for (final e in state)
        if (e.id == updated.id) updated else e,
    ]);
  }
}

/// Filter: which status to show.
final reconFilterProvider =
    NotifierProvider<ReconFilterNotifier, ReconEntryStatus?>(
  ReconFilterNotifier.new,
);

class ReconFilterNotifier extends Notifier<ReconEntryStatus?> {
  @override
  ReconEntryStatus? build() => null; // null = show all

  void select(ReconEntryStatus? value) => state = value;
}

/// Filtered list based on active filter.
final filteredReconEntriesProvider = Provider<List<ReconEntry>>((ref) {
  final all = ref.watch(reconResultsProvider);
  final filter = ref.watch(reconFilterProvider);
  if (filter == null) return all;
  return all.where((e) => e.status == filter).toList();
});

/// Summary counts derived from all entries.
class ReconSummary {
  const ReconSummary({
    required this.total,
    required this.matched,
    required this.mismatched,
    required this.missingIn26as,
    required this.missingInAis,
    required this.missingInItr,
  });

  final int total;
  final int matched;
  final int mismatched;
  final int missingIn26as;
  final int missingInAis;
  final int missingInItr;

  int get missing => missingIn26as + missingInAis + missingInItr;

  double get matchedPercent => total == 0 ? 0 : matched / total * 100;
  double get mismatchedPercent => total == 0 ? 0 : mismatched / total * 100;
  double get missingPercent => total == 0 ? 0 : missing / total * 100;
}

final reconSummaryProvider = Provider<ReconSummary>((ref) {
  final all = ref.watch(reconResultsProvider);
  return ReconSummary(
    total: all.length,
    matched:
        all.where((e) => e.status == ReconEntryStatus.matched).length,
    mismatched:
        all.where((e) => e.status == ReconEntryStatus.mismatched).length,
    missingIn26as:
        all.where((e) => e.status == ReconEntryStatus.missingIn26as).length,
    missingInAis:
        all.where((e) => e.status == ReconEntryStatus.missingInAis).length,
    missingInItr:
        all.where((e) => e.status == ReconEntryStatus.missingInItr).length,
  );
});

// ---------------------------------------------------------------------------
// Three-way match result (mock)
// ---------------------------------------------------------------------------

final threeWayMatchResultProvider =
    NotifierProvider<ThreeWayMatchResultNotifier, ThreeWayMatchResult>(
  ThreeWayMatchResultNotifier.new,
);

class ThreeWayMatchResultNotifier extends Notifier<ThreeWayMatchResult> {
  @override
  ThreeWayMatchResult build() => _mockThreeWayResult;
}

final _mockThreeWayResult = ThreeWayMatchResult(
  pan: 'ABCDE1234F',
  assessmentYear: '2025-26',
  form26AsTotal: 217100000,
  aisTotalIncome: 268500000,
  itrTotalIncome: 262500000,
  form26AsVsAis: const ReconciliationVariance(
    source1Label: 'Form 26AS',
    source2Label: 'AIS',
    source1Amount: 217100000,
    source2Amount: 268500000,
    variance: -51400000,
    variancePercent: -23.67,
    status: VarianceStatus.majorVariance,
    threshold: 100000,
  ),
  form26AsVsItr: const ReconciliationVariance(
    source1Label: 'Form 26AS',
    source2Label: 'ITR',
    source1Amount: 217100000,
    source2Amount: 262500000,
    variance: -45400000,
    variancePercent: -20.91,
    status: VarianceStatus.majorVariance,
    threshold: 100000,
  ),
  aisVsItr: const ReconciliationVariance(
    source1Label: 'AIS',
    source2Label: 'ITR',
    source1Amount: 268500000,
    source2Amount: 262500000,
    variance: 6000000,
    variancePercent: 2.23,
    status: VarianceStatus.minorVariance,
    threshold: 100000,
  ),
  unreportedIncome: const [
    UnreportedIncomeItem(
      sourceName: 'Groww Investments',
      category: 'Capital Gains',
      aisAmount: 3200000,
    ),
    UnreportedIncomeItem(
      sourceName: 'SBI Savings',
      category: 'Interest',
      aisAmount: 1200000,
    ),
  ],
  recommendations: const [
    'Large discrepancy between 26AS and AIS — capital gains and rent '
        'only appear in AIS. Verify all AIS entries.',
    'SBI Savings interest and Groww capital gains not declared in ITR.',
    'TCS TDS missing from AIS — contact TCS to verify TDS filing.',
  ],
);

// ---------------------------------------------------------------------------
// Bank reconciliation (mock)
// ---------------------------------------------------------------------------

final bankReconciliationProvider =
    NotifierProvider<BankReconNotifier, BankReconciliation>(
  BankReconNotifier.new,
);

class BankReconNotifier extends Notifier<BankReconciliation> {
  @override
  BankReconciliation build() => _mockBankRecon;
}

final _mockBankRecon = BankReconciliation(
  accountNumber: '****4821',
  bankName: 'HDFC Bank',
  period: 'Mar 2026',
  bankBalance: 89250000,
  bookBalance: 87430000,
  reconciledItems: [
    BankReconItem(
      transactionId: 'bk-01',
      date: DateTime(2026, 3, 1),
      description: 'Salary credit - Infosys',
      amount: 10000000,
      type: TxType.credit,
      status: ReconItemStatus.matched,
    ),
    BankReconItem(
      transactionId: 'bk-02',
      date: DateTime(2026, 3, 5),
      description: 'Rent payment - Andheri office',
      amount: 4500000,
      type: TxType.debit,
      status: ReconItemStatus.matched,
    ),
    BankReconItem(
      transactionId: 'bk-03',
      date: DateTime(2026, 3, 8),
      description: 'GST refund',
      amount: 1250000,
      type: TxType.credit,
      status: ReconItemStatus.matched,
    ),
  ],
  unreconciledItems: [
    BankReconItem(
      transactionId: 'bk-04',
      date: DateTime(2026, 3, 10),
      description: 'Bank charges - Q4',
      amount: 350000,
      type: TxType.debit,
      status: ReconItemStatus.unmatchedInBank,
    ),
    BankReconItem(
      transactionId: 'bk-05',
      date: DateTime(2026, 3, 11),
      description: 'Interest on FD maturity',
      amount: 780000,
      type: TxType.credit,
      status: ReconItemStatus.unmatchedInBank,
    ),
    BankReconItem(
      transactionId: 'bk-06',
      date: DateTime(2026, 3, 12),
      description: 'Cheque #4521 - Vendor payment',
      amount: 690000,
      type: TxType.debit,
      status: ReconItemStatus.unmatchedInBooks,
    ),
    BankReconItem(
      transactionId: 'bk-07',
      date: DateTime(2026, 3, 12),
      description: 'NEFT - Client retainer fee',
      amount: 1500000,
      type: TxType.credit,
      status: ReconItemStatus.timing,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Comparison tab selection
// ---------------------------------------------------------------------------

enum ReconTab {
  form26asVsAis('26AS vs AIS'),
  aisVsItr('AIS vs ITR'),
  form26asVsItr('26AS vs ITR'),
  threeWay('3-Way Match');

  const ReconTab(this.label);
  final String label;
}

final reconTabProvider = NotifierProvider<ReconTabNotifier, ReconTab>(
  ReconTabNotifier.new,
);

class ReconTabNotifier extends Notifier<ReconTab> {
  @override
  ReconTab build() => ReconTab.threeWay;

  void select(ReconTab tab) => state = tab;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

// ---------------------------------------------------------------------------
// VdaScheduleSummary — computed Schedule VDA totals for one client
// ---------------------------------------------------------------------------

/// Immutable Schedule VDA summary computed by [VdaTaxCalculator].
class VdaScheduleSummary {
  const VdaScheduleSummary({
    required this.totalSaleValue,
    required this.totalCost,
    required this.totalNetGains,
    required this.totalLosses,
    required this.totalTaxPayable,
    required this.totalTdsDeducted,
    required this.netTaxAfterTds,
    this.lossDisallowedNote,
  });

  final double totalSaleValue;
  final double totalCost;
  final double totalNetGains;

  /// Aggregate of all per-transaction losses (always positive magnitude).
  /// Under Section 115BBH these are disallowed for set-off.
  final double totalLosses;
  final double totalTaxPayable;
  final double totalTdsDeducted;
  final double netTaxAfterTds;

  /// Non-null when there are disallowed losses; contains a human-readable note.
  final String? lossDisallowedNote;
}

// ---------------------------------------------------------------------------
// VdaTaxCalculator — Section 115BBH / 194S computation engine
// ---------------------------------------------------------------------------

/// Pure static computation helpers for VDA tax under Section 115BBH.
class VdaTaxCalculator {
  VdaTaxCalculator._();

  /// Section 115BBH: 30% flat tax on net VDA gains + 4% cess.
  /// No deduction allowed except cost of acquisition.
  /// Losses from VDA cannot be set off against any other income.
  static double taxOnVdaGains(double netGains) {
    if (netGains <= 0) {
      return 0;
    }
    return netGains * 0.30 * 1.04; // 30% + 4% cess
  }

  /// TDS under Section 194S: 1% on consideration paid for VDA transfer.
  /// Threshold: ₹50,000 p.a. (specified persons ₹10,000).
  static double tds194S({
    required double transactionValue,
    required bool isSpecifiedPerson,
  }) {
    final double threshold = isSpecifiedPerson ? 10000.0 : 50000.0;
    if (transactionValue < threshold) {
      return 0;
    }
    return transactionValue * 0.01;
  }

  /// Net gain per transaction: sale price − cost of acquisition (no indexation).
  static double netGain({
    required double salePrice,
    required double costOfAcquisition,
  }) {
    return salePrice - costOfAcquisition;
  }

  /// Schedule VDA summary: aggregate all VDA transactions for a PAN / client.
  static VdaScheduleSummary computeScheduleVda(
    List<VdaTransaction> transactions,
  ) {
    double totalSaleValue = 0;
    double totalCost = 0;
    double totalGains = 0;
    double totalLosses = 0;
    double totalTax = 0;
    double totalTdsDeducted = 0;

    for (final VdaTransaction t in transactions) {
      totalSaleValue += t.sellPrice;
      totalCost += t.buyPrice;
      final double gain = netGain(
        salePrice: t.sellPrice,
        costOfAcquisition: t.buyPrice,
      );
      if (gain > 0) {
        totalGains += gain;
        totalTax += taxOnVdaGains(gain);
      } else {
        totalLosses += gain.abs(); // losses disallowed for set-off
      }
      totalTdsDeducted += t.tdsUnder194S;
    }

    final double netTax =
        (totalTax - totalTdsDeducted).clamp(0, double.infinity);

    final String? lossNote = totalLosses > 0
        ? '₹${(totalLosses / 100000).toStringAsFixed(2)}L loss disallowed'
            ' — cannot be set off u/s 115BBH'
        : null;

    return VdaScheduleSummary(
      totalSaleValue: totalSaleValue,
      totalCost: totalCost,
      totalNetGains: totalGains,
      totalLosses: totalLosses,
      totalTaxPayable: totalTax,
      totalTdsDeducted: totalTdsDeducted,
      netTaxAfterTds: netTax,
      lossDisallowedNote: lossNote,
    );
  }
}

// ---------------------------------------------------------------------------
// Mock VDA transactions (15 across 5 clients)
// ---------------------------------------------------------------------------

final List<VdaTransaction> _mockTransactions = <VdaTransaction>[
  // ── Client 1 — Rajesh Mehta ────────────────────────────────────────────
  VdaTransaction(
    id: 'vda-001',
    clientId: 'cli-001',
    clientName: 'Rajesh Mehta',
    assetType: VdaAssetType.crypto,
    assetName: 'Bitcoin (BTC)',
    transactionType: VdaTransactionType.buy,
    quantity: 0.5,
    buyPrice: 2250000,
    sellPrice: 0,
    gainLoss: 0,
    taxAt30Percent: 0,
    tdsUnder194S: 22500,
    exchange: 'WazirX',
    transactionDate: DateTime(2025, 4, 15),
    remarks: 'Long-term hold strategy',
  ),
  VdaTransaction(
    id: 'vda-002',
    clientId: 'cli-001',
    clientName: 'Rajesh Mehta',
    assetType: VdaAssetType.crypto,
    assetName: 'Bitcoin (BTC)',
    transactionType: VdaTransactionType.sell,
    quantity: 0.3,
    buyPrice: 1350000,
    sellPrice: 1620000,
    gainLoss: 270000,
    taxAt30Percent: 84240, // 270000 * 0.30 * 1.04
    tdsUnder194S: 16200,
    exchange: 'WazirX',
    transactionDate: DateTime(2025, 9, 20),
  ),
  VdaTransaction(
    id: 'vda-003',
    clientId: 'cli-001',
    clientName: 'Rajesh Mehta',
    assetType: VdaAssetType.crypto,
    assetName: 'Ethereum (ETH)',
    transactionType: VdaTransactionType.sell,
    quantity: 2.0,
    buyPrice: 380000,
    sellPrice: 340000,
    gainLoss: -40000,
    taxAt30Percent: 0,
    tdsUnder194S: 3400,
    exchange: 'CoinDCX',
    transactionDate: DateTime(2025, 11, 5),
    remarks: 'Loss — disallowed for set-off u/s 115BBH',
  ),
  // ── Client 2 — Priya Sharma ────────────────────────────────────────────
  VdaTransaction(
    id: 'vda-004',
    clientId: 'cli-002',
    clientName: 'Priya Sharma',
    assetType: VdaAssetType.nft,
    assetName: 'Bored Bunny #4421',
    transactionType: VdaTransactionType.sell,
    quantity: 1,
    buyPrice: 45000,
    sellPrice: 120000,
    gainLoss: 75000,
    taxAt30Percent: 23400, // 75000 * 0.30 * 1.04
    tdsUnder194S: 1200,
    exchange: 'OpenSea',
    transactionDate: DateTime(2025, 6, 10),
  ),
  VdaTransaction(
    id: 'vda-005',
    clientId: 'cli-002',
    clientName: 'Priya Sharma',
    assetType: VdaAssetType.crypto,
    assetName: 'Ethereum (ETH)',
    transactionType: VdaTransactionType.staking,
    quantity: 5.0,
    buyPrice: 0,
    sellPrice: 0,
    gainLoss: 0,
    taxAt30Percent: 0,
    tdsUnder194S: 0,
    exchange: 'CoinDCX',
    transactionDate: DateTime(2025, 7, 1),
    remarks: 'Staking rewards taxable on receipt',
  ),
  VdaTransaction(
    id: 'vda-006',
    clientId: 'cli-002',
    clientName: 'Priya Sharma',
    assetType: VdaAssetType.token,
    assetName: 'Polygon (MATIC)',
    transactionType: VdaTransactionType.sell,
    quantity: 5000,
    buyPrice: 325000,
    sellPrice: 280000,
    gainLoss: -45000,
    taxAt30Percent: 0,
    tdsUnder194S: 2800,
    exchange: 'WazirX',
    transactionDate: DateTime(2025, 10, 18),
  ),
  // ── Client 3 — Anil Kapoor ─────────────────────────────────────────────
  VdaTransaction(
    id: 'vda-007',
    clientId: 'cli-003',
    clientName: 'Anil Kapoor',
    assetType: VdaAssetType.crypto,
    assetName: 'Bitcoin (BTC)',
    transactionType: VdaTransactionType.buy,
    quantity: 1.0,
    buyPrice: 4400000,
    sellPrice: 0,
    gainLoss: 0,
    taxAt30Percent: 0,
    tdsUnder194S: 44000,
    exchange: 'Zebpay',
    transactionDate: DateTime(2025, 3, 22),
  ),
  VdaTransaction(
    id: 'vda-008',
    clientId: 'cli-003',
    clientName: 'Anil Kapoor',
    assetType: VdaAssetType.stablecoin,
    assetName: 'USDT (Tether)',
    transactionType: VdaTransactionType.transfer,
    quantity: 10000,
    buyPrice: 830000,
    sellPrice: 830000,
    gainLoss: 0,
    taxAt30Percent: 0,
    tdsUnder194S: 8300,
    exchange: 'Binance',
    transactionDate: DateTime(2025, 5, 14),
    remarks: 'Transfer to cold wallet — TDS still applicable',
  ),
  VdaTransaction(
    id: 'vda-009',
    clientId: 'cli-003',
    clientName: 'Anil Kapoor',
    assetType: VdaAssetType.crypto,
    assetName: 'Solana (SOL)',
    transactionType: VdaTransactionType.sell,
    quantity: 50,
    buyPrice: 175000,
    sellPrice: 290000,
    gainLoss: 115000,
    taxAt30Percent: 35880, // 115000 * 0.30 * 1.04
    tdsUnder194S: 2900,
    exchange: 'CoinSwitch',
    transactionDate: DateTime(2025, 12, 3),
  ),
  // ── Client 4 — Meera Iyer ──────────────────────────────────────────────
  VdaTransaction(
    id: 'vda-010',
    clientId: 'cli-004',
    clientName: 'Meera Iyer',
    assetType: VdaAssetType.crypto,
    assetName: 'Ethereum (ETH)',
    transactionType: VdaTransactionType.airdrop,
    quantity: 0.8,
    buyPrice: 0,
    sellPrice: 152000,
    gainLoss: 152000,
    taxAt30Percent: 47424, // 152000 * 0.30 * 1.04
    tdsUnder194S: 0,
    exchange: 'On-chain',
    transactionDate: DateTime(2025, 8, 22),
    remarks: 'Airdrop — full value taxable as income',
  ),
  VdaTransaction(
    id: 'vda-011',
    clientId: 'cli-004',
    clientName: 'Meera Iyer',
    assetType: VdaAssetType.nft,
    assetName: 'CryptoPunk #7821',
    transactionType: VdaTransactionType.sell,
    quantity: 1,
    buyPrice: 800000,
    sellPrice: 650000,
    gainLoss: -150000,
    taxAt30Percent: 0,
    tdsUnder194S: 6500,
    exchange: 'OpenSea',
    transactionDate: DateTime(2025, 11, 28),
  ),
  VdaTransaction(
    id: 'vda-012',
    clientId: 'cli-004',
    clientName: 'Meera Iyer',
    assetType: VdaAssetType.crypto,
    assetName: 'Bitcoin (BTC)',
    transactionType: VdaTransactionType.mining,
    quantity: 0.01,
    buyPrice: 0,
    sellPrice: 45000,
    gainLoss: 45000,
    taxAt30Percent: 14040, // 45000 * 0.30 * 1.04
    tdsUnder194S: 0,
    exchange: 'Self-mined',
    transactionDate: DateTime(2025, 12, 15),
    remarks: 'Mining income taxable at 30%',
  ),
  // ── Client 5 — Vikram Nair ─────────────────────────────────────────────
  VdaTransaction(
    id: 'vda-013',
    clientId: 'cli-005',
    clientName: 'Vikram Nair',
    assetType: VdaAssetType.crypto,
    assetName: 'Solana (SOL)',
    transactionType: VdaTransactionType.sell,
    quantity: 100,
    buyPrice: 420000,
    sellPrice: 680000,
    gainLoss: 260000,
    taxAt30Percent: 81120, // 260000 * 0.30 * 1.04
    tdsUnder194S: 6800,
    exchange: 'CoinDCX',
    transactionDate: DateTime(2025, 5, 30),
  ),
  VdaTransaction(
    id: 'vda-014',
    clientId: 'cli-005',
    clientName: 'Vikram Nair',
    assetType: VdaAssetType.stablecoin,
    assetName: 'USDT (Tether)',
    transactionType: VdaTransactionType.sell,
    quantity: 5000,
    buyPrice: 415000,
    sellPrice: 416500,
    gainLoss: 1500,
    taxAt30Percent: 468, // 1500 * 0.30 * 1.04
    tdsUnder194S: 4165,
    exchange: 'Binance',
    transactionDate: DateTime(2025, 8, 10),
    remarks: 'Minimal gain from stablecoin conversion',
  ),
  VdaTransaction(
    id: 'vda-015',
    clientId: 'cli-005',
    clientName: 'Vikram Nair',
    assetType: VdaAssetType.token,
    assetName: 'Polygon (MATIC)',
    transactionType: VdaTransactionType.sell,
    quantity: 8000,
    buyPrice: 560000,
    sellPrice: 480000,
    gainLoss: -80000,
    taxAt30Percent: 0,
    tdsUnder194S: 4800,
    exchange: 'WazirX',
    transactionDate: DateTime(2025, 10, 5),
    remarks: 'Loss — disallowed for set-off u/s 115BBH',
  ),
];

// ---------------------------------------------------------------------------
// Mock VDA summaries (5 clients — values computed from transactions above)
// ---------------------------------------------------------------------------

final List<VdaSummary> _mockSummaries = <VdaSummary>[
  const VdaSummary(
    clientId: 'cli-001',
    clientName: 'Rajesh Mehta',
    assessmentYear: '2026-27',
    totalTransactions: 3,
    totalGains: 270000,
    totalLosses: 40000,
    netTaxableGain: 270000,
    taxLiability: 84240,
    tdsCollected: 42100,
    tdsShortfall: 42140,
    hasLossRestrictionViolation: true,
  ),
  const VdaSummary(
    clientId: 'cli-002',
    clientName: 'Priya Sharma',
    assessmentYear: '2026-27',
    totalTransactions: 3,
    totalGains: 75000,
    totalLosses: 45000,
    netTaxableGain: 75000,
    taxLiability: 23400,
    tdsCollected: 4000,
    tdsShortfall: 19400,
    hasLossRestrictionViolation: false,
  ),
  const VdaSummary(
    clientId: 'cli-003',
    clientName: 'Anil Kapoor',
    assessmentYear: '2026-27',
    totalTransactions: 3,
    totalGains: 115000,
    totalLosses: 0,
    netTaxableGain: 115000,
    taxLiability: 35880,
    tdsCollected: 55200,
    tdsShortfall: 0,
    hasLossRestrictionViolation: false,
  ),
  const VdaSummary(
    clientId: 'cli-004',
    clientName: 'Meera Iyer',
    assessmentYear: '2026-27',
    totalTransactions: 3,
    totalGains: 197000,
    totalLosses: 150000,
    netTaxableGain: 197000,
    taxLiability: 61464,
    tdsCollected: 6500,
    tdsShortfall: 54964,
    hasLossRestrictionViolation: true,
  ),
  const VdaSummary(
    clientId: 'cli-005',
    clientName: 'Vikram Nair',
    assessmentYear: '2026-27',
    totalTransactions: 3,
    totalGains: 261500,
    totalLosses: 80000,
    netTaxableGain: 261500,
    taxLiability: 81588,
    tdsCollected: 15765,
    tdsShortfall: 65823,
    hasLossRestrictionViolation: true,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All VDA transactions (alias used by Schedule VDA providers).
final allVdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  return List.unmodifiable(_mockTransactions);
});

/// All VDA transactions (original name kept for backward compatibility).
final vdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  return ref.watch(allVdaTransactionsProvider);
});

/// All VDA client summaries.
final vdaSummariesProvider = Provider<List<VdaSummary>>((ref) {
  return List.unmodifiable(_mockSummaries);
});

/// Computed Schedule VDA summary for a given clientId.
final vdaScheduleSummaryProvider =
    Provider.family<VdaScheduleSummary, String>((
  Ref ref,
  String clientId,
) {
  final List<VdaTransaction> txns = ref
      .watch(allVdaTransactionsProvider)
      .where((VdaTransaction t) => t.clientId == clientId)
      .toList();
  return VdaTaxCalculator.computeScheduleVda(txns);
});

/// Selected client filter for transactions. Null means all clients.
final selectedVdaClientProvider =
    NotifierProvider<SelectedVdaClientNotifier, String?>(
  SelectedVdaClientNotifier.new,
);

class SelectedVdaClientNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected asset type filter. Null means all types.
final selectedAssetTypeProvider =
    NotifierProvider<SelectedAssetTypeNotifier, VdaAssetType?>(
  SelectedAssetTypeNotifier.new,
);

class SelectedAssetTypeNotifier extends Notifier<VdaAssetType?> {
  @override
  VdaAssetType? build() => null;

  void update(VdaAssetType? value) => state = value;
}

/// Selected transaction type filter. Null means all types.
final selectedTransactionTypeProvider =
    NotifierProvider<SelectedTransactionTypeNotifier, VdaTransactionType?>(
  SelectedTransactionTypeNotifier.new,
);

class SelectedTransactionTypeNotifier extends Notifier<VdaTransactionType?> {
  @override
  VdaTransactionType? build() => null;

  void update(VdaTransactionType? value) => state = value;
}

/// Currently selected tab index on the crypto VDA screen.
final selectedVdaTabProvider =
    NotifierProvider<SelectedVdaTabNotifier, int>(SelectedVdaTabNotifier.new);

class SelectedVdaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Transactions filtered by client, asset type, and transaction type.
final filteredVdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  final List<VdaTransaction> all = ref.watch(vdaTransactionsProvider);
  final String? client = ref.watch(selectedVdaClientProvider);
  final VdaAssetType? assetType = ref.watch(selectedAssetTypeProvider);
  final VdaTransactionType? txnType =
      ref.watch(selectedTransactionTypeProvider);

  return List.unmodifiable(
    all.where((VdaTransaction t) {
      final bool matchesClient = client == null || t.clientId == client;
      final bool matchesAsset = assetType == null || t.assetType == assetType;
      final bool matchesTxn = txnType == null || t.transactionType == txnType;
      return matchesClient && matchesAsset && matchesTxn;
    }),
  );
});

/// Unique client names for the filter dropdown.
final vdaClientNamesProvider =
    Provider<List<({String id, String name})>>((ref) {
  final List<VdaTransaction> all = ref.watch(vdaTransactionsProvider);
  final Set<String> seen = <String>{};
  final List<({String id, String name})> result =
      <({String id, String name})>[];

  for (final VdaTransaction t in all) {
    if (seen.add(t.clientId)) {
      result.add((id: t.clientId, name: t.clientName));
    }
  }
  return List.unmodifiable(result);
});

/// Aggregate tax overview across all clients.
final vdaTaxOverviewProvider = Provider<VdaTaxOverview>((ref) {
  final List<VdaSummary> summaries = ref.watch(vdaSummariesProvider);

  double totalGains = 0;
  double totalLosses = 0;
  double totalTax = 0;
  double totalTds = 0;
  double totalShortfall = 0;
  int violationCount = 0;

  for (final VdaSummary s in summaries) {
    totalGains += s.totalGains;
    totalLosses += s.totalLosses;
    totalTax += s.taxLiability;
    totalTds += s.tdsCollected;
    totalShortfall += s.tdsShortfall;
    if (s.hasLossRestrictionViolation) {
      violationCount++;
    }
  }

  return VdaTaxOverview(
    totalGains: totalGains,
    totalLosses: totalLosses,
    totalTaxLiability: totalTax,
    totalTdsCollected: totalTds,
    totalTdsShortfall: totalShortfall,
    lossRestrictionViolations: violationCount,
  );
});

/// Immutable aggregate overview for dashboard cards.
class VdaTaxOverview {
  const VdaTaxOverview({
    required this.totalGains,
    required this.totalLosses,
    required this.totalTaxLiability,
    required this.totalTdsCollected,
    required this.totalTdsShortfall,
    required this.lossRestrictionViolations,
  });

  final double totalGains;
  final double totalLosses;
  final double totalTaxLiability;
  final double totalTdsCollected;
  final double totalTdsShortfall;
  final int lossRestrictionViolations;
}

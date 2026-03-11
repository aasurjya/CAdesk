import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

// ---------------------------------------------------------------------------
// Mock VDA transactions (12 across 4 clients)
// ---------------------------------------------------------------------------

final _mockTransactions = <VdaTransaction>[
  // Client 1 — Rajesh Mehta
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
    taxAt30Percent: 81000,
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
    remarks: 'Loss — no set-off against BTC gain',
  ),
  // Client 2 — Priya Sharma
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
    taxAt30Percent: 22500,
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
  // Client 3 — Anil Kapoor
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
    taxAt30Percent: 34500,
    tdsUnder194S: 2900,
    exchange: 'CoinSwitch',
    transactionDate: DateTime(2025, 12, 3),
  ),
  // Client 4 — Meera Iyer
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
    taxAt30Percent: 45600,
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
    taxAt30Percent: 13500,
    tdsUnder194S: 0,
    exchange: 'Self-mined',
    transactionDate: DateTime(2025, 12, 15),
    remarks: 'Mining income taxable at 30%',
  ),
];

// ---------------------------------------------------------------------------
// Mock VDA summaries (4 clients)
// ---------------------------------------------------------------------------

final _mockSummaries = <VdaSummary>[
  const VdaSummary(
    clientId: 'cli-001',
    clientName: 'Rajesh Mehta',
    assessmentYear: '2026-27',
    totalTransactions: 3,
    totalGains: 270000,
    totalLosses: 40000,
    netTaxableGain: 270000,
    taxLiability: 81000,
    tdsCollected: 42100,
    tdsShortfall: 38900,
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
    taxLiability: 22500,
    tdsCollected: 4000,
    tdsShortfall: 18500,
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
    taxLiability: 34500,
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
    taxLiability: 59100,
    tdsCollected: 6500,
    tdsShortfall: 52600,
    hasLossRestrictionViolation: true,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All VDA transactions.
final vdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  return List.unmodifiable(_mockTransactions);
});

/// All VDA client summaries.
final vdaSummariesProvider = Provider<List<VdaSummary>>((ref) {
  return List.unmodifiable(_mockSummaries);
});

/// Selected client filter for transactions. Null means all clients.
final selectedVdaClientProvider =
    NotifierProvider<SelectedVdaClientNotifier, String?>(
        SelectedVdaClientNotifier.new);

class SelectedVdaClientNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected asset type filter. Null means all types.
final selectedAssetTypeProvider =
    NotifierProvider<SelectedAssetTypeNotifier, VdaAssetType?>(
        SelectedAssetTypeNotifier.new);

class SelectedAssetTypeNotifier extends Notifier<VdaAssetType?> {
  @override
  VdaAssetType? build() => null;

  void update(VdaAssetType? value) => state = value;
}

/// Selected transaction type filter. Null means all types.
final selectedTransactionTypeProvider =
    NotifierProvider<SelectedTransactionTypeNotifier, VdaTransactionType?>(
        SelectedTransactionTypeNotifier.new);

class SelectedTransactionTypeNotifier extends Notifier<VdaTransactionType?> {
  @override
  VdaTransactionType? build() => null;

  void update(VdaTransactionType? value) => state = value;
}

/// Currently selected tab index on the crypto VDA screen.
final selectedVdaTabProvider =
    NotifierProvider<SelectedVdaTabNotifier, int>(
        SelectedVdaTabNotifier.new);

class SelectedVdaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Transactions filtered by client, asset type, and transaction type.
final filteredVdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  final all = ref.watch(vdaTransactionsProvider);
  final client = ref.watch(selectedVdaClientProvider);
  final assetType = ref.watch(selectedAssetTypeProvider);
  final txnType = ref.watch(selectedTransactionTypeProvider);

  return List.unmodifiable(
    all.where((t) {
      final matchesClient = client == null || t.clientId == client;
      final matchesAsset = assetType == null || t.assetType == assetType;
      final matchesTxn = txnType == null || t.transactionType == txnType;
      return matchesClient && matchesAsset && matchesTxn;
    }),
  );
});

/// Unique client names for the filter dropdown.
final vdaClientNamesProvider = Provider<List<({String id, String name})>>((ref) {
  final all = ref.watch(vdaTransactionsProvider);
  final seen = <String>{};
  final result = <({String id, String name})>[];

  for (final t in all) {
    if (seen.add(t.clientId)) {
      result.add((id: t.clientId, name: t.clientName));
    }
  }
  return List.unmodifiable(result);
});

/// Aggregate tax overview across all clients.
final vdaTaxOverviewProvider = Provider<VdaTaxOverview>((ref) {
  final summaries = ref.watch(vdaSummariesProvider);

  var totalGains = 0.0;
  var totalLosses = 0.0;
  var totalTax = 0.0;
  var totalTds = 0.0;
  var totalShortfall = 0.0;
  var violationCount = 0;

  for (final s in summaries) {
    totalGains += s.totalGains;
    totalLosses += s.totalLosses;
    totalTax += s.taxLiability;
    totalTds += s.tdsCollected;
    totalShortfall += s.tdsShortfall;
    if (s.hasLossRestrictionViolation) violationCount++;
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

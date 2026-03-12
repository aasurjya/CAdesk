import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/vda/domain/models/schedule_vda.dart';
import 'package:ca_app/features/vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/vda/domain/services/vda_tax_computation_engine.dart';

// ---------------------------------------------------------------------------
// Mock data — 5 crypto transactions
// ---------------------------------------------------------------------------

final _mockTransactions = List<VdaTransaction>.unmodifiable([
  VdaTransaction(
    assetName: 'Bitcoin (BTC)',
    acquisitionDate: DateTime(2023, 3, 15),
    transferDate: DateTime(2025, 11, 20),
    acquisitionCostPaise: 2500000 * 100, // 25 lakh
    saleConsiderationPaise: 4200000 * 100, // 42 lakh
  ),
  VdaTransaction(
    assetName: 'Ethereum (ETH)',
    acquisitionDate: DateTime(2024, 1, 10),
    transferDate: DateTime(2025, 8, 5),
    acquisitionCostPaise: 800000 * 100, // 8 lakh
    saleConsiderationPaise: 650000 * 100, // 6.5 lakh (loss)
  ),
  VdaTransaction(
    assetName: 'Solana (SOL)',
    acquisitionDate: DateTime(2024, 6, 1),
    transferDate: DateTime(2026, 1, 15),
    acquisitionCostPaise: 300000 * 100, // 3 lakh
    saleConsiderationPaise: 520000 * 100, // 5.2 lakh
  ),
  VdaTransaction(
    assetName: 'Polygon (MATIC)',
    acquisitionDate: DateTime(2023, 9, 20),
    transferDate: DateTime(2025, 12, 10),
    acquisitionCostPaise: 150000 * 100, // 1.5 lakh
    saleConsiderationPaise: 120000 * 100, // 1.2 lakh (loss)
  ),
  VdaTransaction(
    assetName: 'NFT #4821 (CryptoPunk)',
    acquisitionDate: DateTime(2022, 5, 1),
    transferDate: DateTime(2025, 10, 30),
    acquisitionCostPaise: 500000 * 100, // 5 lakh
    saleConsiderationPaise: 1800000 * 100, // 18 lakh
  ),
]);

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All VDA transactions.
final vdaTransactionsProvider =
    NotifierProvider<VdaTransactionsNotifier, List<VdaTransaction>>(
      VdaTransactionsNotifier.new,
    );

class VdaTransactionsNotifier extends Notifier<List<VdaTransaction>> {
  @override
  List<VdaTransaction> build() => _mockTransactions;
}

/// Full Schedule VDA tax computation.
final scheduleVdaProvider = Provider<ScheduleVDA>((ref) {
  final transactions = ref.watch(vdaTransactionsProvider);
  return VdaTaxComputationEngine.instance.computeVdaTax(transactions);
});

/// Net gain across all transactions (can be negative).
final vdaNetGainProvider = Provider<int>((ref) {
  final schedule = ref.watch(scheduleVdaProvider);
  return schedule.totalGainPaise - schedule.totalLossPaise;
});

/// Count of profitable transactions.
final vdaProfitableCountProvider = Provider<int>((ref) {
  final txns = ref.watch(vdaTransactionsProvider);
  return txns.where((t) => t.gainPaise > 0).length;
});

/// Count of loss-making transactions.
final vdaLossCountProvider = Provider<int>((ref) {
  final txns = ref.watch(vdaTransactionsProvider);
  return txns.where((t) => t.gainPaise < 0).length;
});

/// Total portfolio value (sum of all sale considerations).
final vdaTotalPortfolioProvider = Provider<int>((ref) {
  final txns = ref.watch(vdaTransactionsProvider);
  return txns.fold<int>(0, (sum, t) => sum + t.saleConsiderationPaise);
});

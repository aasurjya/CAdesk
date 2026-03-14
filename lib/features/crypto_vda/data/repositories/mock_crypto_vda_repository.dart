import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';
import 'package:ca_app/features/crypto_vda/domain/repositories/crypto_vda_repository.dart';

/// In-memory mock implementation of [CryptoVdaRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockCryptoVdaRepository implements CryptoVdaRepository {
  static final List<VdaTransaction> _seedTransactions = [
    VdaTransaction(
      id: 'vda-tx-001',
      clientId: 'mock-client-001',
      clientName: 'Rahul Sharma',
      assetType: VdaAssetType.crypto,
      assetName: 'Bitcoin',
      transactionType: VdaTransactionType.sell,
      quantity: 0.25,
      buyPrice: 1800000,
      sellPrice: 2200000,
      gainLoss: 100000,
      taxAt30Percent: 30000,
      tdsUnder194S: 2200,
      exchange: 'WazirX',
      transactionDate: DateTime(2026, 2, 15),
      remarks: 'Partial sell after 6 months hold',
    ),
    VdaTransaction(
      id: 'vda-tx-002',
      clientId: 'mock-client-001',
      clientName: 'Rahul Sharma',
      assetType: VdaAssetType.crypto,
      assetName: 'Ethereum',
      transactionType: VdaTransactionType.sell,
      quantity: 2.0,
      buyPrice: 150000,
      sellPrice: 180000,
      gainLoss: 60000,
      taxAt30Percent: 18000,
      tdsUnder194S: 3600,
      exchange: 'CoinDCX',
      transactionDate: DateTime(2026, 3, 1),
    ),
    VdaTransaction(
      id: 'vda-tx-003',
      clientId: 'mock-client-002',
      clientName: 'Priya Verma',
      assetType: VdaAssetType.nft,
      assetName: 'Digital Art #0042',
      transactionType: VdaTransactionType.sell,
      quantity: 1,
      buyPrice: 50000,
      sellPrice: 120000,
      gainLoss: 70000,
      taxAt30Percent: 21000,
      tdsUnder194S: 1200,
      exchange: 'OpenSea',
      transactionDate: DateTime(2026, 3, 10),
      remarks: 'NFT sold on secondary market',
    ),
  ];

  static final List<VdaSummary> _seedSummaries = [
    VdaSummary(
      clientId: 'mock-client-001',
      clientName: 'Rahul Sharma',
      assessmentYear: '2025-26',
      totalTransactions: 2,
      totalGains: 160000,
      totalLosses: 0,
      netTaxableGain: 160000,
      taxLiability: 48000,
      tdsCollected: 5800,
      tdsShortfall: 42200,
      hasLossRestrictionViolation: false,
    ),
  ];

  final List<VdaTransaction> _transactions = List.of(_seedTransactions);
  final List<VdaSummary> _summaries = List.of(_seedSummaries);

  @override
  Future<String> insertTransaction(VdaTransaction transaction) async {
    _transactions.add(transaction);
    return transaction.id;
  }

  @override
  Future<List<VdaTransaction>> getAllTransactions() async =>
      List.unmodifiable(_transactions);

  @override
  Future<List<VdaTransaction>> getTransactionsByClient(String clientId) async =>
      List.unmodifiable(
        _transactions.where((t) => t.clientId == clientId).toList(),
      );

  @override
  Future<bool> updateTransaction(VdaTransaction transaction) async {
    final idx = _transactions.indexWhere((t) => t.id == transaction.id);
    if (idx == -1) return false;
    final updated = List<VdaTransaction>.of(_transactions)..[idx] = transaction;
    _transactions
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    final before = _transactions.length;
    _transactions.removeWhere((t) => t.id == id);
    return _transactions.length < before;
  }

  @override
  Future<VdaSummary?> getSummaryByClient(
    String clientId,
    String assessmentYear,
  ) async => _summaries
      .where(
        (s) => s.clientId == clientId && s.assessmentYear == assessmentYear,
      )
      .firstOrNull;

  @override
  Future<void> upsertSummary(VdaSummary summary) async {
    final idx = _summaries.indexWhere(
      (s) =>
          s.clientId == summary.clientId &&
          s.assessmentYear == summary.assessmentYear,
    );
    if (idx == -1) {
      _summaries.add(summary);
    } else {
      final updated = List<VdaSummary>.of(_summaries)..[idx] = summary;
      _summaries
        ..clear()
        ..addAll(updated);
    }
  }
}

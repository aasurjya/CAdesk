import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/crypto_vda/data/repositories/mock_crypto_vda_repository.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

void main() {
  late MockCryptoVdaRepository repo;

  setUp(() {
    repo = MockCryptoVdaRepository();
  });

  group('MockCryptoVdaRepository - VdaTransaction', () {
    test('getAllTransactions returns non-empty seeded list', () async {
      final txs = await repo.getAllTransactions();
      expect(txs, isNotEmpty);
    });

    test('getTransactionsByClient filters correctly', () async {
      final txs = await repo.getTransactionsByClient('mock-client-001');
      for (final t in txs) {
        expect(t.clientId, 'mock-client-001');
      }
    });

    test('getTransactionsByClient returns empty for unknown client', () async {
      final txs = await repo.getTransactionsByClient('no-such-client');
      expect(txs, isEmpty);
    });

    test('insertTransaction adds entry and returns id', () async {
      final tx = VdaTransaction(
        id: 'vda-tx-new-001',
        clientId: 'mock-client-001',
        clientName: 'Rahul Sharma',
        assetType: VdaAssetType.crypto,
        assetName: 'Bitcoin',
        transactionType: VdaTransactionType.buy,
        quantity: 0.5,
        buyPrice: 2000000,
        sellPrice: 0,
        gainLoss: 0,
        taxAt30Percent: 0,
        tdsUnder194S: 1000,
        exchange: 'WazirX',
        transactionDate: DateTime(2026, 3, 1),
      );
      final id = await repo.insertTransaction(tx);
      expect(id, 'vda-tx-new-001');

      final all = await repo.getAllTransactions();
      expect(all.any((t) => t.id == 'vda-tx-new-001'), isTrue);
    });

    test('updateTransaction updates entry and returns true', () async {
      final all = await repo.getAllTransactions();
      final first = all.first;
      final updated = first.copyWith(remarks: 'Updated remark');
      final success = await repo.updateTransaction(updated);
      expect(success, isTrue);
    });

    test('updateTransaction returns false for non-existent id', () async {
      final ghost = VdaTransaction(
        id: 'non-existent-tx',
        clientId: 'c1',
        clientName: 'Nobody',
        assetType: VdaAssetType.crypto,
        assetName: 'ETH',
        transactionType: VdaTransactionType.sell,
        quantity: 1,
        buyPrice: 100000,
        sellPrice: 200000,
        gainLoss: 100000,
        taxAt30Percent: 30000,
        tdsUnder194S: 2000,
        exchange: 'CoinDCX',
        transactionDate: DateTime(2026, 1, 1),
      );
      final success = await repo.updateTransaction(ghost);
      expect(success, isFalse);
    });

    test('deleteTransaction removes entry and returns true', () async {
      final all = await repo.getAllTransactions();
      final target = all.first;
      final deleted = await repo.deleteTransaction(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllTransactions();
      expect(remaining.any((t) => t.id == target.id), isFalse);
    });

    test('deleteTransaction returns false for non-existent id', () async {
      final deleted = await repo.deleteTransaction('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockCryptoVdaRepository - VdaSummary', () {
    test('getSummaryByClient returns summary for known client', () async {
      final summary = await repo.getSummaryByClient(
        'mock-client-001',
        '2025-26',
      );
      expect(summary, isNotNull);
      expect(summary!.clientId, 'mock-client-001');
    });

    test('getSummaryByClient returns null for unknown client', () async {
      final summary = await repo.getSummaryByClient('unknown', '2025-26');
      expect(summary, isNull);
    });

    test('upsertSummary stores and retrieves summary', () async {
      final summary = VdaSummary(
        clientId: 'mock-client-new',
        clientName: 'New Client',
        assessmentYear: '2025-26',
        totalTransactions: 5,
        totalGains: 50000,
        totalLosses: 0,
        netTaxableGain: 50000,
        taxLiability: 15000,
        tdsCollected: 5000,
        tdsShortfall: 10000,
        hasLossRestrictionViolation: false,
      );
      await repo.upsertSummary(summary);

      final retrieved = await repo.getSummaryByClient(
        'mock-client-new',
        '2025-26',
      );
      expect(retrieved, isNotNull);
      expect(retrieved!.taxLiability, 15000);
    });

    test('upsertSummary replaces existing summary', () async {
      final original = VdaSummary(
        clientId: 'mock-client-upd',
        clientName: 'Update Client',
        assessmentYear: '2025-26',
        totalTransactions: 3,
        totalGains: 30000,
        totalLosses: 0,
        netTaxableGain: 30000,
        taxLiability: 9000,
        tdsCollected: 3000,
        tdsShortfall: 6000,
        hasLossRestrictionViolation: false,
      );
      await repo.upsertSummary(original);

      final updated = original.copyWith(taxLiability: 12000);
      await repo.upsertSummary(updated);

      final retrieved = await repo.getSummaryByClient(
        'mock-client-upd',
        '2025-26',
      );
      expect(retrieved!.taxLiability, 12000);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/crypto_vda/data/mappers/crypto_vda_mapper.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

void main() {
  group('CryptoVdaMapper', () {
    // -------------------------------------------------------------------------
    // VdaTransaction
    // -------------------------------------------------------------------------
    group('transactionFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'vtx-001',
          'client_id': 'client-001',
          'client_name': 'Priya Singh',
          'asset_type': 'crypto',
          'asset_name': 'Bitcoin',
          'transaction_type': 'sell',
          'quantity': 0.5,
          'buy_price': 3000000.0,
          'sell_price': 3500000.0,
          'gain_loss': 250000.0,
          'tax_at_30_percent': 75000.0,
          'tds_under_194s': 35000.0,
          'exchange': 'WazirX',
          'transaction_date': '2025-09-01T00:00:00.000Z',
          'remarks': 'Long term holding sold',
        };

        final tx = CryptoVdaMapper.transactionFromJson(json);

        expect(tx.id, 'vtx-001');
        expect(tx.clientId, 'client-001');
        expect(tx.clientName, 'Priya Singh');
        expect(tx.assetType, VdaAssetType.crypto);
        expect(tx.assetName, 'Bitcoin');
        expect(tx.transactionType, VdaTransactionType.sell);
        expect(tx.quantity, 0.5);
        expect(tx.buyPrice, 3000000.0);
        expect(tx.sellPrice, 3500000.0);
        expect(tx.gainLoss, 250000.0);
        expect(tx.taxAt30Percent, 75000.0);
        expect(tx.tdsUnder194S, 35000.0);
        expect(tx.exchange, 'WazirX');
        expect(tx.remarks, 'Long term holding sold');
      });

      test('handles null remarks', () {
        final json = {
          'id': 'vtx-002',
          'client_id': 'c1',
          'client_name': '',
          'asset_type': 'nft',
          'asset_name': 'CryptoPunk #123',
          'transaction_type': 'transfer',
          'quantity': 1.0,
          'buy_price': 500000.0,
          'sell_price': 0.0,
          'gain_loss': 0.0,
          'tax_at_30_percent': 0.0,
          'tds_under_194s': 0.0,
          'exchange': 'OpenSea',
          'transaction_date': '2025-08-15T00:00:00.000Z',
        };

        final tx = CryptoVdaMapper.transactionFromJson(json);
        expect(tx.remarks, isNull);
        expect(tx.assetType, VdaAssetType.nft);
        expect(tx.transactionType, VdaTransactionType.transfer);
      });

      test('defaults asset_type to crypto for unknown value', () {
        final json = {
          'id': 'vtx-003',
          'client_id': 'c1',
          'client_name': '',
          'asset_type': 'unknownAsset',
          'asset_name': 'Unknown',
          'transaction_type': 'buy',
          'quantity': 1.0,
          'buy_price': 100.0,
          'sell_price': 0.0,
          'gain_loss': 0.0,
          'tax_at_30_percent': 0.0,
          'tds_under_194s': 0.0,
          'exchange': 'Binance',
          'transaction_date': '2025-09-01T00:00:00.000Z',
        };

        final tx = CryptoVdaMapper.transactionFromJson(json);
        expect(tx.assetType, VdaAssetType.crypto);
      });

      test('handles all VdaAssetType values', () {
        for (final assetType in VdaAssetType.values) {
          final json = {
            'id': 'vtx-asset-${assetType.name}',
            'client_id': 'c1',
            'client_name': '',
            'asset_type': assetType.name,
            'asset_name': 'Test',
            'transaction_type': 'buy',
            'quantity': 1.0,
            'buy_price': 100.0,
            'sell_price': 0.0,
            'gain_loss': 0.0,
            'tax_at_30_percent': 0.0,
            'tds_under_194s': 0.0,
            'exchange': 'Test',
            'transaction_date': '2025-09-01T00:00:00.000Z',
          };
          final tx = CryptoVdaMapper.transactionFromJson(json);
          expect(tx.assetType, assetType);
        }
      });

      test('handles all VdaTransactionType values', () {
        for (final txType in VdaTransactionType.values) {
          final json = {
            'id': 'vtx-type-${txType.name}',
            'client_id': 'c1',
            'client_name': '',
            'asset_type': 'crypto',
            'asset_name': 'Ethereum',
            'transaction_type': txType.name,
            'quantity': 1.0,
            'buy_price': 100.0,
            'sell_price': 0.0,
            'gain_loss': 0.0,
            'tax_at_30_percent': 0.0,
            'tds_under_194s': 0.0,
            'exchange': 'Test',
            'transaction_date': '2025-09-01T00:00:00.000Z',
          };
          final tx = CryptoVdaMapper.transactionFromJson(json);
          expect(tx.transactionType, txType);
        }
      });
    });

    group('transactionToJson', () {
      late VdaTransaction sampleTx;

      setUp(() {
        sampleTx = VdaTransaction(
          id: 'vtx-json-001',
          clientId: 'client-json-001',
          clientName: 'Sunita Patel',
          assetType: VdaAssetType.token,
          assetName: 'Matic',
          transactionType: VdaTransactionType.staking,
          quantity: 1000.0,
          buyPrice: 100.0,
          sellPrice: 0.0,
          gainLoss: 0.0,
          taxAt30Percent: 0.0,
          tdsUnder194S: 0.0,
          exchange: 'Polygon',
          transactionDate: DateTime(2025, 6, 15),
          remarks: 'Staking rewards',
        );
      });

      test('includes all fields', () {
        final json = CryptoVdaMapper.transactionToJson(sampleTx);

        expect(json['id'], 'vtx-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Sunita Patel');
        expect(json['asset_type'], 'token');
        expect(json['asset_name'], 'Matic');
        expect(json['transaction_type'], 'staking');
        expect(json['quantity'], 1000.0);
        expect(json['exchange'], 'Polygon');
        expect(json['remarks'], 'Staking rewards');
      });

      test('round-trip transactionFromJson(transactionToJson) preserves all fields', () {
        final json = CryptoVdaMapper.transactionToJson(sampleTx);
        final restored = CryptoVdaMapper.transactionFromJson(json);

        expect(restored.id, sampleTx.id);
        expect(restored.assetType, sampleTx.assetType);
        expect(restored.transactionType, sampleTx.transactionType);
        expect(restored.quantity, sampleTx.quantity);
        expect(restored.remarks, sampleTx.remarks);
      });
    });

    // -------------------------------------------------------------------------
    // VdaSummary
    // -------------------------------------------------------------------------
    group('summaryFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'client_id': 'client-001',
          'client_name': 'Ramesh Kumar',
          'assessment_year': '2025-26',
          'total_transactions': 25,
          'total_gains': 500000.0,
          'total_losses': 100000.0,
          'net_taxable_gain': 500000.0,
          'tax_liability': 150000.0,
          'tds_collected': 120000.0,
          'tds_shortfall': 30000.0,
          'has_loss_restriction_violation': true,
        };

        final summary = CryptoVdaMapper.summaryFromJson(json);

        expect(summary.clientId, 'client-001');
        expect(summary.clientName, 'Ramesh Kumar');
        expect(summary.assessmentYear, '2025-26');
        expect(summary.totalTransactions, 25);
        expect(summary.totalGains, 500000.0);
        expect(summary.totalLosses, 100000.0);
        expect(summary.netTaxableGain, 500000.0);
        expect(summary.taxLiability, 150000.0);
        expect(summary.tdsCollected, 120000.0);
        expect(summary.tdsShortfall, 30000.0);
        expect(summary.hasLossRestrictionViolation, true);
      });

      test('defaults has_loss_restriction_violation to false when missing', () {
        final json = {
          'client_id': 'c1',
          'client_name': '',
          'assessment_year': '2025-26',
          'total_transactions': 0,
          'total_gains': 0.0,
          'total_losses': 0.0,
          'net_taxable_gain': 0.0,
          'tax_liability': 0.0,
          'tds_collected': 0.0,
          'tds_shortfall': 0.0,
        };

        final summary = CryptoVdaMapper.summaryFromJson(json);
        expect(summary.hasLossRestrictionViolation, false);
      });
    });

    group('summaryToJson', () {
      test('includes all fields and round-trips correctly', () {
        final summary = const VdaSummary(
          clientId: 'c1',
          clientName: 'Test Client',
          assessmentYear: '2025-26',
          totalTransactions: 10,
          totalGains: 200000.0,
          totalLosses: 50000.0,
          netTaxableGain: 200000.0,
          taxLiability: 60000.0,
          tdsCollected: 40000.0,
          tdsShortfall: 20000.0,
          hasLossRestrictionViolation: false,
        );

        final json = CryptoVdaMapper.summaryToJson(summary);

        expect(json['client_id'], 'c1');
        expect(json['assessment_year'], '2025-26');
        expect(json['total_transactions'], 10);
        expect(json['net_taxable_gain'], 200000.0);
        expect(json['has_loss_restriction_violation'], false);

        final restored = CryptoVdaMapper.summaryFromJson(json);
        expect(restored.clientId, summary.clientId);
        expect(restored.netTaxableGain, summary.netTaxableGain);
        expect(restored.hasLossRestrictionViolation, summary.hasLossRestrictionViolation);
      });
    });
  });
}

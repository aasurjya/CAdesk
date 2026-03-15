import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/vda/data/mappers/vda_record_mapper.dart';
import 'package:ca_app/features/vda/domain/models/vda_record.dart';

void main() {
  group('VdaRecordMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'vda-001',
          'client_id': 'client-001',
          'transaction_date': '2025-06-15T00:00:00.000Z',
          'asset_type': 'Bitcoin',
          'buy_price': 2500000.0,
          'sell_price': 3000000.0,
          'quantity': 0.5,
          'gain_loss': 250000.0,
          'tds_deducted': 30000.0,
          'exchange': 'WazirX',
          'assessment_year': '2025-26',
        };

        final record = VdaRecordMapper.fromJson(json);

        expect(record.id, 'vda-001');
        expect(record.clientId, 'client-001');
        expect(record.assetType, 'Bitcoin');
        expect(record.buyPrice, 2500000.0);
        expect(record.sellPrice, 3000000.0);
        expect(record.quantity, 0.5);
        expect(record.gainLoss, 250000.0);
        expect(record.tdsDeducted, 30000.0);
        expect(record.exchange, 'WazirX');
        expect(record.assessmentYear, '2025-26');
      });

      test('handles null monetary fields with 0.0 default', () {
        final json = {
          'id': 'vda-002',
          'client_id': 'client-002',
          'transaction_date': '2025-07-01T00:00:00.000Z',
          'asset_type': 'Ethereum',
          'buy_price': null,
          'sell_price': null,
          'quantity': null,
          'gain_loss': null,
          'tds_deducted': null,
          'assessment_year': '2025-26',
        };

        final record = VdaRecordMapper.fromJson(json);
        expect(record.buyPrice, 0.0);
        expect(record.sellPrice, 0.0);
        expect(record.quantity, 0.0);
        expect(record.gainLoss, 0.0);
        expect(record.tdsDeducted, 0.0);
      });

      test('handles null exchange field', () {
        final json = {
          'id': 'vda-003',
          'client_id': 'c1',
          'transaction_date': '2025-08-01T00:00:00.000Z',
          'asset_type': 'NFT',
          'buy_price': 100000.0,
          'sell_price': 150000.0,
          'quantity': 1.0,
          'gain_loss': 50000.0,
          'tds_deducted': 5000.0,
          'assessment_year': '2025-26',
        };

        final record = VdaRecordMapper.fromJson(json);
        expect(record.exchange, isNull);
      });

      test('converts integer numeric values to double', () {
        final json = {
          'id': 'vda-004',
          'client_id': 'c1',
          'transaction_date': '2025-05-15T00:00:00.000Z',
          'asset_type': 'Token',
          'buy_price': 500,
          'sell_price': 750,
          'quantity': 100,
          'gain_loss': 25000,
          'tds_deducted': 2500,
          'assessment_year': '2025-26',
        };

        final record = VdaRecordMapper.fromJson(json);
        expect(record.buyPrice, 500.0);
        expect(record.buyPrice, isA<double>());
        expect(record.gainLoss, 25000.0);
      });

      test('parses transaction_date correctly', () {
        final json = {
          'id': 'vda-005',
          'client_id': 'c1',
          'transaction_date': '2025-03-31T00:00:00.000Z',
          'asset_type': 'Bitcoin',
          'buy_price': 0.0,
          'sell_price': 0.0,
          'quantity': 0.0,
          'gain_loss': 0.0,
          'tds_deducted': 0.0,
          'assessment_year': '2024-25',
        };

        final record = VdaRecordMapper.fromJson(json);
        expect(record.transactionDate.year, 2025);
        expect(record.transactionDate.month, 3);
        expect(record.transactionDate.day, 31);
      });

      test('handles negative gain_loss (loss scenario)', () {
        final json = {
          'id': 'vda-006',
          'client_id': 'c1',
          'transaction_date': '2025-09-01T00:00:00.000Z',
          'asset_type': 'Ethereum',
          'buy_price': 200000.0,
          'sell_price': 150000.0,
          'quantity': 2.0,
          'gain_loss': -100000.0,
          'tds_deducted': 0.0,
          'assessment_year': '2025-26',
        };

        final record = VdaRecordMapper.fromJson(json);
        expect(record.gainLoss, -100000.0);
      });
    });

    group('toJson', () {
      late VdaRecord sampleRecord;

      setUp(() {
        sampleRecord = VdaRecord(
          id: 'vda-json-001',
          clientId: 'client-json-001',
          transactionDate: DateTime(2025, 7, 15),
          assetType: 'Bitcoin',
          buyPrice: 2800000.0,
          sellPrice: 3200000.0,
          quantity: 1.0,
          gainLoss: 400000.0,
          tdsDeducted: 40000.0,
          exchange: 'CoinDCX',
          assessmentYear: '2025-26',
        );
      });

      test('includes all fields', () {
        final json = VdaRecordMapper.toJson(sampleRecord);

        expect(json['id'], 'vda-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['asset_type'], 'Bitcoin');
        expect(json['buy_price'], 2800000.0);
        expect(json['sell_price'], 3200000.0);
        expect(json['quantity'], 1.0);
        expect(json['gain_loss'], 400000.0);
        expect(json['tds_deducted'], 40000.0);
        expect(json['exchange'], 'CoinDCX');
        expect(json['assessment_year'], '2025-26');
      });

      test('serializes transaction_date as ISO string', () {
        final json = VdaRecordMapper.toJson(sampleRecord);
        expect(json['transaction_date'], startsWith('2025-07-15'));
      });

      test('serializes null exchange as null', () {
        final noExchange = VdaRecord(
          id: 'vda-noexchange',
          clientId: 'c1',
          transactionDate: DateTime(2025, 6, 1),
          assetType: 'NFT',
          buyPrice: 100000.0,
          sellPrice: 120000.0,
          quantity: 1.0,
          gainLoss: 20000.0,
          tdsDeducted: 0.0,
          assessmentYear: '2025-26',
        );
        final json = VdaRecordMapper.toJson(noExchange);
        expect(json['exchange'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = VdaRecordMapper.toJson(sampleRecord);
        final restored = VdaRecordMapper.fromJson(json);

        expect(restored.id, sampleRecord.id);
        expect(restored.clientId, sampleRecord.clientId);
        expect(restored.assetType, sampleRecord.assetType);
        expect(restored.buyPrice, sampleRecord.buyPrice);
        expect(restored.sellPrice, sampleRecord.sellPrice);
        expect(restored.quantity, sampleRecord.quantity);
        expect(restored.gainLoss, sampleRecord.gainLoss);
        expect(restored.tdsDeducted, sampleRecord.tdsDeducted);
        expect(restored.exchange, sampleRecord.exchange);
        expect(restored.assessmentYear, sampleRecord.assessmentYear);
      });

      test('handles zero values', () {
        final zeroRecord = sampleRecord.copyWith(
          gainLoss: 0.0,
          tdsDeducted: 0.0,
        );
        final json = VdaRecordMapper.toJson(zeroRecord);
        expect(json['gain_loss'], 0.0);
        expect(json['tds_deducted'], 0.0);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/fema/data/mappers/fema_mapper.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';

void main() {
  group('FemaMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'fema-001',
          'client_id': 'client-001',
          'filing_type': 'fdi',
          'transaction_date': '2025-09-01T00:00:00.000Z',
          'amount': '5000000',
          'currency': 'USD',
          'approval_required': true,
          'status': 'filed',
          'filing_number': 'FDI/2025/001',
          'remarks': 'Initial investment',
        };

        final filing = FemaMapper.fromJson(json);

        expect(filing.id, 'fema-001');
        expect(filing.clientId, 'client-001');
        expect(filing.filingType, FemaType.fdi);
        expect(filing.amount, '5000000');
        expect(filing.currency, 'USD');
        expect(filing.approvalRequired, true);
        expect(filing.status, 'filed');
        expect(filing.filingNumber, 'FDI/2025/001');
        expect(filing.remarks, 'Initial investment');
      });

      test('handles null filingNumber and remarks', () {
        final json = {
          'id': 'fema-002',
          'client_id': 'client-002',
          'filing_type': 'odi',
          'transaction_date': '2025-08-15T00:00:00.000Z',
          'amount': '1000000',
          'currency': 'EUR',
          'approval_required': false,
          'status': 'pending',
        };

        final filing = FemaMapper.fromJson(json);
        expect(filing.filingNumber, isNull);
        expect(filing.remarks, isNull);
        expect(filing.filingType, FemaType.odi);
        expect(filing.approvalRequired, false);
      });

      test('defaults filing_type to other for unknown value', () {
        final json = {
          'id': 'fema-003',
          'client_id': 'c1',
          'filing_type': 'unknownType',
          'transaction_date': '2025-08-01T00:00:00.000Z',
          'amount': '0',
          'currency': 'INR',
          'approval_required': false,
          'status': 'pending',
        };

        final filing = FemaMapper.fromJson(json);
        expect(filing.filingType, FemaType.other);
      });

      test('defaults currency to INR when missing', () {
        final json = {
          'id': 'fema-004',
          'client_id': 'c1',
          'filing_type': 'ecb',
          'transaction_date': '2025-08-01T00:00:00.000Z',
          'status': 'pending',
        };

        final filing = FemaMapper.fromJson(json);
        expect(filing.currency, 'INR');
        expect(filing.amount, '0');
        expect(filing.approvalRequired, false);
      });

      test('handles all FemaType values', () {
        for (final type in FemaType.values) {
          final json = {
            'id': 'fema-type-${type.name}',
            'client_id': 'c1',
            'filing_type': type.name,
            'transaction_date': '2025-08-01T00:00:00.000Z',
            'amount': '0',
            'currency': 'INR',
            'approval_required': false,
            'status': 'pending',
          };
          final filing = FemaMapper.fromJson(json);
          expect(filing.filingType, type);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final filing = FemaFilingData(
          id: 'fema-json-001',
          clientId: 'client-json-001',
          filingType: FemaType.form15ca,
          transactionDate: DateTime.utc(2025, 9, 5),
          amount: '250000',
          currency: 'GBP',
          approvalRequired: true,
          status: 'approved',
          filingNumber: '15CA/2025/100',
          remarks: 'Dividend remittance',
        );

        final json = FemaMapper.toJson(filing);

        expect(json['id'], 'fema-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['filing_type'], 'form15ca');
        expect(json['amount'], '250000');
        expect(json['currency'], 'GBP');
        expect(json['approval_required'], true);
        expect(json['status'], 'approved');
        expect(json['filing_number'], '15CA/2025/100');
        expect(json['remarks'], 'Dividend remittance');

        final restored = FemaMapper.fromJson(json);
        expect(restored.id, filing.id);
        expect(restored.filingType, filing.filingType);
        expect(restored.amount, filing.amount);
        expect(restored.status, filing.status);
      });

      test('serializes null fields as null', () {
        final filing = FemaFilingData(
          id: 'fema-null',
          clientId: 'c1',
          filingType: FemaType.compounding,
          transactionDate: DateTime.utc(2025, 1, 1),
          amount: '0',
          currency: 'INR',
          status: 'pending',
        );

        final json = FemaMapper.toJson(filing);
        expect(json['filing_number'], isNull);
        expect(json['remarks'], isNull);
      });
    });
  });
}

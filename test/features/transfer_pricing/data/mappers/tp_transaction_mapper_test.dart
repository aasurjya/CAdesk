import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/transfer_pricing/data/mappers/tp_transaction_mapper.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';

void main() {
  group('TpTransactionMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'tp-001',
          'client_id': 'client-001',
          'assessment_year': '2025-26',
          'related_party': 'XYZ Corp Singapore',
          'transaction_type': 'Royalty',
          'transaction_value': 5000000.0,
          'tp_method': 'tnmm',
          'documentation_due': '2025-11-30T00:00:00.000Z',
          'status': 'underReview',
          'created_at': '2025-04-01T00:00:00.000Z',
          'updated_at': '2025-07-15T00:00:00.000Z',
        };

        final tx = TpTransactionMapper.fromJson(json);

        expect(tx.id, 'tp-001');
        expect(tx.clientId, 'client-001');
        expect(tx.assessmentYear, '2025-26');
        expect(tx.relatedParty, 'XYZ Corp Singapore');
        expect(tx.transactionType, 'Royalty');
        expect(tx.transactionValue, 5000000.0);
        expect(tx.tpMethod, TpMethod.tnmm);
        expect(tx.documentationDue, isNotNull);
        expect(tx.status, TpStatus.underReview);
      });

      test('handles null documentation_due', () {
        final json = {
          'id': 'tp-002',
          'client_id': 'client-002',
          'assessment_year': '2024-25',
          'related_party': 'ABC Ltd',
          'transaction_type': 'Loan',
          'transaction_value': 10000000.0,
          'tp_method': 'cup',
          'status': 'draft',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };

        final tx = TpTransactionMapper.fromJson(json);
        expect(tx.documentationDue, isNull);
      });

      test('defaults tp_method to tnmm for unknown value', () {
        final json = {
          'id': 'tp-003',
          'client_id': 'c1',
          'assessment_year': '2025-26',
          'related_party': 'TestCorp',
          'transaction_type': 'Service',
          'transaction_value': 0.0,
          'tp_method': 'unknownMethod',
          'status': 'draft',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };

        final tx = TpTransactionMapper.fromJson(json);
        expect(tx.tpMethod, TpMethod.tnmm);
      });

      test('defaults status to draft for unknown value', () {
        final json = {
          'id': 'tp-004',
          'client_id': 'c1',
          'assessment_year': '2025-26',
          'related_party': 'TestCorp',
          'transaction_type': 'Service',
          'transaction_value': 0.0,
          'tp_method': 'psm',
          'status': 'unknownStatus',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };

        final tx = TpTransactionMapper.fromJson(json);
        expect(tx.status, TpStatus.draft);
      });

      test('handles all TpMethod values', () {
        for (final method in TpMethod.values) {
          final json = {
            'id': 'tp-method-${method.name}',
            'client_id': 'c1',
            'assessment_year': '2025-26',
            'related_party': 'TestCorp',
            'transaction_type': 'Service',
            'transaction_value': 0.0,
            'tp_method': method.name,
            'status': 'draft',
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final tx = TpTransactionMapper.fromJson(json);
          expect(tx.tpMethod, method);
        }
      });

      test('handles all TpStatus values', () {
        for (final status in TpStatus.values) {
          final json = {
            'id': 'tp-status-${status.name}',
            'client_id': 'c1',
            'assessment_year': '2025-26',
            'related_party': 'TestCorp',
            'transaction_type': 'Service',
            'transaction_value': 0.0,
            'tp_method': 'tnmm',
            'status': status.name,
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          };
          final tx = TpTransactionMapper.fromJson(json);
          expect(tx.status, status);
        }
      });

      test('converts integer transaction_value to double', () {
        final json = {
          'id': 'tp-005',
          'client_id': 'c1',
          'assessment_year': '2025-26',
          'related_party': 'Corp',
          'transaction_type': 'Dividend',
          'transaction_value': 2500000,
          'tp_method': 'cpm',
          'status': 'draft',
          'created_at': '2025-01-01T00:00:00.000Z',
          'updated_at': '2025-01-01T00:00:00.000Z',
        };

        final tx = TpTransactionMapper.fromJson(json);
        expect(tx.transactionValue, 2500000.0);
        expect(tx.transactionValue, isA<double>());
      });
    });

    group('toJson', () {
      late TpTransaction sampleTx;

      setUp(() {
        sampleTx = TpTransaction(
          id: 'tp-json-001',
          clientId: 'client-json-001',
          assessmentYear: '2025-26',
          relatedParty: 'Global Corp Ltd',
          transactionType: 'Software License',
          transactionValue: 15000000.0,
          tpMethod: TpMethod.cup,
          documentationDue: DateTime(2025, 11, 30),
          status: TpStatus.documented,
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 8, 15),
        );
      });

      test('includes all fields', () {
        final json = TpTransactionMapper.toJson(sampleTx);

        expect(json['id'], 'tp-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['assessment_year'], '2025-26');
        expect(json['related_party'], 'Global Corp Ltd');
        expect(json['transaction_type'], 'Software License');
        expect(json['transaction_value'], 15000000.0);
        expect(json['tp_method'], 'cup');
        expect(json['status'], 'documented');
      });

      test('serializes documentation_due as ISO string', () {
        final json = TpTransactionMapper.toJson(sampleTx);
        expect(json['documentation_due'], startsWith('2025-11-30'));
      });

      test('serializes null documentation_due as null', () {
        final noDueDate = TpTransaction(
          id: 'tp-noduedate',
          clientId: 'c1',
          assessmentYear: '2025-26',
          relatedParty: 'Corp',
          transactionType: 'Loan',
          transactionValue: 0.0,
          tpMethod: TpMethod.psm,
          status: TpStatus.draft,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );
        final json = TpTransactionMapper.toJson(noDueDate);
        expect(json['documentation_due'], isNull);
      });

      test('serializes created_at and updated_at as ISO strings', () {
        final json = TpTransactionMapper.toJson(sampleTx);
        expect(json['created_at'], startsWith('2025-04-01'));
        expect(json['updated_at'], startsWith('2025-08-15'));
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = TpTransactionMapper.toJson(sampleTx);
        final restored = TpTransactionMapper.fromJson(json);

        expect(restored.id, sampleTx.id);
        expect(restored.clientId, sampleTx.clientId);
        expect(restored.assessmentYear, sampleTx.assessmentYear);
        expect(restored.relatedParty, sampleTx.relatedParty);
        expect(restored.transactionType, sampleTx.transactionType);
        expect(restored.transactionValue, sampleTx.transactionValue);
        expect(restored.tpMethod, sampleTx.tpMethod);
        expect(restored.status, sampleTx.status);
      });

      test('serializes tp_method as enum name', () {
        for (final method in TpMethod.values) {
          final tx = sampleTx.copyWith(tpMethod: method);
          final json = TpTransactionMapper.toJson(tx);
          expect(json['tp_method'], method.name);
        }
      });
    });
  });
}

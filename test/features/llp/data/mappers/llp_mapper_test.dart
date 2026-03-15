import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/llp/data/mappers/llp_mapper.dart';
import 'package:ca_app/features/llp/domain/models/llp_filing.dart';

void main() {
  group('LlpMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'llp-001',
          'client_id': 'client-001',
          'form_type': 'form8',
          'financial_year': '2024-25',
          'due_date': '2025-10-30T00:00:00.000Z',
          'filed_date': '2025-10-25T00:00:00.000Z',
          'status': 'filed',
          'filing_number': 'LLP/FORM8/12345',
        };

        final filing = LlpMapper.fromJson(json);

        expect(filing.id, 'llp-001');
        expect(filing.clientId, 'client-001');
        expect(filing.formType, LlpFormType.form8);
        expect(filing.financialYear, '2024-25');
        expect(filing.dueDate.year, 2025);
        expect(filing.dueDate.month, 10);
        expect(filing.filedDate, isNotNull);
        expect(filing.status, 'filed');
        expect(filing.filingNumber, 'LLP/FORM8/12345');
      });

      test('handles null filed_date and filing_number', () {
        final json = {
          'id': 'llp-002',
          'client_id': 'client-002',
          'form_type': 'form11',
          'financial_year': '2024-25',
          'due_date': '2025-05-30T00:00:00.000Z',
          'status': 'pending',
        };

        final filing = LlpMapper.fromJson(json);
        expect(filing.filedDate, isNull);
        expect(filing.filingNumber, isNull);
        expect(filing.formType, LlpFormType.form11);
      });

      test('defaults form_type to other for unknown value', () {
        final json = {
          'id': 'llp-003',
          'client_id': 'c1',
          'form_type': 'unknownForm',
          'financial_year': '2024-25',
          'due_date': '2025-10-30T00:00:00.000Z',
          'status': 'pending',
        };

        final filing = LlpMapper.fromJson(json);
        expect(filing.formType, LlpFormType.other);
      });

      test('defaults financial_year to empty string when missing', () {
        final json = {
          'id': 'llp-004',
          'client_id': 'c1',
          'form_type': 'form3',
          'due_date': '2025-06-30T00:00:00.000Z',
          'status': 'pending',
        };

        final filing = LlpMapper.fromJson(json);
        expect(filing.financialYear, '');
        expect(filing.status, 'pending');
      });

      test('handles all LlpFormType values', () {
        for (final formType in LlpFormType.values) {
          final json = {
            'id': 'llp-form-${formType.name}',
            'client_id': 'c1',
            'form_type': formType.name,
            'financial_year': '2024-25',
            'due_date': '2025-10-30T00:00:00.000Z',
            'status': 'pending',
          };
          final filing = LlpMapper.fromJson(json);
          expect(filing.formType, formType);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final filing = LlpFiling(
          id: 'llp-json-001',
          clientId: 'client-json-001',
          formType: LlpFormType.form4,
          financialYear: '2025-26',
          dueDate: DateTime.utc(2026, 5, 30),
          filedDate: DateTime.utc(2026, 5, 20),
          status: 'approved',
          filingNumber: 'LLP/FORM4/99999',
        );

        final json = LlpMapper.toJson(filing);

        expect(json['id'], 'llp-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['form_type'], 'form4');
        expect(json['financial_year'], '2025-26');
        expect(json['status'], 'approved');
        expect(json['filing_number'], 'LLP/FORM4/99999');
        expect(json['filed_date'], isNotNull);

        final restored = LlpMapper.fromJson(json);
        expect(restored.id, filing.id);
        expect(restored.formType, filing.formType);
        expect(restored.financialYear, filing.financialYear);
        expect(restored.status, filing.status);
      });

      test('serializes null filed_date and filing_number as null', () {
        final filing = LlpFiling(
          id: 'llp-null',
          clientId: 'c1',
          formType: LlpFormType.form15,
          financialYear: '2024-25',
          dueDate: DateTime.utc(2025, 9, 30),
          status: 'pending',
        );

        final json = LlpMapper.toJson(filing);
        expect(json['filed_date'], isNull);
        expect(json['filing_number'], isNull);
      });
    });
  });
}

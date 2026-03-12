import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_schema_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItrSchemaValidator', () {
    group('validatePan', () {
      test('valid PAN returns true', () {
        expect(ItrSchemaValidator.validatePan('ABCDE1234F'), isTrue);
        expect(ItrSchemaValidator.validatePan('ZZZZZ9999Z'), isTrue);
        expect(ItrSchemaValidator.validatePan('PANME1234F'), isTrue);
      });

      test('invalid PAN returns false', () {
        expect(ItrSchemaValidator.validatePan(''), isFalse);
        expect(ItrSchemaValidator.validatePan('ABCD1234F'), isFalse); // too short
        expect(ItrSchemaValidator.validatePan('abcde1234f'), isFalse); // lowercase
        expect(ItrSchemaValidator.validatePan('12345ABCDE'), isFalse); // digits first
        expect(ItrSchemaValidator.validatePan('ABCDE12345'), isFalse); // last char digit
        expect(ItrSchemaValidator.validatePan('ABCDE1234FF'), isFalse); // too long
      });
    });

    group('validateAssessmentYear', () {
      test('valid assessment years return true', () {
        expect(ItrSchemaValidator.validateAssessmentYear('2024-25'), isTrue);
        expect(ItrSchemaValidator.validateAssessmentYear('2023-24'), isTrue);
        expect(ItrSchemaValidator.validateAssessmentYear('2025-26'), isTrue);
      });

      test('invalid assessment years return false', () {
        expect(ItrSchemaValidator.validateAssessmentYear(''), isFalse);
        expect(ItrSchemaValidator.validateAssessmentYear('2024-2025'), isFalse);
        expect(ItrSchemaValidator.validateAssessmentYear('24-25'), isFalse);
        expect(ItrSchemaValidator.validateAssessmentYear('2024/25'), isFalse);
        expect(ItrSchemaValidator.validateAssessmentYear('abcd-ef'), isFalse);
      });
    });

    group('validateMandatoryFields', () {
      test('returns empty list when all fields present', () {
        final json = <String, dynamic>{
          'PAN': 'ABCDE1234F',
          'AssessmentYear': '2024-25',
          'GrossTotalIncome': 500000,
        };
        final errors = ItrSchemaValidator.validateMandatoryFields(
          json,
          ['PAN', 'AssessmentYear', 'GrossTotalIncome'],
        );
        expect(errors, isEmpty);
      });

      test('returns missing field names', () {
        final json = <String, dynamic>{'PAN': 'ABCDE1234F'};
        final errors = ItrSchemaValidator.validateMandatoryFields(
          json,
          ['PAN', 'AssessmentYear', 'GrossTotalIncome'],
        );
        expect(errors.length, 2);
        expect(errors, containsAll(['AssessmentYear', 'GrossTotalIncome']));
      });

      test('returns all fields as missing when json is empty', () {
        final errors = ItrSchemaValidator.validateMandatoryFields(
          {},
          ['PAN', 'AssessmentYear'],
        );
        expect(errors.length, 2);
      });
    });

    group('validateAmounts', () {
      test('returns empty list when all amounts are non-negative integers', () {
        final json = <String, dynamic>{
          'GrossTotalIncome': 500000,
          'TaxPayable': 0,
          'name': 'John Doe', // non-numeric field, skipped
        };
        final errors = ItrSchemaValidator.validateAmounts(json);
        expect(errors, isEmpty);
      });

      test('returns error for negative amounts', () {
        final json = <String, dynamic>{
          'GrossTotalIncome': -100,
          'TaxPayable': 5000,
        };
        final errors = ItrSchemaValidator.validateAmounts(json);
        expect(errors.length, 1);
        expect(errors.first, contains('GrossTotalIncome'));
      });

      test('returns error for double (non-integer) amounts', () {
        final json = <String, dynamic>{
          'GrossTotalIncome': 500000.50,
          'TaxPayable': 5000,
        };
        final errors = ItrSchemaValidator.validateAmounts(json);
        expect(errors.length, 1);
        expect(errors.first, contains('GrossTotalIncome'));
      });

      test('returns empty list when json has no numeric values', () {
        final json = <String, dynamic>{'name': 'Test', 'status': 'active'};
        final errors = ItrSchemaValidator.validateAmounts(json);
        expect(errors, isEmpty);
      });
    });

    group('validate', () {
      test('returns no errors for valid ITR-1 result', () {
        const payload = '{"ITR":{"ITR1":{"PAN":"ABCDE1234F"}}}';
        final checksum = _dummyChecksum();
        final result = ItrExportResult(
          itrType: ItrType.itr1,
          jsonPayload: payload,
          checksum: checksum,
          exportedAt: DateTime(2024, 4, 1),
          assessmentYear: '2024-25',
          panNumber: 'ABCDE1234F',
          validationErrors: const [],
        );
        final errors = ItrSchemaValidator.validate(result);
        expect(errors, isEmpty);
      });

      test('returns error for invalid PAN', () {
        const payload = '{"ITR":{"ITR1":{}}}';
        final result = ItrExportResult(
          itrType: ItrType.itr1,
          jsonPayload: payload,
          checksum: _dummyChecksum(),
          exportedAt: DateTime(2024, 4, 1),
          assessmentYear: '2024-25',
          panNumber: 'INVALID',
          validationErrors: const [],
        );
        final errors = ItrSchemaValidator.validate(result);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for invalid assessment year', () {
        const payload = '{"ITR":{"ITR1":{}}}';
        final result = ItrExportResult(
          itrType: ItrType.itr1,
          jsonPayload: payload,
          checksum: _dummyChecksum(),
          exportedAt: DateTime(2024, 4, 1),
          assessmentYear: 'bad-year',
          panNumber: 'ABCDE1234F',
          validationErrors: const [],
        );
        final errors = ItrSchemaValidator.validate(result);
        expect(errors.any((e) => e.contains('assessment year')), isTrue);
      });

      test('returns error for empty payload', () {
        final result = ItrExportResult(
          itrType: ItrType.itr1,
          jsonPayload: '',
          checksum: _dummyChecksum(),
          exportedAt: DateTime(2024, 4, 1),
          assessmentYear: '2024-25',
          panNumber: 'ABCDE1234F',
          validationErrors: const [],
        );
        final errors = ItrSchemaValidator.validate(result);
        expect(errors.any((e) => e.contains('payload')), isTrue);
      });
    });
  });
}

String _dummyChecksum() => 'a' * 64;

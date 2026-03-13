import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstn_schema_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GstnSchemaValidator', () {
    late GstnSchemaValidator validator;

    setUp(() {
      validator = GstnSchemaValidator.instance;
    });

    // Helper to build a minimal GstrExportResult
    GstrExportResult validGstr1Result({String payload = '{"gstin":"29AABCT1332L1ZB","fp":"032024","b2b":[]}'}) =>
        GstrExportResult(
          returnType: GstrReturnType.gstr1,
          gstin: '29AABCT1332L1ZB',
          period: '032024',
          jsonPayload: payload,
          sectionCount: 0,
          exportedAt: DateTime(2024, 3, 31),
          validationErrors: const [],
        );

    GstrExportResult validGstr3bResult({String payload = '{"gstin":"29AABCT1332L1ZB","ret_period":"032024"}'}) =>
        GstrExportResult(
          returnType: GstrReturnType.gstr3b,
          gstin: '29AABCT1332L1ZB',
          period: '032024',
          jsonPayload: payload,
          sectionCount: 0,
          exportedAt: DateTime(2024, 3, 31),
          validationErrors: const [],
        );

    test('is a singleton', () {
      expect(GstnSchemaValidator.instance, same(GstnSchemaValidator.instance));
    });

    group('validateGstin', () {
      test('valid GSTIN returns true', () {
        expect(validator.validateGstin('29AABCT1332L1ZB'), isTrue);
      });

      test('valid GSTIN with different state code returns true', () {
        expect(validator.validateGstin('27AABCE1234F1Z5'), isTrue);
      });

      test('GSTIN with 14 chars returns false', () {
        expect(validator.validateGstin('29AABCT1332L1Z'), isFalse);
      });

      test('GSTIN with 16 chars returns false', () {
        expect(validator.validateGstin('29AABCT1332L1ZBX'), isFalse);
      });

      test('empty string returns false', () {
        expect(validator.validateGstin(''), isFalse);
      });

      test('GSTIN with invalid state code 00 returns false', () {
        expect(validator.validateGstin('00AABCT1332L1ZB'), isFalse);
      });

      test('GSTIN with state code 38 (max valid) returns true', () {
        expect(validator.validateGstin('38AABCT1332L1ZB'), isTrue);
      });

      test('GSTIN with state code 39 returns false', () {
        expect(validator.validateGstin('39AABCT1332L1ZB'), isFalse);
      });

      test('lowercase GSTIN returns false (must be uppercase)', () {
        expect(validator.validateGstin('29aabct1332l1zb'), isFalse);
      });
    });

    group('validatePeriod', () {
      test('valid period 032024 returns true', () {
        expect(validator.validatePeriod('032024'), isTrue);
      });

      test('valid period 122023 returns true', () {
        expect(validator.validatePeriod('122023'), isTrue);
      });

      test('valid period 012025 returns true', () {
        expect(validator.validatePeriod('012025'), isTrue);
      });

      test('period with month 00 returns false', () {
        expect(validator.validatePeriod('002024'), isFalse);
      });

      test('period with month 13 returns false', () {
        expect(validator.validatePeriod('132024'), isFalse);
      });

      test('5-char period returns false', () {
        expect(validator.validatePeriod('03202'), isFalse);
      });

      test('7-char period returns false', () {
        expect(validator.validatePeriod('0320241'), isFalse);
      });

      test('empty period returns false', () {
        expect(validator.validatePeriod(''), isFalse);
      });

      test('period with letters returns false', () {
        expect(validator.validatePeriod('MAR024'), isFalse);
      });
    });

    group('validateGstr1', () {
      test('valid GSTR-1 result returns empty error list', () {
        final errors = validator.validateGstr1(validGstr1Result());
        expect(errors, isEmpty);
      });

      test('invalid GSTIN in result returns error', () {
        final result = validGstr1Result().copyWith(gstin: 'INVALID');
        final errors = validator.validateGstr1(result);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('GSTIN')), isTrue);
      });

      test('invalid period in result returns error', () {
        final result = validGstr1Result().copyWith(period: '132024');
        final errors = validator.validateGstr1(result);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('period')), isTrue);
      });

      test('wrong return type returns error', () {
        final result = GstrExportResult(
          returnType: GstrReturnType.gstr3b,
          gstin: '29AABCT1332L1ZB',
          period: '032024',
          jsonPayload: '{}',
          sectionCount: 0,
          exportedAt: DateTime(2024, 3, 31),
          validationErrors: const [],
        );
        final errors = validator.validateGstr1(result);
        expect(errors, isNotEmpty);
      });

      test('negative amount in b2b txval returns error', () {
        const payload = '''
{
  "gstin": "29AABCT1332L1ZB",
  "fp": "032024",
  "b2b": [
    {
      "ctin": "27AABCE1234F1Z5",
      "inv": [
        {
          "inum": "INV1",
          "idt": "01-03-2024",
          "val": "100.00",
          "pos": "29",
          "rchrg": "N",
          "itms": [{"num": 1, "itm_det": {"txval": "-100.00", "rt": 18, "camt": "0.00", "samt": "0.00"}}]
        }
      ]
    }
  ]
}''';
        final result = validGstr1Result(payload: payload);
        final errors = validator.validateGstr1(result);
        expect(errors.any((e) => e.toLowerCase().contains('negative')), isTrue);
      });
    });

    group('validateGstr3b', () {
      test('valid GSTR-3B result returns empty error list', () {
        final errors = validator.validateGstr3b(validGstr3bResult());
        expect(errors, isEmpty);
      });

      test('invalid GSTIN in result returns error', () {
        final result = validGstr3bResult().copyWith(gstin: 'INVALID');
        final errors = validator.validateGstr3b(result);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('GSTIN')), isTrue);
      });

      test('invalid period in result returns error', () {
        final result = validGstr3bResult().copyWith(period: '002024');
        final errors = validator.validateGstr3b(result);
        expect(errors, isNotEmpty);
      });

      test('wrong return type returns error', () {
        final result = GstrExportResult(
          returnType: GstrReturnType.gstr1,
          gstin: '29AABCT1332L1ZB',
          period: '032024',
          jsonPayload: '{}',
          sectionCount: 0,
          exportedAt: DateTime(2024, 3, 31),
          validationErrors: const [],
        );
        final errors = validator.validateGstr3b(result);
        expect(errors, isNotEmpty);
      });

      test('negative amount in osup_det camt returns error', () {
        const payload = '''
{
  "gstin": "29AABCT1332L1ZB",
  "ret_period": "032024",
  "sup_details": {
    "osup_det": {"txval": "1000.00", "iamt": "0.00", "camt": "-90.00", "samt": "90.00", "csamt": "0.00"}
  }
}''';
        final result = validGstr3bResult(payload: payload);
        final errors = validator.validateGstr3b(result);
        expect(errors.any((e) => e.toLowerCase().contains('negative')), isTrue);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';

void main() {
  group('ActMode', () {
    test('has two values: act1961 and act2025', () {
      expect(ActMode.values.length, 2);
      expect(ActMode.values, contains(ActMode.act1961));
      expect(ActMode.values, contains(ActMode.act2025));
    });

    test('act1961 has correct label', () {
      expect(ActMode.act1961.label, 'Income-tax Act, 1961');
    });

    test('act2025 has correct label', () {
      expect(ActMode.act2025.label, 'Income-tax Act, 2025');
    });

    test('act1961 has correct shortLabel', () {
      expect(ActMode.act1961.shortLabel, 'IT Act 1961');
    });

    test('act2025 has correct shortLabel', () {
      expect(ActMode.act2025.shortLabel, 'IT Act 2025');
    });

    test('act1961 cutoff is March 31, 2026', () {
      expect(
        ActMode.act1961.effectiveUntil,
        DateTime(2026, 3, 31),
      );
    });

    test('act2025 effective from April 1, 2026', () {
      expect(
        ActMode.act2025.effectiveFrom,
        DateTime(2026, 4, 1),
      );
    });
  });

  group('ActMode.forDate', () {
    test('returns act1961 for dates before April 1, 2026', () {
      expect(ActMode.forDate(DateTime(2025, 6, 15)), ActMode.act1961);
      expect(ActMode.forDate(DateTime(2026, 3, 31)), ActMode.act1961);
    });

    test('returns act2025 for dates on or after April 1, 2026', () {
      expect(ActMode.forDate(DateTime(2026, 4, 1)), ActMode.act2025);
      expect(ActMode.forDate(DateTime(2027, 1, 1)), ActMode.act2025);
    });
  });

  group('ActMode.forFinancialYear', () {
    test('returns act1961 for FY 2025-26 and earlier', () {
      expect(ActMode.forFinancialYear('2025-26'), ActMode.act1961);
      expect(ActMode.forFinancialYear('2024-25'), ActMode.act1961);
      expect(ActMode.forFinancialYear('2020-21'), ActMode.act1961);
    });

    test('returns act2025 for FY 2026-27 onwards (Tax Year)', () {
      expect(ActMode.forFinancialYear('2026-27'), ActMode.act2025);
      expect(ActMode.forFinancialYear('2027-28'), ActMode.act2025);
    });

    test('throws for invalid FY format', () {
      expect(() => ActMode.forFinancialYear('2025'), throwsFormatException);
      expect(() => ActMode.forFinancialYear(''), throwsFormatException);
    });
  });

  group('ActMode.forAssessmentYear', () {
    test('returns act1961 for AY 2026-27 and earlier', () {
      expect(ActMode.forAssessmentYear('2026-27'), ActMode.act1961);
      expect(ActMode.forAssessmentYear('2025-26'), ActMode.act1961);
    });

    test('returns act2025 for AY 2027-28 onwards (Tax Year)', () {
      expect(ActMode.forAssessmentYear('2027-28'), ActMode.act2025);
      expect(ActMode.forAssessmentYear('2028-29'), ActMode.act2025);
    });
  });

  group('ActMode.current', () {
    test('returns a valid ActMode based on current date', () {
      final mode = ActMode.current;
      expect(ActMode.values, contains(mode));
    });
  });
}

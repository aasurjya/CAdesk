import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/it_act_transition/domain/models/tax_year.dart';
import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';

void main() {
  group('TaxYear', () {
    test('creates from start year', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.startYear, 2026);
      expect(ty.endYear, 2027);
    });

    test('formats as financial year string', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.financialYearString, '2026-27');
    });

    test('formats as assessment year string', () {
      final ty = TaxYear(startYear: 2025);
      expect(ty.assessmentYearString, 'AY 2026-27');
    });

    test('formats as tax year string for 2025 Act', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.taxYearString, 'TY 2026-27');
    });

    test('displayLabel returns AY for 1961 Act periods', () {
      final ty = TaxYear(startYear: 2025);
      expect(ty.displayLabel, 'AY 2026-27');
    });

    test('displayLabel returns TY for 2025 Act periods', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.displayLabel, 'TY 2026-27');
    });

    test('actMode returns act1961 for FY 2025-26', () {
      final ty = TaxYear(startYear: 2025);
      expect(ty.actMode, ActMode.act1961);
    });

    test('actMode returns act2025 for FY 2026-27', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.actMode, ActMode.act2025);
    });

    test('startDate is April 1', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.startDate, DateTime(2026, 4, 1));
    });

    test('endDate is March 31 next year', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.endDate, DateTime(2027, 3, 31));
    });

    test('equality by startYear', () {
      final a = TaxYear(startYear: 2026);
      final b = TaxYear(startYear: 2026);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality for different startYear', () {
      final a = TaxYear(startYear: 2025);
      final b = TaxYear(startYear: 2026);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates new instance', () {
      final ty = TaxYear(startYear: 2025);
      final copy = ty.copyWith(startYear: 2026);
      expect(copy.startYear, 2026);
      expect(ty.startYear, 2025); // original unchanged
    });

    test('copyWith with no args returns equivalent', () {
      final ty = TaxYear(startYear: 2025);
      final copy = ty.copyWith();
      expect(copy, equals(ty));
      expect(identical(copy, ty), isFalse);
    });
  });

  group('TaxYear.fromFinancialYear', () {
    test('parses "2025-26"', () {
      final ty = TaxYear.fromFinancialYear('2025-26');
      expect(ty.startYear, 2025);
    });

    test('parses "2026-27"', () {
      final ty = TaxYear.fromFinancialYear('2026-27');
      expect(ty.startYear, 2026);
    });

    test('throws for invalid format', () {
      expect(() => TaxYear.fromFinancialYear('2025'), throwsFormatException);
      expect(() => TaxYear.fromFinancialYear('abc'), throwsFormatException);
    });
  });

  group('TaxYear.fromAssessmentYear', () {
    test('parses "AY 2026-27" to FY 2025-26', () {
      final ty = TaxYear.fromAssessmentYear('AY 2026-27');
      expect(ty.startYear, 2025);
    });

    test('parses "2026-27" without prefix', () {
      final ty = TaxYear.fromAssessmentYear('2026-27');
      expect(ty.startYear, 2025);
    });
  });

  group('TaxYear.fromDate', () {
    test('date in April-March maps correctly', () {
      final ty = TaxYear.fromDate(DateTime(2026, 6, 15));
      expect(ty.startYear, 2026);
    });

    test('date in Jan-March maps to previous start year', () {
      final ty = TaxYear.fromDate(DateTime(2027, 2, 15));
      expect(ty.startYear, 2026);
    });

    test('April 1 maps to that year', () {
      final ty = TaxYear.fromDate(DateTime(2026, 4, 1));
      expect(ty.startYear, 2026);
    });

    test('March 31 maps to previous year start', () {
      final ty = TaxYear.fromDate(DateTime(2027, 3, 31));
      expect(ty.startYear, 2026);
    });
  });

  group('TaxYear.current', () {
    test('returns valid TaxYear', () {
      final ty = TaxYear.current;
      expect(ty.startYear, greaterThan(2020));
    });
  });

  group('TaxYear comparisons', () {
    test('compareTo orders by startYear', () {
      final a = TaxYear(startYear: 2025);
      final b = TaxYear(startYear: 2026);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
      expect(a.compareTo(a), 0);
    });

    test('contains date checks boundary', () {
      final ty = TaxYear(startYear: 2026);
      expect(ty.containsDate(DateTime(2026, 4, 1)), isTrue);
      expect(ty.containsDate(DateTime(2027, 3, 31)), isTrue);
      expect(ty.containsDate(DateTime(2026, 3, 31)), isFalse);
      expect(ty.containsDate(DateTime(2027, 4, 1)), isFalse);
    });
  });
}

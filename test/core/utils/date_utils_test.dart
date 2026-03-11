import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/utils/date_utils.dart';

void main() {
  group('DateUtils', () {
    group('formatIndianDate', () {
      test('formats a known date correctly', () {
        final date = DateTime(2025, 3, 15);
        expect(IndianDateUtils.formatIndianDate(date), '15/03/2025');
      });

      test('formats single-digit day and month with leading zeros', () {
        final date = DateTime(2025, 1, 5);
        expect(IndianDateUtils.formatIndianDate(date), '05/01/2025');
      });

      test('formats December 31 correctly', () {
        final date = DateTime(2025, 12, 31);
        expect(IndianDateUtils.formatIndianDate(date), '31/12/2025');
      });

      test('formats January 1 correctly', () {
        final date = DateTime(2026, 1, 1);
        expect(IndianDateUtils.formatIndianDate(date), '01/01/2026');
      });

      test('formats leap year date correctly', () {
        final date = DateTime(2024, 2, 29);
        expect(IndianDateUtils.formatIndianDate(date), '29/02/2024');
      });
    });

    group('currentFinancialYear', () {
      test('returns correct FY string for date in April-December', () {
        // August 2025 falls in FY 2025-26
        final result = IndianDateUtils.currentFinancialYear(
          DateTime(2025, 8, 15),
        );
        expect(result, 'FY 2025-26');
      });

      test('returns correct FY string for date in January-March', () {
        // February 2026 falls in FY 2025-26
        final result = IndianDateUtils.currentFinancialYear(
          DateTime(2026, 2, 10),
        );
        expect(result, 'FY 2025-26');
      });

      test('returns correct FY for April 1 (FY start)', () {
        final result = IndianDateUtils.currentFinancialYear(
          DateTime(2025, 4, 1),
        );
        expect(result, 'FY 2025-26');
      });

      test('returns correct FY for March 31 (FY end)', () {
        final result = IndianDateUtils.currentFinancialYear(
          DateTime(2026, 3, 31),
        );
        expect(result, 'FY 2025-26');
      });

      test('returns correct FY for January 1', () {
        final result = IndianDateUtils.currentFinancialYear(
          DateTime(2026, 1, 1),
        );
        expect(result, 'FY 2025-26');
      });
    });

    group('financialYearStart', () {
      test('returns April 1 of same year for date in April-December', () {
        final result = IndianDateUtils.financialYearStart(
          DateTime(2025, 7, 15),
        );
        expect(result, DateTime(2025, 4, 1));
      });

      test('returns April 1 of previous year for date in January-March', () {
        final result = IndianDateUtils.financialYearStart(
          DateTime(2026, 2, 10),
        );
        expect(result, DateTime(2025, 4, 1));
      });

      test('returns same date for April 1', () {
        final result = IndianDateUtils.financialYearStart(DateTime(2025, 4, 1));
        expect(result, DateTime(2025, 4, 1));
      });

      test('returns previous year April 1 for March 31', () {
        final result = IndianDateUtils.financialYearStart(
          DateTime(2026, 3, 31),
        );
        expect(result, DateTime(2025, 4, 1));
      });
    });

    group('financialYearEnd', () {
      test('returns March 31 of next year for date in April-December', () {
        final result = IndianDateUtils.financialYearEnd(DateTime(2025, 7, 15));
        expect(result, DateTime(2026, 3, 31));
      });

      test('returns March 31 of same year for date in January-March', () {
        final result = IndianDateUtils.financialYearEnd(DateTime(2026, 2, 10));
        expect(result, DateTime(2026, 3, 31));
      });

      test('returns next year March 31 for April 1', () {
        final result = IndianDateUtils.financialYearEnd(DateTime(2025, 4, 1));
        expect(result, DateTime(2026, 3, 31));
      });

      test('returns same date for March 31', () {
        final result = IndianDateUtils.financialYearEnd(DateTime(2026, 3, 31));
        expect(result, DateTime(2026, 3, 31));
      });
    });

    group('daysUntilDeadline', () {
      test('returns positive number for future deadline', () {
        final today = DateTime(2025, 7, 1);
        final deadline = DateTime(2025, 7, 31);
        expect(IndianDateUtils.daysUntilDeadline(deadline, from: today), 30);
      });

      test('returns 0 when deadline is today', () {
        final today = DateTime(2025, 7, 31);
        final deadline = DateTime(2025, 7, 31);
        expect(IndianDateUtils.daysUntilDeadline(deadline, from: today), 0);
      });

      test('returns negative number for past deadline', () {
        final today = DateTime(2025, 8, 5);
        final deadline = DateTime(2025, 7, 31);
        expect(IndianDateUtils.daysUntilDeadline(deadline, from: today), -5);
      });

      test('handles cross-month calculation', () {
        final today = DateTime(2025, 6, 15);
        final deadline = DateTime(2025, 8, 15);
        expect(IndianDateUtils.daysUntilDeadline(deadline, from: today), 61);
      });

      test('handles cross-year calculation', () {
        final today = DateTime(2025, 12, 25);
        final deadline = DateTime(2026, 1, 5);
        expect(IndianDateUtils.daysUntilDeadline(deadline, from: today), 11);
      });
    });

    group('isOverdue', () {
      test('returns true when deadline is in the past', () {
        final today = DateTime(2025, 8, 1);
        final deadline = DateTime(2025, 7, 31);
        expect(IndianDateUtils.isOverdue(deadline, from: today), isTrue);
      });

      test('returns false when deadline is today', () {
        final today = DateTime(2025, 7, 31);
        final deadline = DateTime(2025, 7, 31);
        expect(IndianDateUtils.isOverdue(deadline, from: today), isFalse);
      });

      test('returns false when deadline is in the future', () {
        final today = DateTime(2025, 7, 1);
        final deadline = DateTime(2025, 7, 31);
        expect(IndianDateUtils.isOverdue(deadline, from: today), isFalse);
      });

      test('returns true when deadline is far in the past', () {
        final today = DateTime(2025, 12, 31);
        final deadline = DateTime(2025, 1, 1);
        expect(IndianDateUtils.isOverdue(deadline, from: today), isTrue);
      });
    });

    group('formatRelativeDate', () {
      test('returns "Today" for today\'s date', () {
        final today = DateTime(2025, 7, 15);
        expect(IndianDateUtils.formatRelativeDate(today, from: today), 'Today');
      });

      test('returns "Yesterday" for yesterday\'s date', () {
        final today = DateTime(2025, 7, 15);
        final yesterday = DateTime(2025, 7, 14);
        expect(
          IndianDateUtils.formatRelativeDate(yesterday, from: today),
          'Yesterday',
        );
      });

      test('returns "X days ago" for dates within the last week', () {
        final today = DateTime(2025, 7, 15);
        final threeDaysAgo = DateTime(2025, 7, 12);
        expect(
          IndianDateUtils.formatRelativeDate(threeDaysAgo, from: today),
          '3 days ago',
        );
      });

      test('returns "X days ago" for 6 days ago', () {
        final today = DateTime(2025, 7, 15);
        final sixDaysAgo = DateTime(2025, 7, 9);
        expect(
          IndianDateUtils.formatRelativeDate(sixDaysAgo, from: today),
          '6 days ago',
        );
      });

      test('returns formatted date for dates older than a week', () {
        final today = DateTime(2025, 7, 15);
        final oldDate = DateTime(2025, 6, 1);
        // Should fall back to formatIndianDate for older dates
        expect(
          IndianDateUtils.formatRelativeDate(oldDate, from: today),
          '01/06/2025',
        );
      });

      test('returns "Tomorrow" for tomorrow\'s date', () {
        final today = DateTime(2025, 7, 15);
        final tomorrow = DateTime(2025, 7, 16);
        expect(
          IndianDateUtils.formatRelativeDate(tomorrow, from: today),
          'Tomorrow',
        );
      });

      test('returns "In X days" for near future dates', () {
        final today = DateTime(2025, 7, 15);
        final inThreeDays = DateTime(2025, 7, 18);
        expect(
          IndianDateUtils.formatRelativeDate(inThreeDays, from: today),
          'In 3 days',
        );
      });
    });
  });
}

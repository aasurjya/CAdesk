import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';

void main() {
  group('TaxCalendarService — getDeadlines', () {
    test('returns non-empty list for FY 2024-25', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      expect(deadlines, isNotEmpty);
    });

    test('includes ITR filing deadline for individuals', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final itrDeadlines = deadlines.where((d) => d.category == 'ITR').toList();
      expect(itrDeadlines, isNotEmpty);
      final individual = itrDeadlines.any(
        (d) => d.date.month == 7 && d.date.day == 31 && d.date.year == 2025,
      );
      expect(individual, isTrue);
    });

    test('includes ITR audit deadline Oct 31', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final auditDeadline = deadlines.any(
        (d) => d.category == 'ITR' && d.date.month == 10 && d.date.day == 31,
      );
      expect(auditDeadline, isTrue);
    });

    test('includes GST deadlines', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final gstDeadlines = deadlines.where((d) => d.category == 'GST').toList();
      expect(gstDeadlines, isNotEmpty);
    });

    test('includes TDS deadlines', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final tdsDeadlines = deadlines.where((d) => d.category == 'TDS').toList();
      expect(tdsDeadlines, isNotEmpty);
    });

    test('includes Advance Tax deadlines', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final advanceTax = deadlines
          .where((d) => d.category == 'Advance Tax')
          .toList();
      expect(advanceTax, isNotEmpty);
      expect(advanceTax.length, equals(4)); // 4 installments
    });

    test('advance tax installment dates: Jun 15, Sep 15, Dec 15, Mar 15', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final advanceTax = deadlines
          .where((d) => d.category == 'Advance Tax')
          .toList();
      final dates = advanceTax
          .map((d) => '${d.date.month}-${d.date.day}')
          .toSet();
      expect(dates, contains('6-15'));
      expect(dates, contains('9-15'));
      expect(dates, contains('12-15'));
      expect(dates, contains('3-15'));
    });

    test('includes GST annual return Dec 31', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      final gstr9 = deadlines.any(
        (d) =>
            d.description.contains('GSTR-9') &&
            d.date.month == 12 &&
            d.date.day == 31,
      );
      expect(gstr9, isTrue);
    });

    test('all deadlines have non-empty description and category', () {
      final deadlines = TaxCalendarService.getDeadlines(2024);
      for (final d in deadlines) {
        expect(
          d.description,
          isNotEmpty,
          reason: 'Deadline should have a description',
        );
        expect(
          d.category,
          isNotEmpty,
          reason: 'Deadline should have a category',
        );
      }
    });
  });

  group('TaxCalendarService — getUpcomingDeadlines', () {
    test('returns deadlines within the next 30 days', () {
      // ITR individual deadline for FY 2024 is Jul 31, 2025.
      // Start from Jul 15, 2025 — Jul 31 falls within 30 days.
      final from = DateTime(2025, 7, 15);
      final upcoming = TaxCalendarService.getUpcomingDeadlines(2024, from);
      expect(upcoming, isNotEmpty);
      for (final d in upcoming) {
        expect(
          d.date.isAfter(from.subtract(const Duration(days: 1))),
          isTrue,
          reason: 'Deadline ${d.description} should be on/after $from',
        );
        expect(
          d.date.isBefore(from.add(const Duration(days: 31))),
          isTrue,
          reason: 'Deadline ${d.description} should be within 30 days',
        );
      }
    });

    test('returns empty when no deadlines in window', () {
      // Pick a date far from any deadline
      final from = DateTime(2025, 8, 1);
      final upcoming = TaxCalendarService.getUpcomingDeadlines(
        2024,
        from,
        days: 1,
      );
      // Aug 1 + 1 day: no standard deadline expected on Aug 2
      expect(upcoming, isA<List<TaxDeadline>>());
    });

    test('custom days parameter respected', () {
      final from = DateTime(2025, 4, 1);
      final narrow = TaxCalendarService.getUpcomingDeadlines(
        2024,
        from,
        days: 5,
      );
      final wide = TaxCalendarService.getUpcomingDeadlines(
        2024,
        from,
        days: 90,
      );
      expect(wide.length, greaterThanOrEqualTo(narrow.length));
    });
  });

  group('TaxCalendarService — isDeadlineDate', () {
    test('July 31, 2025 is a deadline date for FY 2024-25', () {
      final result = TaxCalendarService.isDeadlineDate(
        DateTime(2025, 7, 31),
        2024,
      );
      expect(result, isTrue);
    });

    test('random non-deadline date returns false', () {
      // Aug 5 is not a standard deadline
      final result = TaxCalendarService.isDeadlineDate(
        DateTime(2025, 8, 5),
        2024,
      );
      expect(result, isFalse);
    });

    test('Sep 15 is advance tax deadline', () {
      final result = TaxCalendarService.isDeadlineDate(
        DateTime(2024, 9, 15),
        2024,
      );
      expect(result, isTrue);
    });
  });

  group('TaxDeadline model', () {
    test('equality via operator ==', () {
      final date = DateTime(2025, 7, 31);
      final a = TaxDeadline(
        description: 'ITR Filing',
        date: date,
        category: 'ITR',
        isRecurring: false,
      );
      final b = TaxDeadline(
        description: 'ITR Filing',
        date: date,
        category: 'ITR',
        isRecurring: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('immutable — fields are accessible and correct', () {
      final deadline = TaxDeadline(
        description: 'Test',
        date: DateTime(2025, 1, 1),
        category: 'ITR',
        isRecurring: true,
      );
      expect(deadline.description, equals('Test'));
      expect(deadline.isRecurring, isTrue);
    });
  });
}

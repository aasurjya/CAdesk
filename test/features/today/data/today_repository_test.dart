import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/today/data/repositories/mock_today_repository.dart';

void main() {
  group('MockTodayRepository', () {
    late MockTodayRepository repo;

    setUp(() {
      repo = MockTodayRepository();
    });

    group('getTodaySummary', () {
      test('returns a non-null summary', () async {
        final result = await repo.getTodaySummary();
        expect(result, isNotNull);
      });

      test('date is today', () async {
        final result = await repo.getTodaySummary();
        final today = DateTime.now();
        expect(result.date.year, today.year);
        expect(result.date.month, today.month);
        expect(result.date.day, today.day);
      });

      test('counts are non-negative', () async {
        final result = await repo.getTodaySummary();
        expect(result.overdueCount, greaterThanOrEqualTo(0));
        expect(result.dueTodayCount, greaterThanOrEqualTo(0));
        expect(result.dueThisWeekCount, greaterThanOrEqualTo(0));
        expect(result.completedTodayCount, greaterThanOrEqualTo(0));
      });
    });

    group('getSummaryForDate', () {
      test('returns summary for specific date', () async {
        final date = DateTime(2026, 3, 14);
        final result = await repo.getSummaryForDate(date);
        expect(result, isNotNull);
        expect(result!.date.year, 2026);
        expect(result.date.month, 3);
        expect(result.date.day, 14);
      });
    });

    group('TodaySummary model', () {
      test('hasOverdue is true when overdueCount > 0', () async {
        final summary = await repo.getTodaySummary();
        if (summary.overdueCount > 0) {
          expect(summary.hasOverdue, isTrue);
        } else {
          expect(summary.hasOverdue, isFalse);
        }
      });

      test('copyWith returns new instance with updated fields', () async {
        final summary = await repo.getTodaySummary();
        final updated = summary.copyWith(overdueCount: 99);
        expect(updated.overdueCount, 99);
        expect(updated.dueTodayCount, summary.dueTodayCount);
      });
    });
  });
}

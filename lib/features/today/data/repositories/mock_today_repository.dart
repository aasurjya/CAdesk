import 'package:ca_app/features/today/domain/models/today_summary.dart';
import 'package:ca_app/features/today/domain/repositories/today_repository.dart';

/// In-memory mock implementation of [TodayRepository].
///
/// Returns deterministic sample data for development and testing.
class MockTodayRepository implements TodayRepository {
  @override
  Future<TodaySummary?> getSummaryForDate(DateTime date) async {
    return TodaySummary(
      overdueCount: 2,
      dueTodayCount: 5,
      dueThisWeekCount: 12,
      completedTodayCount: 3,
      date: DateTime(date.year, date.month, date.day),
    );
  }

  @override
  Future<TodaySummary> getTodaySummary() async {
    final today = DateTime.now();
    return TodaySummary(
      overdueCount: 2,
      dueTodayCount: 5,
      dueThisWeekCount: 12,
      completedTodayCount: 3,
      date: DateTime(today.year, today.month, today.day),
    );
  }
}

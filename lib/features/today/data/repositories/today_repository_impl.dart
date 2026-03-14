import 'package:ca_app/features/today/domain/models/today_summary.dart';
import 'package:ca_app/features/today/domain/repositories/today_repository.dart';

/// Real implementation of [TodayRepository].
///
/// Full Drift/Supabase wiring is deferred until the portal integration phase.
class TodayRepositoryImpl implements TodayRepository {
  const TodayRepositoryImpl();

  @override
  Future<TodaySummary?> getSummaryForDate(DateTime date) async => null;

  @override
  Future<TodaySummary> getTodaySummary() async {
    final today = DateTime.now();
    return TodaySummary(
      overdueCount: 0,
      dueTodayCount: 0,
      dueThisWeekCount: 0,
      completedTodayCount: 0,
      date: DateTime(today.year, today.month, today.day),
    );
  }
}

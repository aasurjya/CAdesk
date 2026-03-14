import 'package:ca_app/features/today/domain/models/today_summary.dart';

/// Abstract contract for Today screen data operations.
///
/// Provides aggregated daily summaries for the CA's workload.
abstract class TodayRepository {
  /// Retrieve the summary for [date]. Returns null if unavailable.
  Future<TodaySummary?> getSummaryForDate(DateTime date);

  /// Retrieve the summary for today.
  Future<TodaySummary> getTodaySummary();
}

import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

abstract class TimeTrackingRepository {
  Future<String> insertEntry(TimeEntry entry);
  Future<List<TimeEntry>> getByClient(String clientId);
  Future<List<TimeEntry>> getByDateRange(DateTime from, DateTime to);
  Future<bool> updateEntry(TimeEntry entry);
  Future<bool> deleteEntry(String id);
  Future<List<TimeEntry>> getUnbilled(String clientId);

  /// Returns total hours for a client in the given month and year.
  Future<double> getTotalHours(String clientId, int month, int year);
}

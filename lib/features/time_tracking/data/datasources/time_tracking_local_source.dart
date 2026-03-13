import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/time_tracking/data/mappers/time_entry_mapper.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

class TimeTrackingLocalSource {
  const TimeTrackingLocalSource(this._db);

  final AppDatabase _db;

  Future<String> insertEntry(TimeEntry entry) =>
      _db.timeEntriesDao.insertEntry(TimeEntryMapper.toCompanion(entry));

  Future<List<TimeEntry>> getByClient(String clientId) async {
    final rows = await _db.timeEntriesDao.getByClient(clientId);
    return rows.map(TimeEntryMapper.fromRow).toList();
  }

  Future<List<TimeEntry>> getByDateRange(DateTime from, DateTime to) async {
    final rows = await _db.timeEntriesDao.getByDateRange(from, to);
    return rows.map(TimeEntryMapper.fromRow).toList();
  }

  Future<bool> updateEntry(TimeEntry entry) =>
      _db.timeEntriesDao.updateEntry(TimeEntryMapper.toCompanion(entry));

  Future<bool> deleteEntry(String id) => _db.timeEntriesDao.deleteEntry(id);

  Future<List<TimeEntry>> getUnbilled(String clientId) async {
    final rows = await _db.timeEntriesDao.getUnbilled(clientId);
    return rows.map(TimeEntryMapper.fromRow).toList();
  }

  Future<double> getTotalHours(String clientId, int month, int year) async {
    final rows =
        await _db.timeEntriesDao.getEntriesForMonth(clientId, month, year);
    final totalMinutes = rows.fold<int>(0, (sum, r) => sum + r.durationMinutes);
    return totalMinutes / 60.0;
  }
}

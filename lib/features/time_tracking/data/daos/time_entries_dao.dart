import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/time_entries_table.dart';

part 'time_entries_dao.g.dart';

@DriftAccessor(tables: [TimeEntriesTable])
class TimeEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$TimeEntriesDaoMixin {
  TimeEntriesDao(super.db);

  /// Insert a new time entry and return its ID.
  Future<String> insertEntry(TimeEntriesTableCompanion companion) async {
    await into(timeEntriesTable).insert(companion);
    return companion.id.value;
  }

  /// Get all entries for a client ordered by start time descending.
  Future<List<TimeEntryRow>> getByClient(String clientId) =>
      (select(timeEntriesTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  /// Get entries where start time falls within [from, to].
  Future<List<TimeEntryRow>> getByDateRange(DateTime from, DateTime to) =>
      (select(timeEntriesTable)
            ..where(
              (t) =>
                  t.startTime.isBiggerOrEqualValue(from) &
                  t.startTime.isSmallerOrEqualValue(to),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  /// Get all unbilled entries for a client.
  Future<List<TimeEntryRow>> getUnbilled(String clientId) =>
      (select(timeEntriesTable)
            ..where(
              (t) => t.clientId.equals(clientId) & t.isBilled.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  /// Get a single entry by ID.
  Future<TimeEntryRow?> getEntryById(String id) => (select(
    timeEntriesTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Update a time entry.
  /// Returns true if a row was affected.
  Future<bool> updateEntry(TimeEntriesTableCompanion companion) async {
    final rowsAffected = await (update(
      timeEntriesTable,
    )..where((t) => t.id.equals(companion.id.value))).write(companion);
    return rowsAffected > 0;
  }

  /// Delete an entry by ID.
  /// Returns true if a row was affected.
  Future<bool> deleteEntry(String id) async {
    final rowsAffected = await (delete(
      timeEntriesTable,
    )..where((t) => t.id.equals(id))).go();
    return rowsAffected > 0;
  }

  /// Get entries for a client within a specific month and year (for total hours).
  Future<List<TimeEntryRow>> getEntriesForMonth(
    String clientId,
    int month,
    int year,
  ) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1).subtract(const Duration(seconds: 1));
    return (select(timeEntriesTable)..where(
          (t) =>
              t.clientId.equals(clientId) &
              t.startTime.isBiggerOrEqualValue(start) &
              t.startTime.isSmallerOrEqualValue(end),
        ))
        .get();
  }
}

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/compliance_events_table.dart';

part 'compliance_dao.g.dart';

@DriftAccessor(tables: [ComplianceEventsTable])
class ComplianceDao extends DatabaseAccessor<AppDatabase> with _$ComplianceDaoMixin {
  ComplianceDao(super.db);

  /// Insert a new compliance event and return its ID
  Future<String> insertEvent(ComplianceEventsTableCompanion companion) async {
    await into(complianceEventsTable).insert(companion);
    final rows = await (select(complianceEventsTable)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
            ..limit(1))
        .get();
    return rows.isNotEmpty ? rows.first.id : '';
  }

  /// Get all compliance events for a specific client
  Future<List<ComplianceEventRow>> getEventsByClient(String clientId) =>
      (select(complianceEventsTable)..where((t) => t.clientId.equals(clientId)))
          .get();

  /// Watch compliance events for a specific client (real-time updates)
  Stream<List<ComplianceEventRow>> watchEventsByClient(String clientId) =>
      (select(complianceEventsTable)..where((t) => t.clientId.equals(clientId))).watch();

  /// Get a specific compliance event by ID
  Future<ComplianceEventRow?> getEventById(String eventId) =>
      (select(complianceEventsTable)..where((t) => t.id.equals(eventId)))
          .getSingleOrNull();

  /// Get upcoming compliance events within the specified number of days
  /// Excludes completed events
  Future<List<ComplianceEventRow>> getUpcomingEvents(int daysAhead) async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final futureMidnight = todayMidnight.add(Duration(days: daysAhead));

    return (select(complianceEventsTable)
          ..where((t) =>
              t.dueDate.isBetweenValues(todayMidnight, futureMidnight) &
              t.status.isNotValue('completed')))
        .get();
  }

  /// Get all overdue compliance events (dueDate < today, status != completed)
  Future<List<ComplianceEventRow>> getOverdueEvents() async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    return (select(complianceEventsTable)
          ..where((t) =>
              t.dueDate.isSmallerThanValue(todayMidnight) &
              t.status.isNotValue('completed')))
        .get();
  }

  /// Update the status of a compliance event
  Future<bool> updateEventStatus(String eventId, String status) async {
    final rowsAffected = await (update(complianceEventsTable)
          ..where((t) => t.id.equals(eventId)))
        .write(
          ComplianceEventsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Get all compliance events of a specific type
  Future<List<ComplianceEventRow>> getEventsByType(String type) =>
      (select(complianceEventsTable)..where((t) => t.type.equals(type))).get();

  /// Update a compliance event
  Future<bool> updateEvent(ComplianceEventsTableCompanion companion) =>
      update(complianceEventsTable).replace(companion);

  /// Delete a compliance event
  Future<bool> deleteEvent(String eventId) async {
    final result = await (delete(complianceEventsTable)..where((t) => t.id.equals(eventId))).go();
    return result > 0;
  }
}

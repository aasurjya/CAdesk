import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/compliance/data/mappers/compliance_mapper.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';

/// Local data source for compliance events (SQLite via Drift)
class ComplianceLocalSource {
  const ComplianceLocalSource(this._db);

  final AppDatabase _db;

  /// Insert a new compliance event
  Future<String> insertEvent(ComplianceEvent event) async {
    return _db.complianceDao.insertEvent(ComplianceMapper.toCompanion(event));
  }

  /// Get all compliance events for a specific client
  Future<List<ComplianceEvent>> getEventsByClient(String clientId) async {
    final rows = await _db.complianceDao.getEventsByClient(clientId);
    return rows.map(ComplianceMapper.fromRow).toList();
  }

  /// Get upcoming compliance events within the specified number of days
  Future<List<ComplianceEvent>> getUpcomingEvents(int daysAhead) async {
    final rows = await _db.complianceDao.getUpcomingEvents(daysAhead);
    return rows.map(ComplianceMapper.fromRow).toList();
  }

  /// Get all overdue compliance events
  Future<List<ComplianceEvent>> getOverdueEvents() async {
    final rows = await _db.complianceDao.getOverdueEvents();
    return rows.map(ComplianceMapper.fromRow).toList();
  }

  /// Update the status of a compliance event
  Future<bool> updateEventStatus(
    String eventId,
    ComplianceEventStatus status,
  ) => _db.complianceDao.updateEventStatus(eventId, status.name);

  /// Get all compliance events of a specific type
  Future<List<ComplianceEvent>> getEventsByType(
    ComplianceEventType type,
  ) async {
    final rows = await _db.complianceDao.getEventsByType(type.name);
    return rows.map(ComplianceMapper.fromRow).toList();
  }

  /// Get a specific compliance event by ID
  Future<ComplianceEvent?> getEventById(String eventId) async {
    final row = await _db.complianceDao.getEventById(eventId);
    return row != null ? ComplianceMapper.fromRow(row) : null;
  }

  /// Update a compliance event
  Future<bool> updateEvent(ComplianceEvent event) =>
      _db.complianceDao.updateEvent(ComplianceMapper.toCompanion(event));

  /// Delete a compliance event
  Future<bool> deleteEvent(String eventId) =>
      _db.complianceDao.deleteEvent(eventId);

  /// Watch compliance events for a specific client (real-time updates)
  Stream<List<ComplianceEvent>> watchEventsByClient(String clientId) {
    return _db.complianceDao
        .watchEventsByClient(clientId)
        .map((rows) => rows.map(ComplianceMapper.fromRow).toList());
  }
}

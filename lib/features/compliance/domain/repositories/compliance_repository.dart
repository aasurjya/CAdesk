import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';

/// Repository interface for compliance event data access.
abstract class ComplianceRepository {
  /// Insert a new compliance event and return its ID.
  Future<String> insertEvent(ComplianceEvent event);

  /// Get all compliance events for a specific client.
  Future<List<ComplianceEvent>> getEventsByClient(String clientId);

  /// Get upcoming compliance events within the specified number of days.
  /// Used for dashboard and alerts.
  Future<List<ComplianceEvent>> getUpcomingEvents(int daysAhead);

  /// Get all overdue compliance events.
  Future<List<ComplianceEvent>> getOverdueEvents();

  /// Update the status of a compliance event.
  Future<bool> updateEventStatus(String eventId, ComplianceEventStatus status);

  /// Get all compliance events of a specific type.
  Future<List<ComplianceEvent>> getEventsByType(ComplianceEventType type);

  /// Get a specific compliance event by ID.
  Future<ComplianceEvent?> getEventById(String eventId);

  /// Update a compliance event.
  Future<bool> updateEvent(ComplianceEvent event);

  /// Delete a compliance event.
  Future<bool> deleteEvent(String eventId);

  /// Watch compliance events for a specific client (real-time updates).
  Stream<List<ComplianceEvent>> watchEventsByClient(String clientId);
}

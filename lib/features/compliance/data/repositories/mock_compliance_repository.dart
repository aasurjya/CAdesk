import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';
import 'package:ca_app/features/compliance/domain/repositories/compliance_repository.dart';

/// Mock implementation of ComplianceRepository for testing and offline mode
class MockComplianceRepository implements ComplianceRepository {
  MockComplianceRepository() : _events = <String, ComplianceEvent>{};

  final Map<String, ComplianceEvent> _events;

  @override
  Future<String> insertEvent(ComplianceEvent event) async {
    _events[event.id] = event;
    return event.id;
  }

  @override
  Future<List<ComplianceEvent>> getEventsByClient(String clientId) async {
    return _events.values.where((e) => e.clientId == clientId).toList();
  }

  @override
  Future<List<ComplianceEvent>> getUpcomingEvents(int daysAhead) async {
    final today = DateTime.now();
    final futureDate = today.add(Duration(days: daysAhead));
    return _events.values
        .where(
          (e) =>
              e.dueDate.isAfter(today) &&
              e.dueDate.isBefore(futureDate) &&
              e.status != ComplianceEventStatus.completed,
        )
        .toList();
  }

  @override
  Future<List<ComplianceEvent>> getOverdueEvents() async {
    final today = DateTime.now();
    return _events.values
        .where(
          (e) =>
              e.dueDate.isBefore(today) &&
              e.status != ComplianceEventStatus.completed,
        )
        .toList();
  }

  @override
  Future<bool> updateEventStatus(
    String eventId,
    ComplianceEventStatus status,
  ) async {
    final event = _events[eventId];
    if (event == null) return false;
    _events[eventId] = event.copyWith(status: status);
    return true;
  }

  @override
  Future<List<ComplianceEvent>> getEventsByType(
    ComplianceEventType type,
  ) async {
    return _events.values.where((e) => e.type == type).toList();
  }

  @override
  Future<ComplianceEvent?> getEventById(String eventId) async {
    return _events[eventId];
  }

  @override
  Future<bool> updateEvent(ComplianceEvent event) async {
    if (!_events.containsKey(event.id)) return false;
    _events[event.id] = event;
    return true;
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    if (!_events.containsKey(eventId)) return false;
    _events.remove(eventId);
    return true;
  }

  @override
  Stream<List<ComplianceEvent>> watchEventsByClient(String clientId) async* {
    final events = await getEventsByClient(clientId);
    yield List.unmodifiable(events);
  }
}

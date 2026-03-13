import 'package:ca_app/features/compliance/data/datasources/compliance_local_source.dart';
import 'package:ca_app/features/compliance/data/datasources/compliance_remote_source.dart';
import 'package:ca_app/features/compliance/data/mappers/compliance_mapper.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';
import 'package:ca_app/features/compliance/domain/repositories/compliance_repository.dart';

/// Implementation of ComplianceRepository with fallback to local cache on network error.
class ComplianceRepositoryImpl implements ComplianceRepository {
  const ComplianceRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final ComplianceRemoteSource remote;
  final ComplianceLocalSource local;

  @override
  Future<String> insertEvent(ComplianceEvent event) async {
    try {
      final json = await remote.insertEvent(ComplianceMapper.toJson(event));
      final inserted = ComplianceMapper.fromJson(json);
      // Cache locally after successful remote insert
      await local.insertEvent(inserted);
      return inserted.id;
    } catch (_) {
      // Fallback to local insert on network failure
      return local.insertEvent(event);
    }
  }

  @override
  Future<List<ComplianceEvent>> getEventsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchEventsByClient(clientId);
      final events = jsonList.map(ComplianceMapper.fromJson).toList();
      // Cache locally
      for (final event in events) {
        await local.insertEvent(event);
      }
      return List.unmodifiable(events);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getEventsByClient(clientId);
    }
  }

  @override
  Future<List<ComplianceEvent>> getUpcomingEvents(int daysAhead) async {
    try {
      final jsonList = await remote.fetchUpcomingEvents(daysAhead);
      final events = jsonList.map(ComplianceMapper.fromJson).toList();
      // Cache locally
      for (final event in events) {
        await local.insertEvent(event);
      }
      return List.unmodifiable(events);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getUpcomingEvents(daysAhead);
    }
  }

  @override
  Future<List<ComplianceEvent>> getOverdueEvents() async {
    try {
      final jsonList = await remote.fetchOverdueEvents();
      final events = jsonList.map(ComplianceMapper.fromJson).toList();
      // Cache locally
      for (final event in events) {
        await local.insertEvent(event);
      }
      return List.unmodifiable(events);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getOverdueEvents();
    }
  }

  @override
  Future<bool> updateEventStatus(String eventId, ComplianceEventStatus status) async {
    try {
      await remote.updateEventStatus(eventId, status.name);
      return local.updateEventStatus(eventId, status);
    } catch (_) {
      // Fallback to local update on network failure
      return local.updateEventStatus(eventId, status);
    }
  }

  @override
  Future<List<ComplianceEvent>> getEventsByType(ComplianceEventType type) async {
    try {
      final jsonList = await remote.fetchEventsByType(type.name);
      final events = jsonList.map(ComplianceMapper.fromJson).toList();
      // Cache locally
      for (final event in events) {
        await local.insertEvent(event);
      }
      return List.unmodifiable(events);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getEventsByType(type);
    }
  }

  @override
  Future<ComplianceEvent?> getEventById(String eventId) async {
    try {
      final json = await remote.fetchEventById(eventId);
      if (json == null) return null;
      final event = ComplianceMapper.fromJson(json);
      await local.insertEvent(event);
      return event;
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getEventById(eventId);
    }
  }

  @override
  Future<bool> updateEvent(ComplianceEvent event) async {
    try {
      final json = await remote.updateEvent(event.id, ComplianceMapper.toJson(event));
      final updated = ComplianceMapper.fromJson(json);
      await local.updateEvent(updated);
      return true;
    } catch (_) {
      // Fallback to local update on network failure
      return local.updateEvent(event);
    }
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    try {
      await remote.deleteEvent(eventId);
      await local.deleteEvent(eventId);
      return true;
    } catch (_) {
      // Fallback to local delete on network failure
      return local.deleteEvent(eventId);
    }
  }

  @override
  Stream<List<ComplianceEvent>> watchEventsByClient(String clientId) {
    return local.watchEventsByClient(clientId);
  }
}

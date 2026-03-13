import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for compliance events (Supabase REST API)
class ComplianceRemoteSource {
  const ComplianceRemoteSource(this._client);

  final SupabaseClient _client;

  /// Insert a new compliance event
  Future<Map<String, dynamic>> insertEvent(Map<String, dynamic> data) async {
    return _client
        .from('compliance_events')
        .insert(data)
        .select()
        .single();
  }

  /// Get all compliance events for a specific client
  Future<List<Map<String, dynamic>>> fetchEventsByClient(String clientId) async {
    return _client
        .from('compliance_events')
        .select()
        .eq('client_id', clientId)
        .order('due_date', ascending: true);
  }

  /// Get upcoming compliance events within the specified number of days
  Future<List<Map<String, dynamic>>> fetchUpcomingEvents(int daysAhead) async {
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final futureStr = DateTime(today.year, today.month, today.day + daysAhead).toIso8601String();

    return _client
        .from('compliance_events')
        .select()
        .gte('due_date', todayStr)
        .lte('due_date', futureStr)
        .neq('status', 'completed')
        .order('due_date', ascending: true);
  }

  /// Get all overdue compliance events
  Future<List<Map<String, dynamic>>> fetchOverdueEvents() async {
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();

    return _client
        .from('compliance_events')
        .select()
        .lt('due_date', todayStr)
        .neq('status', 'completed')
        .order('due_date', ascending: true);
  }

  /// Update the status of a compliance event
  Future<Map<String, dynamic>> updateEventStatus(
    String eventId,
    String status,
  ) async {
    return _client
        .from('compliance_events')
        .update({'status': status})
        .eq('id', eventId)
        .select()
        .single();
  }

  /// Get all compliance events of a specific type
  Future<List<Map<String, dynamic>>> fetchEventsByType(String type) async {
    return _client
        .from('compliance_events')
        .select()
        .eq('type', type)
        .order('due_date', ascending: true);
  }

  /// Get a specific compliance event by ID
  Future<Map<String, dynamic>?> fetchEventById(String eventId) async {
    try {
      return _client
          .from('compliance_events')
          .select()
          .eq('id', eventId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  /// Update a compliance event
  Future<Map<String, dynamic>> updateEvent(
    String eventId,
    Map<String, dynamic> data,
  ) async {
    return _client
        .from('compliance_events')
        .update(data)
        .eq('id', eventId)
        .select()
        .single();
  }

  /// Delete a compliance event
  Future<void> deleteEvent(String eventId) async {
    await _client.from('compliance_events').delete().eq('id', eventId);
  }
}

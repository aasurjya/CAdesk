import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for user sessions and guest links backed by Supabase.
class CollaborationRemoteSource {
  const CollaborationRemoteSource(this._client);

  final SupabaseClient _client;

  static const _sessionsTable = 'user_sessions';
  static const _linksTable = 'guest_links';

  // ── UserSession ────────────────────────────────────────────────────────────

  /// Fetch all user sessions.
  Future<List<Map<String, dynamic>>> fetchAllSessions() async {
    final response = await _client
        .from(_sessionsTable)
        .select()
        .order('login_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single user session by [sessionId].
  Future<Map<String, dynamic>?> fetchSessionById(String sessionId) async {
    final response = await _client
        .from(_sessionsTable)
        .select()
        .eq('id', sessionId)
        .maybeSingle();
    return response;
  }

  /// Fetch only active sessions (online or idle).
  Future<List<Map<String, dynamic>>> fetchActiveSessions() async {
    final response = await _client
        .from(_sessionsTable)
        .select()
        .inFilter('presence', ['online', 'idle'])
        .order('last_activity', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new user session. Returns the persisted row.
  Future<Map<String, dynamic>> insertSession(Map<String, dynamic> data) async {
    final response = await _client
        .from(_sessionsTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing user session by [sessionId]. Returns the updated row.
  Future<Map<String, dynamic>> updateSession(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_sessionsTable)
        .update(data)
        .eq('id', sessionId)
        .select()
        .single();
    return response;
  }

  /// Delete a user session by [sessionId].
  Future<void> deleteSession(String sessionId) async {
    await _client.from(_sessionsTable).delete().eq('id', sessionId);
  }

  // ── GuestLink ──────────────────────────────────────────────────────────────

  /// Fetch all guest links.
  Future<List<Map<String, dynamic>>> fetchAllGuestLinks() async {
    final response = await _client
        .from(_linksTable)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single guest link by [linkId].
  Future<Map<String, dynamic>?> fetchGuestLinkById(String linkId) async {
    final response = await _client
        .from(_linksTable)
        .select()
        .eq('id', linkId)
        .maybeSingle();
    return response;
  }

  /// Insert a new guest link. Returns the persisted row.
  Future<Map<String, dynamic>> insertGuestLink(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_linksTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing guest link by [linkId]. Returns the updated row.
  Future<Map<String, dynamic>> updateGuestLink(
    String linkId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_linksTable)
        .update(data)
        .eq('id', linkId)
        .select()
        .single();
    return response;
  }

  /// Delete a guest link by [linkId].
  Future<void> deleteGuestLink(String linkId) async {
    await _client.from(_linksTable).delete().eq('id', linkId);
  }
}

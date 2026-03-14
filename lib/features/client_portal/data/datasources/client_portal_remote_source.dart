import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for client portal messages and queries backed by Supabase.
class ClientPortalRemoteSource {
  const ClientPortalRemoteSource(this._client);

  final SupabaseClient _client;

  static const _messagesTable = 'portal_messages';
  static const _queriesTable = 'client_queries';

  // ── Portal Messages ────────────────────────────────────────────────────────

  /// Fetch all messages in a [threadId].
  Future<List<Map<String, dynamic>>> fetchMessagesByThread(
    String threadId,
  ) async {
    final response = await _client
        .from(_messagesTable)
        .select()
        .eq('thread_id', threadId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch all portal messages.
  Future<List<Map<String, dynamic>>> fetchAllMessages() async {
    final response = await _client
        .from(_messagesTable)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new portal message. Returns the persisted row.
  Future<Map<String, dynamic>> insertMessage(Map<String, dynamic> data) async {
    final response = await _client
        .from(_messagesTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing portal message by [id]. Returns the updated row.
  Future<Map<String, dynamic>> updateMessage(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_messagesTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a portal message by [id].
  Future<void> deleteMessage(String id) async {
    await _client.from(_messagesTable).delete().eq('id', id);
  }

  // ── Client Queries ─────────────────────────────────────────────────────────

  /// Fetch all client queries for a [clientId].
  Future<List<Map<String, dynamic>>> fetchQueriesByClient(
    String clientId,
  ) async {
    final response = await _client
        .from(_queriesTable)
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single client query by [queryId].
  Future<Map<String, dynamic>?> fetchQueryById(String queryId) async {
    final response = await _client
        .from(_queriesTable)
        .select()
        .eq('id', queryId)
        .maybeSingle();
    return response;
  }

  /// Insert a new client query. Returns the persisted row.
  Future<Map<String, dynamic>> insertQuery(Map<String, dynamic> data) async {
    final response = await _client
        .from(_queriesTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing client query by [queryId]. Returns the updated row.
  Future<Map<String, dynamic>> updateQuery(
    String queryId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_queriesTable)
        .update(data)
        .eq('id', queryId)
        .select()
        .single();
    return response;
  }

  /// Delete a client query by [queryId].
  Future<void> deleteQuery(String queryId) async {
    await _client.from(_queriesTable).delete().eq('id', queryId);
  }
}

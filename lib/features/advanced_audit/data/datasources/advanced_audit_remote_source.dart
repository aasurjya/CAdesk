import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for audit engagements backed by Supabase.
///
/// Operates against the `audit_engagements` table.
class AdvancedAuditRemoteSource {
  const AdvancedAuditRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'audit_engagements';

  /// Fetch all audit engagements for a [clientId].
  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single audit engagement by [id].
  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Fetch all audit engagements.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new audit engagement. Returns the persisted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing audit engagement by [id]. Returns the updated row.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete an audit engagement by [id].
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

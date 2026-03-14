import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for tax queries backed by Supabase.
///
/// Operates against the `tax_queries` table.
class CaGptRemoteSource {
  const CaGptRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'tax_queries';

  /// Fetch all tax queries.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('timestamp', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single tax query by [queryId].
  Future<Map<String, dynamic>?> fetchById(String queryId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('query_id', queryId)
        .maybeSingle();
    return response;
  }

  /// Fetch all tax queries of a specific [queryType].
  Future<List<Map<String, dynamic>>> fetchByType(String queryType) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('query_type', queryType)
        .order('timestamp', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new tax query. Returns the persisted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing tax query by [queryId]. Returns the updated row.
  Future<Map<String, dynamic>> update(
    String queryId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_table)
        .update(data)
        .eq('query_id', queryId)
        .select()
        .single();
    return response;
  }

  /// Delete a tax query by [queryId].
  Future<void> delete(String queryId) async {
    await _client.from(_table).delete().eq('query_id', queryId);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for CMA reports backed by Supabase.
///
/// Operates against the `cma_reports` table.
class CmaRemoteSource {
  const CmaRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'cma_reports';

  /// Fetch all CMA reports for a [clientId].
  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('prepared_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single CMA report by [id].
  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Fetch all CMA reports.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('prepared_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new CMA report. Returns the persisted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing CMA report by [id]. Returns the updated row.
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

  /// Delete a CMA report by [id].
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

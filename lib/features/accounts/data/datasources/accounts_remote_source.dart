import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for financial statements backed by Supabase.
///
/// Operates against the `financial_statements` table.
class AccountsRemoteSource {
  const AccountsRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'financial_statements';

  /// Fetch all statements for a [clientId] in a [financialYear].
  Future<List<Map<String, dynamic>>> fetchByClient(
    String clientId,
    String financialYear,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .eq('financial_year', financialYear)
        .order('prepared_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single statement by [id].
  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Fetch all statements.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('prepared_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new statement. Returns the persisted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing statement by [id]. Returns the updated row.
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

  /// Delete a statement by [id].
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

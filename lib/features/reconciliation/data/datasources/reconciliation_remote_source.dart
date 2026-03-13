import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_result.dart';

/// Remote data source for reconciliation results backed by Supabase.
///
/// Supabase table: `reconciliation_results`
class ReconciliationRemoteSource {
  const ReconciliationRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'reconciliation_results';

  /// Fetch all reconciliation results for a client.
  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch results by type and client.
  Future<List<Map<String, dynamic>>> fetchByType(
    ReconciliationType type,
    String clientId,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .eq('reconciliation_type', type.name)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single result by ID.
  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response =
        await _client.from(_table).select().eq('id', id).maybeSingle();
    return response;
  }

  /// Insert a new reconciliation result. Returns the created row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response =
        await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update a reconciliation result. Returns the updated row.
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

  /// Update only the status field.
  Future<bool> updateStatus(String id, String status) async {
    await _client
        .from(_table)
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
    return true;
  }

  /// Delete a reconciliation result.
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

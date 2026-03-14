import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for batch jobs backed by Supabase.
///
/// Operates against the `batch_jobs` table.
class BulkOperationsRemoteSource {
  const BulkOperationsRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'batch_jobs';

  /// Fetch all batch jobs.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single batch job by [jobId].
  Future<Map<String, dynamic>?> fetchById(String jobId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('job_id', jobId)
        .maybeSingle();
    return response;
  }

  /// Fetch all batch jobs with a specific [status].
  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new batch job. Returns the persisted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing batch job by [jobId]. Returns the updated row.
  Future<Map<String, dynamic>> update(
    String jobId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_table)
        .update(data)
        .eq('job_id', jobId)
        .select()
        .single();
    return response;
  }

  /// Delete a batch job by [jobId].
  Future<void> delete(String jobId) async {
    await _client.from(_table).delete().eq('job_id', jobId);
  }
}

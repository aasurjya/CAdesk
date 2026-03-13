import 'package:supabase_flutter/supabase_flutter.dart';

class ExportJobRemoteSource {
  const ExportJobRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('export_jobs')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from('export_jobs')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('export_jobs')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('export_jobs')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateStatus(
    String id,
    String status, {
    String? filePath,
    String? errorMessage,
    String? completedAt,
  }) async {
    final update = <String, dynamic>{'status': status};
    if (filePath != null) update['file_path'] = filePath;
    if (errorMessage != null) update['error_message'] = errorMessage;
    if (completedAt != null) update['completed_at'] = completedAt;

    final response = await _client
        .from('export_jobs')
        .update(update)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<int> deleteOldJobs(DateTime beforeDate) async {
    final response = await _client
        .from('export_jobs')
        .delete()
        .lt('created_at', beforeDate.toIso8601String())
        .select();
    return (response as List<dynamic>).length;
  }
}

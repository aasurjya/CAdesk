import 'package:supabase_flutter/supabase_flutter.dart';

class RpaRemoteSource {
  const RpaRemoteSource(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response =
        await _client.from('rpa_tasks').insert(data).select().single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('rpa_tasks')
        .select()
        .eq('client_id', clientId)
        .order('scheduled_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from('rpa_tasks')
        .select()
        .eq('status', status)
        .order('scheduled_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByType(String taskType) async {
    final response = await _client
        .from('rpa_tasks')
        .select()
        .eq('task_type', taskType)
        .order('scheduled_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateStatus(
    String id,
    String status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (startedAt != null) data['started_at'] = startedAt.toIso8601String();
    if (completedAt != null) {
      data['completed_at'] = completedAt.toIso8601String();
    }
    if (result != null) data['result'] = result;
    if (errorMessage != null) data['error_message'] = errorMessage;
    if (retryCount != null) data['retry_count'] = retryCount;
    await _client.from('rpa_tasks').update(data).eq('id', id);
  }
}

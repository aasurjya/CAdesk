import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

class TaskRemoteSource {
  const TaskRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from('tasks')
          .select()
          .eq('firm_id', firmId)
          .order('due_date');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client.from('tasks').select().order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchByClientId(String clientId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('client_id', clientId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(
    TaskStatus status, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from('tasks')
          .select()
          .eq('firm_id', firmId)
          .eq('status', status.name)
          .order('due_date');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('tasks')
        .select()
        .eq('status', status.name)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> search(
    String query, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from('tasks')
          .select()
          .eq('firm_id', firmId)
          .or(
            'title.ilike.%$query%,client_name.ilike.%$query%,description.ilike.%$query%',
          )
          .order('due_date');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('tasks')
        .select()
        .or(
          'title.ilike.%$query%,client_name.ilike.%$query%,description.ilike.%$query%',
        )
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from('tasks').insert(data).select().single();
    return response;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('tasks')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}

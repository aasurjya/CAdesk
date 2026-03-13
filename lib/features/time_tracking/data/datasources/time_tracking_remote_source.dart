import 'package:supabase_flutter/supabase_flutter.dart';

class TimeTrackingRemoteSource {
  const TimeTrackingRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('time_entries')
        .select()
        .eq('client_id', clientId)
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final response = await _client
        .from('time_entries')
        .select()
        .gte('start_time', from.toIso8601String())
        .lte('start_time', to.toIso8601String())
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchUnbilled(String clientId) async {
    final response = await _client
        .from('time_entries')
        .select()
        .eq('client_id', clientId)
        .eq('is_billed', false)
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('time_entries')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('time_entries')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('time_entries').delete().eq('id', id);
  }
}

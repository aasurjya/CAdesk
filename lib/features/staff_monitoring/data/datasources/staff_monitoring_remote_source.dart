import 'package:supabase_flutter/supabase_flutter.dart';

class StaffMonitoringRemoteSource {
  const StaffMonitoringRemoteSource(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> insertActivity(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('staff_activities')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchByStaff(String staffId) async {
    final response = await _client
        .from('staff_activities')
        .select()
        .eq('staff_id', staffId)
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByPeriod(
    DateTime from,
    DateTime to,
  ) async {
    final response = await _client
        .from('staff_activities')
        .select()
        .gte('start_time', from.toIso8601String())
        .lte('start_time', to.toIso8601String())
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('staff_activities')
        .select()
        .eq('client_id', clientId)
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertPerformance(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('staff_performance')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>?> fetchPerformance(
    String staffId,
    String period,
  ) async {
    final response = await _client
        .from('staff_performance')
        .select()
        .eq('staff_id', staffId)
        .eq('period', period)
        .maybeSingle();
    return response;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class GstReturnRemoteSource {
  const GstReturnRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from('gst_returns')
          .select()
          .eq('firm_id', firmId)
          .order('due_date');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('gst_returns')
        .select()
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByClientId(String clientId) async {
    final response = await _client
        .from('gst_returns')
        .select()
        .eq('client_id', clientId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('gst_returns')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> getByPeriod(
    int month,
    int year, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from('gst_returns')
          .select()
          .eq('firm_id', firmId)
          .eq('period_month', month)
          .eq('period_year', year)
          .order('due_date');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('gst_returns')
        .select()
        .eq('period_month', month)
        .eq('period_year', year)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('gst_returns')
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
        .from('gst_returns')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('gst_returns').delete().eq('id', id);
  }
}

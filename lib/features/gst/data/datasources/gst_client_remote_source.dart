import 'package:supabase_flutter/supabase_flutter.dart';

class GstClientRemoteSource {
  const GstClientRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from('gst_clients')
          .select()
          .eq('firm_id', firmId)
          .order('business_name');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('gst_clients')
        .select()
        .order('business_name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('gst_clients')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>?> getByGstin(String gstin) async {
    final response = await _client
        .from('gst_clients')
        .select()
        .eq('gstin', gstin)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('gst_clients')
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
        .from('gst_clients')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('gst_clients').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> search(
    String query, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from('gst_clients')
          .select()
          .eq('firm_id', firmId)
          .or(
            'business_name.ilike.%$query%,'
            'trade_name.ilike.%$query%,'
            'gstin.ilike.%$query%,'
            'pan.ilike.%$query%',
          )
          .order('business_name');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('gst_clients')
        .select()
        .or(
          'business_name.ilike.%$query%,'
          'trade_name.ilike.%$query%,'
          'gstin.ilike.%$query%,'
          'pan.ilike.%$query%',
        )
        .order('business_name');
    return List<Map<String, dynamic>>.from(response);
  }
}

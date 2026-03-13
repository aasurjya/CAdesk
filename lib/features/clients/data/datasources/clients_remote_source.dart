import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsRemoteSource {
  const ClientsRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    var query = _client.from('clients').select().order('name');
    if (firmId != null) {
      final response = await _client
          .from('clients')
          .select()
          .eq('firm_id', firmId)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('clients')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('clients')
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
        .from('clients')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> search(
    String query, {
    String? firmId,
  }) async {
    var builder = _client
        .from('clients')
        .select()
        .or('name.ilike.%$query%,pan.ilike.%$query%,email.ilike.%$query%');

    if (firmId != null) {
      final response = await _client
          .from('clients')
          .select()
          .eq('firm_id', firmId)
          .or('name.ilike.%$query%,pan.ilike.%$query%,email.ilike.%$query%')
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    }

    final response = await builder.order('name');
    return List<Map<String, dynamic>>.from(response);
  }
}

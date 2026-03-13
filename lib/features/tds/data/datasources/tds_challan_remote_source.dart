import 'package:supabase_flutter/supabase_flutter.dart';

class TdsChallanRemoteSource {
  const TdsChallanRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'tds_challans';

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from(_table)
          .select()
          .eq('firm_id', firmId)
          .order('payment_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from(_table)
        .select()
        .order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchByDeductorId(
    String deductorId,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('deductor_id', deductorId)
        .order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

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

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

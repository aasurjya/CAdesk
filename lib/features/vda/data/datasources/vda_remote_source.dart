import 'package:supabase_flutter/supabase_flutter.dart';

class VdaRemoteSource {
  const VdaRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'vda_records';

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('transaction_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByYear(String assessmentYear) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('assessment_year', assessmentYear)
        .order('transaction_date', ascending: false);
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

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

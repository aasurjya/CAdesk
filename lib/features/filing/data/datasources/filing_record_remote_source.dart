import 'package:supabase_flutter/supabase_flutter.dart';

class FilingRecordRemoteSource {
  const FilingRecordRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('filing_records')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByType(String filingType) async {
    final response = await _client
        .from('filing_records')
        .select()
        .eq('filing_type', filingType)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from('filing_records')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('filing_records')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('filing_records')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateStatus(String id, String status) async {
    final response = await _client
        .from('filing_records')
        .update({'status': status})
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchOverdue() async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    final response = await _client
        .from('filing_records')
        .select()
        .isFilter('filed_date', null)
        .or('status.eq.pending,status.eq.inProgress')
        .lt('created_at', cutoff);
    return List<Map<String, dynamic>>.from(response);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class PostFilingRecordRemoteSource {
  const PostFilingRecordRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchByFiling(String filingId) async {
    final response = await _client
        .from('post_filing_records')
        .select()
        .eq('filing_id', filingId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('post_filing_records')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('post_filing_records')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('post_filing_records')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateStatus(
    String id,
    String status, {
    String? completedAt,
    String? notes,
  }) async {
    final update = <String, dynamic>{'status': status};
    if (completedAt != null) update['completed_at'] = completedAt;
    if (notes != null) update['notes'] = notes;

    final response = await _client
        .from('post_filing_records')
        .update(update)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchPending() async {
    final response = await _client
        .from('post_filing_records')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}

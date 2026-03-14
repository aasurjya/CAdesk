import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for e-verification requests and signing requests.
class EVerificationRemoteSource {
  const EVerificationRemoteSource(this._client);

  final SupabaseClient _client;

  static const _vreqTable = 'verification_requests';
  static const _sreqTable = 'signing_requests';

  Future<List<Map<String, dynamic>>> fetchAllVerificationRequests() async {
    final response = await _client
        .from(_vreqTable)
        .select()
        .order('deadline_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertVerificationRequest(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_vreqTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateVerificationRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_vreqTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteVerificationRequest(String id) async {
    await _client.from(_vreqTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllSigningRequests() async {
    final response = await _client
        .from(_sreqTable)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertSigningRequest(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_sreqTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateSigningRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_sreqTable)
        .update(data)
        .eq('request_id', requestId)
        .select()
        .single();
    return response;
  }

  Future<void> deleteSigningRequest(String requestId) async {
    await _client.from(_sreqTable).delete().eq('request_id', requestId);
  }
}

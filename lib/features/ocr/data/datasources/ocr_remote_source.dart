import 'package:supabase_flutter/supabase_flutter.dart';

class OcrRemoteSource {
  const OcrRemoteSource(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('ocr_jobs')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('ocr_jobs')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from('ocr_jobs')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateStatus(
    String id,
    String status, {
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (completedAt != null) {
      data['completed_at'] = completedAt.toIso8601String();
    }
    if (errorMessage != null) {
      data['error_message'] = errorMessage;
    }
    await _client.from('ocr_jobs').update(data).eq('id', id);
  }

  Future<void> updateParsedData(
    String id,
    String parsedDataJson,
    double confidence,
  ) async {
    await _client
        .from('ocr_jobs')
        .update({'parsed_data': parsedDataJson, 'confidence': confidence})
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchByDocType(String documentType) async {
    final response = await _client
        .from('ocr_jobs')
        .select()
        .eq('document_type', documentType)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}

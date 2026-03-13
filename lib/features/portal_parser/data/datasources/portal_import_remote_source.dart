import 'package:supabase_flutter/supabase_flutter.dart';

class PortalImportRemoteSource {
  const PortalImportRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('portal_imports')
        .select()
        .eq('client_id', clientId)
        .order('import_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByType(String importType) async {
    final response = await _client
        .from('portal_imports')
        .select()
        .eq('import_type', importType)
        .order('import_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchLatest(
    String clientId,
    String importType,
  ) async {
    final response = await _client
        .from('portal_imports')
        .select()
        .eq('client_id', clientId)
        .eq('import_type', importType)
        .order('import_date', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('portal_imports')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('portal_imports')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateStatus(
    String id,
    String status, {
    int? parsedRecords,
    String? errorMessage,
  }) async {
    final update = <String, dynamic>{'status': status};
    if (parsedRecords != null) update['parsed_records'] = parsedRecords;
    if (errorMessage != null) update['error_message'] = errorMessage;

    final response = await _client
        .from('portal_imports')
        .update(update)
        .eq('id', id)
        .select()
        .single();
    return response;
  }
}

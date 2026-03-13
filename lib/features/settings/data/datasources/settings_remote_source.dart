import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsRemoteSource {
  const SettingsRemoteSource(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> fetchByFirmId(String firmId) async {
    final response = await _client
        .from('app_settings')
        .select()
        .eq('firm_id', firmId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> upsert(Map<String, dynamic> data) async {
    final response = await _client
        .from('app_settings')
        .upsert(data)
        .select()
        .single();
    return response;
  }
}

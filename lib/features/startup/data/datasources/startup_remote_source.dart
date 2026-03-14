import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for Startup India records.
class StartupRemoteSource {
  const StartupRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'startup_records';

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('incorporation_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('recognition_status', status)
        .order('incorporation_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchEligibleForExemptions() async {
    final response = await _client
        .from(_table)
        .select()
        .or('section_80iac_eligible.eq.true,section_56_exempt_eligible.eq.true')
        .order('incorporation_date');
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
}

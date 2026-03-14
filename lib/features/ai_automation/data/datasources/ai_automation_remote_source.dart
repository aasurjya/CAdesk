import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for AI automation.
class AiAutomationRemoteSource {
  const AiAutomationRemoteSource(this._client);

  final SupabaseClient _client;

  static const _scanTable = 'ai_scan_results';
  static const _insightTable = 'automation_insights';

  Future<List<Map<String, dynamic>>> fetchAllScanResults() async {
    final response = await _client
        .from(_scanTable)
        .select()
        .order('scanned_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchScanResultsByStatus(
    String status,
  ) async {
    final response = await _client
        .from(_scanTable)
        .select()
        .eq('status', status)
        .order('scanned_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertScanResult(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_scanTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateScanResult(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_scanTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteScanResult(String id) async {
    await _client.from(_scanTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllInsights() async {
    final response = await _client
        .from(_insightTable)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertInsight(Map<String, dynamic> data) async {
    final response = await _client
        .from(_insightTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateInsight(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_insightTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteInsight(String id) async {
    await _client.from(_insightTable).delete().eq('id', id);
  }
}

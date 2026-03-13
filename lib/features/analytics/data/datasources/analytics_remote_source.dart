import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsRemoteSource {
  const AnalyticsRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchSnapshotsByPeriod(
    String firmId,
    String period,
  ) async {
    final response = await _client
        .from('analytics_snapshots')
        .select()
        .eq('firm_id', firmId)
        .eq('period', period)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchLatestSnapshot(String firmId) async {
    final response = await _client
        .from('analytics_snapshots')
        .select()
        .eq('firm_id', firmId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insertSnapshot(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('analytics_snapshots')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchClientMetrics(
    String clientId,
  ) async {
    final response = await _client
        .from('client_metrics')
        .select()
        .eq('client_id', clientId)
        .order('period', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertClientMetric(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('client_metrics')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchRevenueByPeriod(
    String period,
  ) async {
    final response = await _client
        .from('client_metrics')
        .select()
        .eq('period', period)
        .order('revenue', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}

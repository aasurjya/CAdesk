import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';

/// Fetches aggregated dashboard data from Supabase via RPC functions.
///
/// Supabase RPC endpoints are expected to accept a `firm_id` parameter and
/// return aggregated results. Falls back gracefully — callers should wrap
/// invocations in try/catch to fall back to local data on network errors.
class DashboardRemoteSource {
  const DashboardRemoteSource(this._client);

  final SupabaseClient _client;

  /// Calls the `get_dashboard_summary` Supabase RPC function.
  ///
  /// Returns a [DashboardSummary] or throws on network/server error.
  Future<DashboardSummary> getDashboardSummary({String firmId = ''}) async {
    final response = await _client.rpc(
      'get_dashboard_summary',
      params: {'p_firm_id': firmId},
    );
    final json = response as Map<String, dynamic>;
    return DashboardMapper.summaryFromJson(json);
  }

  /// Calls the `get_recent_filings` Supabase RPC function.
  ///
  /// Returns a list of [RecentFiling] records or throws on error.
  Future<List<RecentFiling>> getRecentFilings({
    int limit = 10,
    String firmId = '',
  }) async {
    final response = await _client.rpc(
      'get_recent_filings',
      params: {'p_firm_id': firmId, 'p_limit': limit},
    );
    final rows = response as List<dynamic>;
    return rows
        .cast<Map<String, dynamic>>()
        .map(DashboardMapper.recentFilingFromJson)
        .toList();
  }

  /// Calls the `get_top_clients` Supabase RPC function.
  ///
  /// Returns a list of [TopClient] records or throws on error.
  Future<List<TopClient>> getTopClients({
    int limit = 5,
    String firmId = '',
  }) async {
    final response = await _client.rpc(
      'get_top_clients',
      params: {'p_firm_id': firmId, 'p_limit': limit},
    );
    final rows = response as List<dynamic>;
    return rows
        .cast<Map<String, dynamic>>()
        .map(DashboardMapper.topClientFromJson)
        .toList();
  }
}

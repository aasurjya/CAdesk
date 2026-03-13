import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for LLP filings.
class LlpRemoteSource {
  const LlpRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'llp_filings';

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByYear(
    String clientId,
    String year,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .eq('financial_year', year)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchOverdue() async {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final response = await _client
        .from(_table)
        .select()
        .lt('due_date', todayMidnight.toIso8601String())
        .neq('status', 'filed')
        .neq('status', 'approved')
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchDue(int daysAhead) async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final cutoff = todayMidnight.add(Duration(days: daysAhead));
    final response = await _client
        .from(_table)
        .select()
        .gte('due_date', todayMidnight.toIso8601String())
        .lte('due_date', cutoff.toIso8601String())
        .neq('status', 'filed')
        .neq('status', 'approved')
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response =
        await _client.from(_table).insert(data).select().single();
    return response;
  }

  Future<Map<String, dynamic>> updateStatus(
    String id,
    String status,
  ) async {
    final response = await _client
        .from(_table)
        .update({'status': status})
        .eq('id', id)
        .select()
        .single();
    return response;
  }
}

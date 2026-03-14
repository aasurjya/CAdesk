import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for MCA filings.
///
/// All methods return raw JSON maps / lists; callers are responsible for
/// mapping to domain models via [McaMapper].
class McaRemoteSource {
  const McaRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'mca_filings';

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

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

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('status', status)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchDueFilings(int daysAhead) async {
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

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

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

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

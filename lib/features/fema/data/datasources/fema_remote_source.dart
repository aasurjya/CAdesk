import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for FEMA filings.
class FemaRemoteSource {
  const FemaRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'fema_filings';

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .order('transaction_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByType(String filingType) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('filing_type', filingType)
        .order('transaction_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByYear(
    String clientId,
    int year,
  ) async {
    final start = DateTime(year).toIso8601String();
    final end = DateTime(year + 1).toIso8601String();
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .gte('transaction_date', start)
        .lt('transaction_date', end)
        .order('transaction_date', ascending: false);
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

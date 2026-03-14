import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for crypto/VDA transactions and summaries.
class CryptoVdaRemoteSource {
  const CryptoVdaRemoteSource(this._client);

  final SupabaseClient _client;

  static const _txTable = 'vda_transactions';
  static const _summaryTable = 'vda_summaries';

  Future<List<Map<String, dynamic>>> fetchAllTransactions() async {
    final response = await _client
        .from(_txTable)
        .select()
        .order('transaction_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchTransactionsByClient(
    String clientId,
  ) async {
    final response = await _client
        .from(_txTable)
        .select()
        .eq('client_id', clientId)
        .order('transaction_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertTransaction(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_txTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_txTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from(_txTable).delete().eq('id', id);
  }

  Future<Map<String, dynamic>?> fetchSummaryByClient(
    String clientId,
    String assessmentYear,
  ) async {
    final response = await _client
        .from(_summaryTable)
        .select()
        .eq('client_id', clientId)
        .eq('assessment_year', assessmentYear)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> upsertSummary(Map<String, dynamic> data) async {
    final response = await _client
        .from(_summaryTable)
        .upsert(data)
        .select()
        .single();
    return response;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for e-invoice records and IRN batches.
class EinvoicingRemoteSource {
  const EinvoicingRemoteSource(this._client);

  final SupabaseClient _client;

  static const _recordTable = 'einvoice_records';
  static const _batchTable = 'irn_batches';

  Future<List<Map<String, dynamic>>> fetchAllRecords() async {
    final response = await _client
        .from(_recordTable)
        .select()
        .order('invoice_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertRecord(Map<String, dynamic> data) async {
    final response = await _client
        .from(_recordTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateRecord(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_recordTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteRecord(String id) async {
    await _client.from(_recordTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllBatches() async {
    final response = await _client
        .from(_batchTable)
        .select()
        .order('processed_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertBatch(Map<String, dynamic> data) async {
    final response = await _client
        .from(_batchTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateBatch(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_batchTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteBatch(String id) async {
    await _client.from(_batchTable).delete().eq('id', id);
  }
}

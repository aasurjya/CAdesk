import 'package:supabase_flutter/supabase_flutter.dart';

class InvoiceRemoteSource {
  const InvoiceRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from('invoices')
          .select()
          .eq('firm_id', firmId)
          .order('invoice_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('invoices')
        .select()
        .order('invoice_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('invoices')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('invoices')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('invoices').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchByClientId(String clientId) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('client_id', clientId)
        .order('invoice_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(
    String status, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from('invoices')
          .select()
          .eq('firm_id', firmId)
          .eq('status', status)
          .order('invoice_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('invoices')
        .select()
        .eq('status', status)
        .order('invoice_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> search(
    String query, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from('invoices')
          .select()
          .eq('firm_id', firmId)
          .or('invoice_number.ilike.%$query%,client_id.eq.$query')
          .order('invoice_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('invoices')
        .select()
        .or('invoice_number.ilike.%$query%,client_id.eq.$query')
        .order('invoice_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}

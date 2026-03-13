import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRemoteSource {
  const PaymentRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from('payments')
          .select()
          .eq('firm_id', firmId)
          .order('payment_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from('payments')
        .select()
        .order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('payments')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String id) async {
    await _client.from('payments').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchByInvoiceId(String invoiceId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('invoice_id', invoiceId)
        .order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for DSC certificates and portal credentials.
class DscVaultRemoteSource {
  const DscVaultRemoteSource(this._client);

  final SupabaseClient _client;

  static const _certTable = 'dsc_certificates';
  static const _credTable = 'portal_credentials';

  Future<List<Map<String, dynamic>>> fetchAllCertificates() async {
    final response = await _client
        .from(_certTable)
        .select()
        .order('expiry_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertCertificate(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_certTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateCertificate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_certTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteCertificate(String id) async {
    await _client.from(_certTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllCredentials() async {
    final response = await _client
        .from(_credTable)
        .select()
        .order('last_updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertCredential(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_credTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateCredential(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_credTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteCredential(String id) async {
    await _client.from(_credTable).delete().eq('id', id);
  }
}

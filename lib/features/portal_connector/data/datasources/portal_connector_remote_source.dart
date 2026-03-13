import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote Supabase data source for portal credentials.
///
/// Maps to the `portal_credentials` table in Supabase.
/// All credential values stored here are already encrypted — this source
/// never handles plaintext passwords.
class PortalConnectorRemoteSource {
  const PortalConnectorRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'portal_credentials';

  /// Fetch all stored credential rows (current firm's credentials via RLS).
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _client.from(_table).select().order('portal_type');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetch the credential row for a specific [portalType] string, or `null`.
  Future<Map<String, dynamic>?> fetchByPortalType(String portalType) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('portal_type', portalType)
        .maybeSingle();
    return response;
  }

  /// Insert a new credential row. Returns the inserted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response =
        await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing credential row by [id]. Returns the updated row.
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

  /// Delete the credential row for [portalType].
  Future<void> deleteByPortalType(String portalType) async {
    await _client.from(_table).delete().eq('portal_type', portalType);
  }

  /// Update only the status field for a given [portalType].
  Future<void> updateStatus(String portalType, String status) async {
    await _client
        .from(_table)
        .update({'status': status})
        .eq('portal_type', portalType);
  }
}

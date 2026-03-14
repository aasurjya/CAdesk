import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for ecosystem connectors and marketplace apps.
class EcosystemRemoteSource {
  const EcosystemRemoteSource(this._client);

  final SupabaseClient _client;

  static const _connectorTable = 'integration_connectors';
  static const _appTable = 'marketplace_apps';

  Future<List<Map<String, dynamic>>> fetchAllConnectors() async {
    final response = await _client.from(_connectorTable).select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertConnector(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_connectorTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateConnector(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_connectorTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteConnector(String id) async {
    await _client.from(_connectorTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllMarketplaceApps() async {
    final response = await _client.from(_appTable).select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertMarketplaceApp(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_appTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateMarketplaceApp(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_appTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteMarketplaceApp(String id) async {
    await _client.from(_appTable).delete().eq('id', id);
  }
}

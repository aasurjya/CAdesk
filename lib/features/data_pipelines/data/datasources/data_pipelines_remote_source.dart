import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for data pipelines and broker feeds.
class DataPipelinesRemoteSource {
  const DataPipelinesRemoteSource(this._client);

  final SupabaseClient _client;

  static const _pipelineTable = 'data_pipelines';
  static const _brokerFeedTable = 'broker_feeds';

  Future<List<Map<String, dynamic>>> fetchAllPipelines() async {
    final response = await _client
        .from(_pipelineTable)
        .select()
        .order('last_sync', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertPipeline(Map<String, dynamic> data) async {
    final response = await _client
        .from(_pipelineTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updatePipeline(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_pipelineTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deletePipeline(String id) async {
    await _client.from(_pipelineTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllBrokerFeeds() async {
    final response = await _client
        .from(_brokerFeedTable)
        .select()
        .order('last_fetch', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertBrokerFeed(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_brokerFeedTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateBrokerFeed(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_brokerFeedTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteBrokerFeed(String id) async {
    await _client.from(_brokerFeedTable).delete().eq('id', id);
  }
}

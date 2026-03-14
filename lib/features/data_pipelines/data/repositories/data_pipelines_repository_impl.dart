import 'package:ca_app/features/data_pipelines/data/datasources/data_pipelines_local_source.dart';
import 'package:ca_app/features/data_pipelines/data/datasources/data_pipelines_remote_source.dart';
import 'package:ca_app/features/data_pipelines/data/mappers/data_pipelines_mapper.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';
import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/repositories/data_pipelines_repository.dart';

/// Real implementation of [DataPipelinesRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class DataPipelinesRepositoryImpl implements DataPipelinesRepository {
  const DataPipelinesRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final DataPipelinesRemoteSource remote;
  final DataPipelinesLocalSource local;

  @override
  Future<String> insertPipeline(DataPipeline pipeline) async {
    try {
      final json = await remote.insertPipeline(
        DataPipelinesMapper.pipelineToJson(pipeline),
      );
      final created = DataPipelinesMapper.pipelineFromJson(json);
      await local.insertPipeline(created);
      return created.id;
    } catch (_) {
      return local.insertPipeline(pipeline);
    }
  }

  @override
  Future<List<DataPipeline>> getAllPipelines() async {
    try {
      final jsonList = await remote.fetchAllPipelines();
      final pipelines = jsonList
          .map(DataPipelinesMapper.pipelineFromJson)
          .toList();
      for (final p in pipelines) {
        await local.insertPipeline(p);
      }
      return List.unmodifiable(pipelines);
    } catch (_) {
      return local.getAllPipelines();
    }
  }

  @override
  Future<List<DataPipeline>> getPipelinesByStatus(PipelineStatus status) async {
    try {
      final all = await getAllPipelines();
      return List.unmodifiable(all.where((p) => p.status == status).toList());
    } catch (_) {
      final all = await local.getAllPipelines();
      return List.unmodifiable(all.where((p) => p.status == status).toList());
    }
  }

  @override
  Future<bool> updatePipeline(DataPipeline pipeline) async {
    try {
      await remote.updatePipeline(
        pipeline.id,
        DataPipelinesMapper.pipelineToJson(pipeline),
      );
      await local.updatePipeline(pipeline);
      return true;
    } catch (_) {
      return local.updatePipeline(pipeline);
    }
  }

  @override
  Future<bool> deletePipeline(String id) async {
    try {
      await remote.deletePipeline(id);
      await local.deletePipeline(id);
      return true;
    } catch (_) {
      return local.deletePipeline(id);
    }
  }

  @override
  Future<String> insertBrokerFeed(BrokerFeed feed) async {
    try {
      final json = await remote.insertBrokerFeed(
        DataPipelinesMapper.feedToJson(feed),
      );
      final created = DataPipelinesMapper.feedFromJson(json);
      await local.insertBrokerFeed(created);
      return created.id;
    } catch (_) {
      return local.insertBrokerFeed(feed);
    }
  }

  @override
  Future<List<BrokerFeed>> getAllBrokerFeeds() async {
    try {
      final jsonList = await remote.fetchAllBrokerFeeds();
      final feeds = jsonList.map(DataPipelinesMapper.feedFromJson).toList();
      for (final f in feeds) {
        await local.insertBrokerFeed(f);
      }
      return List.unmodifiable(feeds);
    } catch (_) {
      return local.getAllBrokerFeeds();
    }
  }

  @override
  Future<List<BrokerFeed>> getBrokerFeedsByBroker(BrokerName broker) async {
    try {
      final all = await getAllBrokerFeeds();
      return List.unmodifiable(all.where((f) => f.broker == broker).toList());
    } catch (_) {
      final all = await local.getAllBrokerFeeds();
      return List.unmodifiable(all.where((f) => f.broker == broker).toList());
    }
  }

  @override
  Future<bool> updateBrokerFeed(BrokerFeed feed) async {
    try {
      await remote.updateBrokerFeed(
        feed.id,
        DataPipelinesMapper.feedToJson(feed),
      );
      await local.updateBrokerFeed(feed);
      return true;
    } catch (_) {
      return local.updateBrokerFeed(feed);
    }
  }

  @override
  Future<bool> deleteBrokerFeed(String id) async {
    try {
      await remote.deleteBrokerFeed(id);
      await local.deleteBrokerFeed(id);
      return true;
    } catch (_) {
      return local.deleteBrokerFeed(id);
    }
  }
}

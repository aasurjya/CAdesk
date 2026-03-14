import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';

/// Abstract contract for data pipelines operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class DataPipelinesRepository {
  /// Insert a new [DataPipeline] and return its generated ID.
  Future<String> insertPipeline(DataPipeline pipeline);

  /// Retrieve all data pipelines.
  Future<List<DataPipeline>> getAllPipelines();

  /// Retrieve pipelines filtered by [status].
  Future<List<DataPipeline>> getPipelinesByStatus(PipelineStatus status);

  /// Update an existing [DataPipeline]. Returns true on success.
  Future<bool> updatePipeline(DataPipeline pipeline);

  /// Delete the pipeline identified by [id]. Returns true on success.
  Future<bool> deletePipeline(String id);

  /// Insert a new [BrokerFeed] and return its generated ID.
  Future<String> insertBrokerFeed(BrokerFeed feed);

  /// Retrieve all broker feeds.
  Future<List<BrokerFeed>> getAllBrokerFeeds();

  /// Retrieve broker feeds filtered by [broker].
  Future<List<BrokerFeed>> getBrokerFeedsByBroker(BrokerName broker);

  /// Update an existing [BrokerFeed]. Returns true on success.
  Future<bool> updateBrokerFeed(BrokerFeed feed);

  /// Delete the broker feed identified by [id]. Returns true on success.
  Future<bool> deleteBrokerFeed(String id);
}

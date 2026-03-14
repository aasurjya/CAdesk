import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';
import 'package:ca_app/features/data_pipelines/domain/repositories/data_pipelines_repository.dart';

/// In-memory mock implementation of [DataPipelinesRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockDataPipelinesRepository implements DataPipelinesRepository {
  static final List<DataPipeline> _seedPipelines = [
    DataPipeline(
      id: 'pipe-001',
      name: 'Zerodha Capital Gains Feed',
      sourceType: PipelineSourceType.zerodha,
      status: PipelineStatus.active,
      lastSync: DateTime(2026, 3, 13, 8, 0),
      recordsProcessed: 1240,
      errorCount: 0,
      nextSync: DateTime(2026, 3, 14, 8, 0),
      clientCount: 42,
    ),
    DataPipeline(
      id: 'pipe-002',
      name: 'Tally Accounting Import',
      sourceType: PipelineSourceType.tally,
      status: PipelineStatus.active,
      lastSync: DateTime(2026, 3, 12, 18, 30),
      recordsProcessed: 8560,
      errorCount: 3,
      nextSync: DateTime(2026, 3, 14, 18, 30),
      clientCount: 15,
    ),
    DataPipeline(
      id: 'pipe-003',
      name: 'CAMS Mutual Fund Import',
      sourceType: PipelineSourceType.cams,
      status: PipelineStatus.error,
      lastSync: DateTime(2026, 3, 10, 9, 0),
      recordsProcessed: 0,
      errorCount: 12,
      errorMessage: 'Authentication token expired. Please reconnect.',
      clientCount: 28,
    ),
  ];

  static final List<BrokerFeed> _seedBrokerFeeds = [
    BrokerFeed(
      id: 'feed-001',
      broker: BrokerName.zerodha,
      clientName: 'Rahul Sharma',
      status: BrokerFeedStatus.synced,
      lastFetch: DateTime(2026, 3, 13, 8, 0),
      capitalGainsCount: 18,
      totalTransactions: 85,
      pan: 'ABCDE1234F',
      accountId: 'ZE12345',
    ),
    BrokerFeed(
      id: 'feed-002',
      broker: BrokerName.cams,
      clientName: 'Priya Verma',
      status: BrokerFeedStatus.failed,
      lastFetch: DateTime(2026, 3, 10, 10, 0),
      capitalGainsCount: 0,
      totalTransactions: 0,
      pan: 'PQRST5678A',
    ),
    BrokerFeed(
      id: 'feed-003',
      broker: BrokerName.kfintech,
      clientName: 'Suresh Mehta',
      status: BrokerFeedStatus.stale,
      lastFetch: DateTime(2026, 2, 28, 12, 0),
      capitalGainsCount: 6,
      totalTransactions: 22,
      pan: 'LMNOP9012B',
      accountId: 'KF98765',
    ),
  ];

  final List<DataPipeline> _pipelines = List.of(_seedPipelines);
  final List<BrokerFeed> _brokerFeeds = List.of(_seedBrokerFeeds);

  @override
  Future<String> insertPipeline(DataPipeline pipeline) async {
    _pipelines.add(pipeline);
    return pipeline.id;
  }

  @override
  Future<List<DataPipeline>> getAllPipelines() async =>
      List.unmodifiable(_pipelines);

  @override
  Future<List<DataPipeline>> getPipelinesByStatus(
    PipelineStatus status,
  ) async =>
      List.unmodifiable(_pipelines.where((p) => p.status == status).toList());

  @override
  Future<bool> updatePipeline(DataPipeline pipeline) async {
    final idx = _pipelines.indexWhere((p) => p.id == pipeline.id);
    if (idx == -1) return false;
    final updated = List<DataPipeline>.of(_pipelines)..[idx] = pipeline;
    _pipelines
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deletePipeline(String id) async {
    final before = _pipelines.length;
    _pipelines.removeWhere((p) => p.id == id);
    return _pipelines.length < before;
  }

  @override
  Future<String> insertBrokerFeed(BrokerFeed feed) async {
    _brokerFeeds.add(feed);
    return feed.id;
  }

  @override
  Future<List<BrokerFeed>> getAllBrokerFeeds() async =>
      List.unmodifiable(_brokerFeeds);

  @override
  Future<List<BrokerFeed>> getBrokerFeedsByBroker(BrokerName broker) async =>
      List.unmodifiable(_brokerFeeds.where((f) => f.broker == broker).toList());

  @override
  Future<bool> updateBrokerFeed(BrokerFeed feed) async {
    final idx = _brokerFeeds.indexWhere((f) => f.id == feed.id);
    if (idx == -1) return false;
    final updated = List<BrokerFeed>.of(_brokerFeeds)..[idx] = feed;
    _brokerFeeds
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteBrokerFeed(String id) async {
    final before = _brokerFeeds.length;
    _brokerFeeds.removeWhere((f) => f.id == id);
    return _brokerFeeds.length < before;
  }
}

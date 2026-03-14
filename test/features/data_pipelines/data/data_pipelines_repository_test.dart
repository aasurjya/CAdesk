import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/data_pipelines/data/repositories/mock_data_pipelines_repository.dart';
import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';

void main() {
  late MockDataPipelinesRepository repo;

  setUp(() {
    repo = MockDataPipelinesRepository();
  });

  group('MockDataPipelinesRepository - DataPipeline', () {
    test('getAllPipelines returns non-empty seeded list', () async {
      final pipelines = await repo.getAllPipelines();
      expect(pipelines, isNotEmpty);
    });

    test('getPipelinesByStatus filters correctly', () async {
      final pipelines = await repo.getPipelinesByStatus(PipelineStatus.active);
      for (final p in pipelines) {
        expect(p.status, PipelineStatus.active);
      }
    });

    test('insertPipeline adds entry and returns id', () async {
      final pipeline = DataPipeline(
        id: 'pipe-new-001',
        name: 'Test Pipeline',
        sourceType: PipelineSourceType.tally,
        status: PipelineStatus.pending,
        lastSync: DateTime(2026, 3, 1),
        recordsProcessed: 0,
        errorCount: 0,
      );
      final id = await repo.insertPipeline(pipeline);
      expect(id, 'pipe-new-001');

      final all = await repo.getAllPipelines();
      expect(all.any((p) => p.id == 'pipe-new-001'), isTrue);
    });

    test('updatePipeline updates status and returns true', () async {
      final all = await repo.getAllPipelines();
      final first = all.first;
      final updated = DataPipeline(
        id: first.id,
        name: first.name,
        sourceType: first.sourceType,
        status: PipelineStatus.paused,
        lastSync: first.lastSync,
        recordsProcessed: first.recordsProcessed,
        errorCount: first.errorCount,
      );
      final success = await repo.updatePipeline(updated);
      expect(success, isTrue);
    });

    test('updatePipeline returns false for non-existent id', () async {
      final ghost = DataPipeline(
        id: 'non-existent-pipe',
        name: 'Ghost',
        sourceType: PipelineSourceType.sap,
        status: PipelineStatus.error,
        lastSync: DateTime(2026, 1, 1),
        recordsProcessed: 0,
        errorCount: 5,
      );
      final success = await repo.updatePipeline(ghost);
      expect(success, isFalse);
    });

    test('deletePipeline removes entry and returns true', () async {
      final all = await repo.getAllPipelines();
      final target = all.first;
      final deleted = await repo.deletePipeline(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllPipelines();
      expect(remaining.any((p) => p.id == target.id), isFalse);
    });

    test('deletePipeline returns false for non-existent id', () async {
      final deleted = await repo.deletePipeline('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockDataPipelinesRepository - BrokerFeed', () {
    test('getAllBrokerFeeds returns non-empty seeded list', () async {
      final feeds = await repo.getAllBrokerFeeds();
      expect(feeds, isNotEmpty);
    });

    test('getBrokerFeedsByBroker filters correctly', () async {
      final feeds = await repo.getBrokerFeedsByBroker(BrokerName.zerodha);
      for (final f in feeds) {
        expect(f.broker, BrokerName.zerodha);
      }
    });

    test('insertBrokerFeed adds entry and returns id', () async {
      final feed = BrokerFeed(
        id: 'feed-new-001',
        broker: BrokerName.groww,
        clientName: 'Test Client',
        status: BrokerFeedStatus.synced,
        lastFetch: DateTime(2026, 3, 1),
        capitalGainsCount: 5,
        totalTransactions: 20,
        pan: 'ABCDE1234F',
      );
      final id = await repo.insertBrokerFeed(feed);
      expect(id, 'feed-new-001');
    });

    test('updateBrokerFeed returns true on success', () async {
      final all = await repo.getAllBrokerFeeds();
      final first = all.first;
      final updated = BrokerFeed(
        id: first.id,
        broker: first.broker,
        clientName: first.clientName,
        status: BrokerFeedStatus.stale,
        lastFetch: first.lastFetch,
        capitalGainsCount: first.capitalGainsCount,
        totalTransactions: first.totalTransactions,
      );
      final success = await repo.updateBrokerFeed(updated);
      expect(success, isTrue);
    });

    test('updateBrokerFeed returns false for non-existent id', () async {
      final ghost = BrokerFeed(
        id: 'non-existent-feed',
        broker: BrokerName.cams,
        clientName: 'Ghost',
        status: BrokerFeedStatus.failed,
        lastFetch: DateTime(2026, 1, 1),
        capitalGainsCount: 0,
        totalTransactions: 0,
      );
      final success = await repo.updateBrokerFeed(ghost);
      expect(success, isFalse);
    });

    test('deleteBrokerFeed removes entry and returns true', () async {
      final all = await repo.getAllBrokerFeeds();
      final target = all.first;
      final deleted = await repo.deleteBrokerFeed(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllBrokerFeeds();
      expect(remaining.any((f) => f.id == target.id), isFalse);
    });

    test('deleteBrokerFeed returns false for non-existent id', () async {
      final deleted = await repo.deleteBrokerFeed('no-such-id');
      expect(deleted, isFalse);
    });
  });
}

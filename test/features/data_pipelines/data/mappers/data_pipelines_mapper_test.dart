import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/data_pipelines/data/mappers/data_pipelines_mapper.dart';
import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';
import 'package:ca_app/features/data_pipelines/domain/models/broker_feed.dart';

void main() {
  group('DataPipelinesMapper', () {
    // -------------------------------------------------------------------------
    // DataPipeline
    // -------------------------------------------------------------------------
    group('pipelineFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'pipe-001',
          'name': 'Tally ERP Sync',
          'source_type': 'tally',
          'status': 'active',
          'last_sync': '2025-09-01T06:00:00.000Z',
          'records_processed': 1250,
          'error_count': 0,
          'next_sync': '2025-09-02T06:00:00.000Z',
          'client_count': 12,
          'error_message': null,
        };

        final pipeline = DataPipelinesMapper.pipelineFromJson(json);

        expect(pipeline.id, 'pipe-001');
        expect(pipeline.name, 'Tally ERP Sync');
        expect(pipeline.sourceType, PipelineSourceType.tally);
        expect(pipeline.status, PipelineStatus.active);
        expect(pipeline.recordsProcessed, 1250);
        expect(pipeline.errorCount, 0);
        expect(pipeline.nextSync, isNotNull);
        expect(pipeline.clientCount, 12);
        expect(pipeline.errorMessage, isNull);
      });

      test('handles null next_sync, client_count, and error_message', () {
        final json = {
          'id': 'pipe-002',
          'name': 'Zerodha Feed',
          'source_type': 'zerodha',
          'status': 'pending',
          'last_sync': '2025-08-01T00:00:00.000Z',
          'records_processed': 0,
          'error_count': 0,
        };

        final pipeline = DataPipelinesMapper.pipelineFromJson(json);
        expect(pipeline.nextSync, isNull);
        expect(pipeline.clientCount, isNull);
        expect(pipeline.errorMessage, isNull);
      });

      test('defaults source_type to tally for unknown value', () {
        final json = {
          'id': 'pipe-003',
          'name': 'Unknown Source',
          'source_type': 'unknownSource',
          'status': 'pending',
          'last_sync': '2025-08-01T00:00:00.000Z',
          'records_processed': 0,
          'error_count': 0,
        };

        final pipeline = DataPipelinesMapper.pipelineFromJson(json);
        expect(pipeline.sourceType, PipelineSourceType.tally);
      });

      test('handles error pipeline with message', () {
        final json = {
          'id': 'pipe-004',
          'name': 'Failed Pipeline',
          'source_type': 'zohoBooks',
          'status': 'error',
          'last_sync': '2025-08-31T00:00:00.000Z',
          'records_processed': 50,
          'error_count': 5,
          'error_message': 'API authentication failed',
        };

        final pipeline = DataPipelinesMapper.pipelineFromJson(json);
        expect(pipeline.status, PipelineStatus.error);
        expect(pipeline.errorMessage, 'API authentication failed');
        expect(pipeline.errorCount, 5);
      });

      test('handles all PipelineSourceType values', () {
        for (final sourceType in PipelineSourceType.values) {
          final json = {
            'id': 'pipe-source-${sourceType.name}',
            'name': '',
            'source_type': sourceType.name,
            'status': 'pending',
            'last_sync': '2025-08-01T00:00:00.000Z',
            'records_processed': 0,
            'error_count': 0,
          };
          final pipeline = DataPipelinesMapper.pipelineFromJson(json);
          expect(pipeline.sourceType, sourceType);
        }
      });
    });

    group('pipelineToJson', () {
      test('includes all fields and round-trips correctly', () {
        final pipeline = DataPipeline(
          id: 'pipe-json-001',
          name: 'CAMS Mutual Fund Sync',
          sourceType: PipelineSourceType.cams,
          status: PipelineStatus.active,
          lastSync: DateTime(2025, 9, 1, 6, 0),
          recordsProcessed: 3500,
          errorCount: 0,
          nextSync: DateTime(2025, 9, 2, 6, 0),
          clientCount: 25,
        );

        final json = DataPipelinesMapper.pipelineToJson(pipeline);

        expect(json['id'], 'pipe-json-001');
        expect(json['name'], 'CAMS Mutual Fund Sync');
        expect(json['source_type'], 'cams');
        expect(json['status'], 'active');
        expect(json['records_processed'], 3500);
        expect(json['error_count'], 0);
        expect(json['client_count'], 25);
        expect(json['error_message'], isNull);

        final restored = DataPipelinesMapper.pipelineFromJson(json);
        expect(restored.id, pipeline.id);
        expect(restored.sourceType, pipeline.sourceType);
        expect(restored.status, pipeline.status);
        expect(restored.recordsProcessed, pipeline.recordsProcessed);
      });
    });

    // -------------------------------------------------------------------------
    // BrokerFeed
    // -------------------------------------------------------------------------
    group('feedFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'feed-001',
          'broker': 'zerodha',
          'client_name': 'Ankit Sharma',
          'status': 'synced',
          'last_fetch': '2025-09-01T10:00:00.000Z',
          'capital_gains_count': 15,
          'total_transactions': 45,
          'pan': 'ABCDE1234F',
          'account_id': 'ZER123456',
        };

        final feed = DataPipelinesMapper.feedFromJson(json);

        expect(feed.id, 'feed-001');
        expect(feed.broker, BrokerName.zerodha);
        expect(feed.clientName, 'Ankit Sharma');
        expect(feed.status, BrokerFeedStatus.synced);
        expect(feed.capitalGainsCount, 15);
        expect(feed.totalTransactions, 45);
        expect(feed.pan, 'ABCDE1234F');
        expect(feed.accountId, 'ZER123456');
      });

      test('handles null pan and account_id', () {
        final json = {
          'id': 'feed-002',
          'broker': 'groww',
          'client_name': '',
          'status': 'stale',
          'last_fetch': '2025-09-01T00:00:00.000Z',
          'capital_gains_count': 0,
          'total_transactions': 0,
        };

        final feed = DataPipelinesMapper.feedFromJson(json);
        expect(feed.pan, isNull);
        expect(feed.accountId, isNull);
        expect(feed.broker, BrokerName.groww);
        expect(feed.status, BrokerFeedStatus.stale);
      });

      test('defaults broker to zerodha for unknown value', () {
        final json = {
          'id': 'feed-003',
          'broker': 'unknownBroker',
          'client_name': '',
          'status': 'stale',
          'last_fetch': '2025-09-01T00:00:00.000Z',
          'capital_gains_count': 0,
          'total_transactions': 0,
        };

        final feed = DataPipelinesMapper.feedFromJson(json);
        expect(feed.broker, BrokerName.zerodha);
      });

      test('handles all BrokerName values', () {
        for (final broker in BrokerName.values) {
          final json = {
            'id': 'feed-broker-${broker.name}',
            'broker': broker.name,
            'client_name': '',
            'status': 'stale',
            'last_fetch': '2025-09-01T00:00:00.000Z',
            'capital_gains_count': 0,
            'total_transactions': 0,
          };
          final feed = DataPipelinesMapper.feedFromJson(json);
          expect(feed.broker, broker);
        }
      });
    });

    group('feedToJson', () {
      test('includes all fields and round-trips correctly', () {
        final feed = BrokerFeed(
          id: 'feed-json-001',
          broker: BrokerName.kfintech,
          clientName: 'Priya Singh',
          status: BrokerFeedStatus.syncing,
          lastFetch: DateTime(2025, 9, 5, 8, 0),
          capitalGainsCount: 8,
          totalTransactions: 30,
          pan: 'PQRST5678G',
          accountId: 'KFT98765',
        );

        final json = DataPipelinesMapper.feedToJson(feed);

        expect(json['broker'], 'kfintech');
        expect(json['status'], 'syncing');
        expect(json['capital_gains_count'], 8);
        expect(json['pan'], 'PQRST5678G');

        final restored = DataPipelinesMapper.feedFromJson(json);
        expect(restored.id, feed.id);
        expect(restored.broker, feed.broker);
        expect(restored.status, feed.status);
        expect(restored.capitalGainsCount, feed.capitalGainsCount);
      });
    });
  });
}

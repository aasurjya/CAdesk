import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/sync/sync_queue_processor.dart';

void main() {
  group('SyncQueueProcessor', () {
    final baseTime = DateTime(2024, 6, 1, 12, 0, 0);

    // ---------------------------------------------------------------------------
    // Helper factories
    // ---------------------------------------------------------------------------

    SyncQueueItem _item({
      required String id,
      String tableName = 'clients',
      String recordId = 'rec_1',
      SyncOperation operation = SyncOperation.insert,
      Map<String, Object?> data = const {'name': 'Test'},
      DateTime? timestamp,
      int retryCount = 0,
    }) => SyncQueueItem(
      id: id,
      tableName: tableName,
      recordId: recordId,
      operation: operation,
      data: data,
      localTimestamp: timestamp ?? baseTime,
      retryCount: retryCount,
    );

    group('processPendingItems — empty queue', () {
      test(
        'empty queue emits a single SyncProgress with isComplete true',
        () async {
          const processor = SyncQueueProcessor();
          final snapshots = await processor.processPendingItems([]).toList();

          expect(snapshots, hasLength(1));
          expect(snapshots.first.isComplete, isTrue);
        },
      );

      test(
        'empty queue emits progress with total=0, processed=0, failed=0',
        () async {
          const processor = SyncQueueProcessor();
          final progress =
              (await processor.processPendingItems([]).toList()).first;

          expect(progress.total, equals(0));
          expect(progress.processed, equals(0));
          expect(progress.failed, equals(0));
        },
      );
    });

    group('processPendingItems — successful processing', () {
      test('single item is processed and yields isComplete true', () async {
        const processor = SyncQueueProcessor();
        final item = _item(id: 'item_1');
        final snapshots = await processor.processPendingItems([item]).toList();

        final final_ = snapshots.last;
        expect(final_.isComplete, isTrue);
      });

      test('all items are processed in order', () async {
        final processedIds = <String>[];
        final processor = SyncQueueProcessor(
          syncHandler: (item) async {
            processedIds.add(item.id);
          },
        );

        final items = [
          _item(id: 'first'),
          _item(id: 'second'),
          _item(id: 'third'),
        ];
        await processor.processPendingItems(items).toList();

        expect(processedIds, equals(['first', 'second', 'third']));
      });

      test('processed count increments for each successful item', () async {
        const processor = SyncQueueProcessor();
        final items = [_item(id: '1'), _item(id: '2'), _item(id: '3')];

        final snapshots = await processor.processPendingItems(items).toList();
        final last = snapshots.last;

        expect(last.processed, equals(3));
        expect(last.failed, equals(0));
      });

      test('progressFraction is 1.0 after all items processed', () async {
        const processor = SyncQueueProcessor();
        final items = [_item(id: '1'), _item(id: '2')];
        final snapshots = await processor.processPendingItems(items).toList();

        expect(snapshots.last.progressFraction, closeTo(1.0, 0.001));
      });
    });

    group('processPendingItems — failure handling', () {
      test(
        'failed item increments failed count, not processed count',
        () async {
          final processor = SyncQueueProcessor(
            syncHandler: (item) async {
              throw Exception('Network error');
            },
          );
          final items = [_item(id: 'bad_item')];
          final snapshots = await processor.processPendingItems(items).toList();

          final last = snapshots.last;
          expect(last.failed, equals(1));
          expect(last.processed, equals(0));
        },
      );

      test('error message is set on failed progress snapshot', () async {
        final processor = SyncQueueProcessor(
          syncHandler: (item) async {
            throw Exception('Timeout');
          },
        );
        final items = [_item(id: 'bad')];
        final snapshots = await processor.processPendingItems(items).toList();

        final failedSnapshot = snapshots.firstWhere(
          (s) => s.errorMessage != null,
        );
        expect(failedSnapshot.errorMessage, isNotNull);
        expect(failedSnapshot.errorMessage, isNotEmpty);
      });

      test(
        'failure on one item does not stop processing of subsequent items',
        () async {
          var callCount = 0;
          final processor = SyncQueueProcessor(
            syncHandler: (item) async {
              callCount++;
              if (item.id == 'bad') throw Exception('Error');
            },
          );
          final items = [
            _item(id: 'good_1'),
            _item(id: 'bad'),
            _item(id: 'good_2'),
          ];
          await processor.processPendingItems(items).toList();

          expect(
            callCount,
            equals(3),
            reason: 'All items should be attempted regardless of failures',
          );
        },
      );

      test('isComplete is true even when all items fail', () async {
        final processor = SyncQueueProcessor(
          syncHandler: (_) async => throw Exception('Always fails'),
        );
        final items = [_item(id: '1'), _item(id: '2')];
        final snapshots = await processor.processPendingItems(items).toList();

        expect(snapshots.last.isComplete, isTrue);
      });
    });

    group('resolveConflict — last-write-wins', () {
      test('local wins when local timestamp is strictly later', () {
        const processor = SyncQueueProcessor();
        final local = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {'name': 'Local Version'},
          localTimestamp: DateTime(2024, 6, 1, 12, 0, 1),
          retryCount: 3,
        );
        final remote = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {'name': 'Remote Version'},
          localTimestamp: DateTime(2024, 6, 1, 12, 0, 0),
          retryCount: 0,
        );

        final winner = processor.resolveConflict(local, remote);

        expect(winner.data['name'], equals('Local Version'));
      });

      test('remote wins when timestamps are equal (ties go to remote)', () {
        const processor = SyncQueueProcessor();
        final local = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {'name': 'Local'},
          localTimestamp: baseTime,
          retryCount: 2,
        );
        final remote = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {'name': 'Remote'},
          localTimestamp: baseTime, // same timestamp
          retryCount: 0,
        );

        final winner = processor.resolveConflict(local, remote);

        expect(winner.data['name'], equals('Remote'));
      });

      test('remote wins when remote timestamp is later', () {
        const processor = SyncQueueProcessor();
        final local = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {'name': 'Stale Local'},
          localTimestamp: DateTime(2024, 6, 1, 10, 0, 0),
          retryCount: 0,
        );
        final remote = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {'name': 'Newer Remote'},
          localTimestamp: DateTime(2024, 6, 1, 11, 0, 0),
          retryCount: 0,
        );

        final winner = processor.resolveConflict(local, remote);

        expect(winner.data['name'], equals('Newer Remote'));
      });

      test('winning item retryCount is reset to 0', () {
        const processor = SyncQueueProcessor();
        final local = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {},
          localTimestamp: DateTime(2024, 6, 1, 12, 0, 1),
          retryCount: 5,
        );
        final remote = SyncQueueItem(
          id: 'q1',
          tableName: 'clients',
          recordId: 'rec_1',
          operation: SyncOperation.update,
          data: const {},
          localTimestamp: baseTime,
          retryCount: 0,
        );

        final winner = processor.resolveConflict(local, remote);

        expect(winner.retryCount, equals(0));
      });
    });

    group('SyncQueueItem — model properties', () {
      test('SyncQueueItem has all required fields', () {
        final item = _item(id: 'test_id');

        expect(item.id, equals('test_id'));
        expect(item.tableName, equals('clients'));
        expect(item.recordId, equals('rec_1'));
        expect(item.operation, equals(SyncOperation.insert));
        expect(item.data, isNotEmpty);
        expect(item.localTimestamp, equals(baseTime));
        expect(item.retryCount, equals(0));
      });

      test('SyncQueueItem copyWith creates new immutable instance', () {
        final original = _item(id: '1', retryCount: 0);
        final updated = original.copyWith(retryCount: 3);

        expect(updated.retryCount, equals(3));
        expect(original.retryCount, equals(0));
        expect(identical(original, updated), isFalse);
      });

      test(
        'SyncQueueItem equality is based on id, tableName, recordId, operation, localTimestamp',
        () {
          final a = _item(id: 'x', retryCount: 0);
          final b = _item(id: 'x', retryCount: 99);

          expect(a, equals(b));
        },
      );
    });

    group('SyncProgress — computed properties', () {
      test('isComplete is false when processed + failed < total', () {
        const progress = SyncProgress(total: 5, processed: 2, failed: 1);
        expect(progress.isComplete, isFalse);
      });

      test('isComplete is true when processed + failed == total', () {
        const progress = SyncProgress(total: 5, processed: 3, failed: 2);
        expect(progress.isComplete, isTrue);
      });

      test('progressFraction is 0.0 when total is 0', () {
        const progress = SyncProgress(total: 0, processed: 0, failed: 0);
        expect(progress.progressFraction, equals(0.0));
      });

      test('progressFraction is 0.5 when half the items are handled', () {
        const progress = SyncProgress(total: 4, processed: 2, failed: 0);
        expect(progress.progressFraction, closeTo(0.5, 0.001));
      });
    });
  });
}

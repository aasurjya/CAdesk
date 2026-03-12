import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/domain/services/offline_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OfflineSyncService service;

  setUp(() {
    service = OfflineSyncService();
  });

  group('OfflineSyncService.enqueue', () {
    test('creates a pending SyncQueueItem', () {
      final item = service.enqueue(
        'Client',
        'client-1',
        SyncOperation.create,
        '{"name":"Test"}',
      );

      expect(item.entityType, 'Client');
      expect(item.entityId, 'client-1');
      expect(item.operation, SyncOperation.create);
      expect(item.payload, '{"name":"Test"}');
      expect(item.status, SyncStatus.pending);
      expect(item.itemId, isNotEmpty);
    });

    test('createdAt is close to now', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final item =
          service.enqueue('Client', 'c-1', SyncOperation.update, '{}');
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(
        item.createdAt.isAfter(before) && item.createdAt.isBefore(after),
        isTrue,
      );
    });

    test('syncedAt and conflictResolution are null initially', () {
      final item =
          service.enqueue('Client', 'c-1', SyncOperation.create, '{}');
      expect(item.syncedAt, isNull);
      expect(item.conflictResolution, isNull);
    });
  });

  group('OfflineSyncService.getPendingItems', () {
    test('returns only pending items', () {
      final item1 = service.enqueue('A', 'id-1', SyncOperation.create, '{}');
      service.markSynced(item1, DateTime.now());
      service.enqueue('B', 'id-2', SyncOperation.update, '{}');

      final pending = service.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.entityId, 'id-2');
    });

    test('returns empty list when no pending items', () {
      expect(service.getPendingItems(), isEmpty);
    });
  });

  group('OfflineSyncService.markSynced', () {
    test('returns new item with synced status and syncedAt set', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.create, '{}');
      final syncTime = DateTime(2025, 6, 1, 12, 0, 0);

      final synced = service.markSynced(item, syncTime);

      expect(synced.status, SyncStatus.synced);
      expect(synced.syncedAt, syncTime);
      expect(synced.itemId, item.itemId);
      expect(identical(item, synced), isFalse);
    });

    test('updates the queue item in internal store', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.create, '{}');
      service.markSynced(item, DateTime.now());

      expect(service.getPendingCount(), 0);
    });
  });

  group('OfflineSyncService.markFailed', () {
    test('returns new item with failed status', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.create, '{}');
      final failed = service.markFailed(item);

      expect(failed.status, SyncStatus.failed);
      expect(failed.itemId, item.itemId);
      expect(identical(item, failed), isFalse);
    });

    test('failed items are not returned by getPendingItems', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.create, '{}');
      service.markFailed(item);

      expect(service.getPendingItems(), isEmpty);
    });
  });

  group('OfflineSyncService.detectConflict', () {
    test('returns true when server payload differs from local', () {
      final item = service.enqueue(
        'Client',
        'c-1',
        SyncOperation.update,
        '{"name":"LocalName","version":1}',
      );
      final serverVersion = {'name': 'ServerName', 'version': 2};

      expect(service.detectConflict(item, serverVersion), isTrue);
    });

    test('returns false when server matches local payload', () {
      final item = service.enqueue(
        'Client',
        'c-1',
        SyncOperation.update,
        '{"name":"SameName"}',
      );
      final serverVersion = {'name': 'SameName'};

      expect(service.detectConflict(item, serverVersion), isFalse);
    });
  });

  group('OfflineSyncService.resolveConflict', () {
    test('sets status to conflicted with serverWins resolution', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.update, '{}');

      final resolved =
          service.resolveConflict(item, ConflictResolution.serverWins);

      expect(resolved.status, SyncStatus.conflicted);
      expect(resolved.conflictResolution, ConflictResolution.serverWins);
      expect(identical(item, resolved), isFalse);
    });

    test('sets status to conflicted with clientWins resolution', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.update, '{}');

      final resolved =
          service.resolveConflict(item, ConflictResolution.clientWins);

      expect(resolved.conflictResolution, ConflictResolution.clientWins);
    });

    test('sets status to conflicted with manual resolution', () {
      final item = service.enqueue('A', 'id-1', SyncOperation.update, '{}');

      final resolved =
          service.resolveConflict(item, ConflictResolution.manual);

      expect(resolved.conflictResolution, ConflictResolution.manual);
    });
  });

  group('OfflineSyncService.getPendingCount', () {
    test('returns count of only pending items', () {
      service.enqueue('A', '1', SyncOperation.create, '{}');
      service.enqueue('B', '2', SyncOperation.create, '{}');
      final third = service.enqueue('C', '3', SyncOperation.create, '{}');
      service.markSynced(third, DateTime.now());

      expect(service.getPendingCount(), 2);
    });

    test('returns 0 when queue is empty', () {
      expect(service.getPendingCount(), 0);
    });
  });

  group('SyncQueueItem immutability', () {
    test('copyWith returns new instance with updated fields', () {
      final item = SyncQueueItem(
        itemId: 'item-1',
        entityType: 'Client',
        entityId: 'c-1',
        operation: SyncOperation.create,
        payload: '{}',
        createdAt: DateTime(2025, 1, 1),
        status: SyncStatus.pending,
      );

      final updated = item.copyWith(status: SyncStatus.synced);
      expect(updated.status, SyncStatus.synced);
      expect(updated.itemId, 'item-1');
      expect(identical(item, updated), isFalse);
    });

    test('operator == is based on itemId', () {
      final a = SyncQueueItem(
        itemId: 'item-1',
        entityType: 'A',
        entityId: 'e-1',
        operation: SyncOperation.create,
        payload: '{}',
        createdAt: DateTime(2025, 1, 1),
        status: SyncStatus.pending,
      );
      final b = SyncQueueItem(
        itemId: 'item-1',
        entityType: 'B',
        entityId: 'e-2',
        operation: SyncOperation.delete,
        payload: '{"x":1}',
        createdAt: DateTime(2025, 6, 1),
        status: SyncStatus.synced,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}

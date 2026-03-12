import 'dart:convert';

import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';

/// In-memory offline sync queue service.
///
/// Manages the lifecycle of [SyncQueueItem] entries that represent local
/// mutations to be synchronised with the remote server.
/// Production implementations persist the queue to a local SQLite database.
class OfflineSyncService {
  OfflineSyncService();

  final Map<String, SyncQueueItem> _queue = {};
  int _counter = 0;

  String _nextId() {
    _counter++;
    return 'sync-${DateTime.now().millisecondsSinceEpoch}-$_counter';
  }

  /// Creates a new [SyncQueueItem] in [SyncStatus.pending] and adds it to the
  /// queue.
  SyncQueueItem enqueue(
    String entityType,
    String entityId,
    SyncOperation operation,
    String payload,
  ) {
    final item = SyncQueueItem(
      itemId: _nextId(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
      status: SyncStatus.pending,
    );
    _queue[item.itemId] = item;
    return item;
  }

  /// Returns all items currently in [SyncStatus.pending] state.
  List<SyncQueueItem> getPendingItems() {
    return _queue.values
        .where((i) => i.status == SyncStatus.pending)
        .toList(growable: false);
  }

  /// Marks [item] as [SyncStatus.synced] with the provided [syncedAt] time.
  ///
  /// Returns a new immutable [SyncQueueItem]; the internal store is updated.
  SyncQueueItem markSynced(SyncQueueItem item, DateTime syncedAt) {
    final updated = item.copyWith(
      status: SyncStatus.synced,
      syncedAt: syncedAt,
    );
    _queue[item.itemId] = updated;
    return updated;
  }

  /// Marks [item] as [SyncStatus.failed].
  ///
  /// Returns a new immutable [SyncQueueItem]; the internal store is updated.
  SyncQueueItem markFailed(SyncQueueItem item) {
    final updated = item.copyWith(status: SyncStatus.failed);
    _queue[item.itemId] = updated;
    return updated;
  }

  /// Returns true when [serverVersion] differs from [item]'s JSON payload.
  ///
  /// Comparison is performed by re-encoding [serverVersion] and doing a
  /// string equality check against the local [SyncQueueItem.payload].
  bool detectConflict(
    SyncQueueItem item,
    Map<String, dynamic> serverVersion,
  ) {
    final serverJson = jsonEncode(serverVersion);
    return item.payload != serverJson;
  }

  /// Records the conflict [resolution] strategy on [item] and sets its status
  /// to [SyncStatus.conflicted].
  ///
  /// Returns a new immutable [SyncQueueItem]; the internal store is updated.
  SyncQueueItem resolveConflict(
    SyncQueueItem item,
    ConflictResolution resolution,
  ) {
    final updated = item.copyWith(
      status: SyncStatus.conflicted,
      conflictResolution: resolution,
    );
    _queue[item.itemId] = updated;
    return updated;
  }

  /// Returns the number of items in [SyncStatus.pending] state.
  int getPendingCount() {
    return _queue.values
        .where((i) => i.status == SyncStatus.pending)
        .length;
  }
}

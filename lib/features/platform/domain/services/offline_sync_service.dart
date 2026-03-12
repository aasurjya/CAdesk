// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';

/// Service managing offline mutation queuing, conflict detection, and resolution.
///
/// Each instance maintains its own in-memory queue — use a fresh instance
/// per test to avoid state leakage.
final class OfflineSyncService {
  OfflineSyncService();

  final Map<String, SyncQueueItem> _queue = {};
  int _counter = 0;

  // ---------------------------------------------------------------------------
  // Enqueue
  // ---------------------------------------------------------------------------

  /// Adds a new [SyncQueueItem] with [SyncStatus.pending] to the queue.
  SyncQueueItem enqueue(
    String entityType,
    String entityId,
    SyncOperation operation,
    String payload,
  ) {
    _counter++;
    final item = SyncQueueItem(
      itemId: 'sync-$_counter-${DateTime.now().microsecondsSinceEpoch}',
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

  // ---------------------------------------------------------------------------
  // Status transitions (immutable — always return new instances)
  // ---------------------------------------------------------------------------

  /// Marks [item] as synced, records [syncedAt], and updates the queue.
  SyncQueueItem markSynced(SyncQueueItem item, DateTime syncedAt) {
    final updated = item.copyWith(
      status: SyncStatus.synced,
      syncedAt: syncedAt,
    );
    _queue[item.itemId] = updated;
    return updated;
  }

  /// Marks [item] as failed and updates the queue.
  SyncQueueItem markFailed(SyncQueueItem item) {
    final updated = item.copyWith(status: SyncStatus.failed);
    _queue[item.itemId] = updated;
    return updated;
  }

  /// Records [resolution] on [item] with status [SyncStatus.conflicted].
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

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns all items currently in [SyncStatus.pending] state.
  List<SyncQueueItem> getPendingItems() {
    return _queue.values
        .where((i) => i.status == SyncStatus.pending)
        .toList();
  }

  /// Returns the count of items in [SyncStatus.pending] state.
  int getPendingCount() => getPendingItems().length;

  // ---------------------------------------------------------------------------
  // Conflict detection
  // ---------------------------------------------------------------------------

  /// Returns `true` when the JSON [serverVersion] differs from [item.payload].
  ///
  /// Compares the decoded maps by value equality so field-ordering differences
  /// do not produce false positives.
  bool detectConflict(
    SyncQueueItem item,
    Map<String, dynamic> serverVersion,
  ) {
    try {
      final local = jsonDecode(item.payload) as Map<String, dynamic>;
      return !_mapsEqual(local, serverVersion);
    } catch (_) {
      return true;
    }
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final av = a[key];
      final bv = b[key];
      if (av is Map<String, dynamic> && bv is Map<String, dynamic>) {
        if (!_mapsEqual(av, bv)) return false;
      } else if (av != bv) {
        return false;
      }
    }
    return true;
  }
}

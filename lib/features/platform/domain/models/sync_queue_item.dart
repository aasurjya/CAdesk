<<<<<<< HEAD
// ignore_for_file: public_member_api_docs

/// CRUD operations that can be queued for offline sync.
enum SyncOperation { create, update, delete }

/// Status of an item in the offline sync queue.
enum SyncStatus { pending, synced, failed, conflicted }

/// How a sync conflict was resolved.
enum ConflictResolution { serverWins, clientWins, manual }

/// Immutable record of a queued offline mutation.
final class SyncQueueItem {
=======
/// The CRUD operation type being queued for sync.
enum SyncOperation { create, update, delete }

/// Lifecycle status of a sync queue item.
enum SyncStatus {
  /// Waiting to be synced.
  pending,

  /// Currently being sent to the server.
  syncing,

  /// Successfully synced.
  synced,

  /// Sync attempt failed; will retry.
  failed,

  /// A conflict was detected between local and server versions.
  conflicted,
}

/// Strategy for resolving a server vs. client data conflict.
enum ConflictResolution {
  /// Accept the server's version as the truth.
  serverWins,

  /// Keep the client's version and overwrite the server.
  clientWins,

  /// Requires manual intervention to merge the two versions.
  manual,
}

/// Immutable entry in the offline sync queue.
class SyncQueueItem {
>>>>>>> worktree-agent-ad3dc1f5
  const SyncQueueItem({
    required this.itemId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.status,
    this.syncedAt,
    this.conflictResolution,
  });

  final String itemId;
<<<<<<< HEAD
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final String payload;
  final DateTime createdAt;
  final SyncStatus status;
  final DateTime? syncedAt;
=======

  /// Domain entity type, e.g. "Client", "FilingJob".
  final String entityType;
  final String entityId;
  final SyncOperation operation;

  /// JSON-serialised entity payload.
  final String payload;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final SyncStatus status;
>>>>>>> worktree-agent-ad3dc1f5
  final ConflictResolution? conflictResolution;

  SyncQueueItem copyWith({
    String? itemId,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    String? payload,
    DateTime? createdAt,
<<<<<<< HEAD
    SyncStatus? status,
    DateTime? syncedAt,
=======
    DateTime? syncedAt,
    SyncStatus? status,
>>>>>>> worktree-agent-ad3dc1f5
    ConflictResolution? conflictResolution,
  }) {
    return SyncQueueItem(
      itemId: itemId ?? this.itemId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
<<<<<<< HEAD
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
=======
      syncedAt: syncedAt ?? this.syncedAt,
      status: status ?? this.status,
>>>>>>> worktree-agent-ad3dc1f5
      conflictResolution: conflictResolution ?? this.conflictResolution,
    );
  }

<<<<<<< HEAD
  /// Equality is based solely on [itemId].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItem &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId;
=======
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem && other.itemId == itemId;
  }
>>>>>>> worktree-agent-ad3dc1f5

  @override
  int get hashCode => itemId.hashCode;

  @override
  String toString() =>
      'SyncQueueItem(itemId: $itemId, entityType: $entityType, '
<<<<<<< HEAD
      'entityId: $entityId, operation: $operation, status: $status)';
=======
      'operation: $operation, status: $status)';
>>>>>>> worktree-agent-ad3dc1f5
}

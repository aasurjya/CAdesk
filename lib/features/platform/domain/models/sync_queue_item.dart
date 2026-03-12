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

  /// Domain entity type, e.g. "Client", "FilingJob".
  final String entityType;
  final String entityId;
  final SyncOperation operation;

  /// JSON-serialised entity payload.
  final String payload;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final SyncStatus status;
  final ConflictResolution? conflictResolution;

  SyncQueueItem copyWith({
    String? itemId,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    String? payload,
    DateTime? createdAt,
    DateTime? syncedAt,
    SyncStatus? status,
    ConflictResolution? conflictResolution,
  }) {
    return SyncQueueItem(
      itemId: itemId ?? this.itemId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      status: status ?? this.status,
      conflictResolution: conflictResolution ?? this.conflictResolution,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;

  @override
  String toString() =>
      'SyncQueueItem(itemId: $itemId, entityType: $entityType, '
      'operation: $operation, status: $status)';
}

// ignore_for_file: public_member_api_docs

/// CRUD operations that can be queued for offline sync.
enum SyncOperation { create, update, delete }

/// Status of an item in the offline sync queue.
enum SyncStatus { pending, synced, failed, conflicted }

/// How a sync conflict was resolved.
enum ConflictResolution { serverWins, clientWins, manual }

/// Immutable record of a queued offline mutation.
final class SyncQueueItem {
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
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final String payload;
  final DateTime createdAt;
  final SyncStatus status;
  final DateTime? syncedAt;
  final ConflictResolution? conflictResolution;

  SyncQueueItem copyWith({
    String? itemId,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    String? payload,
    DateTime? createdAt,
    SyncStatus? status,
    DateTime? syncedAt,
    ConflictResolution? conflictResolution,
  }) {
    return SyncQueueItem(
      itemId: itemId ?? this.itemId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
      conflictResolution: conflictResolution ?? this.conflictResolution,
    );
  }

  /// Equality is based solely on [itemId].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItem &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId;

  @override
  int get hashCode => itemId.hashCode;

  @override
  String toString() =>
      'SyncQueueItem(itemId: $itemId, entityType: $entityType, '
      'entityId: $entityId, operation: $operation, status: $status)';
}

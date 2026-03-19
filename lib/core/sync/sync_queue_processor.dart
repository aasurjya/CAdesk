/// The type of database operation recorded in a sync queue entry.
enum SyncOperation { insert, update, delete }

/// Immutable record of a pending database change waiting to be synced.
class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.localTimestamp,
    this.retryCount = 0,
  });

  /// Unique identifier for this queue entry.
  final String id;

  /// Name of the local database table the change belongs to.
  final String tableName;

  /// Primary key of the record being synced.
  final String recordId;

  /// Operation that was performed locally.
  final SyncOperation operation;

  /// Full record payload for [SyncOperation.insert] and [SyncOperation.update].
  /// Empty map for [SyncOperation.delete].
  final Map<String, Object?> data;

  /// Timestamp of the local write that produced this entry.
  final DateTime localTimestamp;

  /// Number of times this item has been retried after a transient failure.
  final int retryCount;

  SyncQueueItem copyWith({
    String? id,
    String? tableName,
    String? recordId,
    SyncOperation? operation,
    Map<String, Object?>? data,
    DateTime? localTimestamp,
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem &&
        other.id == id &&
        other.tableName == tableName &&
        other.recordId == recordId &&
        other.operation == operation &&
        other.localTimestamp == localTimestamp;
  }

  @override
  int get hashCode =>
      Object.hash(id, tableName, recordId, operation, localTimestamp);

  @override
  String toString() =>
      'SyncQueueItem(id: $id, table: $tableName, '
      'record: $recordId, op: ${operation.name})';
}

/// Immutable progress snapshot emitted by [SyncQueueProcessor.processPendingItems].
class SyncProgress {
  const SyncProgress({
    required this.total,
    required this.processed,
    required this.failed,
    this.currentItem,
    this.errorMessage,
  });

  /// Total number of items in the current sync batch.
  final int total;

  /// Items successfully synced so far.
  final int processed;

  /// Items that failed to sync after all retries.
  final int failed;

  /// The item currently being processed; `null` when the batch is complete.
  final SyncQueueItem? currentItem;

  /// Error detail when the latest item failed; `null` on success.
  final String? errorMessage;

  /// Returns `true` when all items have been processed or failed.
  bool get isComplete => processed + failed >= total;

  /// Fraction of [total] items handled (0.0–1.0).
  double get progressFraction => total > 0 ? (processed + failed) / total : 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncProgress &&
        other.total == total &&
        other.processed == processed &&
        other.failed == failed;
  }

  @override
  int get hashCode => Object.hash(total, processed, failed);

  @override
  String toString() =>
      'SyncProgress($processed/$total processed, $failed failed)';
}

/// Processes a batch of [SyncQueueItem]s using a last-write-wins conflict
/// resolution strategy.
///
/// Stateless — each call to [processPendingItems] is independent.
/// Pass a [syncHandler] callback to connect to the actual remote data
/// source (e.g. Supabase upsert). In tests, inject a mock handler.
///
/// Usage:
/// ```dart
/// final processor = SyncQueueProcessor();
/// final items = await localDb.getPendingItems();
/// await for (final progress in processor.processPendingItems(items)) {
///   print(progress);
/// }
/// ```
class SyncQueueProcessor {
  const SyncQueueProcessor({
    Future<void> Function(SyncQueueItem item)? syncHandler,
  }) : _syncHandler = syncHandler;

  /// Called for each item during [processPendingItems].
  ///
  /// When `null`, the processor simulates a successful sync (useful in tests
  /// and during development before the remote layer is wired up).
  final Future<void> Function(SyncQueueItem item)? _syncHandler;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Processes [items] one by one, yielding a [SyncProgress] snapshot after
  /// each item is handled.
  ///
  /// Items are processed in the order they appear in [items]. When an item
  /// fails (the [syncHandler] throws), the failure is recorded in
  /// [SyncProgress.failed] and execution continues with the next item —
  /// no item permanently blocks the queue.
  ///
  /// Yields:
  /// - One [SyncProgress] per item as it starts processing.
  /// - A final [SyncProgress] with [SyncProgress.isComplete] == `true`.
  Stream<SyncProgress> processPendingItems(List<SyncQueueItem> items) async* {
    if (items.isEmpty) {
      yield const SyncProgress(total: 0, processed: 0, failed: 0);
      return;
    }

    var processed = 0;
    var failed = 0;

    for (final item in items) {
      yield SyncProgress(
        total: items.length,
        processed: processed,
        failed: failed,
        currentItem: item,
      );

      try {
        await _handleItem(item);
        processed++;
        yield SyncProgress(
          total: items.length,
          processed: processed,
          failed: failed,
          currentItem: item,
        );
      } catch (e) {
        failed++;
        yield SyncProgress(
          total: items.length,
          processed: processed,
          failed: failed,
          currentItem: item,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// Resolves a conflict between a [local] and [remote] version of the same
  /// record using last-write-wins (the newer [SyncQueueItem.localTimestamp]
  /// takes precedence).
  ///
  /// Returns [local] when its timestamp is strictly later than [remote]'s.
  /// Returns [remote] otherwise (ties go to remote — server authority).
  ///
  /// The winning item's [retryCount] is reset to zero.
  SyncQueueItem resolveConflict(SyncQueueItem local, SyncQueueItem remote) {
    final winner = local.localTimestamp.isAfter(remote.localTimestamp)
        ? local
        : remote;
    return winner.copyWith(retryCount: 0);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _handleItem(SyncQueueItem item) async {
    final handler = _syncHandler;
    if (handler != null) {
      await handler(item);
    }
    // When no handler is provided, simulate a successful no-op sync.
  }
}

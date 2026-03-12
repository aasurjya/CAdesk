/// Status of a single item within a batch job.
enum BatchJobItemStatus {
  pending,
  processing,
  completed,
  failed,
  skipped,
}

/// Immutable model representing one unit of work within a [BatchJob].
///
/// Each item corresponds to a single client's filing or export task.
class BatchJobItem {
  const BatchJobItem({
    required this.itemId,
    required this.clientName,
    required this.pan,
    required this.payload,
    required this.status,
    required this.attempts,
    this.lastAttemptAt,
    this.error,
    this.completedAt,
  });

  /// Unique identifier for this item within the job.
  final String itemId;

  /// Human-readable client name (e.g. "Rahul Sharma").
  final String clientName;

  /// PAN or GSTIN of the client.
  final String pan;

  /// JSON-encoded payload describing what needs to be filed or exported.
  final String payload;

  /// Current processing status of this item.
  final BatchJobItemStatus status;

  /// Number of processing attempts made so far.
  final int attempts;

  /// Timestamp of the most recent processing attempt, or null if not yet tried.
  final DateTime? lastAttemptAt;

  /// Error code from the last failed attempt, or null if no failure.
  final String? error;

  /// Timestamp when this item was successfully completed, or null.
  final DateTime? completedAt;

  BatchJobItem copyWith({
    String? itemId,
    String? clientName,
    String? pan,
    String? payload,
    BatchJobItemStatus? status,
    int? attempts,
    DateTime? lastAttemptAt,
    String? error,
    DateTime? completedAt,
    bool clearError = false,
    bool clearCompletedAt = false,
    bool clearLastAttemptAt = false,
  }) {
    return BatchJobItem(
      itemId: itemId ?? this.itemId,
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: clearLastAttemptAt ? null : (lastAttemptAt ?? this.lastAttemptAt),
      error: clearError ? null : (error ?? this.error),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BatchJobItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;

  @override
  String toString() =>
      'BatchJobItem(itemId: $itemId, client: $clientName, status: $status, attempts: $attempts)';
}

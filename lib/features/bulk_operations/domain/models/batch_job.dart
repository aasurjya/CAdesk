import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';

/// Type of work performed by a [BatchJob].
enum JobType {
  itrFiling,
  gstFiling,
  tdsFiling,
  bulkExport,
  bulkSigning,
}

/// Priority level for scheduling a [BatchJob].
///
/// Higher priority values are processed first.
enum JobPriority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  const JobPriority(this.level);

  /// Numeric level used for sorting (higher = higher priority).
  final int level;
}

/// Lifecycle status of a [BatchJob].
enum JobStatus {
  queued,
  running,
  paused,
  completed,
  failed,
  cancelled,
}

/// Immutable model representing a batch of related filing or export operations.
///
/// Computed properties [totalItems] and [progress] are derived from [items]
/// and [completedItems] — they are never stored separately.
class BatchJob {
  const BatchJob({
    required this.jobId,
    required this.name,
    required this.jobType,
    required this.priority,
    required this.items,
    required this.status,
    required this.completedItems,
    required this.failedItems,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  /// Unique identifier for this job.
  final String jobId;

  /// Human-readable name (e.g. "Bulk ITR Filing — July 2025").
  final String name;

  /// The category of work this job performs.
  final JobType jobType;

  /// Scheduling priority; higher priority jobs are dequeued first.
  final JobPriority priority;

  /// Ordered list of individual work items in this job.
  final List<BatchJobItem> items;

  /// Current lifecycle status.
  final JobStatus status;

  /// Timestamp when this job transitioned to [JobStatus.running].
  final DateTime? startedAt;

  /// Timestamp when this job reached a terminal state (completed/failed/cancelled).
  final DateTime? completedAt;

  /// Number of items that have been successfully completed.
  final int completedItems;

  /// Number of items that have failed (all retry attempts exhausted).
  final int failedItems;

  /// Creation timestamp used for FIFO ordering within the same priority.
  final DateTime createdAt;

  // ── Computed properties ────────────────────────────────────────────────────

  /// Total number of items in this job.
  int get totalItems => items.length;

  /// Fraction of items completed, in the range [0.0, 1.0].
  ///
  /// Returns 0.0 when there are no items to avoid division by zero.
  double get progress =>
      totalItems == 0 ? 0.0 : completedItems / totalItems;

  // ── Immutable update ───────────────────────────────────────────────────────

  BatchJob copyWith({
    String? jobId,
    String? name,
    JobType? jobType,
    JobPriority? priority,
    List<BatchJobItem>? items,
    JobStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? completedItems,
    int? failedItems,
    DateTime? createdAt,
  }) {
    return BatchJob(
      jobId: jobId ?? this.jobId,
      name: name ?? this.name,
      jobType: jobType ?? this.jobType,
      priority: priority ?? this.priority,
      items: items ?? this.items,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      completedItems: completedItems ?? this.completedItems,
      failedItems: failedItems ?? this.failedItems,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BatchJob && other.jobId == jobId;
  }

  @override
  int get hashCode => jobId.hashCode;

  @override
  String toString() =>
      'BatchJob(jobId: $jobId, name: $name, status: $status, '
      'progress: ${(progress * 100).toStringAsFixed(1)}%)';
}

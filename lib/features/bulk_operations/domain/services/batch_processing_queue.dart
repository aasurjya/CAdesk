import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

/// In-memory priority queue for [BatchJob] instances.
///
/// Jobs are dequeued in priority order (critical → high → normal → low).
/// Within the same priority, FIFO order is maintained using [BatchJob.createdAt].
///
/// This is pure domain logic with no persistence — use a repository layer to
/// persist queue state across sessions.
class BatchProcessingQueue {
  BatchProcessingQueue() : _queue = [];

  final List<BatchJob> _queue;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Adds [job] to the queue and returns it (with [JobStatus.queued] ensured).
  ///
  /// Returns a new [BatchJob] instance — the original is never mutated.
  BatchJob enqueue(BatchJob job) {
    final queued = job.copyWith(status: JobStatus.queued);
    _queue.add(queued);
    return queued;
  }

  /// Removes and returns the highest-priority queued job, or null if empty.
  ///
  /// When [filterType] is provided, only jobs of that [JobType] are considered.
  /// Jobs of other types remain in the queue untouched.
  BatchJob? dequeue([JobType? filterType]) {
    // Build candidate list respecting optional type filter.
    final candidates = _queue
        .where(
          (j) =>
              j.status == JobStatus.queued &&
              (filterType == null || j.jobType == filterType),
        )
        .toList();

    if (candidates.isEmpty) return null;

    // Sort by priority (descending) then by createdAt (ascending — FIFO).
    candidates.sort(_compareJobs);

    final top = candidates.first;
    _queue.remove(top);
    return top;
  }

  /// Returns a new sorted list of [jobs] ordered by priority then FIFO.
  ///
  /// The original list is never mutated.
  List<BatchJob> prioritizeJobs(List<BatchJob> jobs) {
    final copy = List<BatchJob>.of(jobs);
    copy.sort(_compareJobs);
    return copy;
  }

  /// Returns the number of jobs currently in the queue with status
  /// [JobStatus.queued] or [JobStatus.running].
  int getQueueDepth() {
    return _queue
        .where(
          (j) =>
              j.status == JobStatus.queued || j.status == JobStatus.running,
        )
        .length;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Comparator: higher priority first; tie-break by earlier createdAt (FIFO).
  static int _compareJobs(BatchJob a, BatchJob b) {
    final priorityDiff = b.priority.level - a.priority.level;
    if (priorityDiff != 0) return priorityDiff;
    return a.createdAt.compareTo(b.createdAt);
  }
}

import 'dart:math' as math;

import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
import 'package:ca_app/features/bulk_operations/domain/models/retry_policy.dart';

/// Stateless engine encapsulating all retry decision logic.
///
/// All methods are static — no instance state is needed or maintained.
class RetryEngine {
  const RetryEngine._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true when [item] is eligible for another processing attempt
  /// according to [policy].
  ///
  /// Criteria (all must hold):
  /// - [item.attempts] < [policy.maxAttempts]
  /// - [item.error] is non-null and present in [policy.retryableErrorCodes]
  static bool shouldRetry(BatchJobItem item, RetryPolicy policy) {
    if (item.attempts >= policy.maxAttempts) return false;
    final error = item.error;
    if (error == null) return false;
    return policy.retryableErrorCodes.contains(error);
  }

  /// Computes the delay before the [attemptNumber]-th retry attempt.
  ///
  /// Uses exponential back-off:
  /// `delay = initialDelay × backoffMultiplier^(attemptNumber - 1)`,
  /// capped at [policy.maxDelaySeconds].
  ///
  /// [attemptNumber] is 1-based: pass 1 for the first retry.
  static Duration computeRetryDelay(int attemptNumber, RetryPolicy policy) {
    final rawSeconds =
        policy.initialDelaySeconds *
        math.pow(policy.backoffMultiplier, attemptNumber - 1);
    final cappedSeconds = math.min(
      rawSeconds,
      policy.maxDelaySeconds.toDouble(),
    );
    return Duration(seconds: cappedSeconds.round());
  }

  /// Returns a new [BatchJobItem] ready to be reprocessed.
  ///
  /// Increments [BatchJobItem.attempts] by 1, resets status to
  /// [BatchJobItemStatus.pending], and clears the [BatchJobItem.error] field.
  /// All other fields are preserved.
  static BatchJobItem retryItem(BatchJobItem item) {
    return item.copyWith(
      attempts: item.attempts + 1,
      status: BatchJobItemStatus.pending,
      clearError: true,
    );
  }

  /// Creates a new [BatchJob] containing only the failed items from [failedJob].
  ///
  /// Each failed item is reset to pending via [retryItem]. The new job:
  /// - Gets a fresh unique [BatchJob.jobId]
  /// - Has [JobStatus.queued] status
  /// - Inherits [BatchJob.priority] from [failedJob]
  /// - Starts with 0 [BatchJob.completedItems] and 0 [BatchJob.failedItems]
  static BatchJob createRetryJob(BatchJob failedJob) {
    final failedItems = failedJob.items
        .where((i) => i.status == BatchJobItemStatus.failed)
        .map(retryItem)
        .toList();

    final newJobId =
        'retry-${failedJob.jobId}-${DateTime.now().millisecondsSinceEpoch}';

    return BatchJob(
      jobId: newJobId,
      name: 'Retry: ${failedJob.name}',
      jobType: failedJob.jobType,
      priority: failedJob.priority,
      items: failedItems,
      status: JobStatus.queued,
      completedItems: 0,
      failedItems: 0,
      createdAt: DateTime.now(),
    );
  }
}

import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
import 'package:ca_app/features/bulk_operations/domain/models/retry_policy.dart';
import 'package:ca_app/features/bulk_operations/domain/services/retry_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 7, 1, 10, 0);

  const defaultPolicy = RetryPolicy(
    maxAttempts: 3,
    initialDelaySeconds: 30,
    backoffMultiplier: 2.0,
    maxDelaySeconds: 3600,
    retryableErrorCodes: ['PORTAL_TIMEOUT', 'RATE_LIMIT', 'SERVER_ERROR_5XX'],
  );

  BatchJobItem makeFailedItem({
    String id = 'item-1',
    int attempts = 1,
    String? error,
  }) {
    return BatchJobItem(
      itemId: id,
      clientName: 'Test Client',
      pan: 'ABCDE1234F',
      payload: '{}',
      status: BatchJobItemStatus.failed,
      attempts: attempts,
      lastAttemptAt: now,
      error: error,
    );
  }

  BatchJob makeFailedJob({required String id, List<BatchJobItem>? items}) {
    final jobItems = items ??
        [
          makeFailedItem(id: '$id-item-1', attempts: 1),
          makeFailedItem(id: '$id-item-2', attempts: 2),
          BatchJobItem(
            itemId: '$id-item-3',
            clientName: 'Client OK',
            pan: 'XYZOK5678G',
            payload: '{}',
            status: BatchJobItemStatus.completed,
            attempts: 1,
          ),
        ];
    return BatchJob(
      jobId: id,
      name: 'Job $id',
      jobType: JobType.itrFiling,
      priority: JobPriority.normal,
      items: jobItems,
      status: JobStatus.failed,
      completedItems: 1,
      failedItems: 2,
      createdAt: now,
    );
  }

  group('RetryEngine.shouldRetry', () {
    test('returns true when attempts < maxAttempts and error is retryable', () {
      final item = makeFailedItem(attempts: 1, error: 'PORTAL_TIMEOUT');
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isTrue);
    });

    test('returns false when attempts >= maxAttempts', () {
      final item = makeFailedItem(attempts: 3, error: 'PORTAL_TIMEOUT');
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isFalse);
    });

    test('returns false when error is non-retryable', () {
      final item = makeFailedItem(attempts: 1, error: 'VALIDATION_ERROR');
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isFalse);
    });

    test('returns false when error is null', () {
      final item = makeFailedItem(attempts: 1, error: null);
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isFalse);
    });

    test('returns false for AUTH_FAILED non-retryable error', () {
      final item = makeFailedItem(attempts: 1, error: 'AUTH_FAILED');
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isFalse);
    });

    test('returns false for DUPLICATE_FILING non-retryable error', () {
      final item = makeFailedItem(attempts: 1, error: 'DUPLICATE_FILING');
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isFalse);
    });

    test('returns true for RATE_LIMIT on attempt 2 of 3', () {
      final item = makeFailedItem(attempts: 2, error: 'RATE_LIMIT');
      expect(RetryEngine.shouldRetry(item, defaultPolicy), isTrue);
    });
  });

  group('RetryEngine.computeRetryDelay', () {
    test('attempt 1 returns initial delay (30s)', () {
      final delay = RetryEngine.computeRetryDelay(1, defaultPolicy);
      expect(delay.inSeconds, 30);
    });

    test('attempt 2 returns 60s (30 * 2^1)', () {
      final delay = RetryEngine.computeRetryDelay(2, defaultPolicy);
      expect(delay.inSeconds, 60);
    });

    test('attempt 3 returns 120s (30 * 2^2)', () {
      final delay = RetryEngine.computeRetryDelay(3, defaultPolicy);
      expect(delay.inSeconds, 120);
    });

    test('attempt 4 returns 240s (30 * 2^3)', () {
      final delay = RetryEngine.computeRetryDelay(4, defaultPolicy);
      expect(delay.inSeconds, 240);
    });

    test('delay is capped at maxDelaySeconds', () {
      const policy = RetryPolicy(
        maxAttempts: 10,
        initialDelaySeconds: 30,
        backoffMultiplier: 2.0,
        maxDelaySeconds: 100,
        retryableErrorCodes: ['PORTAL_TIMEOUT'],
      );
      final delay = RetryEngine.computeRetryDelay(5, policy);
      expect(delay.inSeconds, 100);
    });

    test('computeRetryDelay matches RetryPolicy.computeNextRetryDelay', () {
      final engineDelay = RetryEngine.computeRetryDelay(2, defaultPolicy);
      final policyDelay = defaultPolicy.computeNextRetryDelay(2);
      expect(engineDelay, policyDelay);
    });
  });

  group('RetryEngine.retryItem', () {
    test('increments attempts by 1', () {
      final item = makeFailedItem(attempts: 1);
      final retried = RetryEngine.retryItem(item);
      expect(retried.attempts, 2);
    });

    test('resets status to pending', () {
      final item = makeFailedItem(attempts: 1);
      final retried = RetryEngine.retryItem(item);
      expect(retried.status, BatchJobItemStatus.pending);
    });

    test('clears error field', () {
      final item = makeFailedItem(attempts: 1, error: 'PORTAL_TIMEOUT');
      final retried = RetryEngine.retryItem(item);
      expect(retried.error, isNull);
    });

    test('returns new object — original is not mutated', () {
      final item = makeFailedItem(attempts: 1);
      final retried = RetryEngine.retryItem(item);
      expect(identical(item, retried), isFalse);
      expect(item.attempts, 1); // original unchanged
    });

    test('preserves itemId, clientName, pan, payload', () {
      final item = BatchJobItem(
        itemId: 'i-99',
        clientName: 'Sharma',
        pan: 'ABCSH9999X',
        payload: '{"form": "ITR1"}',
        status: BatchJobItemStatus.failed,
        attempts: 2,
      );
      final retried = RetryEngine.retryItem(item);
      expect(retried.itemId, 'i-99');
      expect(retried.clientName, 'Sharma');
      expect(retried.pan, 'ABCSH9999X');
      expect(retried.payload, '{"form": "ITR1"}');
    });
  });

  group('RetryEngine.createRetryJob', () {
    test('creates a new job with only failed items', () {
      final original = makeFailedJob(id: 'orig');
      final retryJob = RetryEngine.createRetryJob(original);

      expect(retryJob.items.length, 2); // only the 2 failed items
      expect(retryJob.items.every((i) => i.status == BatchJobItemStatus.pending), isTrue);
    });

    test('new job has queued status', () {
      final original = makeFailedJob(id: 'orig');
      final retryJob = RetryEngine.createRetryJob(original);
      expect(retryJob.status, JobStatus.queued);
    });

    test('new job has a different jobId', () {
      final original = makeFailedJob(id: 'orig');
      final retryJob = RetryEngine.createRetryJob(original);
      expect(retryJob.jobId, isNot(original.jobId));
    });

    test('new job inherits priority from original', () {
      final original = makeFailedJob(id: 'orig').copyWith(priority: JobPriority.critical);
      final retryJob = RetryEngine.createRetryJob(original);
      expect(retryJob.priority, JobPriority.critical);
    });

    test('new job has 0 completedItems and 0 failedItems', () {
      final original = makeFailedJob(id: 'orig');
      final retryJob = RetryEngine.createRetryJob(original);
      expect(retryJob.completedItems, 0);
      expect(retryJob.failedItems, 0);
    });

    test('returns empty items job if no failed items', () {
      final allOk = BatchJob(
        jobId: 'clean',
        name: 'Clean Job',
        jobType: JobType.itrFiling,
        priority: JobPriority.normal,
        items: const [],
        status: JobStatus.completed,
        completedItems: 2,
        failedItems: 0,
        createdAt: now,
      );
      final retryJob = RetryEngine.createRetryJob(allOk);
      expect(retryJob.items, isEmpty);
    });
  });
}

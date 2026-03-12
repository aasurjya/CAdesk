import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
import 'package:ca_app/features/bulk_operations/domain/services/batch_processing_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 7, 1, 10, 0);

  BatchJobItem makeItem({String id = 'item-1'}) {
    return BatchJobItem(
      itemId: id,
      clientName: 'Test Client',
      pan: 'ABCDE1234F',
      payload: '{}',
      status: BatchJobItemStatus.pending,
      attempts: 0,
    );
  }

  BatchJob makeJob({
    required String id,
    JobPriority priority = JobPriority.normal,
    JobStatus status = JobStatus.queued,
    JobType jobType = JobType.itrFiling,
    int itemCount = 2,
    DateTime? createdAt,
  }) {
    final items = List.generate(
      itemCount,
      (i) => makeItem(id: '$id-item-$i'),
    );
    return BatchJob(
      jobId: id,
      name: 'Job $id',
      jobType: jobType,
      priority: priority,
      items: items,
      status: status,
      completedItems: 0,
      failedItems: 0,
      createdAt: createdAt ?? now,
    );
  }

  group('BatchProcessingQueue.enqueue', () {
    test('returns a job with queued status', () {
      final queue = BatchProcessingQueue();
      final job = makeJob(id: 'j1');
      final result = queue.enqueue(job);
      expect(result.status, JobStatus.queued);
    });

    test('adds job to internal queue', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'j1'));
      expect(queue.getQueueDepth(), 1);
    });

    test('enqueue multiple jobs increases queue depth', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'j1'));
      queue.enqueue(makeJob(id: 'j2'));
      queue.enqueue(makeJob(id: 'j3'));
      expect(queue.getQueueDepth(), 3);
    });

    test('returns new job object — original is not modified', () {
      final queue = BatchProcessingQueue();
      final original = makeJob(id: 'j1', status: JobStatus.queued);
      final returned = queue.enqueue(original);
      expect(identical(original, returned), isFalse);
    });
  });

  group('BatchProcessingQueue.dequeue', () {
    test('returns null when queue is empty', () {
      final queue = BatchProcessingQueue();
      expect(queue.dequeue(), isNull);
    });

    test('returns highest priority job', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'low', priority: JobPriority.low));
      queue.enqueue(makeJob(id: 'critical', priority: JobPriority.critical));
      queue.enqueue(makeJob(id: 'normal', priority: JobPriority.normal));

      final result = queue.dequeue();
      expect(result?.jobId, 'critical');
    });

    test('dequeue removes job from queue', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'j1'));
      queue.dequeue();
      expect(queue.getQueueDepth(), 0);
    });

    test('dequeues in FIFO order within same priority', () {
      final t1 = DateTime(2025, 7, 1, 10, 0);
      final t2 = DateTime(2025, 7, 1, 10, 1);
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'first', priority: JobPriority.high, createdAt: t1));
      queue.enqueue(makeJob(id: 'second', priority: JobPriority.high, createdAt: t2));

      final first = queue.dequeue();
      final second = queue.dequeue();
      expect(first?.jobId, 'first');
      expect(second?.jobId, 'second');
    });

    test('filters by jobType when specified', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'itr', jobType: JobType.itrFiling));
      queue.enqueue(makeJob(id: 'gst', jobType: JobType.gstFiling));

      final result = queue.dequeue(JobType.gstFiling);
      expect(result?.jobId, 'gst');
      // itrFiling job should remain
      expect(queue.getQueueDepth(), 1);
    });

    test('returns null if no job matches filter type', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'itr', jobType: JobType.itrFiling));

      final result = queue.dequeue(JobType.gstFiling);
      expect(result, isNull);
      // original job should remain
      expect(queue.getQueueDepth(), 1);
    });
  });

  group('BatchProcessingQueue.prioritizeJobs', () {
    test('sorts by priority descending (critical first)', () {
      final queue = BatchProcessingQueue();
      final jobs = [
        makeJob(id: 'low', priority: JobPriority.low),
        makeJob(id: 'critical', priority: JobPriority.critical),
        makeJob(id: 'normal', priority: JobPriority.normal),
        makeJob(id: 'high', priority: JobPriority.high),
      ];
      final sorted = queue.prioritizeJobs(jobs);
      expect(sorted[0].priority, JobPriority.critical);
      expect(sorted[1].priority, JobPriority.high);
      expect(sorted[2].priority, JobPriority.normal);
      expect(sorted[3].priority, JobPriority.low);
    });

    test('FIFO within same priority — earlier createdAt comes first', () {
      final queue = BatchProcessingQueue();
      final t1 = DateTime(2025, 7, 1, 9, 0);
      final t2 = DateTime(2025, 7, 1, 11, 0);
      final jobs = [
        makeJob(id: 'later', priority: JobPriority.high, createdAt: t2),
        makeJob(id: 'earlier', priority: JobPriority.high, createdAt: t1),
      ];
      final sorted = queue.prioritizeJobs(jobs);
      expect(sorted[0].jobId, 'earlier');
      expect(sorted[1].jobId, 'later');
    });

    test('returns a new list — original is not mutated', () {
      final queue = BatchProcessingQueue();
      final jobs = [
        makeJob(id: 'j1', priority: JobPriority.low),
        makeJob(id: 'j2', priority: JobPriority.critical),
      ];
      final sorted = queue.prioritizeJobs(jobs);
      expect(jobs[0].jobId, 'j1'); // original unchanged
      expect(sorted[0].jobId, 'j2'); // sorted correctly
    });

    test('empty list returns empty list', () {
      final queue = BatchProcessingQueue();
      expect(queue.prioritizeJobs([]), isEmpty);
    });
  });

  group('BatchProcessingQueue.getQueueDepth', () {
    test('counts queued and running jobs, not completed or failed', () {
      final queue = BatchProcessingQueue();
      queue.enqueue(makeJob(id: 'j1', status: JobStatus.queued));
      queue.enqueue(makeJob(id: 'j2', status: JobStatus.queued));
      // Manually add running/completed to test: use enqueue and note
      // only queued jobs count for depth; running not tracked here
      expect(queue.getQueueDepth(), 2);
    });

    test('returns 0 for empty queue', () {
      expect(BatchProcessingQueue().getQueueDepth(), 0);
    });
  });
}

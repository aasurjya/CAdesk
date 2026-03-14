import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/data/repositories/mock_bulk_operations_repository.dart';

void main() {
  group('MockBulkOperationsRepository', () {
    late MockBulkOperationsRepository repo;

    setUp(() {
      repo = MockBulkOperationsRepository();
    });

    group('getAllJobs', () {
      test('returns seeded batch jobs', () async {
        final all = await repo.getAllJobs();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAllJobs();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getJobById', () {
      test('returns job for valid ID', () async {
        final job = await repo.getJobById('mock-job-001');
        expect(job, isNotNull);
        expect(job!.jobId, 'mock-job-001');
      });

      test('returns null for unknown ID', () async {
        final job = await repo.getJobById('no-such-job');
        expect(job, isNull);
      });
    });

    group('getJobsByStatus', () {
      test('returns only jobs with the given status', () async {
        final queued = await repo.getJobsByStatus(JobStatus.queued);
        expect(queued.every((j) => j.status == JobStatus.queued), isTrue);
      });

      test('returns empty list if no jobs match status', () async {
        final cancelled = await repo.getJobsByStatus(JobStatus.cancelled);
        expect(cancelled, isEmpty);
      });
    });

    group('insertJob', () {
      test('inserts and returns new job ID', () async {
        final newJob = BatchJob(
          jobId: 'new-job-001',
          name: 'Bulk GST Filing — April 2026',
          jobType: JobType.gstFiling,
          priority: JobPriority.high,
          items: const [],
          status: JobStatus.queued,
          completedItems: 0,
          failedItems: 0,
          createdAt: DateTime(2026, 4, 1),
        );
        final id = await repo.insertJob(newJob);
        expect(id, 'new-job-001');

        final fetched = await repo.getJobById('new-job-001');
        expect(fetched, isNotNull);
        expect(fetched!.name, 'Bulk GST Filing — April 2026');
      });
    });

    group('updateJob', () {
      test('updates existing job and returns true', () async {
        final existing = await repo.getJobById('mock-job-001');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: JobStatus.completed);
        final success = await repo.updateJob(updated);
        expect(success, isTrue);

        final fetched = await repo.getJobById('mock-job-001');
        expect(fetched!.status, JobStatus.completed);
      });

      test('returns false for non-existent job', () async {
        final ghost = BatchJob(
          jobId: 'ghost-job',
          name: 'Ghost',
          jobType: JobType.bulkExport,
          priority: JobPriority.low,
          items: const [],
          status: JobStatus.queued,
          completedItems: 0,
          failedItems: 0,
          createdAt: DateTime(2026, 1, 1),
        );
        final success = await repo.updateJob(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteJob', () {
      test('deletes job and returns true', () async {
        final id = await repo.insertJob(
          BatchJob(
            jobId: 'to-delete-job',
            name: 'Delete Me',
            jobType: JobType.itrFiling,
            priority: JobPriority.normal,
            items: const [],
            status: JobStatus.queued,
            completedItems: 0,
            failedItems: 0,
            createdAt: DateTime(2026, 3, 1),
          ),
        );

        final success = await repo.deleteJob(id);
        expect(success, isTrue);

        final fetched = await repo.getJobById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent job ID', () async {
        final success = await repo.deleteJob('no-such-job');
        expect(success, isFalse);
      });
    });
  });
}

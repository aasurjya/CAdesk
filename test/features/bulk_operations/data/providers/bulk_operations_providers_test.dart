import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/bulk_operations/data/providers/bulk_operations_providers.dart';
import 'package:ca_app/features/bulk_operations/domain/models/filing_batch.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

void main() {
  group('Bulk Operations Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // batchListProvider
    // -------------------------------------------------------------------------
    group('batchListProvider', () {
      test('initial state is non-empty list of batches', () {
        final batches = container.read(batchListProvider);
        expect(batches, isNotEmpty);
        expect(batches.length, greaterThanOrEqualTo(3));
      });

      test('all items are FilingBatch objects', () {
        final batches = container.read(batchListProvider);
        expect(batches, everyElement(isA<FilingBatch>()));
      });

      test('list is unmodifiable', () {
        final batches = container.read(batchListProvider);
        expect(() => batches.add(batches.first), throwsA(anything));
      });

      test('batches include varied types', () {
        final batches = container.read(batchListProvider);
        final types = batches.map((b) => b.type).toSet();
        expect(types.length, greaterThanOrEqualTo(2));
      });

      test('batches include varied statuses', () {
        final batches = container.read(batchListProvider);
        final statuses = batches.map((b) => b.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // batchListProvider.notifier mutations
    // -------------------------------------------------------------------------
    group('batchListProvider mutations', () {
      test('addBatch() prepends a new batch immutably', () {
        final before = container.read(batchListProvider).length;
        final newBatch = FilingBatch(
          batchId: 'batch-test-001',
          name: 'Test Batch',
          type: BatchType.itrFiling,
          status: BatchStatus.queued,
          jobs: const [],
          createdAt: DateTime(2026, 3, 15),
          financialYear: 'AY 2026-27',
        );
        container.read(batchListProvider.notifier).addBatch(newBatch);
        final after = container.read(batchListProvider);
        expect(after.length, before + 1);
        // addBatch prepends
        expect(after.first.batchId, 'batch-test-001');
      });

      test('updateBatch() replaces the batch with matching id', () {
        final original = container.read(batchListProvider).first;
        final updated = original.copyWith(status: BatchStatus.completed);
        container.read(batchListProvider.notifier).updateBatch(updated);
        final result = container.read(batchListProvider);
        final found = result.firstWhere((b) => b.batchId == original.batchId);
        expect(found.status, BatchStatus.completed);
      });

      test('removeBatch() removes batch with matching id', () {
        final before = container.read(batchListProvider);
        final idToRemove = before.first.batchId;
        container.read(batchListProvider.notifier).removeBatch(idToRemove);
        final after = container.read(batchListProvider);
        expect(after.length, before.length - 1);
        expect(after.any((b) => b.batchId == idToRemove), isFalse);
      });

      test('cancelBatch() sets batch status to cancelled', () {
        final batches = container.read(batchListProvider);
        final runningBatch = batches.firstWhere(
          (b) => b.status == BatchStatus.running,
        );
        container
            .read(batchListProvider.notifier)
            .cancelBatch(runningBatch.batchId);
        final after = container.read(batchListProvider);
        final found = after.firstWhere(
          (b) => b.batchId == runningBatch.batchId,
        );
        expect(found.status, BatchStatus.cancelled);
      });

      test('retryFailedJobs() resets failed jobs to queued', () {
        // Find a batch with failed jobs
        final batches = container.read(batchListProvider);
        final failedBatch = batches.firstWhere(
          (b) => b.status == BatchStatus.failed,
        );
        final failedJobCount = failedBatch.jobs
            .where((j) => j.status == JobStatus.failed)
            .length;
        expect(failedJobCount, greaterThan(0));

        container
            .read(batchListProvider.notifier)
            .retryFailedJobs(failedBatch.batchId);
        final after = container.read(batchListProvider);
        final retried = after.firstWhere(
          (b) => b.batchId == failedBatch.batchId,
        );

        // Status should change to running
        expect(retried.status, BatchStatus.running);
        // Previously failed jobs should now be queued
        final stillFailed = retried.jobs.where(
          (j) => j.status == JobStatus.failed,
        );
        expect(stillFailed, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // activeBatchProvider
    // -------------------------------------------------------------------------
    group('activeBatchProvider', () {
      test('initial state is null', () {
        expect(container.read(activeBatchProvider), isNull);
      });

      test('select() sets the active batch', () {
        final batch = container.read(batchListProvider).first;
        container.read(activeBatchProvider.notifier).select(batch);
        expect(container.read(activeBatchProvider), batch);
      });

      test('clear() resets active batch to null', () {
        final batch = container.read(batchListProvider).first;
        container.read(activeBatchProvider.notifier).select(batch);
        container.read(activeBatchProvider.notifier).clear();
        expect(container.read(activeBatchProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // batchStatsProvider
    // -------------------------------------------------------------------------
    group('batchStatsProvider', () {
      test('activeBatches counts running and queued batches', () {
        final batches = container.read(batchListProvider);
        final expectedActive = batches
            .where(
              (b) =>
                  b.status == BatchStatus.running ||
                  b.status == BatchStatus.queued,
            )
            .length;
        final stats = container.read(batchStatsProvider);
        expect(stats.activeBatches, expectedActive);
      });

      test('totalJobs equals sum of jobs across all batches', () {
        final batches = container.read(batchListProvider);
        final expectedTotal = batches.fold<int>(
          0,
          (sum, b) => sum + b.jobs.length,
        );
        final stats = container.read(batchStatsProvider);
        expect(stats.totalJobs, expectedTotal);
      });

      test('completedJobs counts completed jobs', () {
        final batches = container.read(batchListProvider);
        final expectedCompleted = batches
            .expand((b) => b.jobs)
            .where((j) => j.status == JobStatus.completed)
            .length;
        final stats = container.read(batchStatsProvider);
        expect(stats.completedJobs, expectedCompleted);
      });

      test('failedJobs counts failed jobs', () {
        final batches = container.read(batchListProvider);
        final expectedFailed = batches
            .expand((b) => b.jobs)
            .where((j) => j.status == JobStatus.failed)
            .length;
        final stats = container.read(batchStatsProvider);
        expect(stats.failedJobs, expectedFailed);
      });

      test('successRate is percentage between 0 and 100', () {
        final stats = container.read(batchStatsProvider);
        expect(stats.successRate, greaterThanOrEqualTo(0.0));
        expect(stats.successRate, lessThanOrEqualTo(100.0));
      });

      test('successRate is computed from completed / (completed + failed)', () {
        final batches = container.read(batchListProvider);
        final completed = batches
            .expand((b) => b.jobs)
            .where((j) => j.status == JobStatus.completed)
            .length;
        final failed = batches
            .expand((b) => b.jobs)
            .where((j) => j.status == JobStatus.failed)
            .length;
        final finished = completed + failed;
        final expectedRate = finished > 0 ? completed / finished * 100 : 0.0;
        final stats = container.read(batchStatsProvider);
        expect(stats.successRate, closeTo(expectedRate, 0.001));
      });

      test('stats update after adding a new batch', () {
        final before = container.read(batchStatsProvider);
        final newBatch = FilingBatch(
          batchId: 'batch-stats-test',
          name: 'Stats Test Batch',
          type: BatchType.gstFiling,
          status: BatchStatus.queued,
          jobs: const [],
          createdAt: DateTime(2026, 3, 15),
          financialYear: 'FY 2025-26',
        );
        container.read(batchListProvider.notifier).addBatch(newBatch);
        final after = container.read(batchStatsProvider);
        // Active batches count should increase (queued batch is active)
        expect(after.activeBatches, before.activeBatches + 1);
      });
    });
  });
}

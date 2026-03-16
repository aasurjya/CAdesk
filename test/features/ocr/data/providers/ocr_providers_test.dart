import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ocr/data/providers/ocr_providers.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_pipeline_service.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_data_mapper_service.dart';

void main() {
  group('OCR Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // ocrJobListProvider
    // -------------------------------------------------------------------------
    group('ocrJobListProvider', () {
      test('initial state is non-empty list of OCR jobs', () {
        final jobs = container.read(ocrJobListProvider);
        expect(jobs, isNotEmpty);
        expect(jobs.length, greaterThanOrEqualTo(3));
      });

      test('all items are OcrJob objects', () {
        final jobs = container.read(ocrJobListProvider);
        expect(jobs, everyElement(isA<OcrJob>()));
      });

      test('initial jobs span multiple statuses', () {
        final jobs = container.read(ocrJobListProvider);
        final statuses = jobs.map((j) => j.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(2));
      });

      test('list is unmodifiable', () {
        final jobs = container.read(ocrJobListProvider);
        expect(() => jobs.add(jobs.first), throwsA(anything));
      });

      test('jobs include completed and failed items', () {
        final jobs = container.read(ocrJobListProvider);
        final hasCompleted = jobs.any(
          (j) => j.status == OcrJobStatus.completed,
        );
        final hasFailed = jobs.any((j) => j.status == OcrJobStatus.failed);
        expect(hasCompleted, isTrue);
        expect(hasFailed, isTrue);
      });

      test('completed jobs have non-null result', () {
        final jobs = container.read(ocrJobListProvider);
        final completedJobs = jobs.where(
          (j) => j.status == OcrJobStatus.completed,
        );
        for (final job in completedJobs) {
          expect(job.result, isNotNull);
        }
      });

      test('failed jobs have non-null errorMessage', () {
        final jobs = container.read(ocrJobListProvider);
        final failedJobs = jobs.where((j) => j.status == OcrJobStatus.failed);
        for (final job in failedJobs) {
          expect(job.errorMessage, isNotNull);
        }
      });
    });

    // -------------------------------------------------------------------------
    // ocrActiveJobProvider
    // -------------------------------------------------------------------------
    group('ocrActiveJobProvider', () {
      test('initial state is null', () {
        expect(container.read(ocrActiveJobProvider), isNull);
      });

      test('select() sets the active job', () {
        final job = container.read(ocrJobListProvider).first;
        container.read(ocrActiveJobProvider.notifier).select(job);
        expect(container.read(ocrActiveJobProvider), job);
      });

      test('select(null) clears the active job', () {
        final job = container.read(ocrJobListProvider).first;
        container.read(ocrActiveJobProvider.notifier).select(job);
        container.read(ocrActiveJobProvider.notifier).select(null);
        expect(container.read(ocrActiveJobProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // ocrPipelineProvider
    // -------------------------------------------------------------------------
    group('ocrPipelineProvider', () {
      test('returns OcrPipelineService instance', () {
        final pipeline = container.read(ocrPipelineProvider);
        expect(pipeline, isA<OcrPipelineService>());
        expect(pipeline, same(OcrPipelineService.instance));
      });
    });

    // -------------------------------------------------------------------------
    // ocrDataMapperProvider
    // -------------------------------------------------------------------------
    group('ocrDataMapperProvider', () {
      test('returns OcrDataMapperService instance', () {
        final mapper = container.read(ocrDataMapperProvider);
        expect(mapper, isA<OcrDataMapperService>());
        expect(mapper, same(OcrDataMapperService.instance));
      });
    });

    // -------------------------------------------------------------------------
    // ocrQueuedJobsProvider
    // -------------------------------------------------------------------------
    group('ocrQueuedJobsProvider', () {
      test('returns only queued or processing jobs', () {
        final queued = container.read(ocrQueuedJobsProvider);
        expect(
          queued.every(
            (j) =>
                j.status == OcrJobStatus.queued ||
                j.status == OcrJobStatus.processing,
          ),
          isTrue,
        );
      });

      test('count matches queued and processing jobs in full list', () {
        final all = container.read(ocrJobListProvider);
        final expectedCount = all
            .where(
              (j) =>
                  j.status == OcrJobStatus.queued ||
                  j.status == OcrJobStatus.processing,
            )
            .length;
        final queued = container.read(ocrQueuedJobsProvider);
        expect(queued.length, expectedCount);
      });
    });

    // -------------------------------------------------------------------------
    // ocrHistoryJobsProvider
    // -------------------------------------------------------------------------
    group('ocrHistoryJobsProvider', () {
      test('returns only completed or failed jobs', () {
        final history = container.read(ocrHistoryJobsProvider);
        expect(history, isNotEmpty);
        expect(
          history.every(
            (j) =>
                j.status == OcrJobStatus.completed ||
                j.status == OcrJobStatus.failed,
          ),
          isTrue,
        );
      });

      test('count matches completed and failed jobs in full list', () {
        final all = container.read(ocrJobListProvider);
        final expectedCount = all
            .where(
              (j) =>
                  j.status == OcrJobStatus.completed ||
                  j.status == OcrJobStatus.failed,
            )
            .length;
        final history = container.read(ocrHistoryJobsProvider);
        expect(history.length, expectedCount);
      });
    });

    // -------------------------------------------------------------------------
    // OcrJob model
    // -------------------------------------------------------------------------
    group('OcrJob model', () {
      test('confidence returns result confidence when result exists', () {
        final jobs = container.read(ocrJobListProvider);
        final completedJob = jobs.firstWhere(
          (j) => j.status == OcrJobStatus.completed,
        );
        expect(
          completedJob.confidence,
          completedJob.result!.document.confidence,
        );
      });

      test('confidence returns document confidence when no result', () {
        final jobs = container.read(ocrJobListProvider);
        final processingJob = jobs.firstWhere(
          (j) => j.status == OcrJobStatus.processing,
        );
        expect(processingJob.confidence, processingJob.document.confidence);
      });

      test('copyWith preserves unchanged fields', () {
        final job = container.read(ocrJobListProvider).first;
        final updated = job.copyWith(status: OcrJobStatus.failed);
        expect(updated.jobId, job.jobId);
        expect(updated.fileName, job.fileName);
        expect(updated.status, OcrJobStatus.failed);
      });
    });

    // -------------------------------------------------------------------------
    // Jobs span multiple document types
    // -------------------------------------------------------------------------
    group('OCR job variety', () {
      test('initial jobs include multiple document types', () {
        final jobs = container.read(ocrJobListProvider);
        final docTypes = jobs.map((j) => j.document.documentType).toSet();
        expect(docTypes.length, greaterThanOrEqualTo(2));
      });

      test('all jobs have non-empty fileName', () {
        final jobs = container.read(ocrJobListProvider);
        for (final job in jobs) {
          expect(job.fileName, isNotEmpty);
        }
      });

      test('all jobs have non-empty jobId', () {
        final jobs = container.read(ocrJobListProvider);
        for (final job in jobs) {
          expect(job.jobId, isNotEmpty);
        }
      });
    });
  });
}

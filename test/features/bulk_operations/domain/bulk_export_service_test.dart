import 'package:ca_app/features/bulk_operations/domain/services/bulk_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

BulkExportJob _buildJob({
  String clientId = 'client-001',
  String clientName = 'Acme Ltd',
  BulkExportType exportType = BulkExportType.gstrExcel,
  String? jobId,
}) {
  return BulkExportJob(
    jobId: jobId ?? 'job-$clientId',
    clientId: clientId,
    clientName: clientName,
    exportType: exportType,
  );
}

/// A custom job processor that always succeeds with deterministic output.
Future<BulkExportResult> _successProcessor(BulkExportJob job) async {
  return BulkExportResult(
    jobId: job.jobId,
    clientId: job.clientId,
    clientName: job.clientName,
    exportType: job.exportType,
    success: true,
    outputBytes: [1, 2, 3],
    completedAt: DateTime.now(),
  );
}

/// A custom job processor that always fails.
Future<BulkExportResult> _failureProcessor(BulkExportJob job) async {
  return BulkExportResult(
    jobId: job.jobId,
    clientId: job.clientId,
    clientName: job.clientName,
    exportType: job.exportType,
    success: false,
    errorMessage: 'Simulated export failure',
    completedAt: DateTime.now(),
  );
}

/// A job processor that throws an exception (should be caught by service).
Future<BulkExportResult> _throwingProcessor(BulkExportJob job) async {
  throw Exception('Processor blew up');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BulkExportService', () {
    // ── BulkExportType labels ─────────────────────────────────────────────────

    group('BulkExportType labels', () {
      test('itrPdf has correct label', () {
        expect(BulkExportType.itrPdf.label, 'ITR PDF');
      });

      test('gstrExcel has correct label', () {
        expect(BulkExportType.gstrExcel.label, 'GSTR Excel');
      });

      test('form16Pdf has correct label', () {
        expect(BulkExportType.form16Pdf.label, 'Form 16 PDF');
      });
    });

    // ── buildJob ──────────────────────────────────────────────────────────────

    group('buildJob', () {
      test('generates unique jobId', () {
        final job1 = BulkExportService.buildJob(
          clientId: 'c1',
          clientName: 'Client 1',
          exportType: BulkExportType.itrPdf,
        );
        final job2 = BulkExportService.buildJob(
          clientId: 'c2',
          clientName: 'Client 2',
          exportType: BulkExportType.itrPdf,
        );
        expect(job1.jobId, isNot(job2.jobId));
      });

      test('jobId contains clientId', () {
        final job = BulkExportService.buildJob(
          clientId: 'myClient',
          clientName: 'My Client',
          exportType: BulkExportType.gstrExcel,
        );
        expect(job.jobId, contains('myClient'));
      });

      test('sets clientId, clientName, exportType correctly', () {
        final job = BulkExportService.buildJob(
          clientId: 'c99',
          clientName: 'Test Co',
          exportType: BulkExportType.balanceSheetPdf,
          parameters: {'fy': '2024-25'},
        );
        expect(job.clientId, 'c99');
        expect(job.clientName, 'Test Co');
        expect(job.exportType, BulkExportType.balanceSheetPdf);
        expect(job.parameters['fy'], '2024-25');
      });
    });

    // ── BulkExportJob equality ────────────────────────────────────────────────

    group('BulkExportJob equality', () {
      test('two jobs with same jobId are equal', () {
        final a = _buildJob(jobId: 'job-xyz');
        final b = _buildJob(jobId: 'job-xyz');
        expect(a, equals(b));
      });

      test('two jobs with different jobId are not equal', () {
        final a = _buildJob(jobId: 'job-a');
        final b = _buildJob(jobId: 'job-b');
        expect(a, isNot(equals(b)));
      });
    });

    // ── processQueue — empty list ─────────────────────────────────────────────

    group('processQueue — empty list', () {
      test('stream completes immediately with no events', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final events = await service.processQueue([]).toList();
        expect(events, isEmpty);
      });
    });

    // ── processQueue — single job ─────────────────────────────────────────────

    group('processQueue — single job', () {
      test('emits one progress event', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events, hasLength(1));
      });

      test('progress event has completedCount = 1, totalCount = 1', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.completedCount, 1);
        expect(events.first.totalCount, 1);
      });

      test('progress event isComplete is true', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.isComplete, isTrue);
      });

      test('progress fraction is 1.0 after single job', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.fraction, 1.0);
      });

      test('progress currentJobId matches job', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob(jobId: 'my-job-id');
        final events = await service.processQueue([job]).toList();
        expect(events.first.currentJobId, 'my-job-id');
      });

      test('progress currentClientName matches job', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob(clientName: 'Specific Corp');
        final events = await service.processQueue([job]).toList();
        expect(events.first.currentClientName, 'Specific Corp');
      });

      test('results list has one entry', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.results, hasLength(1));
      });

      test('result in progress is successful', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.results.first.success, isTrue);
      });
    });

    // ── processQueue — multiple jobs ──────────────────────────────────────────

    group('processQueue — multiple jobs', () {
      test('emits one event per job', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = [
          _buildJob(clientId: 'c1', jobId: 'j1'),
          _buildJob(clientId: 'c2', jobId: 'j2'),
          _buildJob(clientId: 'c3', jobId: 'j3'),
        ];
        final events = await service.processQueue(jobs).toList();
        expect(events, hasLength(3));
      });

      test('completedCount increments from 1 to N', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = List.generate(
          4,
          (i) => _buildJob(clientId: 'c$i', jobId: 'j$i'),
        );
        final events = await service.processQueue(jobs).toList();
        for (var i = 0; i < events.length; i++) {
          expect(events[i].completedCount, i + 1);
          expect(events[i].totalCount, 4);
        }
      });

      test('last event isComplete is true', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = [
          _buildJob(clientId: 'c1', jobId: 'j1'),
          _buildJob(clientId: 'c2', jobId: 'j2'),
        ];
        final events = await service.processQueue(jobs).toList();
        expect(events.last.isComplete, isTrue);
      });

      test('intermediate events have isComplete = false', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = List.generate(
          3,
          (i) => _buildJob(clientId: 'c$i', jobId: 'j$i'),
        );
        final events = await service.processQueue(jobs).toList();
        // All except the last should be incomplete
        for (var i = 0; i < events.length - 1; i++) {
          expect(events[i].isComplete, isFalse);
        }
      });

      test('results list grows with each event', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = [
          _buildJob(clientId: 'c1', jobId: 'j1'),
          _buildJob(clientId: 'c2', jobId: 'j2'),
          _buildJob(clientId: 'c3', jobId: 'j3'),
        ];
        final events = await service.processQueue(jobs).toList();
        for (var i = 0; i < events.length; i++) {
          expect(events[i].results.length, i + 1);
        }
      });

      test('fraction progresses from near-0 to 1.0', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = List.generate(
          5,
          (i) => _buildJob(clientId: 'c$i', jobId: 'j$i'),
        );
        final events = await service.processQueue(jobs).toList();
        expect(events.first.fraction, closeTo(0.2, 0.001));
        expect(events.last.fraction, 1.0);
      });
    });

    // ── processQueue — failed jobs ────────────────────────────────────────────

    group('processQueue — failed jobs', () {
      test('stream never errors even when all jobs fail', () async {
        final service = BulkExportService(jobProcessor: _failureProcessor);
        final jobs = [_buildJob(), _buildJob(clientId: 'c2', jobId: 'j2')];
        // Should complete without error
        expect(
          () async => service.processQueue(jobs).toList(),
          returnsNormally,
        );
      });

      test('failed result has success = false', () async {
        final service = BulkExportService(jobProcessor: _failureProcessor);
        final events = await service.processQueue([_buildJob()]).toList();
        expect(events.first.results.first.success, isFalse);
      });

      test('failed result has errorMessage set', () async {
        final service = BulkExportService(jobProcessor: _failureProcessor);
        final events = await service.processQueue([_buildJob()]).toList();
        expect(events.first.results.first.errorMessage, isNotNull);
        expect(events.first.results.first.errorMessage, isNotEmpty);
      });
    });

    // ── processQueue — throwing processor ────────────────────────────────────

    group('processQueue — throwing processor', () {
      test('stream does not propagate exception; captures in result', () async {
        final service = BulkExportService(jobProcessor: _throwingProcessor);
        final events = await service.processQueue([_buildJob()]).toList();
        expect(events, hasLength(1));
        expect(events.first.results.first.success, isFalse);
        expect(
          events.first.results.first.errorMessage,
          contains('Unexpected error'),
        );
      });
    });

    // ── processQueue — default processor ─────────────────────────────────────

    group('processQueue — default processor', () {
      test('default processor marks jobs as succeeded', () async {
        final service = BulkExportService(); // no custom processor
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.results.first.success, isTrue);
      });

      test('default processor returns empty outputBytes', () async {
        final service = BulkExportService();
        final job = _buildJob();
        final events = await service.processQueue([job]).toList();
        expect(events.first.results.first.outputBytes, isEmpty);
      });
    });

    // ── BulkExportProgress immutability ──────────────────────────────────────

    group('BulkExportProgress', () {
      test('copyWith creates new instance with updated field', () {
        const original = BulkExportProgress(
          completedCount: 1,
          totalCount: 5,
          currentJobId: 'job-1',
          currentClientName: 'Acme',
          results: [],
        );
        final updated = original.copyWith(completedCount: 2);
        expect(updated.completedCount, 2);
        expect(updated.totalCount, original.totalCount);
        expect(updated.currentJobId, original.currentJobId);
      });

      test('fraction is 0.0 when totalCount is 0', () {
        const p = BulkExportProgress(
          completedCount: 0,
          totalCount: 0,
          currentJobId: '',
          currentClientName: '',
          results: [],
        );
        expect(p.fraction, 0.0);
      });

      test('isComplete is false when completedCount < totalCount', () {
        const p = BulkExportProgress(
          completedCount: 2,
          totalCount: 5,
          currentJobId: 'j',
          currentClientName: 'C',
          results: [],
        );
        expect(p.isComplete, isFalse);
      });
    });

    // ── expectLater / Stream style ────────────────────────────────────────────

    group('processQueue stream — expectLater', () {
      test('emits progress events in order for 3 jobs', () async {
        final service = BulkExportService(jobProcessor: _successProcessor);
        final jobs = [
          _buildJob(clientId: 'a', jobId: 'ja'),
          _buildJob(clientId: 'b', jobId: 'jb'),
          _buildJob(clientId: 'c', jobId: 'jc'),
        ];
        final counts = <int>[];
        await for (final p in service.processQueue(jobs)) {
          counts.add(p.completedCount);
        }
        expect(counts, [1, 2, 3]);
      });
    });
  });
}

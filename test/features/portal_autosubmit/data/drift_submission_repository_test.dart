import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/drift_submission_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('DriftSubmissionRepository', () {
    late DriftSubmissionRepository repo;
    final now = DateTime(2026, 3, 14, 10, 0);

    SubmissionJob makeJob(
      String id, {
      PortalType portalType = PortalType.itd,
      SubmissionStep step = SubmissionStep.pending,
      String clientId = 'client-1',
      String clientName = 'Test Client',
      String returnType = 'ITR-1',
      int retryCount = 0,
      DateTime? createdAt,
    }) {
      return SubmissionJob(
        id: id,
        clientId: clientId,
        clientName: clientName,
        portalType: portalType,
        returnType: returnType,
        currentStep: step,
        retryCount: retryCount,
        createdAt: createdAt ?? now,
      );
    }

    SubmissionLog makeLog(
      String id, {
      String jobId = 'job-001',
      SubmissionStep step = SubmissionStep.loggingIn,
      String message = 'Log message',
      bool isError = false,
      DateTime? timestamp,
    }) {
      return SubmissionLog(
        id: id,
        jobId: jobId,
        timestamp: timestamp ?? now,
        step: step,
        message: message,
        isError: isError,
      );
    }

    setUp(() {
      repo = DriftSubmissionRepository(sqlite3.openInMemory());
    });

    tearDown(() {
      repo.dispose();
    });

    // -----------------------------------------------------------------------
    // insert
    // -----------------------------------------------------------------------

    group('insert', () {
      test('adds job to repository and retrieves it', () async {
        final job = makeJob('job-001');
        await repo.insert(job);
        final result = await repo.getById('job-001');
        expect(result, isNotNull);
        expect(result!.id, equals('job-001'));
        expect(result.clientId, equals('client-1'));
        expect(result.clientName, equals('Test Client'));
        expect(result.portalType, equals(PortalType.itd));
        expect(result.returnType, equals('ITR-1'));
        expect(result.currentStep, equals(SubmissionStep.pending));
        expect(result.retryCount, equals(0));
      });

      test('preserves all nullable fields when set', () async {
        final job = SubmissionJob(
          id: 'job-full',
          clientId: 'c1',
          clientName: 'Full Client',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.done,
          retryCount: 2,
          createdAt: now,
          ackNumber: 'ACK-12345',
          filedAt: now.add(const Duration(hours: 1)),
          errorMessage: 'some error',
          itrJsonPath: '/path/to/itr.json',
          assessmentYear: '2025-26',
        );
        await repo.insert(job);
        final result = await repo.getById('job-full');
        expect(result, isNotNull);
        expect(result!.ackNumber, equals('ACK-12345'));
        expect(result.filedAt, equals(now.add(const Duration(hours: 1))));
        expect(result.errorMessage, equals('some error'));
        expect(result.itrJsonPath, equals('/path/to/itr.json'));
        expect(result.assessmentYear, equals('2025-26'));
      });

      test('preserves null for unset nullable fields', () async {
        final job = makeJob('job-minimal');
        await repo.insert(job);
        final result = await repo.getById('job-minimal');
        expect(result!.ackNumber, isNull);
        expect(result.filedAt, isNull);
        expect(result.errorMessage, isNull);
        expect(result.itrJsonPath, isNull);
        expect(result.assessmentYear, isNull);
      });

      test('throws on duplicate id', () async {
        await repo.insert(makeJob('job-dup'));
        expect(() => repo.insert(makeJob('job-dup')), throwsStateError);
      });
    });

    // -----------------------------------------------------------------------
    // getById
    // -----------------------------------------------------------------------

    group('getById', () {
      test('returns null for unknown id', () async {
        final result = await repo.getById('unknown');
        expect(result, isNull);
      });

      test('returns correct job among several', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        await repo.insert(makeJob('job-003'));
        final result = await repo.getById('job-002');
        expect(result, isNotNull);
        expect(result!.id, equals('job-002'));
      });
    });

    // -----------------------------------------------------------------------
    // getAll
    // -----------------------------------------------------------------------

    group('getAll', () {
      test('returns empty list initially', () async {
        final result = await repo.getAll();
        expect(result, isEmpty);
      });

      test('returns all inserted jobs', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        await repo.insert(makeJob('job-003'));
        final result = await repo.getAll();
        expect(result, hasLength(3));
      });

      test('returns jobs ordered by createdAt', () async {
        await repo.insert(makeJob('job-b', createdAt: now.add(const Duration(hours: 2))));
        await repo.insert(makeJob('job-a', createdAt: now));
        await repo.insert(makeJob('job-c', createdAt: now.add(const Duration(hours: 1))));
        final result = await repo.getAll();
        expect(result.map((j) => j.id).toList(), ['job-a', 'job-c', 'job-b']);
      });
    });

    // -----------------------------------------------------------------------
    // getByPortal
    // -----------------------------------------------------------------------

    group('getByPortal', () {
      test('returns only jobs for the given portal type', () async {
        await repo.insert(makeJob('job-itd', portalType: PortalType.itd));
        await repo.insert(makeJob('job-gst', portalType: PortalType.gstn));
        await repo.insert(makeJob('job-itd-2', portalType: PortalType.itd));
        await repo.insert(makeJob('job-traces', portalType: PortalType.traces));
        final result = await repo.getByPortal(PortalType.itd);
        expect(result, hasLength(2));
        expect(result.every((j) => j.portalType == PortalType.itd), isTrue);
      });

      test('returns empty list when no jobs match', () async {
        await repo.insert(makeJob('job-itd', portalType: PortalType.itd));
        final result = await repo.getByPortal(PortalType.epfo);
        expect(result, isEmpty);
      });

      test('handles all portal types correctly', () async {
        for (final portal in PortalType.values) {
          await repo.insert(makeJob('job-${portal.name}', portalType: portal));
        }
        for (final portal in PortalType.values) {
          final result = await repo.getByPortal(portal);
          expect(result, hasLength(1));
          expect(result.first.portalType, equals(portal));
        }
      });
    });

    // -----------------------------------------------------------------------
    // getByClient
    // -----------------------------------------------------------------------

    group('getByClient', () {
      test('returns only jobs for the given client', () async {
        await repo.insert(makeJob('job-c1a', clientId: 'client-A', clientName: 'A'));
        await repo.insert(makeJob('job-c1b', clientId: 'client-A', clientName: 'A'));
        await repo.insert(makeJob('job-c2', clientId: 'client-B', clientName: 'B'));
        final result = await repo.getByClient('client-A');
        expect(result, hasLength(2));
        expect(result.every((j) => j.clientId == 'client-A'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        await repo.insert(makeJob('job-001'));
        final result = await repo.getByClient('unknown-client');
        expect(result, isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // getPending
    // -----------------------------------------------------------------------

    group('getPending', () {
      test('returns only pending jobs', () async {
        await repo.insert(makeJob('j-pending', step: SubmissionStep.pending));
        await repo.insert(makeJob('j-logging', step: SubmissionStep.loggingIn));
        await repo.insert(makeJob('j-done', step: SubmissionStep.done));
        await repo.insert(makeJob('j-failed', step: SubmissionStep.failed));
        await repo.insert(makeJob('j-pending2', step: SubmissionStep.pending));
        final result = await repo.getPending();
        expect(result, hasLength(2));
        expect(result.every((j) => j.currentStep == SubmissionStep.pending), isTrue);
      });

      test('returns empty list when no pending jobs', () async {
        await repo.insert(makeJob('j-done', step: SubmissionStep.done));
        final result = await repo.getPending();
        expect(result, isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // update
    // -----------------------------------------------------------------------

    group('update', () {
      test('updates an existing job', () async {
        await repo.insert(makeJob('job-001'));
        final updated = makeJob('job-001', step: SubmissionStep.loggingIn);
        await repo.update(updated);
        final result = await repo.getById('job-001');
        expect(result!.currentStep, equals(SubmissionStep.loggingIn));
      });

      test('updates all fields of an existing job', () async {
        await repo.insert(makeJob('job-001'));
        final updated = SubmissionJob(
          id: 'job-001',
          clientId: 'new-client',
          clientName: 'New Client Name',
          portalType: PortalType.mca,
          returnType: 'MGT-7',
          currentStep: SubmissionStep.done,
          retryCount: 3,
          createdAt: now,
          ackNumber: 'ACK-999',
          filedAt: now.add(const Duration(hours: 5)),
          errorMessage: null,
          itrJsonPath: '/new/path.json',
          assessmentYear: '2026-27',
        );
        await repo.update(updated);
        final result = await repo.getById('job-001');
        expect(result!.clientId, equals('new-client'));
        expect(result.clientName, equals('New Client Name'));
        expect(result.portalType, equals(PortalType.mca));
        expect(result.returnType, equals('MGT-7'));
        expect(result.currentStep, equals(SubmissionStep.done));
        expect(result.retryCount, equals(3));
        expect(result.ackNumber, equals('ACK-999'));
        expect(result.assessmentYear, equals('2026-27'));
      });

      test('does nothing for unknown id', () async {
        final unknown = makeJob('not-in-repo');
        await repo.update(unknown); // Should not throw
        final result = await repo.getById('not-in-repo');
        expect(result, isNull);
      });

      test('does not affect other jobs', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        await repo.update(makeJob('job-001', step: SubmissionStep.submitting));
        final job2 = await repo.getById('job-002');
        expect(job2!.currentStep, equals(SubmissionStep.pending));
      });
    });

    // -----------------------------------------------------------------------
    // insertLog
    // -----------------------------------------------------------------------

    group('insertLog', () {
      test('adds log entry', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insertLog(makeLog('log-001', jobId: 'job-001'));
        final logs = await repo.getLogs('job-001');
        expect(logs, hasLength(1));
        expect(logs.first.id, equals('log-001'));
        expect(logs.first.jobId, equals('job-001'));
      });

      test('preserves log fields correctly', () async {
        await repo.insert(makeJob('job-001'));
        final log = SubmissionLog(
          id: 'log-full',
          jobId: 'job-001',
          timestamp: now,
          step: SubmissionStep.filling,
          message: 'Filling the form fields',
          isError: true,
        );
        await repo.insertLog(log);
        final logs = await repo.getLogs('job-001');
        expect(logs.first.step, equals(SubmissionStep.filling));
        expect(logs.first.message, equals('Filling the form fields'));
        expect(logs.first.isError, isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // getLogs
    // -----------------------------------------------------------------------

    group('getLogs', () {
      test('returns empty list for job with no logs', () async {
        final logs = await repo.getLogs('nonexistent');
        expect(logs, isEmpty);
      });

      test('returns logs in chronological order', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insertLog(makeLog(
          'log-3',
          jobId: 'job-001',
          timestamp: now.add(const Duration(seconds: 3)),
        ));
        await repo.insertLog(makeLog(
          'log-1',
          jobId: 'job-001',
          timestamp: now.add(const Duration(seconds: 1)),
        ));
        await repo.insertLog(makeLog(
          'log-2',
          jobId: 'job-001',
          timestamp: now.add(const Duration(seconds: 2)),
        ));
        final logs = await repo.getLogs('job-001');
        expect(logs, hasLength(3));
        expect(logs.map((l) => l.id).toList(), ['log-1', 'log-2', 'log-3']);
      });

      test('returns only logs for the specified job', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        await repo.insertLog(makeLog('log-a', jobId: 'job-001'));
        await repo.insertLog(makeLog('log-b', jobId: 'job-002'));
        await repo.insertLog(makeLog('log-c', jobId: 'job-001'));
        final logs1 = await repo.getLogs('job-001');
        final logs2 = await repo.getLogs('job-002');
        expect(logs1, hasLength(2));
        expect(logs2, hasLength(1));
      });
    });

    // -----------------------------------------------------------------------
    // watchAll
    // -----------------------------------------------------------------------

    group('watchAll', () {
      test('emits current snapshot on subscription', () async {
        await repo.insert(makeJob('job-001'));
        final events = <List<SubmissionJob>>[];
        final sub = repo.watchAll().listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events, isNotEmpty);
        expect(events.first, hasLength(1));
        await sub.cancel();
      });

      test('emits empty list when no jobs exist', () async {
        final events = <List<SubmissionJob>>[];
        final sub = repo.watchAll().listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events, isNotEmpty);
        expect(events.first, isEmpty);
        await sub.cancel();
      });

      test('emits updated list after insert', () async {
        final events = <List<SubmissionJob>>[];
        final sub = repo.watchAll().listen(events.add);
        await Future<void>.delayed(Duration.zero);
        await repo.insert(makeJob('job-001'));
        await Future<void>.delayed(Duration.zero);
        // Should have at least 2 events: initial empty + after insert.
        expect(events.length, greaterThanOrEqualTo(2));
        expect(events.last, hasLength(1));
        await sub.cancel();
      });

      test('emits updated list after update', () async {
        await repo.insert(makeJob('job-001'));
        final events = <List<SubmissionJob>>[];
        final sub = repo.watchAll().listen(events.add);
        await Future<void>.delayed(Duration.zero);
        await repo.update(makeJob('job-001', step: SubmissionStep.done));
        await Future<void>.delayed(Duration.zero);
        final lastEvent = events.last;
        expect(lastEvent.first.currentStep, equals(SubmissionStep.done));
        await sub.cancel();
      });
    });

    // -----------------------------------------------------------------------
    // watchJob
    // -----------------------------------------------------------------------

    group('watchJob', () {
      test('emits current job on subscription', () async {
        await repo.insert(makeJob('job-001'));
        final events = <SubmissionJob>[];
        final sub = repo.watchJob('job-001').listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events, hasLength(1));
        expect(events.first.id, equals('job-001'));
        await sub.cancel();
      });

      test('does not emit for unknown job', () async {
        final events = <SubmissionJob>[];
        final sub = repo.watchJob('unknown').listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events, isEmpty);
        await sub.cancel();
      });

      test('emits updated job after update', () async {
        await repo.insert(makeJob('job-001'));
        final events = <SubmissionJob>[];
        final sub = repo.watchJob('job-001').listen(events.add);
        await Future<void>.delayed(Duration.zero);
        await repo.update(makeJob('job-001', step: SubmissionStep.loggingIn));
        await Future<void>.delayed(Duration.zero);
        expect(
          events.any((j) => j.currentStep == SubmissionStep.loggingIn),
          isTrue,
        );
        await sub.cancel();
      });

      test('emits multiple updates in sequence', () async {
        await repo.insert(makeJob('job-001'));
        final events = <SubmissionJob>[];
        final sub = repo.watchJob('job-001').listen(events.add);
        await Future<void>.delayed(Duration.zero);
        await repo.update(makeJob('job-001', step: SubmissionStep.loggingIn));
        await Future<void>.delayed(Duration.zero);
        await repo.update(makeJob('job-001', step: SubmissionStep.filling));
        await Future<void>.delayed(Duration.zero);
        await repo.update(makeJob('job-001', step: SubmissionStep.submitting));
        await Future<void>.delayed(Duration.zero);
        // Initial + 3 updates = 4 events.
        expect(events, hasLength(4));
        expect(events.last.currentStep, equals(SubmissionStep.submitting));
        await sub.cancel();
      });
    });

    // -----------------------------------------------------------------------
    // watchLogs
    // -----------------------------------------------------------------------

    group('watchLogs', () {
      test('emits logs as they are inserted', () async {
        await repo.insert(makeJob('job-001'));
        final allLogs = <SubmissionLog>[];
        final sub = repo.watchLogs('job-001').listen(allLogs.addAll);
        await repo.insertLog(makeLog('log-x', jobId: 'job-001'));
        await Future<void>.delayed(Duration.zero);
        expect(allLogs, hasLength(1));
        expect(allLogs.first.id, equals('log-x'));
        await sub.cancel();
      });

      test('emits multiple log batches', () async {
        await repo.insert(makeJob('job-001'));
        final allLogs = <SubmissionLog>[];
        final sub = repo.watchLogs('job-001').listen(allLogs.addAll);
        await repo.insertLog(makeLog('log-1', jobId: 'job-001'));
        await Future<void>.delayed(Duration.zero);
        await repo.insertLog(makeLog('log-2', jobId: 'job-001'));
        await Future<void>.delayed(Duration.zero);
        await repo.insertLog(makeLog('log-3', jobId: 'job-001'));
        await Future<void>.delayed(Duration.zero);
        expect(allLogs, hasLength(3));
        await sub.cancel();
      });

      test('does not emit logs for other jobs', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        final allLogs = <SubmissionLog>[];
        final sub = repo.watchLogs('job-001').listen(allLogs.addAll);
        await repo.insertLog(makeLog('log-other', jobId: 'job-002'));
        await Future<void>.delayed(Duration.zero);
        expect(allLogs, isEmpty);
        await sub.cancel();
      });
    });

    // -----------------------------------------------------------------------
    // SubmissionStep enum roundtrip
    // -----------------------------------------------------------------------

    group('enum serialization roundtrip', () {
      test('all SubmissionStep values survive storage and retrieval', () async {
        for (final step in SubmissionStep.values) {
          final id = 'job-step-${step.name}';
          await repo.insert(makeJob(id, step: step));
          final result = await repo.getById(id);
          expect(result!.currentStep, equals(step),
              reason: 'Step ${step.name} should roundtrip correctly');
        }
      });

      test('all PortalType values survive storage and retrieval', () async {
        for (final portal in PortalType.values) {
          final id = 'job-portal-${portal.name}';
          await repo.insert(makeJob(id, portalType: portal));
          final result = await repo.getById(id);
          expect(result!.portalType, equals(portal),
              reason: 'Portal ${portal.name} should roundtrip correctly');
        }
      });

      test('SubmissionStep in logs survives roundtrip', () async {
        await repo.insert(makeJob('job-001'));
        for (final step in SubmissionStep.values) {
          await repo.insertLog(makeLog(
            'log-${step.name}',
            jobId: 'job-001',
            step: step,
          ));
        }
        final logs = await repo.getLogs('job-001');
        expect(logs, hasLength(SubmissionStep.values.length));
      });
    });

    // -----------------------------------------------------------------------
    // dispose
    // -----------------------------------------------------------------------

    group('dispose', () {
      test('can be called without errors', () {
        // Create a fresh repo to dispose (setUp one will be disposed in tearDown).
        final disposableRepo = DriftSubmissionRepository(sqlite3.openInMemory());
        expect(() => disposableRepo.dispose(), returnsNormally);
      });
    });
  });
}

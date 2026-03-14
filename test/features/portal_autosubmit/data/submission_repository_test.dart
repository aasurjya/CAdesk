import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

void main() {
  group('MockSubmissionRepository', () {
    late MockSubmissionRepository repo;
    final now = DateTime(2026, 3, 14, 10, 0);

    SubmissionJob makeJob(String id, {
      PortalType portalType = PortalType.itd,
      SubmissionStep step = SubmissionStep.pending,
    }) {
      return SubmissionJob(
        id: id,
        clientId: 'client-1',
        clientName: 'Test Client',
        portalType: portalType,
        returnType: 'ITR-1',
        currentStep: step,
        retryCount: 0,
        createdAt: now,
      );
    }

    setUp(() {
      repo = MockSubmissionRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('insert', () {
      test('adds job to repository', () async {
        final job = makeJob('job-001');
        await repo.insert(job);
        final result = await repo.getById('job-001');
        expect(result, isNotNull);
        expect(result!.id, equals('job-001'));
      });

      test('throws on duplicate id', () async {
        final job = makeJob('job-dup');
        await repo.insert(job);
        expect(() => repo.insert(job), throwsA(anything));
      });
    });

    group('getById', () {
      test('returns null for unknown id', () async {
        final result = await repo.getById('unknown');
        expect(result, isNull);
      });

      test('returns correct job', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        final result = await repo.getById('job-002');
        expect(result!.id, equals('job-002'));
      });
    });

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
    });

    group('getByPortal', () {
      test('returns only jobs for the given portal type', () async {
        await repo.insert(makeJob('job-itd', portalType: PortalType.itd));
        await repo.insert(makeJob('job-gst', portalType: PortalType.gstn));
        await repo.insert(makeJob('job-itd-2', portalType: PortalType.itd));
        final result = await repo.getByPortal(PortalType.itd);
        expect(result, hasLength(2));
        expect(result.every((j) => j.portalType == PortalType.itd), isTrue);
      });
    });

    group('getByClient', () {
      test('returns only jobs for the given client', () async {
        final job1 = SubmissionJob(
          id: 'job-c1',
          clientId: 'client-A',
          clientName: 'Client A',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: now,
        );
        final job2 = SubmissionJob(
          id: 'job-c2',
          clientId: 'client-B',
          clientName: 'Client B',
          portalType: PortalType.itd,
          returnType: 'ITR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: now,
        );
        await repo.insert(job1);
        await repo.insert(job2);
        final result = await repo.getByClient('client-A');
        expect(result, hasLength(1));
        expect(result.first.clientId, equals('client-A'));
      });
    });

    group('getPending', () {
      test('returns only pending jobs', () async {
        await repo.insert(makeJob('job-pending', step: SubmissionStep.pending));
        await repo.insert(makeJob('job-done', step: SubmissionStep.done));
        await repo.insert(makeJob('job-failed', step: SubmissionStep.failed));
        final result = await repo.getPending();
        expect(result, hasLength(1));
        expect(result.first.id, equals('job-pending'));
      });
    });

    group('update', () {
      test('updates an existing job', () async {
        final job = makeJob('job-001');
        await repo.insert(job);
        final updated = job.copyWith(currentStep: SubmissionStep.loggingIn);
        await repo.update(updated);
        final result = await repo.getById('job-001');
        expect(result!.currentStep, equals(SubmissionStep.loggingIn));
      });

      test('does nothing for unknown id', () async {
        final unknown = makeJob('not-in-repo');
        await repo.update(unknown); // Should not throw
      });
    });

    group('insertLog', () {
      test('adds log entry', () async {
        final job = makeJob('job-001');
        await repo.insert(job);
        final log = SubmissionLog(
          id: 'log-001',
          jobId: 'job-001',
          timestamp: now,
          step: SubmissionStep.loggingIn,
          message: 'Starting login',
        );
        await repo.insertLog(log);
        final logs = await repo.getLogs('job-001');
        expect(logs, hasLength(1));
        expect(logs.first.message, equals('Starting login'));
      });
    });

    group('getLogs', () {
      test('returns empty list for job with no logs', () async {
        await repo.insert(makeJob('job-001'));
        final logs = await repo.getLogs('job-001');
        expect(logs, isEmpty);
      });

      test('returns all logs for a job', () async {
        await repo.insert(makeJob('job-001'));
        await repo.insert(makeJob('job-002'));
        for (var i = 1; i <= 3; i++) {
          await repo.insertLog(SubmissionLog(
            id: 'log-00$i',
            jobId: 'job-001',
            timestamp: now.add(Duration(seconds: i)),
            step: SubmissionStep.loggingIn,
            message: 'Log $i',
          ));
        }
        await repo.insertLog(SubmissionLog(
          id: 'log-other',
          jobId: 'job-002',
          timestamp: now,
          step: SubmissionStep.loggingIn,
          message: 'Other job log',
        ));
        final logs = await repo.getLogs('job-001');
        expect(logs, hasLength(3));
        expect(logs.every((l) => l.jobId == 'job-001'), isTrue);
      });
    });

    group('watchAll', () {
      test('emits current list on subscription', () async {
        await repo.insert(makeJob('job-001'));
        final events = <List<SubmissionJob>>[];
        final sub = repo.watchAll().listen(events.add);
        await Future<void>.delayed(Duration.zero);
        expect(events, isNotEmpty);
        await sub.cancel();
      });

      test('emits new list after insert', () async {
        final events = <List<SubmissionJob>>[];
        final sub = repo.watchAll().listen(events.add);
        await repo.insert(makeJob('job-001'));
        await Future<void>.delayed(Duration.zero);
        final lengths = events.map((e) => e.length).toList();
        expect(lengths, contains(1));
        await sub.cancel();
      });
    });

    group('watchJob', () {
      test('emits job on update', () async {
        await repo.insert(makeJob('job-001'));
        final events = <SubmissionJob>[];
        final sub = repo.watchJob('job-001').listen(events.add);
        await repo.update(makeJob('job-001', step: SubmissionStep.loggingIn));
        await Future<void>.delayed(Duration.zero);
        expect(events.any((j) => j.currentStep == SubmissionStep.loggingIn), isTrue);
        await sub.cancel();
      });
    });

    group('watchLogs', () {
      test('emits logs as they are inserted', () async {
        await repo.insert(makeJob('job-001'));
        final allLogs = <SubmissionLog>[];
        final sub = repo.watchLogs('job-001').listen(allLogs.addAll);
        await repo.insertLog(SubmissionLog(
          id: 'log-x',
          jobId: 'job-001',
          timestamp: now,
          step: SubmissionStep.filling,
          message: 'Filling',
        ));
        await Future<void>.delayed(Duration.zero);
        expect(allLogs, isNotEmpty);
        await sub.cancel();
      });
    });
  });
}

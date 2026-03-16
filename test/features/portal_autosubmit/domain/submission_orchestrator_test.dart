import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

void main() {
  group('SubmissionOrchestrator', () {
    late MockSubmissionRepository repository;
    late SubmissionOrchestrator orchestrator;

    final baseJob = SubmissionJob(
      id: 'job-test-001',
      clientId: 'client-1',
      clientName: 'Test Client',
      portalType: PortalType.itd,
      returnType: 'ITR-1',
      currentStep: SubmissionStep.pending,
      retryCount: 0,
      createdAt: DateTime(2026, 3, 14),
    );

    setUp(() {
      repository = MockSubmissionRepository();
      orchestrator = SubmissionOrchestrator(repository: repository);
    });

    group('enqueue', () {
      test('adds job to repository', () async {
        await orchestrator.enqueue(baseJob);
        final jobs = await repository.getAll();
        expect(jobs, hasLength(1));
        expect(jobs.first.id, equals(baseJob.id));
      });

      test('returns the enqueued job', () async {
        final result = await orchestrator.enqueue(baseJob);
        expect(result.id, equals(baseJob.id));
        expect(result.currentStep, equals(SubmissionStep.pending));
      });
    });

    group('getJob', () {
      test('returns null for unknown id', () async {
        final result = await orchestrator.getJob('unknown-id');
        expect(result, isNull);
      });

      test('returns job after enqueue', () async {
        await orchestrator.enqueue(baseJob);
        final result = await orchestrator.getJob(baseJob.id);
        expect(result, isNotNull);
        expect(result!.id, equals(baseJob.id));
      });
    });

    group('getPending', () {
      test('returns empty list when no jobs', () async {
        final result = await orchestrator.getPending();
        expect(result, isEmpty);
      });

      test('returns only pending jobs', () async {
        final pendingJob = baseJob;
        final doneJob = baseJob.copyWith(
          id: 'job-done',
          currentStep: SubmissionStep.done,
        );
        await orchestrator.enqueue(pendingJob);
        await orchestrator.enqueue(doneJob);
        final result = await orchestrator.getPending();
        expect(result, hasLength(1));
        expect(result.first.id, equals(pendingJob.id));
      });
    });

    group('watchJob', () {
      test('emits updated job when state changes', () async {
        await orchestrator.enqueue(baseJob);
        final updates = <SubmissionJob>[];
        final subscription = orchestrator
            .watchJob(baseJob.id)
            .listen(updates.add);

        await orchestrator.updateStep(baseJob.id, SubmissionStep.loggingIn);
        await Future<void>.delayed(Duration.zero);
        expect(updates, isNotEmpty);
        expect(updates.last.currentStep, equals(SubmissionStep.loggingIn));
        await subscription.cancel();
      });
    });

    group('updateStep', () {
      test('updates the current step', () async {
        await orchestrator.enqueue(baseJob);
        await orchestrator.updateStep(baseJob.id, SubmissionStep.loggingIn);
        final job = await orchestrator.getJob(baseJob.id);
        expect(job!.currentStep, equals(SubmissionStep.loggingIn));
      });

      test('appends a log entry', () async {
        await orchestrator.enqueue(baseJob);
        await orchestrator.updateStep(
          baseJob.id,
          SubmissionStep.filling,
          message: 'Filling form fields',
        );
        final logs = await orchestrator.getLogs(baseJob.id);
        expect(logs, hasLength(1));
        expect(logs.first.step, equals(SubmissionStep.filling));
        expect(logs.first.message, equals('Filling form fields'));
      });

      test('does nothing for unknown job id', () async {
        // Should not throw
        await orchestrator.updateStep('unknown', SubmissionStep.done);
      });
    });

    group('markFailed', () {
      test('sets step to failed with error message', () async {
        await orchestrator.enqueue(baseJob);
        await orchestrator.markFailed(baseJob.id, 'Network timeout');
        final job = await orchestrator.getJob(baseJob.id);
        expect(job!.currentStep, equals(SubmissionStep.failed));
        expect(job.errorMessage, equals('Network timeout'));
      });

      test('increments retry count', () async {
        await orchestrator.enqueue(baseJob);
        await orchestrator.markFailed(baseJob.id, 'Error 1');
        final job = await orchestrator.getJob(baseJob.id);
        expect(job!.retryCount, equals(1));
      });
    });

    group('markDone', () {
      test('sets step to done with ack number and filedAt', () async {
        await orchestrator.enqueue(baseJob);
        final filedAt = DateTime(2026, 3, 14, 11, 0);
        await orchestrator.markDone(
          baseJob.id,
          ackNumber: 'ACK-2026-ITR1-00001',
          filedAt: filedAt,
        );
        final job = await orchestrator.getJob(baseJob.id);
        expect(job!.currentStep, equals(SubmissionStep.done));
        expect(job.ackNumber, equals('ACK-2026-ITR1-00001'));
        expect(job.filedAt, equals(filedAt));
      });
    });

    group('getLogs', () {
      test('returns empty list for job with no logs', () async {
        await orchestrator.enqueue(baseJob);
        final logs = await orchestrator.getLogs(baseJob.id);
        expect(logs, isEmpty);
      });

      test('returns logs in chronological order', () async {
        await orchestrator.enqueue(baseJob);
        await orchestrator.updateStep(
          baseJob.id,
          SubmissionStep.loggingIn,
          message: 'Step 1',
        );
        await orchestrator.updateStep(
          baseJob.id,
          SubmissionStep.filling,
          message: 'Step 2',
        );
        final logs = await orchestrator.getLogs(baseJob.id);
        expect(logs, hasLength(2));
        expect(logs[0].message, equals('Step 1'));
        expect(logs[1].message, equals('Step 2'));
      });

      test('returns empty list for unknown job', () async {
        final logs = await orchestrator.getLogs('unknown');
        expect(logs, isEmpty);
      });
    });

    group('watchLogs', () {
      test('streams log entries as they are added', () async {
        await orchestrator.enqueue(baseJob);
        final logs = <SubmissionLog>[];
        final subscription = orchestrator
            .watchLogs(baseJob.id)
            .listen((list) => logs.addAll(list));
        await orchestrator.updateStep(
          baseJob.id,
          SubmissionStep.loggingIn,
          message: 'Log 1',
        );
        await Future<void>.delayed(Duration.zero);
        expect(logs, isNotEmpty);
        await subscription.cancel();
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

void main() {
  group('SubmissionStep', () {
    test('has all expected values', () {
      expect(SubmissionStep.values, containsAll([
        SubmissionStep.pending,
        SubmissionStep.loggingIn,
        SubmissionStep.filling,
        SubmissionStep.otp,
        SubmissionStep.submitting,
        SubmissionStep.downloading,
        SubmissionStep.done,
        SubmissionStep.failed,
      ]));
    });

    test('each step has a non-empty label', () {
      for (final step in SubmissionStep.values) {
        expect(step.label, isNotEmpty);
      }
    });
  });

  group('SubmissionJob', () {
    final now = DateTime(2026, 3, 14, 10, 0);

    SubmissionJob makeJob({
      String id = 'job-001',
      String clientId = 'client-1',
      String clientName = 'Ravi Sharma',
      PortalType portalType = PortalType.itd,
      String returnType = 'ITR-1',
      SubmissionStep currentStep = SubmissionStep.pending,
      String? ackNumber,
      DateTime? filedAt,
      String? errorMessage,
      int retryCount = 0,
    }) {
      return SubmissionJob(
        id: id,
        clientId: clientId,
        clientName: clientName,
        portalType: portalType,
        returnType: returnType,
        currentStep: currentStep,
        ackNumber: ackNumber,
        filedAt: filedAt,
        errorMessage: errorMessage,
        retryCount: retryCount,
        createdAt: now,
      );
    }

    test('creates with required fields', () {
      final job = makeJob();
      expect(job.id, equals('job-001'));
      expect(job.clientId, equals('client-1'));
      expect(job.clientName, equals('Ravi Sharma'));
      expect(job.portalType, equals(PortalType.itd));
      expect(job.returnType, equals('ITR-1'));
      expect(job.currentStep, equals(SubmissionStep.pending));
      expect(job.retryCount, equals(0));
      expect(job.createdAt, equals(now));
    });

    test('optional fields default to null', () {
      final job = makeJob();
      expect(job.ackNumber, isNull);
      expect(job.filedAt, isNull);
      expect(job.errorMessage, isNull);
    });

    group('copyWith', () {
      test('creates new instance with updated fields', () {
        final original = makeJob();
        final updated = original.copyWith(
          currentStep: SubmissionStep.loggingIn,
          retryCount: 1,
        );
        expect(updated.currentStep, equals(SubmissionStep.loggingIn));
        expect(updated.retryCount, equals(1));
        expect(updated.id, equals(original.id));
        expect(updated.clientName, equals(original.clientName));
      });

      test('original is not mutated', () {
        final original = makeJob();
        original.copyWith(currentStep: SubmissionStep.done);
        expect(original.currentStep, equals(SubmissionStep.pending));
      });

      test('can set ackNumber', () {
        final job = makeJob().copyWith(
          ackNumber: 'ACK-2025-001',
          currentStep: SubmissionStep.done,
          filedAt: now,
        );
        expect(job.ackNumber, equals('ACK-2025-001'));
        expect(job.filedAt, equals(now));
      });

      test('can set errorMessage on failure', () {
        final job = makeJob().copyWith(
          currentStep: SubmissionStep.failed,
          errorMessage: 'Login failed: invalid credentials',
        );
        expect(job.currentStep, equals(SubmissionStep.failed));
        expect(job.errorMessage, equals('Login failed: invalid credentials'));
      });
    });

    group('computed properties', () {
      test('isCompleted returns true when done', () {
        expect(makeJob(currentStep: SubmissionStep.done).isCompleted, isTrue);
        expect(makeJob(currentStep: SubmissionStep.pending).isCompleted, isFalse);
      });

      test('isFailed returns true when failed', () {
        expect(makeJob(currentStep: SubmissionStep.failed).isFailed, isTrue);
        expect(makeJob(currentStep: SubmissionStep.done).isFailed, isFalse);
      });

      test('isInProgress returns true for active steps', () {
        for (final step in [
          SubmissionStep.loggingIn,
          SubmissionStep.filling,
          SubmissionStep.otp,
          SubmissionStep.submitting,
          SubmissionStep.downloading,
        ]) {
          expect(makeJob(currentStep: step).isInProgress, isTrue);
        }
        expect(makeJob(currentStep: SubmissionStep.pending).isInProgress, isFalse);
        expect(makeJob(currentStep: SubmissionStep.done).isInProgress, isFalse);
        expect(makeJob(currentStep: SubmissionStep.failed).isInProgress, isFalse);
      });

      test('canRetry returns true when failed and retryCount < 3', () {
        expect(
          makeJob(currentStep: SubmissionStep.failed, retryCount: 0).canRetry,
          isTrue,
        );
        expect(
          makeJob(currentStep: SubmissionStep.failed, retryCount: 2).canRetry,
          isTrue,
        );
        expect(
          makeJob(currentStep: SubmissionStep.failed, retryCount: 3).canRetry,
          isFalse,
        );
        expect(
          makeJob(currentStep: SubmissionStep.done, retryCount: 0).canRetry,
          isFalse,
        );
      });
    });

    group('equality', () {
      test('two jobs with same id are equal', () {
        final j1 = makeJob(id: 'job-abc');
        final j2 = makeJob(id: 'job-abc', clientName: 'Different Name');
        expect(j1, equals(j2));
      });

      test('jobs with different ids are not equal', () {
        final j1 = makeJob(id: 'job-001');
        final j2 = makeJob(id: 'job-002');
        expect(j1, isNot(equals(j2)));
      });
    });
  });

  group('SubmissionLog', () {
    final now = DateTime(2026, 3, 14, 10, 30);

    test('creates with all fields', () {
      final log = SubmissionLog(
        id: 'log-001',
        jobId: 'job-001',
        timestamp: now,
        step: SubmissionStep.loggingIn,
        message: 'Navigating to login page',
        isError: false,
      );
      expect(log.id, equals('log-001'));
      expect(log.jobId, equals('job-001'));
      expect(log.timestamp, equals(now));
      expect(log.step, equals(SubmissionStep.loggingIn));
      expect(log.message, equals('Navigating to login page'));
      expect(log.isError, isFalse);
    });

    test('isError defaults to false', () {
      final log = SubmissionLog(
        id: 'log-002',
        jobId: 'job-001',
        timestamp: now,
        step: SubmissionStep.filling,
        message: 'Filling PAN field',
      );
      expect(log.isError, isFalse);
    });

    test('creates error log', () {
      final log = SubmissionLog(
        id: 'log-003',
        jobId: 'job-001',
        timestamp: now,
        step: SubmissionStep.failed,
        message: 'Network error: connection timeout',
        isError: true,
      );
      expect(log.isError, isTrue);
    });

    test('copyWith creates new instance', () {
      final original = SubmissionLog(
        id: 'log-001',
        jobId: 'job-001',
        timestamp: now,
        step: SubmissionStep.loggingIn,
        message: 'Starting login',
      );
      final updated = original.copyWith(
        message: 'Login completed',
        step: SubmissionStep.filling,
      );
      expect(updated.message, equals('Login completed'));
      expect(updated.step, equals(SubmissionStep.filling));
      expect(updated.id, equals(original.id));
    });
  });
}

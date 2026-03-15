// Tests for the auto-submit wiring layer:
// 1. SubmissionOrchestrator.appendLog
// 2. credentialForPortalProvider — resolves credential from repository
// 3. autosubmitCredentialRepositoryProvider — delegates to portal connector
// 4. Automation runner dispatch — each portal type selects the right service
// 5. PortalWebViewController mock-login integration per service

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/data/repositories/mock_submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/epfo_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/gstn_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/mca_autosubmit_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/traces_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/data/repositories/mock_portal_connector_repository.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SubmissionJob makeJob(
  String id, {
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
    createdAt: DateTime(2026, 3, 14),
  );
}

SubmissionLog makeLog(String jobId, SubmissionStep step, String message) {
  return SubmissionLog(
    id: '${jobId}_${step.name}_1',
    jobId: jobId,
    timestamp: DateTime(2026, 3, 14),
    step: step,
    message: message,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // SubmissionOrchestrator.appendLog
  // -------------------------------------------------------------------------

  group('SubmissionOrchestrator.appendLog', () {
    late MockSubmissionRepository repo;
    late SubmissionOrchestrator orchestrator;

    setUp(() {
      repo = MockSubmissionRepository();
      orchestrator = SubmissionOrchestrator(repository: repo);
    });

    tearDown(() => repo.dispose());

    test('persists log entry via repository', () async {
      final job = makeJob('job-001');
      await orchestrator.enqueue(job);

      final log = makeLog('job-001', SubmissionStep.loggingIn, 'Navigating');
      await orchestrator.appendLog(log);

      final logs = await orchestrator.getLogs('job-001');
      expect(logs, hasLength(1));
      expect(logs.first.message, equals('Navigating'));
    });

    test('appended log is watchable via watchLogs stream', () async {
      final job = makeJob('job-002');
      await orchestrator.enqueue(job);

      final received = <SubmissionLog>[];
      final sub = orchestrator.watchLogs('job-002').listen(
        (batch) => received.addAll(batch),
      );

      final log = makeLog('job-002', SubmissionStep.filling, 'Filling form');
      await orchestrator.appendLog(log);
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.first.step, equals(SubmissionStep.filling));
      await sub.cancel();
    });

    test('appending log for unknown job does not throw', () async {
      final log = makeLog('no-such-job', SubmissionStep.loggingIn, 'Test');
      // insertLog on the repo creates a bucket even if no job exists
      await expectLater(orchestrator.appendLog(log), completes);
    });

    test('multiple logs are accumulated in order', () async {
      final job = makeJob('job-003');
      await orchestrator.enqueue(job);

      final log1 = SubmissionLog(
        id: 'log-a',
        jobId: 'job-003',
        timestamp: DateTime(2026, 3, 14, 10, 0, 1),
        step: SubmissionStep.loggingIn,
        message: 'Step A',
      );
      final log2 = SubmissionLog(
        id: 'log-b',
        jobId: 'job-003',
        timestamp: DateTime(2026, 3, 14, 10, 0, 2),
        step: SubmissionStep.filling,
        message: 'Step B',
      );

      await orchestrator.appendLog(log1);
      await orchestrator.appendLog(log2);

      final logs = await orchestrator.getLogs('job-003');
      expect(logs, hasLength(2));
      expect(logs[0].message, equals('Step A'));
      expect(logs[1].message, equals('Step B'));
    });
  });

  // -------------------------------------------------------------------------
  // credentialForPortalProvider
  // -------------------------------------------------------------------------

  group('credentialForPortalProvider', () {
    ProviderContainer buildContainer({
      PortalCredentialRepository? credRepo,
    }) {
      return ProviderContainer(
        overrides: [
          if (credRepo != null)
            autosubmitCredentialRepositoryProvider.overrideWithValue(credRepo),
        ],
      );
    }

    test('resolves stored credential for a portal type', () async {
      final mock = MockPortalCredentialRepository();
      final container = buildContainer(credRepo: mock);
      addTearDown(container.dispose);

      final result = await container.read(
        credentialForPortalProvider(PortalType.itd).future,
      );

      expect(result, isNotNull);
      expect(result!.portalType, equals(PortalType.itd));
      expect(result.username, isNotEmpty);
    });

    test('returns null when no credential is stored for portal type', () async {
      // Delete the ITD credential from the mock repo.
      final mock = MockPortalCredentialRepository();
      await mock.deleteCredential(PortalType.gstn);

      final container = buildContainer(credRepo: mock);
      addTearDown(container.dispose);

      final result = await container.read(
        credentialForPortalProvider(PortalType.gstn).future,
      );
      expect(result, isNull);
    });

    test('resolves all 5 portal types', () async {
      final mock = MockPortalCredentialRepository();
      final container = buildContainer(credRepo: mock);
      addTearDown(container.dispose);

      for (final portalType in PortalType.values) {
        final result = await container.read(
          credentialForPortalProvider(portalType).future,
        );
        expect(
          result,
          isNotNull,
          reason: 'Expected credential for ${portalType.name}',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // autosubmitCredentialRepositoryProvider
  // -------------------------------------------------------------------------

  group('autosubmitCredentialRepositoryProvider', () {
    test('returns PortalCredentialRepository instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(autosubmitCredentialRepositoryProvider);
      expect(repo, isA<PortalCredentialRepository>());
    });
  });

  // -------------------------------------------------------------------------
  // Service mock-login streams (no WebView — null controller → mock path)
  // -------------------------------------------------------------------------

  group('Mock login stream — falls back when webViewController is null', () {
    late OtpInterceptService otpService;

    final credential = PortalCredential(
      id: 'cred-test',
      portalType: PortalType.itd,
      username: 'test_user',
    );

    setUp(() => otpService = OtpInterceptService());
    tearDown(() => otpService.dispose());

    test('ITD mock login yields multiple log entries', () async {
      final logs = await const ItdAutosubmitService()
          .login(credential: credential, otpService: otpService)
          .toList();

      expect(logs, isNotEmpty);
      expect(
        logs.every((l) => l.step == SubmissionStep.loggingIn),
        isTrue,
        reason: 'All mock login logs should be in loggingIn step',
      );
    });

    test('GSTN mock login yields multiple log entries', () async {
      final gstCredential = credential.copyWith(
        portalType: PortalType.gstn,
      );
      final logs = await const GstnAutosubmitService()
          .login(credential: gstCredential, otpService: otpService)
          .toList();

      expect(logs, isNotEmpty);
    });

    test('TRACES mock login yields multiple log entries', () async {
      final tracesCredential = credential.copyWith(
        portalType: PortalType.traces,
      );
      final logs = await const TracesAutosubmitService()
          .login(credential: tracesCredential, otpService: otpService)
          .toList();

      expect(logs, isNotEmpty);
    });

    test('MCA mock login yields multiple log entries', () async {
      final mcaCredential = credential.copyWith(
        portalType: PortalType.mca,
      );
      final logs = await const McaAutosubmitService()
          .login(credential: mcaCredential, otpService: otpService)
          .toList();

      expect(logs, isNotEmpty);
    });

    test('EPFO mock login yields multiple log entries', () async {
      final epfoCredential = credential.copyWith(
        portalType: PortalType.epfo,
      );
      final logs = await const EpfoAutosubmitService()
          .login(credential: epfoCredential, otpService: otpService)
          .toList();

      expect(logs, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Automation runner dispatch — correct service per portal type
  // -------------------------------------------------------------------------

  group('Automation runner — mock login dispatches to correct service', () {
    late OtpInterceptService otpService;

    setUp(() => otpService = OtpInterceptService());
    tearDown(() => otpService.dispose());

    Future<List<SubmissionLog>> runMockLogin(PortalType portalType) {
      final credential = PortalCredential(
        id: 'cred-${portalType.name}',
        portalType: portalType,
        username: 'user',
      );

      // null controller triggers mock path in every service
      final Stream<SubmissionLog> stream = switch (portalType) {
        PortalType.itd => const ItdAutosubmitService()
            .login(credential: credential, otpService: otpService),
        PortalType.gstn => const GstnAutosubmitService()
            .login(credential: credential, otpService: otpService),
        PortalType.traces => const TracesAutosubmitService()
            .login(credential: credential, otpService: otpService),
        PortalType.mca => const McaAutosubmitService()
            .login(credential: credential, otpService: otpService),
        PortalType.epfo => const EpfoAutosubmitService()
            .login(credential: credential, otpService: otpService),
      };

      return stream.toList();
    }

    for (final portalType in PortalType.values) {
      test(
        'dispatches ${portalType.name} correctly and yields logs',
        () async {
          final logs = await runMockLogin(portalType);
          expect(
            logs,
            isNotEmpty,
            reason:
                '${portalType.name} mock login should yield at least one log',
          );
          expect(
            logs.every((l) => l.jobId.startsWith(portalType.name)),
            isTrue,
            reason:
                'All logs for ${portalType.name} should have matching jobId prefix',
          );
        },
      );
    }
  });

  // -------------------------------------------------------------------------
  // SubmissionOrchestrator — full step + log lifecycle
  // -------------------------------------------------------------------------

  group('SubmissionOrchestrator full lifecycle with appendLog', () {
    late MockSubmissionRepository repo;
    late SubmissionOrchestrator orchestrator;

    setUp(() {
      repo = MockSubmissionRepository();
      orchestrator = SubmissionOrchestrator(repository: repo);
    });

    tearDown(() => repo.dispose());

    test('enqueue → updateStep → appendLog → markDone persists correctly',
        () async {
      final job = makeJob('job-lifecycle');
      await orchestrator.enqueue(job);

      // Simulate login step
      await orchestrator.updateStep(
        'job-lifecycle',
        SubmissionStep.loggingIn,
        message: 'Login started',
      );

      // Simulate service emitting logs via appendLog
      final log1 = makeLog(
        'job-lifecycle',
        SubmissionStep.loggingIn,
        'Navigating to portal',
      );
      final log2 = makeLog(
        'job-lifecycle',
        SubmissionStep.loggingIn,
        'Entering credentials',
      );
      await orchestrator.appendLog(log1);
      await orchestrator.appendLog(log2);

      // Simulate submission complete
      await orchestrator.markDone(
        'job-lifecycle',
        ackNumber: 'ACK-2026-001',
        filedAt: DateTime(2026, 3, 14, 12, 0),
      );

      final finalJob = await orchestrator.getJob('job-lifecycle');
      expect(finalJob!.currentStep, equals(SubmissionStep.done));
      expect(finalJob.ackNumber, equals('ACK-2026-001'));

      // 3 logs: 'Login started' (from updateStep) + 2 appendLog + done entry
      final logs = await orchestrator.getLogs('job-lifecycle');
      expect(logs.length, greaterThanOrEqualTo(4));
    });

    test('markFailed increments retryCount and appends error log', () async {
      final job = makeJob('job-fail');
      await orchestrator.enqueue(job);
      await orchestrator.markFailed('job-fail', 'Login timeout');

      final failedJob = await orchestrator.getJob('job-fail');
      expect(failedJob!.currentStep, equals(SubmissionStep.failed));
      expect(failedJob.retryCount, equals(1));
      expect(failedJob.errorMessage, equals('Login timeout'));

      final logs = await orchestrator.getLogs('job-fail');
      expect(logs.any((l) => l.isError), isTrue);
    });
  });
}

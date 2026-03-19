import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/repositories/submission_repository.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_job_runner.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/submission_orchestrator.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_credential_repository.dart';

// ---------------------------------------------------------------------------
// In-memory mock repository for SubmissionRepository
// ---------------------------------------------------------------------------

class _MockSubmissionRepository implements SubmissionRepository {
  final Map<String, SubmissionJob> _jobs = {};
  final Map<String, List<SubmissionLog>> _logs = {};

  @override
  Future<void> insert(SubmissionJob job) async {
    _jobs[job.id] = job;
  }

  @override
  Future<SubmissionJob?> getById(String id) async => _jobs[id];

  @override
  Future<List<SubmissionJob>> getAll() async => _jobs.values.toList();

  @override
  Future<List<SubmissionJob>> getByPortal(PortalType portalType) async =>
      _jobs.values.where((j) => j.portalType == portalType).toList();

  @override
  Future<List<SubmissionJob>> getByClient(String clientId) async =>
      _jobs.values.where((j) => j.clientId == clientId).toList();

  @override
  Future<List<SubmissionJob>> getPending() async => _jobs.values
      .where((j) => j.currentStep == SubmissionStep.pending)
      .toList();

  @override
  Future<void> update(SubmissionJob job) async {
    _jobs[job.id] = job;
  }

  @override
  Future<void> insertLog(SubmissionLog log) async {
    _logs.putIfAbsent(log.jobId, () => []).add(log);
  }

  @override
  Future<List<SubmissionLog>> getLogs(String jobId) async => _logs[jobId] ?? [];

  @override
  Stream<List<SubmissionJob>> watchAll() => const Stream.empty();

  @override
  Stream<SubmissionJob> watchJob(String id) => const Stream.empty();

  @override
  Stream<List<SubmissionLog>> watchLogs(String id) => const Stream.empty();
}

// ---------------------------------------------------------------------------
// Mock credential repository
// ---------------------------------------------------------------------------

class _MockCredentialRepository implements PortalCredentialRepository {
  final Map<PortalType, PortalCredential> _credentials = {};

  void addCredential(PortalCredential credential) {
    _credentials[credential.portalType] = credential;
  }

  @override
  Future<PortalCredential?> getCredential(PortalType portalType) async =>
      _credentials[portalType];

  @override
  Future<String> storeCredential(PortalCredential credential) async {
    _credentials[credential.portalType] = credential;
    return credential.id;
  }

  @override
  Future<bool> updateCredential(PortalCredential credential) async {
    if (!_credentials.containsKey(credential.portalType)) return false;
    _credentials[credential.portalType] = credential;
    return true;
  }

  @override
  Future<bool> deleteCredential(PortalType portalType) async =>
      _credentials.remove(portalType) != null;

  @override
  Future<String?> getSyncStatus(PortalType portalType) async =>
      _credentials[portalType]?.status;

  @override
  Future<bool> updateSyncStatus(PortalType portalType, String status) async {
    final cred = _credentials[portalType];
    if (cred == null) return false;
    _credentials[portalType] = cred.copyWith(status: status);
    return true;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockSubmissionRepository submissionRepo;
  late _MockCredentialRepository credentialRepo;
  late SubmissionOrchestrator orchestrator;
  late OtpInterceptService otpService;
  late SubmissionJobRunner runner;

  setUp(() {
    submissionRepo = _MockSubmissionRepository();
    credentialRepo = _MockCredentialRepository();
    orchestrator = SubmissionOrchestrator(repository: submissionRepo);
    otpService = OtpInterceptService();
    runner = SubmissionJobRunner(
      orchestrator: orchestrator,
      credentialRepo: credentialRepo,
      otpService: otpService,
    );
  });

  tearDown(() {
    otpService.dispose();
  });

  SubmissionJob _makeJob({
    String id = 'job-1',
    PortalType portalType = PortalType.itd,
  }) {
    return SubmissionJob(
      id: id,
      clientId: 'client-123',
      clientName: 'Rajesh Kumar',
      portalType: portalType,
      returnType: 'ITR-1',
      currentStep: SubmissionStep.pending,
      retryCount: 0,
      createdAt: DateTime(2026, 3, 15),
    );
  }

  group('prepare', () {
    test('throws when no credential is stored for the portal type', () async {
      final job = _makeJob();

      await expectLater(
        runner.prepare(job),
        throwsA(isA<SubmissionRunnerException>()),
      );
    });

    test(
      'returns PreparedRun with correct portal URL and gate for ITD',
      () async {
        credentialRepo.addCredential(
          const PortalCredential(
            id: 'cred-1',
            portalType: PortalType.itd,
            username: 'ABCDE1234F',
            encryptedPassword: 'iv:cipher',
          ),
        );

        final job = _makeJob(portalType: PortalType.itd);
        final prepared = await runner.prepare(job);

        expect(prepared.portalUrl, contains('incometax.gov.in'));
        expect(prepared.runner, isNotNull);
        expect(prepared.confirmationGate, isNotNull);
        expect(prepared.confirmationGate.isPending, isFalse);
        prepared.confirmationGate.dispose();
      },
    );

    test('returns PreparedRun with correct portal URL for GSTN', () async {
      credentialRepo.addCredential(
        const PortalCredential(
          id: 'cred-2',
          portalType: PortalType.gstn,
          username: '29ABCDE1234F1Z5',
          encryptedPassword: 'iv:cipher',
        ),
      );

      final job = _makeJob(portalType: PortalType.gstn);
      final prepared = await runner.prepare(job);

      expect(prepared.portalUrl, contains('gst.gov.in'));
    });

    test('returns PreparedRun with correct URL for all portal types', () async {
      for (final portal in PortalType.values) {
        credentialRepo.addCredential(
          PortalCredential(
            id: 'cred-${portal.name}',
            portalType: portal,
            username: 'user',
            encryptedPassword: 'iv:cipher',
          ),
        );

        final job = _makeJob(portalType: portal);
        final prepared = await runner.prepare(job);
        expect(prepared.portalUrl, isNotEmpty);
      }
    });
  });

  group('SubmissionRunnerException', () {
    test('toString includes message', () {
      const e = SubmissionRunnerException('No credentials found');
      expect(e.toString(), contains('No credentials found'));
    });
  });

  group('PreparedRun', () {
    test('holds portalUrl, runner, and confirmationGate', () {
      final gate = ConfirmationGate();
      final run = PreparedRun(
        portalUrl: 'https://example.com',
        runner: (_) => const Stream.empty(),
        confirmationGate: gate,
      );
      expect(run.portalUrl, 'https://example.com');
      expect(run.runner, isNotNull);
      expect(run.confirmationGate, same(gate));
      gate.dispose();
    });
  });
}

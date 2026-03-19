import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/traces_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end integration test for the TRACES autosubmit pipeline.
///
/// Proves the complete flow through all four TRACES operations using mock
/// streams (no real WebView). Verifies:
///
/// 1. **Login** — TAN/password login with CAPTCHA acknowledgement
/// 2. **FVU Upload** — Form type selection, file upload, submission
/// 3. **Challan Verification** — BSR/date/serial input, status extraction
/// 4. **Form 16 Download** — FY selection, bulk download trigger
/// 5. **Justification Report** — Token number entry, report download
/// 6. **Job State Machine** — SubmissionJob transitions for TRACES portal
/// 7. **Full Pipeline** — All operations sequenced end-to-end
void main() {
  group('TRACES End-to-End Pipeline', () {
    const tracesService = TracesAutosubmitService();
    const testTan = 'PNET12345A';
    const testFy = '2025-26';

    // -----------------------------------------------------------------------
    // Phase 1: Login
    // -----------------------------------------------------------------------

    group('Phase 1 — Login', () {
      test('mock login stream emits expected steps', () async {
        final credential = PortalCredential(
          id: 'cred-traces-001',
          portalType: PortalType.traces,
          username: testTan,
          encryptedPassword: 'mock-encrypted',
        );

        final logs = <SubmissionLog>[];
        await for (final log in tracesService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs.first.step, SubmissionStep.loggingIn);
        expect(logs.first.message, contains('Navigating'));
        expect(logs[1].message, contains('TAN'));
        expect(logs[2].message, contains('CAPTCHA'));
        expect(logs.last.message, contains('Login completed'));
      });

      test('all login logs reference correct job ID', () async {
        final credential = PortalCredential(
          id: 'cred-traces-002',
          portalType: PortalType.traces,
          username: testTan,
          encryptedPassword: 'mock-encrypted',
        );

        final logs = <SubmissionLog>[];
        await for (final log in tracesService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        for (final log in logs) {
          expect(log.jobId, contains('traces_login_'));
          expect(log.jobId, contains('cred-traces-002'));
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 2: FVU Upload
    // -----------------------------------------------------------------------

    group('Phase 2 — FVU Upload', () {
      test('mock FVU upload emits fill + submit steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.uploadFvu(
          tan: testTan,
          fvuFilePath: '/tmp/26Q_FVU_Q2.fvu',
          formType: '26Q',
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 5);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains('Navigating'));
        expect(logs[1].message, contains('26Q'));
        expect(logs[2].message, contains('FVU file'));
        expect(logs[3].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(testTan));
      });

      test('FVU upload supports all form types', () async {
        for (final formType in ['24Q', '26Q', '27Q', '27EQ']) {
          final logs = <SubmissionLog>[];
          await for (final log in tracesService.uploadFvu(
            tan: testTan,
            fvuFilePath: '/tmp/${formType}_FVU.fvu',
            formType: formType,
            otpService: OtpInterceptService(),
          )) {
            logs.add(log);
          }

          expect(logs.last.step, SubmissionStep.done);
          expect(
            logs.last.message,
            contains(formType),
            reason: 'Done message should mention form type $formType',
          );
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 3: Challan Verification
    // -----------------------------------------------------------------------

    group('Phase 3 — Challan Verification', () {
      test('mock challan verification emits expected steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.verifyChallan(
          tan: testTan,
          bsrCode: '0510461',
          challanDate: '15-01-2026',
          serialNumber: '00123',
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains('challan verification'));
        expect(logs[1].message, contains('BSR'));
        expect(logs[1].message, contains('0510461'));
        expect(logs[1].message, contains('15-01-2026'));
        expect(logs[1].message, contains('00123'));
        expect(logs[2].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(testTan));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 4: Form 16 Download
    // -----------------------------------------------------------------------

    group('Phase 4 — Form 16 Download', () {
      test('mock Form 16 download emits download steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.downloadForm16(
          tan: testTan,
          financialYear: testFy,
          savePath: '/tmp/Form16_$testTan.zip',
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 5);
        expect(logs.first.step, SubmissionStep.downloading);
        expect(logs.first.message, contains('Form 16'));
        expect(logs[1].message, contains(testFy));
        expect(logs[2].message, contains('bulk download'));
        expect(logs[3].message, contains('/tmp/'));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(testTan));
        expect(logs.last.message, contains(testFy));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 5: Justification Report
    // -----------------------------------------------------------------------

    group('Phase 5 — Justification Report', () {
      test('mock JR download emits download steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.downloadJustificationReport(
          tan: testTan,
          tokenNumber: 'TKN20260315001',
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs.first.step, SubmissionStep.downloading);
        expect(logs.first.message, contains('justification report'));
        expect(logs[1].message, contains('TKN20260315001'));
        expect(logs[2].message, contains('Downloading'));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains('TKN20260315001'));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 6: Job State Machine
    // -----------------------------------------------------------------------

    group('Phase 6 — Submission job for TRACES', () {
      test('creates a valid TRACES submission job', () {
        final job = SubmissionJob(
          id: 'job-traces-001',
          clientId: testTan,
          clientName: 'Test Deductor Pvt Ltd',
          portalType: PortalType.traces,
          returnType: '26Q',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        expect(job.isCompleted, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isInProgress, isFalse);
        expect(job.portalType, PortalType.traces);
        expect(job.returnType, '26Q');
      });

      test('TRACES job transitions through all steps', () {
        final pending = SubmissionJob(
          id: 'job-traces-002',
          clientId: testTan,
          clientName: 'Test Deductor',
          portalType: PortalType.traces,
          returnType: '26Q',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        // pending -> loggingIn -> filling -> submitting -> downloading -> done
        final loggingIn =
            pending.copyWith(currentStep: SubmissionStep.loggingIn);
        expect(loggingIn.isInProgress, isTrue);

        final filling =
            loggingIn.copyWith(currentStep: SubmissionStep.filling);
        expect(filling.isInProgress, isTrue);

        final submitting =
            filling.copyWith(currentStep: SubmissionStep.submitting);
        expect(submitting.isInProgress, isTrue);

        final downloading =
            submitting.copyWith(currentStep: SubmissionStep.downloading);
        expect(downloading.isInProgress, isTrue);

        final done = downloading.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'TKN20260315001',
          filedAt: DateTime.now(),
        );
        expect(done.isCompleted, isTrue);
        expect(done.ackNumber, 'TKN20260315001');
      });

      test('failed TRACES job supports retry', () {
        final failed = SubmissionJob(
          id: 'job-traces-003',
          clientId: testTan,
          clientName: 'Test Deductor',
          portalType: PortalType.traces,
          returnType: '24Q',
          currentStep: SubmissionStep.failed,
          retryCount: 0,
          createdAt: DateTime.now(),
          errorMessage: 'CAPTCHA timeout',
        );

        expect(failed.canRetry, isTrue);

        final maxRetries = failed.copyWith(retryCount: 3);
        expect(maxRetries.canRetry, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 7: Full Pipeline
    // -----------------------------------------------------------------------

    group('Phase 7 — Full pipeline: login -> upload -> verify -> download',
        () {
      test('complete TRACES automation sequence runs all phases', () async {
        final credential = PortalCredential(
          id: 'cred-e2e',
          portalType: PortalType.traces,
          username: testTan,
          encryptedPassword: 'mock-encrypted',
        );

        final allLogs = <SubmissionLog>[];

        // Phase 1: Login
        await for (final log in tracesService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Login completed'));

        // Phase 2: Upload FVU
        await for (final log in tracesService.uploadFvu(
          tan: testTan,
          fvuFilePath: '/tmp/26Q_FVU_Q2.fvu',
          formType: '26Q',
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('FVU submitted'));

        // Phase 3: Verify Challan
        await for (final log in tracesService.verifyChallan(
          tan: testTan,
          bsrCode: '0510461',
          challanDate: '15-01-2026',
          serialNumber: '00123',
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('verification completed'));

        // Phase 4: Download Form 16
        await for (final log in tracesService.downloadForm16(
          tan: testTan,
          financialYear: testFy,
          savePath: '/tmp/Form16_$testTan.zip',
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Form 16 downloaded'));

        // Phase 5: Download Justification Report
        await for (final log in tracesService.downloadJustificationReport(
          tan: testTan,
          tokenNumber: 'TKN20260315001',
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Justification report'));

        // ---- ASSERTIONS: The full pipeline completed ----
        expect(
          allLogs.length,
          greaterThanOrEqualTo(20),
          reason: 'Full TRACES pipeline should emit 20+ log entries '
              '(4+5+4+5+4 = 22)',
        );

        // Verify progression through all steps
        final steps = allLogs.map((l) => l.step).toSet();
        expect(
          steps,
          containsAll([
            SubmissionStep.loggingIn,
            SubmissionStep.filling,
            SubmissionStep.submitting,
            SubmissionStep.downloading,
            SubmissionStep.done,
          ]),
        );

        // Verify no errors in the stream
        expect(allLogs.where((l) => l.isError), isEmpty);

        // Verify all logs have valid timestamps and metadata
        for (final log in allLogs) {
          expect(log.timestamp, isNotNull);
          expect(log.jobId, isNotEmpty);
          expect(log.message, isNotEmpty);
          expect(log.id, isNotEmpty);
        }
      });

      test('pipeline with job state tracking', () async {
        final credential = PortalCredential(
          id: 'cred-e2e-job',
          portalType: PortalType.traces,
          username: testTan,
          encryptedPassword: 'mock-encrypted',
        );

        var job = SubmissionJob(
          id: 'e2e-traces-001',
          clientId: testTan,
          clientName: 'Test Deductor Pvt Ltd',
          portalType: PortalType.traces,
          returnType: '26Q',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        final allLogs = <SubmissionLog>[];

        // Login
        job = job.copyWith(currentStep: SubmissionStep.loggingIn);
        await for (final log in tracesService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // Upload FVU
        job = job.copyWith(currentStep: SubmissionStep.filling);
        await for (final log in tracesService.uploadFvu(
          tan: testTan,
          fvuFilePath: '/tmp/26Q_FVU_Q2.fvu',
          formType: '26Q',
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // Download Form 16
        job = job.copyWith(currentStep: SubmissionStep.downloading);
        await for (final log in tracesService.downloadForm16(
          tan: testTan,
          financialYear: testFy,
          savePath: '/tmp/Form16_$testTan.zip',
        )) {
          allLogs.add(log);
        }

        // Mark done
        job = job.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'TKN-E2E-TEST',
          filedAt: DateTime.now(),
        );

        expect(job.isCompleted, isTrue);
        expect(job.ackNumber, 'TKN-E2E-TEST');
        expect(allLogs.where((l) => l.isError), isEmpty);
        expect(
          allLogs.length,
          greaterThanOrEqualTo(13),
          reason: 'Login(4) + Upload(5) + Download(5) = 14 log entries',
        );
      });
    });

    // -----------------------------------------------------------------------
    // Phase 8: Mock stream null-safety (webViewController = null)
    // -----------------------------------------------------------------------

    group('Phase 8 — Mock fallback when WebView is null', () {
      test('uploadFvu falls back to mock when webViewController is null',
          () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.uploadFvu(
          tan: testTan,
          fvuFilePath: '/tmp/test.fvu',
          formType: '24Q',
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }
        expect(logs, isNotEmpty);
        expect(logs.last.step, SubmissionStep.done);
      });

      test('verifyChallan falls back to mock when webViewController is null',
          () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.verifyChallan(
          tan: testTan,
          bsrCode: '0510461',
          challanDate: '15-01-2026',
          serialNumber: '00123',
        )) {
          logs.add(log);
        }
        expect(logs, isNotEmpty);
        expect(logs.last.step, SubmissionStep.done);
      });

      test('downloadForm16 falls back to mock when webViewController is null',
          () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.downloadForm16(
          tan: testTan,
          financialYear: testFy,
          savePath: '/tmp/form16.zip',
        )) {
          logs.add(log);
        }
        expect(logs, isNotEmpty);
        expect(logs.last.step, SubmissionStep.done);
      });

      test(
          'downloadJustificationReport falls back to mock when '
          'webViewController is null', () async {
        final logs = <SubmissionLog>[];
        await for (final log in tracesService.downloadJustificationReport(
          tan: testTan,
          tokenNumber: 'TKN001',
        )) {
          logs.add(log);
        }
        expect(logs, isNotEmpty);
        expect(logs.last.step, SubmissionStep.done);
      });
    });
  });
}

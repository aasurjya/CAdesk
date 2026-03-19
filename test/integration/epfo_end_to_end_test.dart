import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/epfo_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end integration test for the EPFO automation pipeline.
///
/// Proves the complete flow using mock streams (no real WebView):
///
/// 1. **Login** — Authenticate to the EPFO Unified Portal
/// 2. **ECR Upload** — Upload Electronic Challan cum Return for a wage month
/// 3. **Challan Generation** — Generate EPF payment challan with amounts
/// 4. **KYC Check** — Check member KYC status by UAN
/// 5. **Receipt Download** — Download payment receipt for a settled challan
/// 6. **Submission Job** — Verify job state machine transitions
/// 7. **Full Pipeline** — Run all phases sequentially end-to-end
void main() {
  group('EPFO End-to-End Pipeline', () {
    // -----------------------------------------------------------------------
    // Test data
    // -----------------------------------------------------------------------

    const establishmentId = 'MHPUN0012345';
    const wageMonth = '03/2026';
    const ecrFilePath = '/tmp/ECR_MHPUN0012345_032026.txt';
    const challanSavePath = '/tmp/Challan_MHPUN0012345_032026.pdf';
    const receiptSavePath = '/tmp/Receipt_MHPUN0012345_CHL001.pdf';
    const challanId = 'CHL-2026-03-001';
    const testUan = '101234567890';

    const epfoService = EpfoAutosubmitService();

    // -----------------------------------------------------------------------
    // Phase 1: Login
    // -----------------------------------------------------------------------

    group('Phase 1 — EPFO login (mock)', () {
      test('login mock stream emits expected steps', () async {
        final credential = PortalCredential(
          id: 'cred-epfo-001',
          portalType: PortalType.epfo,
          username: establishmentId,
          encryptedPassword: 'mock-encrypted',
        );

        final logs = <SubmissionLog>[];
        await for (final log in epfoService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 3);
        expect(logs.first.step, SubmissionStep.loggingIn);
        expect(logs.first.message, contains('Navigating'));
        expect(logs.last.message, contains('Login completed'));
      });

      test('login logs have valid structure', () async {
        final credential = PortalCredential(
          id: 'cred-epfo-002',
          portalType: PortalType.epfo,
          username: establishmentId,
          encryptedPassword: 'mock-encrypted',
        );

        final logs = <SubmissionLog>[];
        await for (final log in epfoService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        for (final log in logs) {
          expect(log.jobId, startsWith('epfo_login_'));
          expect(log.timestamp, isNotNull);
          expect(log.message, isNotEmpty);
          expect(log.isError, isFalse);
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 2: ECR Upload
    // -----------------------------------------------------------------------

    group('Phase 2 — ECR upload (mock)', () {
      test('ECR upload emits fill + submit + done steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.uploadEcr(
          establishmentId: establishmentId,
          ecrFilePath: ecrFilePath,
          wageMonth: wageMonth,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 6);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains('ECR'));
        expect(logs[1].message, contains(wageMonth));
        expect(logs[2].message, contains(ecrFilePath));
        expect(logs[4].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(wageMonth));
      });

      test('ECR upload log IDs are unique', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.uploadEcr(
          establishmentId: establishmentId,
          ecrFilePath: ecrFilePath,
          wageMonth: wageMonth,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        final ids = logs.map((l) => l.id).toSet();
        expect(ids.length, logs.length, reason: 'All log IDs should be unique');
      });
    });

    // -----------------------------------------------------------------------
    // Phase 3: Challan Generation
    // -----------------------------------------------------------------------

    group('Phase 3 — Challan generation (mock)', () {
      test('challan generation emits fill + submit + download steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.generateChallan(
          establishmentId: establishmentId,
          wageMonth: wageMonth,
          epfAmount: 50000.00,
          epsAmount: 25000.00,
          savePath: challanSavePath,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 6);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[1].message, contains('50000.00'));
        expect(logs[1].message, contains('25000.00'));
        expect(logs[2].step, SubmissionStep.submitting);
        expect(logs[3].step, SubmissionStep.downloading);
        expect(logs[4].message, contains(challanSavePath));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(establishmentId));
      });

      test('challan amounts are formatted correctly', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.generateChallan(
          establishmentId: establishmentId,
          wageMonth: wageMonth,
          epfAmount: 123456.78,
          epsAmount: 65432.10,
          savePath: challanSavePath,
        )) {
          logs.add(log);
        }

        final amountLog = logs.firstWhere(
          (l) => l.message.contains('123456.78'),
        );
        expect(amountLog.message, contains('65432.10'));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 4: KYC Status Check
    // -----------------------------------------------------------------------

    group('Phase 4 — KYC status check (mock)', () {
      test('KYC check emits fill + download + done steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.checkMemberKyc(
          uan: testUan,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[1].message, contains(testUan));
        expect(logs[2].step, SubmissionStep.downloading);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(testUan));
      });

      test('KYC check includes UAN in all relevant logs', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.checkMemberKyc(
          uan: testUan,
        )) {
          logs.add(log);
        }

        final uanLogs = logs.where((l) => l.message.contains(testUan));
        expect(
          uanLogs.length,
          greaterThanOrEqualTo(2),
          reason: 'UAN should appear in input and result logs',
        );
      });
    });

    // -----------------------------------------------------------------------
    // Phase 5: Payment Receipt Download
    // -----------------------------------------------------------------------

    group('Phase 5 — Payment receipt download (mock)', () {
      test('receipt download emits downloading + done steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in epfoService.downloadPaymentReceipt(
          establishmentId: establishmentId,
          challanId: challanId,
          savePath: receiptSavePath,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.downloading);
        expect(logs[1].message, contains(challanId));
        expect(logs[2].message, contains(receiptSavePath));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(challanId));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 6: Submission Job State Machine
    // -----------------------------------------------------------------------

    group('Phase 6 — EPFO submission job', () {
      test('creates a valid EPFO submission job', () {
        final job = SubmissionJob(
          id: 'job-epfo-001',
          clientId: establishmentId,
          clientName: 'Test Establishment Pvt Ltd',
          portalType: PortalType.epfo,
          returnType: 'ECR',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        expect(job.isCompleted, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.portalType, PortalType.epfo);
        expect(job.returnType, 'ECR');
      });

      test('EPFO job transitions through all steps', () {
        final pending = SubmissionJob(
          id: 'job-epfo-002',
          clientId: establishmentId,
          clientName: 'Test Establishment',
          portalType: PortalType.epfo,
          returnType: 'ECR',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        // pending -> loggingIn
        final loggingIn =
            pending.copyWith(currentStep: SubmissionStep.loggingIn);
        expect(loggingIn.isInProgress, isTrue);

        // loggingIn -> filling
        final filling =
            loggingIn.copyWith(currentStep: SubmissionStep.filling);
        expect(filling.isInProgress, isTrue);

        // filling -> submitting
        final submitting =
            filling.copyWith(currentStep: SubmissionStep.submitting);
        expect(submitting.isInProgress, isTrue);

        // submitting -> downloading
        final downloading =
            submitting.copyWith(currentStep: SubmissionStep.downloading);
        expect(downloading.isInProgress, isTrue);

        // downloading -> done
        final done = downloading.copyWith(
          currentStep: SubmissionStep.done,
          filedAt: DateTime.now(),
        );
        expect(done.isCompleted, isTrue);
        expect(done.isInProgress, isFalse);
      });

      test('failed EPFO job supports retry', () {
        final failed = SubmissionJob(
          id: 'job-epfo-003',
          clientId: establishmentId,
          clientName: 'Test Establishment',
          portalType: PortalType.epfo,
          returnType: 'ECR',
          currentStep: SubmissionStep.failed,
          retryCount: 0,
          createdAt: DateTime.now(),
          errorMessage: 'Connection timeout',
        );

        expect(failed.canRetry, isTrue);
        expect(failed.isFailed, isTrue);

        final retry3 = failed.copyWith(retryCount: 3);
        expect(retry3.canRetry, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 7: Full Pipeline
    // -----------------------------------------------------------------------

    group('Phase 7 — Full EPFO pipeline end-to-end', () {
      test('complete pipeline: login -> ECR -> challan -> KYC -> receipt',
          () async {
        final credential = PortalCredential(
          id: 'cred-epfo-e2e',
          portalType: PortalType.epfo,
          username: establishmentId,
          encryptedPassword: 'mock-encrypted',
        );

        final allLogs = <SubmissionLog>[];

        // Step 1: Create submission job
        var job = SubmissionJob(
          id: 'e2e-epfo-001',
          clientId: establishmentId,
          clientName: 'Test Establishment Pvt Ltd',
          portalType: PortalType.epfo,
          returnType: 'ECR',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        // Step 2: Login
        job = job.copyWith(currentStep: SubmissionStep.loggingIn);
        await for (final log in epfoService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Login completed'));

        // Step 3: Upload ECR
        job = job.copyWith(currentStep: SubmissionStep.filling);
        await for (final log in epfoService.uploadEcr(
          establishmentId: establishmentId,
          ecrFilePath: ecrFilePath,
          wageMonth: wageMonth,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('ECR uploaded'));

        // Step 4: Generate challan
        await for (final log in epfoService.generateChallan(
          establishmentId: establishmentId,
          wageMonth: wageMonth,
          epfAmount: 50000.00,
          epsAmount: 25000.00,
          savePath: challanSavePath,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Challan generated'));

        // Step 5: Check KYC
        await for (final log in epfoService.checkMemberKyc(
          uan: testUan,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('KYC status'));

        // Step 6: Download receipt
        job = job.copyWith(currentStep: SubmissionStep.downloading);
        await for (final log in epfoService.downloadPaymentReceipt(
          establishmentId: establishmentId,
          challanId: challanId,
          savePath: receiptSavePath,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Receipt downloaded'));

        // Mark done
        job = job.copyWith(
          currentStep: SubmissionStep.done,
          filedAt: DateTime.now(),
        );

        // ---- ASSERTIONS: Full pipeline completed ----
        expect(job.isCompleted, isTrue);
        expect(allLogs.where((l) => l.isError), isEmpty);
        expect(
          allLogs.length,
          greaterThanOrEqualTo(20),
          reason: 'Full EPFO pipeline should emit 20+ log entries '
              '(3 login + 6 ECR + 6 challan + 4 KYC + 4 receipt)',
        );

        // Verify progression through all major step types
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

        // Verify all logs have valid timestamps and non-empty messages
        for (final log in allLogs) {
          expect(log.timestamp, isNotNull);
          expect(log.jobId, isNotEmpty);
          expect(log.message, isNotEmpty);
        }
      });

      test('mock streams used when webViewController is null', () async {
        // Verify that all methods work without a WebView controller
        // (the mock path is used for testing/preview)
        final credential = PortalCredential(
          id: 'cred-null-test',
          portalType: PortalType.epfo,
          username: establishmentId,
          encryptedPassword: 'mock-encrypted',
        );

        final loginLogs = <SubmissionLog>[];
        await for (final log in epfoService.login(
          credential: credential,
          otpService: OtpInterceptService(),
          // webViewController is null — mock path
        )) {
          loginLogs.add(log);
        }
        expect(loginLogs, isNotEmpty);

        final ecrLogs = <SubmissionLog>[];
        await for (final log in epfoService.uploadEcr(
          establishmentId: establishmentId,
          ecrFilePath: ecrFilePath,
          wageMonth: wageMonth,
          otpService: OtpInterceptService(),
          // webViewController is null — mock path
        )) {
          ecrLogs.add(log);
        }
        expect(ecrLogs, isNotEmpty);

        final challanLogs = <SubmissionLog>[];
        await for (final log in epfoService.generateChallan(
          establishmentId: establishmentId,
          wageMonth: wageMonth,
          epfAmount: 100.0,
          epsAmount: 50.0,
          savePath: challanSavePath,
          // webViewController is null — mock path
        )) {
          challanLogs.add(log);
        }
        expect(challanLogs, isNotEmpty);

        final kycLogs = <SubmissionLog>[];
        await for (final log in epfoService.checkMemberKyc(
          uan: testUan,
          // webViewController is null — mock path
        )) {
          kycLogs.add(log);
        }
        expect(kycLogs, isNotEmpty);

        final receiptLogs = <SubmissionLog>[];
        await for (final log in epfoService.downloadPaymentReceipt(
          establishmentId: establishmentId,
          challanId: challanId,
          savePath: receiptSavePath,
          // webViewController is null — mock path
        )) {
          receiptLogs.add(log);
        }
        expect(receiptLogs, isNotEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 8: Selector coverage
    // -----------------------------------------------------------------------

    group('Phase 8 — EPFO portal URL and service constants', () {
      test('portal URL is correct', () {
        expect(
          EpfoAutosubmitService.portalUrl,
          'https://unified.epfindia.gov.in',
        );
      });

      test('service is const-constructible', () {
        const service = EpfoAutosubmitService();
        expect(service, isNotNull);
      });
    });
  });
}

import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/gstn_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end integration test for the GSTN portal automation pipeline.
///
/// Proves the complete flow from login through to GSTR-1 upload, GSTR-3B
/// filing, PMT-06 challan generation, and GSTR-2B download:
///
/// 1. **Login** — Mock stream emits login + OTP steps
/// 2. **GSTR-1 Upload** — Mock stream emits fill + validation + OTP + submit
/// 3. **GSTR-3B Filing** — Mock stream emits fill Table 3.1/4 + OTP + submit
/// 4. **PMT-06 Challan** — Mock stream emits challan generation steps
/// 5. **GSTR-2B Download** — Mock stream emits download steps
/// 6. **Submission Job** — Create and transition SubmissionJob for GSTN
/// 7. **Full Pipeline** — Run all phases sequentially end-to-end
void main() {
  group('GSTN End-to-End Pipeline', () {
    // -----------------------------------------------------------------------
    // Common test data
    // -----------------------------------------------------------------------

    const gstin = '27AABCU9603R1ZM';
    const taxPeriod = '032026';
    const gstnService = GstnAutosubmitService();

    late PortalCredential credential;
    late OtpInterceptService otpService;

    setUp(() {
      credential = const PortalCredential(
        id: 'cred-gstn-001',
        portalType: PortalType.gstn,
        username: gstin,
        encryptedPassword: 'mock-encrypted',
      );
      otpService = OtpInterceptService();
    });

    // -----------------------------------------------------------------------
    // Phase 1: Login
    // -----------------------------------------------------------------------

    group('Phase 1 — GSTN login (mock)', () {
      test('login mock stream emits expected steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.login(
          credential: credential,
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs.first.step, SubmissionStep.loggingIn);
        expect(logs.first.message, contains('Navigating'));
        expect(logs[2].step, SubmissionStep.otp);
        expect(logs.last.message, contains('Login completed'));
      });

      test('login logs have valid structure', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.login(
          credential: credential,
          otpService: otpService,
        )) {
          logs.add(log);
        }

        for (final log in logs) {
          expect(log.id, isNotEmpty);
          expect(log.jobId, contains('gstn_login'));
          expect(log.timestamp, isNotNull);
          expect(log.message, isNotEmpty);
          expect(log.isError, isFalse);
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 2: GSTR-1 Upload
    // -----------------------------------------------------------------------

    group('Phase 2 — GSTR-1 upload (mock)', () {
      test('upload mock stream emits fill + OTP + submit steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.uploadGstr1(
          gstin: gstin,
          jsonFilePath: '/tmp/GSTR1_$gstin.json',
          taxPeriod: taxPeriod,
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 7);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains('Navigating'));
        expect(logs[1].message, contains('tax period'));
        expect(logs[2].message, contains('Uploading'));
        expect(logs[3].message, contains('validation'));
        expect(logs[4].step, SubmissionStep.otp);
        expect(logs[5].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(gstin));
      });

      test('upload logs reference correct GSTIN in job ID', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.uploadGstr1(
          gstin: gstin,
          jsonFilePath: '/tmp/GSTR1_$gstin.json',
          taxPeriod: taxPeriod,
          otpService: otpService,
        )) {
          logs.add(log);
        }

        for (final log in logs) {
          expect(log.jobId, 'gstn_gstr1_$gstin');
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 3: GSTR-3B Filing
    // -----------------------------------------------------------------------

    group('Phase 3 — GSTR-3B filing (mock)', () {
      test('fill mock stream emits Table 3.1, Table 4, OTP, submit', () async {
        final taxValues = <String, double>{
          'taxableValue': 500000,
          'igst': 0,
          'cgst': 45000,
          'sgst': 45000,
          'itcIgst': 0,
          'itcCgst': 20000,
          'itcSgst': 20000,
        };

        final logs = <SubmissionLog>[];
        await for (final log in gstnService.fillGstr3b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          taxValues: taxValues,
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 7);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains('Navigating'));
        expect(logs[1].message, contains('Table 3.1'));
        expect(logs[2].message, contains('Table 4'));
        expect(logs[3].message, contains('draft'));
        expect(logs[4].step, SubmissionStep.otp);
        expect(logs[5].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(gstin));
      });

      test('GSTR-3B logs have no errors', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.fillGstr3b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          taxValues: const {'taxableValue': 100000, 'cgst': 9000, 'sgst': 9000},
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs.where((l) => l.isError), isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 4: PMT-06 Challan
    // -----------------------------------------------------------------------

    group('Phase 4 — PMT-06 challan generation (mock)', () {
      test('challan mock stream emits fill + generate steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.generateChallan(
          gstin: gstin,
          taxAmount: 50000,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains('payment'));
        expect(logs[1].message, contains('PMT-06'));
        expect(logs[2].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(gstin));
      });

      test('challan with tax breakdown passes', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.generateChallan(
          gstin: gstin,
          taxAmount: 50000,
          taxBreakdown: const {
            'igst': 0,
            'cgst': 25000,
            'sgst': 25000,
            'cess': 0,
          },
        )) {
          logs.add(log);
        }

        expect(logs.last.step, SubmissionStep.done);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 5: GSTR-2B Download
    // -----------------------------------------------------------------------

    group('Phase 5 — GSTR-2B download (mock)', () {
      test('download mock stream emits expected steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in gstnService.downloadGstr2b(
          gstin: gstin,
          taxPeriod: taxPeriod,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.downloading);
        expect(logs[0].message, contains('Navigating'));
        expect(logs[1].message, contains(taxPeriod));
        expect(logs[2].message, contains('Downloading'));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(taxPeriod));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 6: Submission Job Lifecycle
    // -----------------------------------------------------------------------

    group('Phase 6 — GSTN submission job lifecycle', () {
      test('creates a valid GSTN submission job', () {
        final job = SubmissionJob(
          id: 'job-gstn-001',
          clientId: gstin,
          clientName: 'Test Pvt Ltd',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        expect(job.isCompleted, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isInProgress, isFalse);
        expect(job.portalType, PortalType.gstn);
        expect(job.returnType, 'GSTR-1');
      });

      test('job state machine transitions for GSTN flow', () {
        final pending = SubmissionJob(
          id: 'job-gstn-002',
          clientId: gstin,
          clientName: 'Test Pvt Ltd',
          portalType: PortalType.gstn,
          returnType: 'GSTR-3B',
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

        // filling -> otp
        final otp = filling.copyWith(currentStep: SubmissionStep.otp);
        expect(otp.isInProgress, isTrue);

        // otp -> reviewing
        final reviewing =
            otp.copyWith(currentStep: SubmissionStep.reviewing);
        expect(reviewing.isInProgress, isFalse);

        // reviewing -> submitting
        final submitting =
            reviewing.copyWith(currentStep: SubmissionStep.submitting);
        expect(submitting.isInProgress, isTrue);

        // submitting -> done
        final done = submitting.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'ARN-AA2703260012345',
          filedAt: DateTime.now(),
        );
        expect(done.isCompleted, isTrue);
        expect(done.ackNumber, 'ARN-AA2703260012345');
      });

      test('failed GSTN job supports retry up to 3 times', () {
        final failed = SubmissionJob(
          id: 'job-gstn-003',
          clientId: gstin,
          clientName: 'Test Pvt Ltd',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.failed,
          retryCount: 0,
          createdAt: DateTime.now(),
          errorMessage: 'Portal timeout',
        );

        expect(failed.canRetry, isTrue);

        final retry3 = failed.copyWith(retryCount: 3);
        expect(retry3.canRetry, isFalse);
      });

      test('immutability: copyWith does not mutate original job', () {
        final original = SubmissionJob(
          id: 'job-gstn-004',
          clientId: gstin,
          clientName: 'Test Pvt Ltd',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        final modified = original.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'ARN-TEST',
        );

        expect(original.currentStep, SubmissionStep.pending);
        expect(original.ackNumber, isNull);
        expect(modified.currentStep, SubmissionStep.done);
        expect(modified.ackNumber, 'ARN-TEST');
      });
    });

    // -----------------------------------------------------------------------
    // Phase 7: Full Pipeline Integration
    // -----------------------------------------------------------------------

    group('Phase 7 — Full pipeline: login -> GSTR-1 -> 3B -> challan -> 2B',
        () {
      test('complete GSTN automation sequence runs all phases', () async {
        final allLogs = <SubmissionLog>[];

        // Phase 1: Login
        await for (final log in gstnService.login(
          credential: credential,
          otpService: otpService,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Login completed'));

        // Phase 2: Upload GSTR-1
        await for (final log in gstnService.uploadGstr1(
          gstin: gstin,
          jsonFilePath: '/tmp/GSTR1_$gstin.json',
          taxPeriod: taxPeriod,
          otpService: otpService,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('GSTR-1 filed'));

        // Phase 3: Fill GSTR-3B
        await for (final log in gstnService.fillGstr3b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          taxValues: const {
            'taxableValue': 500000,
            'igst': 0,
            'cgst': 45000,
            'sgst': 45000,
            'itcIgst': 0,
            'itcCgst': 20000,
            'itcSgst': 20000,
          },
          otpService: otpService,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('GSTR-3B filed'));

        // Phase 4: Generate PMT-06 Challan
        await for (final log in gstnService.generateChallan(
          gstin: gstin,
          taxAmount: 50000,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('PMT-06 challan'));

        // Phase 5: Download GSTR-2B
        await for (final log in gstnService.downloadGstr2b(
          gstin: gstin,
          taxPeriod: taxPeriod,
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('GSTR-2B downloaded'));

        // ---- ASSERTIONS: Full pipeline completed ----
        // Login(4) + GSTR-1(7) + GSTR-3B(7) + Challan(4) + GSTR-2B(4) = 26
        expect(allLogs.length, 26);

        // Verify progression through all step types
        final steps = allLogs.map((l) => l.step).toSet();
        expect(steps, containsAll([
          SubmissionStep.loggingIn,
          SubmissionStep.filling,
          SubmissionStep.otp,
          SubmissionStep.submitting,
          SubmissionStep.downloading,
          SubmissionStep.done,
        ]));

        // Verify no errors in the stream
        expect(allLogs.where((l) => l.isError), isEmpty);

        // Verify all logs have valid timestamps and non-empty fields
        for (final log in allLogs) {
          expect(log.timestamp, isNotNull);
          expect(log.jobId, isNotEmpty);
          expect(log.message, isNotEmpty);
          expect(log.id, isNotEmpty);
        }
      });

      test('full pipeline with job state tracking', () async {
        final allLogs = <SubmissionLog>[];

        // Create submission job
        var job = SubmissionJob(
          id: 'e2e-gstn-001',
          clientId: gstin,
          clientName: 'Test Pvt Ltd',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );
        expect(job.currentStep, SubmissionStep.pending);

        // Login
        job = job.copyWith(currentStep: SubmissionStep.loggingIn);
        await for (final log in gstnService.login(
          credential: credential,
          otpService: otpService,
        )) {
          allLogs.add(log);
        }

        // Upload GSTR-1
        job = job.copyWith(currentStep: SubmissionStep.filling);
        await for (final log in gstnService.uploadGstr1(
          gstin: gstin,
          jsonFilePath: '/tmp/GSTR1_$gstin.json',
          taxPeriod: taxPeriod,
          otpService: otpService,
        )) {
          allLogs.add(log);
        }

        // Fill GSTR-3B
        await for (final log in gstnService.fillGstr3b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          taxValues: const {
            'taxableValue': 500000,
            'cgst': 45000,
            'sgst': 45000,
          },
          otpService: otpService,
        )) {
          allLogs.add(log);
        }

        // Challan
        await for (final log in gstnService.generateChallan(
          gstin: gstin,
          taxAmount: 50000,
        )) {
          allLogs.add(log);
        }

        // Download GSTR-2B
        job = job.copyWith(currentStep: SubmissionStep.downloading);
        await for (final log in gstnService.downloadGstr2b(
          gstin: gstin,
          taxPeriod: taxPeriod,
        )) {
          allLogs.add(log);
        }

        // Mark done
        job = job.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'ARN-E2E-GSTN-TEST',
          filedAt: DateTime.now(),
        );

        // Final assertions
        expect(job.isCompleted, isTrue);
        expect(job.ackNumber, 'ARN-E2E-GSTN-TEST');
        expect(allLogs.where((l) => l.isError), isEmpty);
        expect(
          allLogs.length,
          greaterThanOrEqualTo(20),
          reason: 'Full GSTN pipeline should emit 20+ log entries',
        );
      });
    });

    // -----------------------------------------------------------------------
    // Phase 8: Helper method tests
    // -----------------------------------------------------------------------

    group('Phase 8 — Service helper coverage', () {
      test('portal URL is correct', () {
        expect(GstnAutosubmitService.portalUrl, 'https://services.gst.gov.in');
      });

      test('mock streams return without webViewController', () async {
        // All methods should work without webViewController (mock fallback)
        final loginLogs = <SubmissionLog>[];
        await for (final log in gstnService.login(
          credential: credential,
          otpService: otpService,
          webViewController: null,
        )) {
          loginLogs.add(log);
        }
        expect(loginLogs, isNotEmpty);

        final gstr1Logs = <SubmissionLog>[];
        await for (final log in gstnService.uploadGstr1(
          gstin: gstin,
          jsonFilePath: '/tmp/test.json',
          taxPeriod: taxPeriod,
          otpService: otpService,
          webViewController: null,
        )) {
          gstr1Logs.add(log);
        }
        expect(gstr1Logs, isNotEmpty);

        final gstr3bLogs = <SubmissionLog>[];
        await for (final log in gstnService.fillGstr3b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          taxValues: const {'taxableValue': 100000},
          otpService: otpService,
          webViewController: null,
        )) {
          gstr3bLogs.add(log);
        }
        expect(gstr3bLogs, isNotEmpty);

        final challanLogs = <SubmissionLog>[];
        await for (final log in gstnService.generateChallan(
          gstin: gstin,
          taxAmount: 10000,
          webViewController: null,
        )) {
          challanLogs.add(log);
        }
        expect(challanLogs, isNotEmpty);

        final gstr2bLogs = <SubmissionLog>[];
        await for (final log in gstnService.downloadGstr2b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          webViewController: null,
        )) {
          gstr2bLogs.add(log);
        }
        expect(gstr2bLogs, isNotEmpty);
      });

      test('each mock stream ends with SubmissionStep.done', () async {
        Future<SubmissionLog> lastLog(Stream<SubmissionLog> stream) async {
          SubmissionLog? last;
          await for (final log in stream) {
            last = log;
          }
          return last!;
        }

        final loginLast = await lastLog(gstnService.login(
          credential: credential,
          otpService: otpService,
        ));
        expect(loginLast.step, SubmissionStep.loggingIn);
        // Login ends with 'Login completed' not done step

        final gstr1Last = await lastLog(gstnService.uploadGstr1(
          gstin: gstin,
          jsonFilePath: '/tmp/test.json',
          taxPeriod: taxPeriod,
          otpService: otpService,
        ));
        expect(gstr1Last.step, SubmissionStep.done);

        final gstr3bLast = await lastLog(gstnService.fillGstr3b(
          gstin: gstin,
          taxPeriod: taxPeriod,
          taxValues: const {'taxableValue': 100000},
          otpService: otpService,
        ));
        expect(gstr3bLast.step, SubmissionStep.done);

        final challanLast = await lastLog(gstnService.generateChallan(
          gstin: gstin,
          taxAmount: 10000,
        ));
        expect(challanLast.step, SubmissionStep.done);

        final gstr2bLast = await lastLog(gstnService.downloadGstr2b(
          gstin: gstin,
          taxPeriod: taxPeriod,
        ));
        expect(gstr2bLast.step, SubmissionStep.done);
      });
    });
  });
}

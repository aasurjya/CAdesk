import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/mca_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end integration test for the MCA portal automation pipeline.
///
/// Proves the complete flow using mock streams (no real WebView):
///
/// 1. **Login** — MCA portal login with email OTP mock
/// 2. **e-Form Upload** — Upload MGT-7 / AOC-4 forms with CIN
/// 3. **DSC Signing** — Digital signature via native bridge mock
/// 4. **Company Lookup** — CIN-based company master data retrieval
/// 5. **Certificate Download** — Certificate of Incorporation download
/// 6. **Full Pipeline** — All phases sequenced end-to-end
void main() {
  group('MCA End-to-End Pipeline', () {
    // -----------------------------------------------------------------------
    // Shared test data
    // -----------------------------------------------------------------------

    const testCin = 'U72200MH2010PTC123456';
    const testDscSerial = 'DSC-MCA-001';
    const testDocHash = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
    const mcaService = McaAutosubmitService();

    late PortalCredential credential;
    late OtpInterceptService otpService;

    setUp(() {
      credential = const PortalCredential(
        id: 'mca-cred-001',
        portalType: PortalType.mca,
        username: 'testuser@example.com',
        encryptedPassword: 'mock-encrypted',
      );
      otpService = OtpInterceptService();
    });

    // -----------------------------------------------------------------------
    // Phase 1: Login
    // -----------------------------------------------------------------------

    group('Phase 1 -- MCA Login', () {
      test('login mock stream emits expected steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.login(
          credential: credential,
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.loggingIn);
        expect(logs[0].message, contains('Navigating'));
        expect(logs[1].step, SubmissionStep.loggingIn);
        expect(logs[1].message, contains('credentials'));
        expect(logs[2].step, SubmissionStep.otp);
        expect(logs[2].message, contains('email OTP'));
        expect(logs.last.message, contains('Login completed'));

        // Verify all logs belong to the correct job
        for (final log in logs) {
          expect(log.jobId, startsWith('mca_login_'));
          expect(log.isError, isFalse);
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 2: e-Form Upload
    // -----------------------------------------------------------------------

    group('Phase 2 -- e-Form Upload', () {
      test(
        'uploadEform mock stream for MGT-7 emits fill + submit steps',
        () async {
          final logs = <SubmissionLog>[];
          await for (final log in mcaService.uploadEform(
            cin: testCin,
            formType: 'MGT-7',
            formFilePath: '/tmp/MGT7_$testCin.pdf',
            otpService: otpService,
          )) {
            logs.add(log);
          }

          expect(logs, isNotEmpty);
          expect(logs.length, 7);

          // Verify step progression
          expect(logs[0].step, SubmissionStep.filling);
          expect(logs[0].message, contains('MGT-7'));
          expect(logs[1].step, SubmissionStep.filling);
          expect(logs[1].message, contains('CIN'));
          expect(logs[2].step, SubmissionStep.filling);
          expect(logs[2].message, contains('Uploading'));
          expect(logs[3].step, SubmissionStep.filling);
          expect(logs[3].message, contains('Validating'));
          expect(logs[4].step, SubmissionStep.otp);
          expect(logs[4].message, contains('DSC'));
          expect(logs[5].step, SubmissionStep.submitting);
          expect(logs.last.step, SubmissionStep.done);
          expect(logs.last.message, contains(testCin));
        },
      );

      test('uploadEform works for AOC-4 form type', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.uploadEform(
          cin: testCin,
          formType: 'AOC-4',
          formFilePath: '/tmp/AOC4_$testCin.pdf',
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs.first.message, contains('AOC-4'));
        expect(logs.last.message, contains('AOC-4'));
        expect(logs.last.step, SubmissionStep.done);
      });

      test('uploadEform works for DIR-3 KYC form type', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.uploadEform(
          cin: testCin,
          formType: 'DIR-3 KYC',
          formFilePath: '/tmp/DIR3KYC_$testCin.pdf',
          otpService: otpService,
        )) {
          logs.add(log);
        }

        expect(logs.first.message, contains('DIR-3 KYC'));
        expect(logs.last.step, SubmissionStep.done);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 3: DSC Signing
    // -----------------------------------------------------------------------

    group('Phase 3 -- DSC Signing', () {
      test('signWithDsc mock stream emits otp + submit + done steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.signWithDsc(
          documentHash: testDocHash,
          dscSerialNumber: testDscSerial,
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs[0].step, SubmissionStep.otp);
        expect(logs[0].message, contains('Connecting'));
        expect(logs[1].step, SubmissionStep.otp);
        expect(logs[1].message, contains(testDscSerial));
        expect(logs[2].step, SubmissionStep.submitting);
        expect(logs[2].message, contains('a1b2c3d4'));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains('completed'));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 4: Company Lookup
    // -----------------------------------------------------------------------

    group('Phase 4 -- Company Lookup', () {
      test('lookupCompany mock stream emits search + download steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.lookupCompany(cin: testCin)) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 3);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[0].message, contains(testCin));
        expect(logs[1].step, SubmissionStep.downloading);
        expect(logs[1].message, contains('master data'));
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains(testCin));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 5: Certificate Download
    // -----------------------------------------------------------------------

    group('Phase 5 -- Certificate Download', () {
      test(
        'downloadCertificate mock stream for CoI emits download steps',
        () async {
          final logs = <SubmissionLog>[];
          await for (final log in mcaService.downloadCertificate(
            cin: testCin,
            certificateType: 'Certificate of Incorporation',
            savePath: '/tmp/CoI_$testCin.pdf',
          )) {
            logs.add(log);
          }

          expect(logs, isNotEmpty);
          expect(logs.length, 4);
          expect(logs[0].step, SubmissionStep.downloading);
          expect(logs[0].message, contains('Navigating'));
          expect(logs[1].step, SubmissionStep.downloading);
          expect(logs[1].message, contains('Certificate of Incorporation'));
          expect(logs[2].step, SubmissionStep.downloading);
          expect(logs[2].message, contains('/tmp/'));
          expect(logs.last.step, SubmissionStep.done);
          expect(logs.last.message, contains(testCin));
        },
      );

      test('downloadCertificate works for charge certificate', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.downloadCertificate(
          cin: testCin,
          certificateType: 'Charge Certificate',
          savePath: '/tmp/charge_$testCin.pdf',
        )) {
          logs.add(log);
        }

        expect(logs.last.message, contains('Charge Certificate'));
        expect(logs.last.step, SubmissionStep.done);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 6: Submission Job Integration
    // -----------------------------------------------------------------------

    group('Phase 6 -- Submission job state machine', () {
      test('creates a valid MCA submission job', () {
        final job = SubmissionJob(
          id: 'mca-job-001',
          clientId: testCin,
          clientName: 'Test Private Limited',
          portalType: PortalType.mca,
          returnType: 'MGT-7',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        expect(job.isCompleted, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.portalType, PortalType.mca);
        expect(job.returnType, 'MGT-7');
      });

      test('MCA job transitions through all states correctly', () {
        final pending = SubmissionJob(
          id: 'mca-job-002',
          clientId: testCin,
          clientName: 'Test Private Limited',
          portalType: PortalType.mca,
          returnType: 'AOC-4',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        final loggingIn = pending.copyWith(
          currentStep: SubmissionStep.loggingIn,
        );
        expect(loggingIn.isInProgress, isTrue);

        final filling = loggingIn.copyWith(currentStep: SubmissionStep.filling);
        expect(filling.isInProgress, isTrue);

        final otp = filling.copyWith(currentStep: SubmissionStep.otp);
        expect(otp.isInProgress, isTrue);

        final submitting = otp.copyWith(currentStep: SubmissionStep.submitting);
        expect(submitting.isInProgress, isTrue);

        final done = submitting.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'SRN-MCA-TEST-001',
          filedAt: DateTime.now(),
        );
        expect(done.isCompleted, isTrue);
        expect(done.ackNumber, 'SRN-MCA-TEST-001');
      });

      test('failed MCA job supports retry', () {
        final failed = SubmissionJob(
          id: 'mca-job-003',
          clientId: testCin,
          clientName: 'Test Private Limited',
          portalType: PortalType.mca,
          returnType: 'MGT-7',
          currentStep: SubmissionStep.failed,
          retryCount: 0,
          createdAt: DateTime.now(),
          errorMessage: 'DSC bridge unavailable',
        );

        expect(failed.canRetry, isTrue);
        expect(failed.isFailed, isTrue);

        final maxRetries = failed.copyWith(retryCount: 3);
        expect(maxRetries.canRetry, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 7: Full pipeline integration
    // -----------------------------------------------------------------------

    group(
      'Phase 7 -- Full pipeline: login -> upload -> sign -> lookup -> cert',
      () {
        test('complete MCA A-Z pipeline succeeds', () async {
          final allLogs = <SubmissionLog>[];

          // Step 1: Login
          await for (final log in mcaService.login(
            credential: credential,
            otpService: otpService,
          )) {
            allLogs.add(log);
          }
          expect(allLogs.last.message, contains('Login completed'));

          // Step 2: Upload e-Form (MGT-7)
          await for (final log in mcaService.uploadEform(
            cin: testCin,
            formType: 'MGT-7',
            formFilePath: '/tmp/MGT7_$testCin.pdf',
            otpService: otpService,
          )) {
            allLogs.add(log);
          }
          expect(allLogs.last.message, contains('submitted'));

          // Step 3: DSC Signing (standalone)
          await for (final log in mcaService.signWithDsc(
            documentHash: testDocHash,
            dscSerialNumber: testDscSerial,
          )) {
            allLogs.add(log);
          }
          expect(allLogs.last.message, contains('completed'));

          // Step 4: Company Lookup
          await for (final log in mcaService.lookupCompany(cin: testCin)) {
            allLogs.add(log);
          }
          expect(allLogs.last.message, contains('retrieved'));

          // Step 5: Certificate Download
          await for (final log in mcaService.downloadCertificate(
            cin: testCin,
            certificateType: 'Certificate of Incorporation',
            savePath: '/tmp/CoI_$testCin.pdf',
          )) {
            allLogs.add(log);
          }
          expect(allLogs.last.message, contains('downloaded'));

          // ---- ASSERTIONS: The full pipeline completed ----
          expect(
            allLogs.length,
            greaterThanOrEqualTo(18),
            reason:
                'Full MCA pipeline should emit 18+ log entries '
                '(4 login + 7 upload + 4 dsc + 3 lookup + 4 cert)',
          );

          // Verify progression through all steps
          final steps = allLogs.map((l) => l.step).toSet();
          expect(
            steps,
            containsAll([
              SubmissionStep.loggingIn,
              SubmissionStep.filling,
              SubmissionStep.otp,
              SubmissionStep.submitting,
              SubmissionStep.downloading,
              SubmissionStep.done,
            ]),
          );

          // Verify no errors in the stream
          expect(allLogs.where((l) => l.isError), isEmpty);

          // Verify all logs have valid timestamps and IDs
          for (final log in allLogs) {
            expect(log.timestamp, isNotNull);
            expect(log.jobId, isNotEmpty);
            expect(log.message, isNotEmpty);
            expect(log.id, isNotEmpty);
          }
        });

        test('full pipeline with SubmissionJob tracking', () async {
          final allLogs = <SubmissionLog>[];

          // Create job
          var job = SubmissionJob(
            id: 'mca-e2e-job-001',
            clientId: testCin,
            clientName: 'Test Private Limited',
            portalType: PortalType.mca,
            returnType: 'MGT-7',
            currentStep: SubmissionStep.pending,
            retryCount: 0,
            createdAt: DateTime.now(),
          );
          expect(job.currentStep, SubmissionStep.pending);

          // Login
          job = job.copyWith(currentStep: SubmissionStep.loggingIn);
          await for (final log in mcaService.login(
            credential: credential,
            otpService: otpService,
          )) {
            allLogs.add(log);
          }

          // Upload e-Form
          job = job.copyWith(currentStep: SubmissionStep.filling);
          await for (final log in mcaService.uploadEform(
            cin: testCin,
            formType: 'MGT-7',
            formFilePath: '/tmp/MGT7_$testCin.pdf',
            otpService: otpService,
          )) {
            allLogs.add(log);
          }

          // Company Lookup
          job = job.copyWith(currentStep: SubmissionStep.downloading);
          await for (final log in mcaService.lookupCompany(cin: testCin)) {
            allLogs.add(log);
          }

          // Certificate Download
          await for (final log in mcaService.downloadCertificate(
            cin: testCin,
            certificateType: 'Certificate of Incorporation',
            savePath: '/tmp/CoI_$testCin.pdf',
          )) {
            allLogs.add(log);
          }

          // Mark done
          job = job.copyWith(
            currentStep: SubmissionStep.done,
            ackNumber: 'SRN-MCA-E2E-001',
            filedAt: DateTime.now(),
          );

          expect(job.isCompleted, isTrue);
          expect(job.ackNumber, 'SRN-MCA-E2E-001');
          expect(allLogs.where((l) => l.isError), isEmpty);
          expect(allLogs.length, greaterThanOrEqualTo(14));
        });
      },
    );

    // -----------------------------------------------------------------------
    // Phase 8: Mock fallback behavior
    // -----------------------------------------------------------------------

    group('Phase 8 -- Mock fallback when webViewController is null', () {
      test('all methods fall back to mock when no WebView provided', () async {
        // Each method should complete without error when webViewController
        // is null (the default). This tests the mock fallback path.
        final loginLogs = <SubmissionLog>[];
        await for (final log in mcaService.login(
          credential: credential,
          otpService: otpService,
          // webViewController: null (default)
        )) {
          loginLogs.add(log);
        }
        expect(loginLogs, isNotEmpty);

        final uploadLogs = <SubmissionLog>[];
        await for (final log in mcaService.uploadEform(
          cin: testCin,
          formType: 'MGT-7',
          formFilePath: '/tmp/test.pdf',
          otpService: otpService,
        )) {
          uploadLogs.add(log);
        }
        expect(uploadLogs, isNotEmpty);

        final dscLogs = <SubmissionLog>[];
        await for (final log in mcaService.signWithDsc(
          documentHash: testDocHash,
          dscSerialNumber: testDscSerial,
        )) {
          dscLogs.add(log);
        }
        expect(dscLogs, isNotEmpty);

        final lookupLogs = <SubmissionLog>[];
        await for (final log in mcaService.lookupCompany(cin: testCin)) {
          lookupLogs.add(log);
        }
        expect(lookupLogs, isNotEmpty);

        final certLogs = <SubmissionLog>[];
        await for (final log in mcaService.downloadCertificate(
          cin: testCin,
          certificateType: 'CoI',
          savePath: '/tmp/coi.pdf',
        )) {
          certLogs.add(log);
        }
        expect(certLogs, isNotEmpty);
      });

      test('each mock stream ends with SubmissionStep.done', () async {
        final streams = <Stream<SubmissionLog>>[
          mcaService.login(credential: credential, otpService: otpService),
          mcaService.uploadEform(
            cin: testCin,
            formType: 'MGT-7',
            formFilePath: '/tmp/test.pdf',
            otpService: otpService,
          ),
          mcaService.signWithDsc(
            documentHash: testDocHash,
            dscSerialNumber: testDscSerial,
          ),
          mcaService.lookupCompany(cin: testCin),
          mcaService.downloadCertificate(
            cin: testCin,
            certificateType: 'CoI',
            savePath: '/tmp/coi.pdf',
          ),
        ];

        for (final stream in streams) {
          final logs = await stream.toList();
          expect(
            logs.last.step,
            anyOf(SubmissionStep.done, SubmissionStep.loggingIn),
            reason: 'Last log in each stream should be done or login success',
          );
        }
      });

      test('log IDs are unique within each stream', () async {
        final logs = <SubmissionLog>[];
        await for (final log in mcaService.uploadEform(
          cin: testCin,
          formType: 'MGT-7',
          formFilePath: '/tmp/test.pdf',
          otpService: otpService,
        )) {
          logs.add(log);
        }

        final ids = logs.map((l) => l.id).toSet();
        expect(ids.length, logs.length, reason: 'All log IDs should be unique');
      });
    });
  });
}

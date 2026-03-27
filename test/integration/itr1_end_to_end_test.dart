import 'dart:convert';

import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/tds_payment_summary.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/itd_autosubmit_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr1_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end integration test for the ITR-1 filing pipeline.
///
/// Proves the complete flow from data entry through to portal submission:
///
/// 1. **Data Entry** — Construct Itr1FormData with realistic Indian taxpayer data
/// 2. **Tax Computation** — Verify gross total income, deductions, and taxable income
/// 3. **JSON Export** — Export to ITD e-Filing 2.0 JSON schema
/// 4. **Schema Validation** — Verify JSON structure matches ITD portal requirements
/// 5. **Submission Job** — Create SubmissionJob for ITD portal
/// 6. **Portal Automation** — Run ItdAutosubmitService mock streams end-to-end
/// 7. **JSON Roundtrip** — Verify Itr1FormData serialization/deserialization
void main() {
  group('ITR-1 End-to-End Pipeline', () {
    // -----------------------------------------------------------------------
    // Phase 1: Realistic test data (salaried individual, AY 2025-26)
    // -----------------------------------------------------------------------

    late Itr1FormData formData;
    const assessmentYear = '2025-26';

    setUp(() {
      formData = Itr1FormData(
        personalInfo: PersonalInfo(
          firstName: 'Rajesh',
          middleName: 'Kumar',
          lastName: 'Sharma',
          pan: 'ABCPS1234K',
          aadhaarNumber: '123456789012',
          dateOfBirth: DateTime(1985, 3, 15),
          email: 'rajesh.sharma@example.com',
          mobile: '9876543210',
          flatDoorBlock: '302, Sai Apartment',
          street: 'MG Road',
          city: 'Pune',
          state: 'Maharashtra',
          pincode: '411001',
          employerName: 'TCS Limited',
          employerTan: 'PNET12345A',
          bankAccountNumber: '1234567890',
          bankIfsc: 'SBIN0001234',
          bankName: 'State Bank of India',
        ),
        salaryIncome: const SalaryIncome(
          grossSalary: 1200000, // ₹12L gross salary
          allowancesExemptUnderSection10: 50000, // ₹50k HRA exempt
          valueOfPerquisites: 0,
          profitsInLieuOfSalary: 0,
          standardDeduction: 75000, // New regime standard deduction
        ),
        housePropertyIncome: const HousePropertyIncome(
          annualLetableValue: 240000, // ₹20k/month rent received
          municipalTaxesPaid: 12000,
          interestOnLoan: 180000, // ₹1.8L home loan interest
        ),
        otherSourceIncome: const OtherSourceIncome(
          savingsAccountInterest: 15000,
          fixedDepositInterest: 45000,
          dividendIncome: 10000,
          familyPension: 0,
          otherIncome: 5000,
        ),
        deductions: const ChapterViaDeductions(
          section80C: 150000, // PPF + ELSS = ₹1.5L (maxed out)
          section80CCD1B: 50000, // NPS ₹50k
          section80DSelf: 25000, // Medical insurance self
          section80DParents: 50000, // Medical insurance parents (senior)
          section80E: 0,
          section80G: 10000, // Donations
          section80TTA: 10000, // Savings interest cap
          section80TTB: 0,
        ),
        selectedRegime: TaxRegime.oldRegime, // Old regime to use deductions
        tdsPaymentSummary: const TdsPaymentSummary(
          tdsOnSalary: 120000, // ₹1.2L TDS on salary
          tdsOnOtherIncome: 4500, // TDS on FD interest
          advanceTaxQ1: 0,
          advanceTaxQ2: 0,
          advanceTaxQ3: 0,
          advanceTaxQ4: 0,
          selfAssessmentTax: 0,
        ),
      );
    });

    // -----------------------------------------------------------------------
    // Phase 2: Data Entry Validation
    // -----------------------------------------------------------------------

    group('Phase 1 — Data entry validation', () {
      test('personal info is complete and valid', () {
        final pi = formData.personalInfo;
        expect(pi.fullName, 'Rajesh Kumar Sharma');
        expect(pi.pan, 'ABCPS1234K');
        expect(pi.pan.length, 10);
        expect(pi.aadhaarNumber.length, 12);
        expect(pi.mobile.length, 10);
        expect(pi.pincode.length, 6);
        expect(pi.bankIfsc.length, 11);
      });

      test('salary income computes net salary correctly', () {
        final s = formData.salaryIncome;
        // Net = 1200000 - 50000 + 0 + 0 - 75000 = 1075000
        expect(s.netSalary, 1075000);
      });

      test('house property income applies Section 24 deductions', () {
        final hp = formData.housePropertyIncome;
        // Net Annual Value = 240000 - 12000 = 228000
        expect(hp.netAnnualValue, 228000);
        // 30% standard deduction = 228000 * 0.30 = 68400
        expect(hp.standardDeduction30Percent, 68400);
        // Income from HP = 228000 - 68400 - 180000 = -20400 (loss)
        expect(hp.incomeFromHouseProperty, -20400);
      });

      test('other source income aggregates correctly', () {
        // 15000 + 45000 + 10000 + 0 + 5000 = 75000
        expect(formData.otherSourceIncome.total, 75000);
      });

      test('deductions apply statutory caps', () {
        final d = formData.deductions;
        // 80C: min(150000, 150000) = 150000
        // 80CCD1B: min(50000, 50000) = 50000
        // 80D Self: min(25000, 25000) = 25000
        // 80D Parents: min(50000, 50000) = 50000
        // 80E: 0, 80G: 10000, 80TTA: min(10000, 10000) = 10000, 80TTB: 0
        // Total = 150000 + 50000 + 25000 + 50000 + 0 + 10000 + 10000 + 0 = 295000
        expect(d.totalDeductions, 295000);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 3: Tax Computation
    // -----------------------------------------------------------------------

    group('Phase 2 — Tax computation', () {
      test('gross total income aggregates all heads', () {
        // Salary net: 1075000 + HP: -20400 + Other: 75000 = 1129600
        expect(formData.grossTotalIncome, 1129600);
      });

      test('allowable deductions match old regime', () {
        expect(formData.allowableDeductions, 295000);
      });

      test('taxable income = gross total - deductions', () {
        // 1129600 - 295000 = 834600
        expect(formData.taxableIncome, 834600);
      });

      test('new regime disallows Chapter VI-A deductions', () {
        final newRegimeData = formData.copyWith(
          selectedRegime: TaxRegime.newRegime,
        );
        expect(newRegimeData.allowableDeductions, 0);
        expect(newRegimeData.taxableIncome, 1129600);
      });

      test('TDS and taxes paid are tracked correctly', () {
        final tds = formData.tdsPaymentSummary;
        expect(tds.totalTds, 124500); // 120000 + 4500
        expect(tds.totalAdvanceTax, 0);
        expect(tds.totalTaxesPaid, 124500);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 4: JSON Export
    // -----------------------------------------------------------------------

    group('Phase 3 — JSON export to ITD schema', () {
      late ItrExportResult exportResult;

      setUp(() {
        exportResult = Itr1ExportService.export(formData, assessmentYear);
      });

      test('export produces valid ItrExportResult', () {
        expect(exportResult.itrType, ItrType.itr1);
        expect(exportResult.assessmentYear, assessmentYear);
        expect(exportResult.panNumber, 'ABCPS1234K');
        expect(exportResult.isValid, isTrue);
        expect(exportResult.checksum, isNotEmpty);
        expect(exportResult.jsonPayload, isNotEmpty);
      });

      test('JSON payload has correct ITD schema structure', () {
        final json =
            jsonDecode(exportResult.jsonPayload) as Map<String, dynamic>;

        // Top-level: ITR → ITR1
        expect(json.containsKey('ITR'), isTrue);
        final itr = json['ITR'] as Map<String, dynamic>;
        expect(itr.containsKey('ITR1'), isTrue);
        final itr1 = itr['ITR1'] as Map<String, dynamic>;

        // Required sections
        expect(itr1.containsKey('PersonalInfo'), isTrue);
        expect(itr1.containsKey('FilingStatus'), isTrue);
        expect(itr1.containsKey('ITR1_IncomeDeductions'), isTrue);
        expect(itr1.containsKey('TaxComputation'), isTrue);
        expect(itr1.containsKey('ScheduleTDS'), isTrue);
        expect(itr1.containsKey('ScheduleTaxPayment'), isTrue);
      });

      test('PersonalInfo section maps correctly', () {
        final json =
            jsonDecode(exportResult.jsonPayload) as Map<String, dynamic>;
        final pi = json['ITR']['ITR1']['PersonalInfo'] as Map<String, dynamic>;

        expect(pi['PAN'], 'ABCPS1234K');
        expect(pi['AssessmentYear'], assessmentYear);
        expect(pi['AadhaarCardNo'], '123456789012');

        final name = pi['AssesseeName'] as Map<String, dynamic>;
        expect(name['FirstName'], 'Rajesh');
        expect(name['MiddleName'], 'Kumar');
        expect(name['SurNameOrOrgName'], 'Sharma');
      });

      test('FilingStatus reflects old regime election', () {
        final json =
            jsonDecode(exportResult.jsonPayload) as Map<String, dynamic>;
        final fs = json['ITR']['ITR1']['FilingStatus'] as Map<String, dynamic>;

        expect(fs['ReturnFileSec'], 11); // Section 139(1)
        expect(fs['OptOutNewTaxRegime'], 'Y'); // Old regime selected
      });

      test('income/deductions section has integer rupee amounts', () {
        final json =
            jsonDecode(exportResult.jsonPayload) as Map<String, dynamic>;
        final inc =
            json['ITR']['ITR1']['ITR1_IncomeDeductions']
                as Map<String, dynamic>;

        expect(inc['GrossSalary'], isA<int>());
        expect(inc['GrossSalary'], 1200000);
        expect(inc['NetSalary'], 1075000);
        expect(inc['IncomeFromHP'], -20400);
        expect(inc['IncomeOthSrc'], 75000);
        expect(inc['GrossTotIncome'], 1129600);
        expect(inc['TotalDeductions'], 295000);
        expect(inc['IncomeAfterDeduction'], 834600);
      });

      test('ScheduleTDS section maps TDS amounts', () {
        final json =
            jsonDecode(exportResult.jsonPayload) as Map<String, dynamic>;
        final tds = json['ITR']['ITR1']['ScheduleTDS'] as Map<String, dynamic>;

        expect(tds['TDSonSalary'], 120000);
        expect(tds['TDSonOtherThanSalary'], 4500);
        expect(tds['TotalTDS'], 124500);
      });

      test('ScheduleTaxPayment includes advance and self-assessment', () {
        final json =
            jsonDecode(exportResult.jsonPayload) as Map<String, dynamic>;
        final pay =
            json['ITR']['ITR1']['ScheduleTaxPayment'] as Map<String, dynamic>;

        expect(pay['TotalAdvanceTax'], 0);
        expect(pay['SelfAssessmentTax'], 0);
        expect(pay['TotalTaxPayments'], 0);
      });

      test('SHA-256 checksum is deterministic for same data', () {
        final second = Itr1ExportService.export(formData, assessmentYear);
        expect(second.checksum, exportResult.checksum);
      });
    });

    // -----------------------------------------------------------------------
    // Phase 5: Submission Job Creation
    // -----------------------------------------------------------------------

    group('Phase 4 — Submission job creation', () {
      test('creates a valid ITD submission job', () {
        final job = SubmissionJob(
          id: 'job-itr1-001',
          clientId: 'ABCPS1234K',
          clientName: 'Rajesh Kumar Sharma',
          portalType: PortalType.itd,
          returnType: 'ITR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
          itrJsonPath: '/tmp/ITR1_ABCPS1234K_AY2025-26.json',
          assessmentYear: '2025-26',
        );

        expect(job.isCompleted, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isInProgress, isFalse);
        expect(job.canRetry, isFalse); // not failed, so can't retry
        expect(job.portalType, PortalType.itd);
        expect(job.returnType, 'ITR-1');
        expect(job.itrJsonPath, isNotNull);
        expect(job.assessmentYear, '2025-26');
      });

      test('job state machine transitions correctly', () {
        final pending = SubmissionJob(
          id: 'job-001',
          clientId: 'ABCPS1234K',
          clientName: 'Rajesh',
          portalType: PortalType.itd,
          returnType: 'ITR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
        );

        // pending → loggingIn
        final loggingIn = pending.copyWith(
          currentStep: SubmissionStep.loggingIn,
        );
        expect(loggingIn.isInProgress, isTrue);

        // loggingIn → filling
        final filling = loggingIn.copyWith(currentStep: SubmissionStep.filling);
        expect(filling.isInProgress, isTrue);

        // filling → otp
        final otp = filling.copyWith(currentStep: SubmissionStep.otp);
        expect(otp.isInProgress, isTrue);

        // otp → reviewing
        final reviewing = otp.copyWith(currentStep: SubmissionStep.reviewing);
        expect(
          reviewing.isInProgress,
          isFalse,
        ); // reviewing is NOT in progress set

        // reviewing → submitting
        final submitting = reviewing.copyWith(
          currentStep: SubmissionStep.submitting,
        );
        expect(submitting.isInProgress, isTrue);

        // submitting → downloading
        final downloading = submitting.copyWith(
          currentStep: SubmissionStep.downloading,
        );
        expect(downloading.isInProgress, isTrue);

        // downloading → done
        final done = downloading.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'ACK123456789',
          filedAt: DateTime.now(),
        );
        expect(done.isCompleted, isTrue);
        expect(done.isInProgress, isFalse);
        expect(done.ackNumber, 'ACK123456789');
      });

      test('failed job supports retry up to 3 times', () {
        final failed = SubmissionJob(
          id: 'job-002',
          clientId: 'ABCPS1234K',
          clientName: 'Rajesh',
          portalType: PortalType.itd,
          returnType: 'ITR-1',
          currentStep: SubmissionStep.failed,
          retryCount: 0,
          createdAt: DateTime.now(),
          errorMessage: 'CAPTCHA timeout',
        );

        expect(failed.canRetry, isTrue);

        final retry1 = failed.copyWith(retryCount: 1);
        expect(retry1.canRetry, isTrue);

        final retry3 = failed.copyWith(retryCount: 3);
        expect(retry3.canRetry, isFalse);
      });

      test('job equality is based on ID only', () {
        final job1 = SubmissionJob(
          id: 'same-id',
          clientId: 'A',
          clientName: 'A',
          portalType: PortalType.itd,
          returnType: 'ITR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime(2025),
        );

        final job2 = SubmissionJob(
          id: 'same-id',
          clientId: 'B',
          clientName: 'B',
          portalType: PortalType.gstn,
          returnType: 'GSTR-1',
          currentStep: SubmissionStep.done,
          retryCount: 5,
          createdAt: DateTime(2026),
        );

        expect(job1, equals(job2));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 6: Portal Automation (Mock Streams)
    // -----------------------------------------------------------------------

    group('Phase 5 — ITD portal automation (mock)', () {
      const itdService = ItdAutosubmitService();

      test('login mock stream emits expected steps', () async {
        const credential = PortalCredential(
          id: 'cred-001',
          portalType: PortalType.itd,
          username: 'ABCPS1234K',
          encryptedPassword: 'mock-encrypted',
        );

        final logs = <SubmissionLog>[];
        await for (final log in itdService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 4);
        expect(logs.first.step, SubmissionStep.loggingIn);
        expect(logs.first.message, contains('Navigating'));
        expect(logs.last.message, contains('Login completed'));
      });

      test('upload ITR mock stream emits fill + submit steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in itdService.uploadItr(
          clientPan: 'ABCPS1234K',
          itrJsonPath: '/tmp/ITR1_ABCPS1234K_AY2025-26.json',
          assessmentYear: '2025-26',
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.length, 5);
        expect(logs[0].step, SubmissionStep.filling);
        expect(logs[3].step, SubmissionStep.submitting);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains('ABCPS1234K'));
      });

      test('e-verify mock stream emits OTP steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in itdService.eVerify(
          clientPan: 'ABCPS1234K',
          otpService: OtpInterceptService(),
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.first.step, SubmissionStep.otp);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains('e-Verification completed'));
      });

      test('ITR-V download mock stream emits download steps', () async {
        final logs = <SubmissionLog>[];
        await for (final log in itdService.downloadItrV(
          clientPan: 'ABCPS1234K',
          ackNumber: 'ACK123456789',
          savePath: '/tmp/ITR-V_ABCPS1234K.pdf',
        )) {
          logs.add(log);
        }

        expect(logs, isNotEmpty);
        expect(logs.first.step, SubmissionStep.downloading);
        expect(logs.last.step, SubmissionStep.done);
        expect(logs.last.message, contains('downloaded'));
      });

      test('full automation sequence runs all phases', () async {
        const credential = PortalCredential(
          id: 'cred-001',
          portalType: PortalType.itd,
          username: 'ABCPS1234K',
          encryptedPassword: 'mock-encrypted',
        );

        final allLogs = <SubmissionLog>[];

        // Phase 1: Login
        await for (final log in itdService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // Phase 2: Upload ITR
        await for (final log in itdService.uploadItr(
          clientPan: 'ABCPS1234K',
          itrJsonPath: '/tmp/ITR1_ABCPS1234K_AY2025-26.json',
          assessmentYear: '2025-26',
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // Phase 3: e-Verify
        await for (final log in itdService.eVerify(
          clientPan: 'ABCPS1234K',
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // Phase 4: Download ITR-V
        await for (final log in itdService.downloadItrV(
          clientPan: 'ABCPS1234K',
          ackNumber: 'ACK123456789',
          savePath: '/tmp/ITR-V_ABCPS1234K.pdf',
        )) {
          allLogs.add(log);
        }

        // Verify complete pipeline
        expect(allLogs.length, greaterThanOrEqualTo(15));

        // Verify progression through all steps
        final steps = allLogs.map((l) => l.step).toSet();
        expect(
          steps,
          containsAll([
            SubmissionStep.loggingIn,
            SubmissionStep.filling,
            SubmissionStep.submitting,
            SubmissionStep.otp,
            SubmissionStep.downloading,
            SubmissionStep.done,
          ]),
        );

        // Verify no errors in the stream
        expect(allLogs.where((l) => l.isError), isEmpty);

        // Verify all logs have valid timestamps
        for (final log in allLogs) {
          expect(log.timestamp, isNotNull);
          expect(log.jobId, isNotEmpty);
          expect(log.message, isNotEmpty);
        }
      });
    });

    // -----------------------------------------------------------------------
    // Phase 7: Data Roundtrip
    // -----------------------------------------------------------------------

    group('Phase 6 — Data serialization roundtrip', () {
      test('Itr1FormData survives JSON roundtrip', () {
        final json = formData.toJson();
        final restored = Itr1FormData.fromJson(json);

        expect(restored.personalInfo.pan, formData.personalInfo.pan);
        expect(restored.personalInfo.fullName, formData.personalInfo.fullName);
        expect(
          restored.salaryIncome.grossSalary,
          formData.salaryIncome.grossSalary,
        );
        expect(
          restored.salaryIncome.netSalary,
          formData.salaryIncome.netSalary,
        );
        expect(
          restored.housePropertyIncome.incomeFromHouseProperty,
          formData.housePropertyIncome.incomeFromHouseProperty,
        );
        expect(
          restored.otherSourceIncome.total,
          formData.otherSourceIncome.total,
        );
        expect(
          restored.deductions.totalDeductions,
          formData.deductions.totalDeductions,
        );
        expect(restored.selectedRegime, formData.selectedRegime);
        expect(
          restored.tdsPaymentSummary.totalTaxesPaid,
          formData.tdsPaymentSummary.totalTaxesPaid,
        );
        expect(restored.grossTotalIncome, formData.grossTotalIncome);
        expect(restored.taxableIncome, formData.taxableIncome);
      });

      test('export JSON re-export produces identical checksum', () {
        final first = Itr1ExportService.export(formData, assessmentYear);
        final json = formData.toJson();
        final restored = Itr1FormData.fromJson(json);
        final second = Itr1ExportService.export(restored, assessmentYear);

        expect(second.checksum, first.checksum);
        expect(second.jsonPayload, first.jsonPayload);
      });

      test('immutability: copyWith does not mutate original', () {
        final modified = formData.copyWith(
          salaryIncome: formData.salaryIncome.copyWith(grossSalary: 2000000),
        );

        expect(formData.salaryIncome.grossSalary, 1200000);
        expect(modified.salaryIncome.grossSalary, 2000000);
        expect(formData.grossTotalIncome, isNot(modified.grossTotalIncome));
      });
    });

    // -----------------------------------------------------------------------
    // Phase 8: Full pipeline integration
    // -----------------------------------------------------------------------

    group('Phase 7 — Full pipeline: data → export → job → automation', () {
      test('complete A-Z pipeline succeeds', () async {
        // Step 1: User enters data (represented by formData from setUp)
        expect(formData.personalInfo.pan, isNotEmpty);
        expect(formData.grossTotalIncome, greaterThan(0));

        // Step 2: Export to ITD JSON
        final exportResult = Itr1ExportService.export(formData, assessmentYear);
        expect(exportResult.isValid, isTrue);
        expect(exportResult.jsonPayload, isNotEmpty);

        // Step 3: Create submission job with export path
        final job = SubmissionJob(
          id: 'e2e-job-001',
          clientId: formData.personalInfo.pan,
          clientName: formData.personalInfo.fullName,
          portalType: PortalType.itd,
          returnType: 'ITR-1',
          currentStep: SubmissionStep.pending,
          retryCount: 0,
          createdAt: DateTime.now(),
          itrJsonPath:
              'ITR1_${formData.personalInfo.pan}_AY$assessmentYear.json',
          assessmentYear: assessmentYear,
        );
        expect(job.currentStep, SubmissionStep.pending);

        // Step 4: Run automation sequence (mock — no real WebView)
        const itdService = ItdAutosubmitService();
        final credential = PortalCredential(
          id: 'cred-e2e',
          portalType: PortalType.itd,
          username: formData.personalInfo.pan,
          encryptedPassword: 'mock-encrypted',
        );

        final allLogs = <SubmissionLog>[];

        // Login
        var updatedJob = job.copyWith(currentStep: SubmissionStep.loggingIn);
        await for (final log in itdService.login(
          credential: credential,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }
        expect(allLogs.last.message, contains('Login completed'));

        // Upload ITR
        updatedJob = updatedJob.copyWith(currentStep: SubmissionStep.filling);
        await for (final log in itdService.uploadItr(
          clientPan: job.clientId,
          itrJsonPath: job.itrJsonPath!,
          assessmentYear: job.assessmentYear!,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // e-Verify
        updatedJob = updatedJob.copyWith(currentStep: SubmissionStep.otp);
        await for (final log in itdService.eVerify(
          clientPan: job.clientId,
          otpService: OtpInterceptService(),
        )) {
          allLogs.add(log);
        }

        // Download ITR-V
        updatedJob = updatedJob.copyWith(
          currentStep: SubmissionStep.downloading,
        );
        await for (final log in itdService.downloadItrV(
          clientPan: job.clientId,
          ackNumber: 'ACK-E2E-TEST',
          savePath: '/tmp/ITR-V_${job.clientId}.pdf',
        )) {
          allLogs.add(log);
        }

        // Mark done
        updatedJob = updatedJob.copyWith(
          currentStep: SubmissionStep.done,
          ackNumber: 'ACK-E2E-TEST',
          filedAt: DateTime.now(),
        );

        // ---- ASSERTIONS: The full pipeline completed ----
        expect(updatedJob.isCompleted, isTrue);
        expect(updatedJob.ackNumber, 'ACK-E2E-TEST');
        expect(allLogs.where((l) => l.isError), isEmpty);
        expect(
          allLogs.length,
          greaterThanOrEqualTo(15),
          reason: 'Full pipeline should emit 15+ log entries',
        );

        // Verify export checksum matches what would be filed
        final verifyExport = Itr1ExportService.export(formData, assessmentYear);
        expect(
          verifyExport.checksum,
          exportResult.checksum,
          reason: 'Export should be deterministic',
        );
      });
    });
  });
}

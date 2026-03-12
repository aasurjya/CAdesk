import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/services/fvu_pre_scrutiny_service.dart';

void main() {
  group('FvuPreScrutinyService', () {
    const validBatchHeader = FvuBatchHeader(
      tan: 'MUMA12345B',
      pan: 'ABCDE1234F',
      deductorName: 'Test Corp',
      financialYear: '2025-26',
      quarter: TdsQuarter.q1,
      formType: TdsFormType.form26Q,
      preparationDate: '15032026',
      totalChallans: 1,
      totalDeductees: 1,
      totalTaxDeducted: 10000.00,
    );

    const validChallan = FvuChallanRecord(
      bsrCode: '0002390',
      challanTenderDate: '10032026',
      challanSerialNumber: '0000000100',
      totalTaxDeposited: 10000.00,
      deducteeCount: 1,
      sectionCode: '194J',
    );

    const validDeductee = FvuDeducteeRecord(
      pan: 'ABCDE1234F',
      deducteeName: 'Consultant',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '01032026',
      sectionCode: '194J',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    const validStructure = FvuFileStructure(
      batchHeader: validBatchHeader,
      challans: [
        FvuChallanWithDeductees(
          challan: validChallan,
          deductees: [validDeductee],
        ),
      ],
    );

    group('PAN validation', () {
      test('valid PAN passes scrutiny', () {
        final issues = FvuPreScrutinyService.scrutinize(validStructure);
        final panIssues = issues.where(
          (i) => i.type == ScrutinyIssueType.invalidPan,
        );
        expect(panIssues, isEmpty);
      });

      test('invalid deductor PAN is flagged', () {
        final header = validBatchHeader.copyWith(pan: 'INVALID');
        final structure = FvuFileStructure(
          batchHeader: header,
          challans: validStructure.challans,
        );
        final issues = FvuPreScrutinyService.scrutinize(structure);
        expect(
          issues.any((i) => i.type == ScrutinyIssueType.invalidPan),
          isTrue,
        );
      });

      test('invalid deductee PAN is flagged', () {
        const badPanDeductee = FvuDeducteeRecord(
          pan: 'BADINVALID',
          deducteeName: 'Bad Person',
          amountPaid: 100000.00,
          tdsAmount: 10000.00,
          dateOfPayment: '01032026',
          sectionCode: '194J',
          deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
        );
        const structure = FvuFileStructure(
          batchHeader: validBatchHeader,
          challans: [
            FvuChallanWithDeductees(
              challan: validChallan,
              deductees: [badPanDeductee],
            ),
          ],
        );
        final issues = FvuPreScrutinyService.scrutinize(structure);
        expect(
          issues.any((i) => i.type == ScrutinyIssueType.invalidPan),
          isTrue,
        );
      });

      test('PANNOTAVBL deductee is flagged as warning', () {
        const noPanDeductee = FvuDeducteeRecord(
          pan: 'PANNOTAVBL',
          deducteeName: 'Unknown',
          amountPaid: 100000.00,
          tdsAmount: 20000.00,
          dateOfPayment: '01032026',
          sectionCode: '194J',
          deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
        );
        const structure = FvuFileStructure(
          batchHeader: validBatchHeader,
          challans: [
            FvuChallanWithDeductees(
              challan: validChallan,
              deductees: [noPanDeductee],
            ),
          ],
        );
        final issues = FvuPreScrutinyService.scrutinize(structure);
        expect(
          issues.any(
            (i) =>
                i.type == ScrutinyIssueType.panNotAvailable &&
                i.severity == ScrutinyIssueSeverity.warning,
          ),
          isTrue,
        );
      });
    });

    group('TAN validation', () {
      test('valid TAN passes scrutiny', () {
        final issues = FvuPreScrutinyService.scrutinize(validStructure);
        final tanIssues = issues.where(
          (i) => i.type == ScrutinyIssueType.invalidTan,
        );
        expect(tanIssues, isEmpty);
      });

      test('invalid TAN is flagged', () {
        final header = validBatchHeader.copyWith(tan: 'BAD_TAN');
        final structure = FvuFileStructure(
          batchHeader: header,
          challans: validStructure.challans,
        );
        final issues = FvuPreScrutinyService.scrutinize(structure);
        expect(
          issues.any((i) => i.type == ScrutinyIssueType.invalidTan),
          isTrue,
        );
      });
    });

    group('Challan shortfall validation', () {
      test('no shortfall when challan covers deductees', () {
        final issues = FvuPreScrutinyService.scrutinize(validStructure);
        final shortfallIssues = issues.where(
          (i) => i.type == ScrutinyIssueType.challanShortfall,
        );
        expect(shortfallIssues, isEmpty);
      });

      test('shortfall is flagged when deductee TDS exceeds challan amount', () {
        const highDeductee = FvuDeducteeRecord(
          pan: 'ABCDE1234F',
          deducteeName: 'High TDS',
          amountPaid: 200000.00,
          tdsAmount: 50000.00,
          dateOfPayment: '01032026',
          sectionCode: '194J',
          deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
        );
        const structure = FvuFileStructure(
          batchHeader: validBatchHeader,
          challans: [
            FvuChallanWithDeductees(
              challan: validChallan,
              deductees: [highDeductee],
            ),
          ],
        );
        final issues = FvuPreScrutinyService.scrutinize(structure);
        expect(
          issues.any((i) => i.type == ScrutinyIssueType.challanShortfall),
          isTrue,
        );
      });
    });

    group('Rate variance validation', () {
      test('no rate variance for correct TDS at 10%', () {
        // 194J: 10%, amountPaid=100000, tdsAmount=10000 = exactly 10%
        final issues = FvuPreScrutinyService.scrutinize(validStructure);
        final rateIssues = issues.where(
          (i) => i.type == ScrutinyIssueType.rateVariance,
        );
        expect(rateIssues, isEmpty);
      });

      test('rate variance is flagged when deducted rate differs > 5%', () {
        // 194C: 1%, but we deduct at effectively 15% → variance > 5%
        const wrongRateDeductee = FvuDeducteeRecord(
          pan: 'ABCDE1234F',
          deducteeName: 'Contractor',
          amountPaid: 100000.00,
          tdsAmount: 15000.00, // 15% instead of 1%
          dateOfPayment: '01032026',
          sectionCode: '194C',
          deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
        );
        const wrongRateChallan = FvuChallanRecord(
          bsrCode: '0002390',
          challanTenderDate: '10032026',
          challanSerialNumber: '0000000100',
          totalTaxDeposited: 15000.00,
          deducteeCount: 1,
          sectionCode: '194C',
        );
        const structure = FvuFileStructure(
          batchHeader: validBatchHeader,
          challans: [
            FvuChallanWithDeductees(
              challan: wrongRateChallan,
              deductees: [wrongRateDeductee],
            ),
          ],
        );
        final issues = FvuPreScrutinyService.scrutinize(structure);
        expect(
          issues.any((i) => i.type == ScrutinyIssueType.rateVariance),
          isTrue,
        );
      });
    });

    group('ScrutinyIssue model', () {
      test('ScrutinyIssue has correct fields', () {
        const issue = ScrutinyIssue(
          type: ScrutinyIssueType.invalidPan,
          severity: ScrutinyIssueSeverity.error,
          message: 'Invalid PAN: INVALID123',
          fieldReference: 'deductee.pan',
        );
        expect(issue.type, ScrutinyIssueType.invalidPan);
        expect(issue.severity, ScrutinyIssueSeverity.error);
        expect(issue.message, 'Invalid PAN: INVALID123');
        expect(issue.fieldReference, 'deductee.pan');
      });

      test('ScrutinyIssue equality is value-based', () {
        const a = ScrutinyIssue(
          type: ScrutinyIssueType.invalidPan,
          severity: ScrutinyIssueSeverity.error,
          message: 'Test',
          fieldReference: 'ref',
        );
        const b = ScrutinyIssue(
          type: ScrutinyIssueType.invalidPan,
          severity: ScrutinyIssueSeverity.error,
          message: 'Test',
          fieldReference: 'ref',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('validatePanFormat', () {
      test('valid PAN returns true', () {
        expect(FvuPreScrutinyService.isValidPan('ABCDE1234F'), isTrue);
        expect(FvuPreScrutinyService.isValidPan('XYZPQ9876K'), isTrue);
      });

      test('invalid PAN formats return false', () {
        expect(FvuPreScrutinyService.isValidPan('ABCDE123'), isFalse);
        expect(FvuPreScrutinyService.isValidPan('abcde1234f'), isFalse);
        expect(FvuPreScrutinyService.isValidPan('12345ABCDE'), isFalse);
        expect(FvuPreScrutinyService.isValidPan(''), isFalse);
        expect(FvuPreScrutinyService.isValidPan('PANNOTAVBL'), isFalse);
      });
    });

    group('validateTanFormat', () {
      test('valid TAN returns true', () {
        expect(FvuPreScrutinyService.isValidTan('MUMA12345B'), isTrue);
        expect(FvuPreScrutinyService.isValidTan('ABCD12345F'), isTrue);
      });

      test('invalid TAN formats return false', () {
        expect(FvuPreScrutinyService.isValidTan('MUM12345B'), isFalse);
        expect(FvuPreScrutinyService.isValidTan('muma12345b'), isFalse);
        expect(FvuPreScrutinyService.isValidTan(''), isFalse);
      });
    });
  });
}

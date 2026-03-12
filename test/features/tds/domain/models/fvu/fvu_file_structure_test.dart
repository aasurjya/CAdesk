import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

void main() {
  group('FvuFileStructure', () {
    const batchHeader = FvuBatchHeader(
      tan: 'MUMA12345B',
      pan: 'ABCDE1234F',
      deductorName: 'Test Corp',
      financialYear: '2025-26',
      quarter: TdsQuarter.q1,
      formType: TdsFormType.form26Q,
      preparationDate: '15032026',
      totalChallans: 1,
      totalDeductees: 2,
      totalTaxDeducted: 20000.00,
    );

    const challan = FvuChallanRecord(
      bsrCode: '0002390',
      challanTenderDate: '07032026',
      challanSerialNumber: '0000000234',
      totalTaxDeposited: 20000.00,
      deducteeCount: 2,
      sectionCode: '194C',
    );

    const deductee1 = FvuDeducteeRecord(
      pan: 'ABCDE1234F',
      deducteeName: 'Vendor One',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '01032026',
      sectionCode: '194C',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    const deductee2 = FvuDeducteeRecord(
      pan: 'XYZAB5678G',
      deducteeName: 'Vendor Two',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '05032026',
      sectionCode: '194C',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    const structure = FvuFileStructure(
      batchHeader: batchHeader,
      challans: [
        FvuChallanWithDeductees(
          challan: challan,
          deductees: [deductee1, deductee2],
        ),
      ],
    );

    test('creates immutable instance with correct values', () {
      expect(structure.batchHeader, batchHeader);
      expect(structure.challans.length, 1);
      expect(structure.challans.first.challan, challan);
      expect(structure.challans.first.deductees.length, 2);
    });

    test('totalChallanCount returns count of challans', () {
      expect(structure.totalChallanCount, 1);
    });

    test('totalDeducteeCount returns sum across challans', () {
      expect(structure.totalDeducteeCount, 2);
    });

    test('totalTaxDeducted returns sum of all TDS amounts', () {
      expect(structure.totalTaxDeducted, 20000.00);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = structure.copyWith(challans: []);
      expect(updated.challans, isEmpty);
      expect(updated.batchHeader, structure.batchHeader);
    });

    test('equality is value-based', () {
      const same = FvuFileStructure(
        batchHeader: batchHeader,
        challans: [
          FvuChallanWithDeductees(
            challan: challan,
            deductees: [deductee1, deductee2],
          ),
        ],
      );
      expect(structure, equals(same));
    });

    test('toString includes key fields', () {
      final str = structure.toString();
      expect(str, contains('MUMA12345B'));
    });
  });

  group('FvuChallanWithDeductees', () {
    const challan = FvuChallanRecord(
      bsrCode: '0002390',
      challanTenderDate: '07032026',
      challanSerialNumber: '0000000234',
      totalTaxDeposited: 10000.00,
      deducteeCount: 1,
      sectionCode: '194J',
    );
    const deductee = FvuDeducteeRecord(
      pan: 'ABCDE1234F',
      deducteeName: 'Consultant',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '01032026',
      sectionCode: '194J',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    const group1 = FvuChallanWithDeductees(
      challan: challan,
      deductees: [deductee],
    );

    test('creates immutable instance', () {
      expect(group1.challan, challan);
      expect(group1.deductees.length, 1);
    });

    test('equality is value-based', () {
      const same = FvuChallanWithDeductees(
        challan: challan,
        deductees: [deductee],
      );
      expect(group1, equals(same));
      expect(group1.hashCode, equals(same.hashCode));
    });

    test('copyWith creates new instance', () {
      final updated = group1.copyWith(deductees: []);
      expect(updated.deductees, isEmpty);
      expect(updated.challan, group1.challan);
    });
  });
}

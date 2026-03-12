import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_batch_header.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

void main() {
  group('FvuBatchHeader', () {
    const header = FvuBatchHeader(
      tan: 'MUMA12345B',
      pan: 'ABCDE1234F',
      deductorName: 'ABC Pvt Ltd',
      financialYear: '2025-26',
      quarter: TdsQuarter.q1,
      formType: TdsFormType.form26Q,
      preparationDate: '15032026',
      totalChallans: 3,
      totalDeductees: 10,
      totalTaxDeducted: 50000.00,
    );

    test('creates immutable instance with correct values', () {
      expect(header.tan, 'MUMA12345B');
      expect(header.pan, 'ABCDE1234F');
      expect(header.deductorName, 'ABC Pvt Ltd');
      expect(header.financialYear, '2025-26');
      expect(header.quarter, TdsQuarter.q1);
      expect(header.formType, TdsFormType.form26Q);
      expect(header.preparationDate, '15032026');
      expect(header.totalChallans, 3);
      expect(header.totalDeductees, 10);
      expect(header.totalTaxDeducted, 50000.00);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = header.copyWith(totalChallans: 5, totalDeductees: 20);
      expect(updated.totalChallans, 5);
      expect(updated.totalDeductees, 20);
      expect(updated.tan, header.tan);
      expect(updated.pan, header.pan);
    });

    test('equality is value-based', () {
      const same = FvuBatchHeader(
        tan: 'MUMA12345B',
        pan: 'ABCDE1234F',
        deductorName: 'ABC Pvt Ltd',
        financialYear: '2025-26',
        quarter: TdsQuarter.q1,
        formType: TdsFormType.form26Q,
        preparationDate: '15032026',
        totalChallans: 3,
        totalDeductees: 10,
        totalTaxDeducted: 50000.00,
      );
      expect(header, equals(same));
      expect(header.hashCode, equals(same.hashCode));
    });

    test('inequality when fields differ', () {
      final different = header.copyWith(totalChallans: 99);
      expect(header, isNot(equals(different)));
    });

    test('toString includes key fields', () {
      final str = header.toString();
      expect(str, contains('MUMA12345B'));
      expect(str, contains('2025-26'));
    });

    test('formTypeCode returns correct code for each form type', () {
      expect(header.formTypeCode, '26');
      final h24 = header.copyWith(formType: TdsFormType.form24Q);
      expect(h24.formTypeCode, '24');
      final h27 = header.copyWith(formType: TdsFormType.form27Q);
      expect(h27.formTypeCode, '27');
      final h27eq = header.copyWith(formType: TdsFormType.form27EQ);
      expect(h27eq.formTypeCode, '2E');
    });

    test('quarterNumber returns correct number for each quarter', () {
      expect(header.quarterNumber, 1);
      final q2 = header.copyWith(quarter: TdsQuarter.q2);
      expect(q2.quarterNumber, 2);
      final q3 = header.copyWith(quarter: TdsQuarter.q3);
      expect(q3.quarterNumber, 3);
      final q4 = header.copyWith(quarter: TdsQuarter.q4);
      expect(q4.quarterNumber, 4);
    });
  });
}

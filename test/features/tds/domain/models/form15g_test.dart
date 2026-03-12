import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/form15g.dart';

void main() {
  group('Form15G', () {
    final form = Form15G(
      formNumber: 'F15G/2025-26/001',
      pan: 'ABCDE1234F',
      declarantName: 'Ravi Kumar',
      assessmentYear: '2026-27',
      financialYear: '2025-26',
      dateSubmitted: DateTime(2025, 4, 10),
      estimatedTotalIncome: 200000.0,
      estimatedIncomeFromSection: 15000.0,
      aggregateDeclaredAmount: 15000.0,
      deductorTan: 'MUMA12345B',
      deductorName: 'ABC Bank',
      sectionCode: '194A',
    );

    test('creates immutable instance with correct values', () {
      expect(form.formNumber, 'F15G/2025-26/001');
      expect(form.pan, 'ABCDE1234F');
      expect(form.declarantName, 'Ravi Kumar');
      expect(form.assessmentYear, '2026-27');
      expect(form.financialYear, '2025-26');
      expect(form.estimatedTotalIncome, 200000.0);
      expect(form.estimatedIncomeFromSection, 15000.0);
      expect(form.aggregateDeclaredAmount, 15000.0);
      expect(form.deductorTan, 'MUMA12345B');
      expect(form.sectionCode, '194A');
    });

    test('isValid returns true when income is below taxable limit', () {
      // 200000 is below the basic exemption limit
      expect(form.isValid, isTrue);
    });

    test('isExpired returns false within the same financial year', () {
      // form submitted April 2025, financial year ends March 2026
      expect(form.isExpiredAt(DateTime(2025, 12, 31)), isFalse);
    });

    test('isExpired returns true after financial year ends', () {
      expect(form.isExpiredAt(DateTime(2026, 4, 1)), isTrue);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = form.copyWith(declarantName: 'Sita Devi');
      expect(updated.declarantName, 'Sita Devi');
      expect(updated.pan, form.pan);
    });

    test('equality is value-based', () {
      final same = Form15G(
        formNumber: 'F15G/2025-26/001',
        pan: 'ABCDE1234F',
        declarantName: 'Ravi Kumar',
        assessmentYear: '2026-27',
        financialYear: '2025-26',
        dateSubmitted: DateTime(2025, 4, 10),
        estimatedTotalIncome: 200000.0,
        estimatedIncomeFromSection: 15000.0,
        aggregateDeclaredAmount: 15000.0,
        deductorTan: 'MUMA12345B',
        deductorName: 'ABC Bank',
        sectionCode: '194A',
      );
      expect(form, equals(same));
      expect(form.hashCode, equals(same.hashCode));
    });

    test('inequality when fields differ', () {
      final different = form.copyWith(formNumber: 'F15G/2025-26/999');
      expect(form, isNot(equals(different)));
    });

    test('toString includes key fields', () {
      final str = form.toString();
      expect(str, contains('ABCDE1234F'));
      expect(str, contains('2025-26'));
    });
  });
}

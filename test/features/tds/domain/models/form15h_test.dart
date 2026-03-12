import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/form15h.dart';

void main() {
  group('Form15H', () {
    final form = Form15H(
      formNumber: 'F15H/2025-26/001',
      pan: 'PQRST5678X',
      declarantName: 'Ramesh Sharma',
      dateOfBirth: DateTime(1958, 6, 15),
      assessmentYear: '2026-27',
      financialYear: '2025-26',
      dateSubmitted: DateTime(2025, 4, 5),
      estimatedTotalIncome: 280000.0,
      estimatedIncomeFromSection: 30000.0,
      aggregateDeclaredAmount: 30000.0,
      deductorTan: 'MUMA12345B',
      deductorName: 'ABC Bank',
      sectionCode: '194A',
    );

    test('creates immutable instance with correct values', () {
      expect(form.formNumber, 'F15H/2025-26/001');
      expect(form.pan, 'PQRST5678X');
      expect(form.declarantName, 'Ramesh Sharma');
      expect(form.dateOfBirth, DateTime(1958, 6, 15));
      expect(form.assessmentYear, '2026-27');
      expect(form.estimatedTotalIncome, 280000.0);
    });

    test('ageAtSubmission is calculated correctly', () {
      // Born 1958, submitted 2025 → age 66 (or 67 if birthday passed)
      expect(form.ageAtSubmission, greaterThanOrEqualTo(66));
      expect(form.ageAtSubmission, lessThanOrEqualTo(67));
    });

    test('isSeniorCitizen returns true for age >= 60', () {
      expect(form.isSeniorCitizen, isTrue);
    });

    test('isSeniorCitizen returns false for younger person', () {
      final young = form.copyWith(dateOfBirth: DateTime(1990, 1, 1));
      expect(young.isSeniorCitizen, isFalse);
    });

    test('isValid returns true for senior citizen', () {
      expect(form.isValid, isTrue);
    });

    test('isExpired returns false within the same financial year', () {
      expect(form.isExpiredAt(DateTime(2026, 1, 1)), isFalse);
    });

    test('isExpired returns true after financial year ends', () {
      expect(form.isExpiredAt(DateTime(2026, 4, 1)), isTrue);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = form.copyWith(declarantName: 'Suresh Sharma');
      expect(updated.declarantName, 'Suresh Sharma');
      expect(updated.pan, form.pan);
    });

    test('equality is value-based', () {
      final same = Form15H(
        formNumber: 'F15H/2025-26/001',
        pan: 'PQRST5678X',
        declarantName: 'Ramesh Sharma',
        dateOfBirth: DateTime(1958, 6, 15),
        assessmentYear: '2026-27',
        financialYear: '2025-26',
        dateSubmitted: DateTime(2025, 4, 5),
        estimatedTotalIncome: 280000.0,
        estimatedIncomeFromSection: 30000.0,
        aggregateDeclaredAmount: 30000.0,
        deductorTan: 'MUMA12345B',
        deductorName: 'ABC Bank',
        sectionCode: '194A',
      );
      expect(form, equals(same));
      expect(form.hashCode, equals(same.hashCode));
    });

    test('inequality when fields differ', () {
      final different = form.copyWith(formNumber: 'F15H/2025-26/999');
      expect(form, isNot(equals(different)));
    });

    test('toString includes key fields', () {
      final str = form.toString();
      expect(str, contains('PQRST5678X'));
      expect(str, contains('2025-26'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/services/interest_computation_service.dart';

void main() {
  group('InterestComputationService — 234A (late filing)', () {
    test('filing on time → zero interest', () {
      final result = InterestComputationService.compute(
        taxPayable: 100000,
        advanceTaxPaid: 0,
        advanceTaxByQuarter: [0, 0, 0, 0],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234A, 0);
      expect(result.months234A, 0);
    });

    test('filing 2 months late → 1% per month on unpaid tax', () {
      final result = InterestComputationService.compute(
        taxPayable: 100000,
        advanceTaxPaid: 0,
        advanceTaxByQuarter: [0, 0, 0, 0],
        filingDate: DateTime(2026, 9, 30), // ~2 months after Jul 31
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234A, greaterThan(0));
      expect(result.months234A, greaterThanOrEqualTo(2));
    });

    test('zero tax → zero interest even if filed late', () {
      final result = InterestComputationService.compute(
        taxPayable: 0,
        advanceTaxPaid: 0,
        advanceTaxByQuarter: [0, 0, 0, 0],
        filingDate: DateTime(2026, 12, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234A, 0);
    });
  });

  group('InterestComputationService — 234B (advance tax shortfall)', () {
    test('advance tax ≥ 90% → no 234B interest', () {
      final result = InterestComputationService.compute(
        taxPayable: 100000,
        advanceTaxPaid: 90000, // exactly 90%
        advanceTaxByQuarter: [22500, 22500, 22500, 22500],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234B, 0);
    });

    test('advance tax < 90% → 1% per month on shortfall', () {
      final result = InterestComputationService.compute(
        taxPayable: 100000,
        advanceTaxPaid: 50000, // 50% < 90%
        advanceTaxByQuarter: [12500, 12500, 12500, 12500],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      // Shortfall = 50000, months Apr 1 to Jul 31 = ~4 months
      expect(result.interest234B, greaterThan(0));
      expect(result.months234B, greaterThanOrEqualTo(3));
    });

    test('zero advance tax on ₹200k payable → full shortfall interest', () {
      final result = InterestComputationService.compute(
        taxPayable: 200000,
        advanceTaxPaid: 0,
        advanceTaxByQuarter: [0, 0, 0, 0],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234B, greaterThan(0));
    });
  });

  group('InterestComputationService — 234C (quarterly deferment)', () {
    test('tax payable < ₹10,000 → no 234C interest', () {
      final result = InterestComputationService.compute(
        taxPayable: 9000,
        advanceTaxPaid: 0,
        advanceTaxByQuarter: [0, 0, 0, 0],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234C, 0);
    });

    test('full installments paid on time → no 234C', () {
      const tax = 100000.0;
      final result = InterestComputationService.compute(
        taxPayable: tax,
        advanceTaxPaid: tax,
        advanceTaxByQuarter: [15000, 30000, 30000, 25000],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(result.interest234C, 0);
    });

    test(
      'no advance tax paid on ₹100k → deferment interest on all quarters',
      () {
        final result = InterestComputationService.compute(
          taxPayable: 100000,
          advanceTaxPaid: 0,
          advanceTaxByQuarter: [0, 0, 0, 0],
          filingDate: DateTime(2026, 7, 31),
          dueDate: DateTime(2026, 7, 31),
          assessmentYearStart: DateTime(2026, 4, 1),
        );
        expect(result.interest234C, greaterThan(0));
      },
    );

    test('partial advance tax → proportional deferment interest', () {
      // Pay 15% by Q1 but nothing for Q2/Q3/Q4
      final result = InterestComputationService.compute(
        taxPayable: 100000,
        advanceTaxPaid: 15000,
        advanceTaxByQuarter: [15000, 0, 0, 0],
        filingDate: DateTime(2026, 7, 31),
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      // Q1 met (15%), Q2 short (need 45%, have 15%), Q3/Q4 short
      expect(result.interest234C, greaterThan(0));
    });
  });

  group('InterestComputationService — totalInterest', () {
    test('sum of all three sections', () {
      final result = InterestComputationService.compute(
        taxPayable: 200000,
        advanceTaxPaid: 0,
        advanceTaxByQuarter: [0, 0, 0, 0],
        filingDate: DateTime(2026, 10, 31), // late filing
        dueDate: DateTime(2026, 7, 31),
        assessmentYearStart: DateTime(2026, 4, 1),
      );
      expect(
        result.totalInterest,
        result.interest234A + result.interest234B + result.interest234C,
      );
    });
  });
}

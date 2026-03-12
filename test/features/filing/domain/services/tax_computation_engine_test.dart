import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/services/tax_computation_engine.dart';

Itr1FormData _makeForm({
  double grossSalary = 0,
  double deductions80C = 0,
  double otherIncome = 0,
  TaxRegime regime = TaxRegime.newRegime,
}) {
  return Itr1FormData.empty().copyWith(
    salaryIncome: SalaryIncome.empty().copyWith(grossSalary: grossSalary),
    deductions: ChapterViaDeductions.empty().copyWith(
      section80C: deductions80C,
    ),
    otherSourceIncome: OtherSourceIncome.empty().copyWith(
      otherIncome: otherIncome,
    ),
    selectedRegime: regime,
  );
}

void main() {
  group('TaxComputationEngine — New Regime', () {
    test('zero income → zero tax', () {
      final data = _makeForm();
      expect(TaxComputationEngine.computeNewRegimeTax(data), 0);
    });

    test('income below ₹4L (after std ded) → zero tax (rebate 87A)', () {
      // Gross 4,75,000 - std ded 75,000 = taxable 4,00,000 → rebate
      final data = _makeForm(grossSalary: 475000);
      expect(TaxComputationEngine.computeNewRegimeTax(data), 0);
    });

    test('income exactly ₹12L (after std ded) → rebate applies, zero tax', () {
      // Gross 12,75,000 - std ded 75,000 = taxable 12,00,000 → rebate
      final data = _makeForm(grossSalary: 1275000);
      expect(TaxComputationEngine.computeNewRegimeTax(data), 0);
    });

    test('income ₹12,00,001 → rebate does NOT apply', () {
      // Gross 12,75,001 - std ded 75,000 = taxable 12,00,001
      final data = _makeForm(grossSalary: 1275001);
      expect(TaxComputationEngine.computeNewRegimeTax(data), greaterThan(0));
    });

    test('income ₹16L → correct slab computation', () {
      // Gross 16,75,000 - std ded 75,000 = taxable 16,00,000
      // 0-4L: 0, 4-8L: 20k, 8-12L: 40k, 12-16L: 60k = 1,20,000
      final data = _makeForm(grossSalary: 1675000);
      expect(TaxComputationEngine.computeNewRegimeTax(data), 120000);
    });

    test('income ₹25L → all slabs including 30%', () {
      // Gross 25,75,000 - std ded 75,000 = taxable 25,00,000
      // 0-4L: 0, 4-8L: 20k, 8-12L: 40k, 12-16L: 60k,
      // 16-20L: 80k, 20-24L: 100k, 24-25L: 30k = 3,30,000
      final data = _makeForm(grossSalary: 2575000);
      expect(TaxComputationEngine.computeNewRegimeTax(data), 330000);
    });

    test('new regime ignores Chapter VI-A deductions', () {
      final withDeductions = _makeForm(
        grossSalary: 1675000,
        deductions80C: 150000,
      );
      final withoutDeductions = _makeForm(grossSalary: 1675000);
      expect(
        TaxComputationEngine.computeNewRegimeTax(withDeductions),
        TaxComputationEngine.computeNewRegimeTax(withoutDeductions),
      );
    });
  });

  group('TaxComputationEngine — Old Regime', () {
    test('zero income → zero tax', () {
      final data = _makeForm();
      expect(TaxComputationEngine.computeOldRegimeTax(data), 0);
    });

    test('income ≤ ₹5L → rebate 87A, zero tax', () {
      // Gross 5,50,000 - old std ded 50,000 = 5,00,000 → rebate
      final data = _makeForm(grossSalary: 550000);
      expect(TaxComputationEngine.computeOldRegimeTax(data), 0);
    });

    test('income ₹10L → correct old regime slabs', () {
      // Gross 10,50,000 - old std ded 50,000 = 10,00,000
      // 0-2.5L: 0, 2.5-5L: 12.5k, 5-10L: 100k = 1,12,500
      final data = _makeForm(grossSalary: 1050000);
      expect(TaxComputationEngine.computeOldRegimeTax(data), 112500);
    });

    test('income ₹15L with 80C deductions', () {
      // Gross 15,50,000 - old std ded 50,000 = 15,00,000
      // Deductions: 80C 1,50,000 → taxable = 13,50,000
      // 0-2.5L: 0, 2.5-5L: 12.5k, 5-10L: 100k, 10-13.5L: 105k = 2,17,500
      final data = _makeForm(grossSalary: 1550000, deductions80C: 150000);
      expect(TaxComputationEngine.computeOldRegimeTax(data), 217500);
    });
  });

  group('TaxComputationEngine — Surcharge', () {
    test('income ≤ 50L → no surcharge', () {
      expect(
        TaxComputationEngine.computeSurcharge(
          100000,
          4500000,
          isNewRegime: true,
        ),
        0,
      );
    });

    test('income 50L-1Cr → 10% surcharge', () {
      expect(
        TaxComputationEngine.computeSurcharge(
          100000,
          7500000,
          isNewRegime: false,
        ),
        10000,
      );
    });

    test('income 1Cr-2Cr → 15% surcharge', () {
      expect(
        TaxComputationEngine.computeSurcharge(
          100000,
          15000000,
          isNewRegime: false,
        ),
        15000,
      );
    });

    test('income 2Cr-5Cr → 25% surcharge', () {
      expect(
        TaxComputationEngine.computeSurcharge(
          100000,
          30000000,
          isNewRegime: true,
        ),
        25000,
      );
    });

    test('income >5Cr old regime → 37%', () {
      expect(
        TaxComputationEngine.computeSurcharge(
          100000,
          60000000,
          isNewRegime: false,
        ),
        37000,
      );
    });

    test('income >5Cr new regime → capped at 25%', () {
      expect(
        TaxComputationEngine.computeSurcharge(
          100000,
          60000000,
          isNewRegime: true,
        ),
        25000,
      );
    });
  });

  group('TaxComputationEngine — Cess', () {
    test('4% on tax + surcharge', () {
      expect(TaxComputationEngine.computeCess(100000), 4000);
    });

    test('zero on zero', () {
      expect(TaxComputationEngine.computeCess(0), 0);
    });
  });

  group('TaxComputationEngine — compare()', () {
    test('returns valid TaxRegimeResult with all fields', () {
      final data = _makeForm(grossSalary: 1050000);
      final result = TaxComputationEngine.compare(data);

      expect(result.oldRegimeTaxableIncome, greaterThan(0));
      expect(result.newRegimeTaxableIncome, greaterThan(0));
      expect(
        result.recommendedRegime,
        anyOf(TaxRegime.oldRegime, TaxRegime.newRegime),
      );
      expect(result.savings, greaterThanOrEqualTo(0));
    });

    test('recommends regime with lower tax', () {
      final data = _makeForm(grossSalary: 1050000);
      final result = TaxComputationEngine.compare(data);
      if (result.newRegimeTax <= result.oldRegimeTax) {
        expect(result.recommendedRegime, TaxRegime.newRegime);
      } else {
        expect(result.recommendedRegime, TaxRegime.oldRegime);
      }
    });

    test('savings equals absolute difference', () {
      final data = _makeForm(grossSalary: 2000000, deductions80C: 150000);
      final result = TaxComputationEngine.compare(data);
      expect(result.savings, (result.oldRegimeTax - result.newRegimeTax).abs());
    });

    test('includes surcharge and cess in totals', () {
      // High income to trigger surcharge
      final data = _makeForm(grossSalary: 6000000);
      final result = TaxComputationEngine.compare(data);

      final expectedOldTotal =
          result.oldRegimeTaxBeforeCess +
          result.oldRegimeSurcharge +
          result.oldRegimeCess;
      expect(result.oldRegimeTax, closeTo(expectedOldTotal, 0.01));

      final expectedNewTotal =
          result.newRegimeTaxBeforeCess +
          result.newRegimeSurcharge +
          result.newRegimeCess;
      expect(result.newRegimeTax, closeTo(expectedNewTotal, 0.01));
    });
  });
}

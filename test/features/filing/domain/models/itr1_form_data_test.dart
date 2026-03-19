import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';

void main() {
  group('Itr1FormData — computed properties', () {
    test('empty form → negative gross (std deduction on zero salary)', () {
      final form = Itr1FormData.empty();
      // Empty salary has ₹75k standard deduction, so netSalary = -75000
      expect(form.grossTotalIncome, -75000);
      // But taxableIncome is floored at zero
      expect(form.taxableIncome, 0);
      expect(form.allowableDeductions, 0);
    });

    test('grossTotalIncome = salary + HP + other sources', () {
      final form = Itr1FormData.empty().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 1000000),
        housePropertyIncome: const HousePropertyIncome(
          annualLetableValue: 200000,
          municipalTaxesPaid: 20000,
          interestOnLoan: 50000,
        ),
        otherSourceIncome: OtherSourceIncome.empty().copyWith(
          savingsAccountInterest: 30000,
        ),
      );
      const expectedSalary = 1000000 - 75000; // gross - std ded
      const expectedHP = (200000 - 20000) - ((200000 - 20000) * 0.30) - 50000;
      const expectedOther = 30000.0;
      expect(
        form.grossTotalIncome,
        closeTo(expectedSalary + expectedHP + expectedOther, 0.01),
      );
    });

    test('new regime → zero allowable deductions', () {
      final form = Itr1FormData.empty().copyWith(
        selectedRegime: TaxRegime.newRegime,
        deductions: ChapterViaDeductions.empty().copyWith(
          section80C: 150000,
          section80CCD1B: 50000,
        ),
      );
      expect(form.allowableDeductions, 0);
    });

    test('old regime → full Chapter VI-A deductions', () {
      final form = Itr1FormData.empty().copyWith(
        selectedRegime: TaxRegime.oldRegime,
        deductions: ChapterViaDeductions.empty().copyWith(
          section80C: 150000,
          section80CCD1B: 50000,
        ),
      );
      expect(form.allowableDeductions, 200000);
    });

    test('taxableIncome floored at zero', () {
      final form = Itr1FormData.empty().copyWith(
        selectedRegime: TaxRegime.oldRegime,
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 100000),
        deductions: ChapterViaDeductions.empty().copyWith(section80C: 150000),
      );
      expect(form.taxableIncome, 0);
    });

    test('taxableIncome = gross - deductions (old regime)', () {
      final form = Itr1FormData.empty().copyWith(
        selectedRegime: TaxRegime.oldRegime,
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 1000000),
        deductions: ChapterViaDeductions.empty().copyWith(section80C: 150000),
      );
      // Salary: 1M - 75k std ded = 925k gross total
      // Deductions: 150k → taxable = 775k
      expect(form.taxableIncome, closeTo(775000, 0.01));
    });
  });

  group('Itr1FormData — copyWith', () {
    test('returns new instance with updated field', () {
      final form = Itr1FormData.empty();
      final updated = form.copyWith(selectedRegime: TaxRegime.oldRegime);
      expect(updated.selectedRegime, TaxRegime.oldRegime);
      expect(form.selectedRegime, TaxRegime.newRegime); // original unchanged
    });
  });

  group('Itr1FormData — equality', () {
    test('identical forms are equal', () {
      final a = Itr1FormData.empty();
      final b = Itr1FormData.empty();
      expect(a, equals(b));
    });

    test('different forms are not equal', () {
      final a = Itr1FormData.empty();
      final b = a.copyWith(selectedRegime: TaxRegime.oldRegime);
      expect(a, isNot(equals(b)));
    });
  });
}

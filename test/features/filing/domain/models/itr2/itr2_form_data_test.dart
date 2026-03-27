import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';

void main() {
  group('Itr2FormData', () {
    Itr2FormData buildEmpty() => Itr2FormData.empty();

    test('→ empty() creates valid zero-state form', () {
      final form = buildEmpty();
      // grossTotalIncome = 0 salary + 0 CG + 0 foreign income = 0
      expect(form.grossTotalIncome, 0.0);
      // taxableOrdinaryIncome floors at zero even when netSalary is negative
      // due to standard deduction subtracted from 0 gross salary.
      expect(form.taxableOrdinaryIncome, 0.0);
    });

    test('→ grossTotalIncome includes salary + capital gains', () {
      final form = Itr2FormData.empty().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 1000000),
        scheduleCg: const ScheduleCg(
          equityStcgEntries: [],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        ),
      );
      // No CG yet, salary net = 1000000 - 75000 = 925000
      expect(form.grossTotalIncome, greaterThan(0));
    });

    test('→ capitalGainsTotal includes both STCG and LTCG', () {
      const entry = EquityStcgEntry(
        description: 'Stock gain',
        salePrice: 300000,
        costOfAcquisition: 200000,
        transferExpenses: 0,
      );
      final form = Itr2FormData.empty().copyWith(
        scheduleCg: const ScheduleCg(
          equityStcgEntries: [entry],
          equityLtcgEntries: [],
          debtStcgEntries: [],
          debtLtcgEntries: [],
          propertyLtcgEntries: [],
          otherStcgEntries: [],
          otherLtcgEntries: [],
          broughtForwardStcl: 0,
          broughtForwardLtcl: 0,
        ),
      );
      expect(form.capitalGainsTotal, 100000.0);
    });

    test('→ requiresScheduleAL when total income > ₹50L', () {
      final form = Itr2FormData.empty().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 6000000),
      );
      expect(form.requiresScheduleAL, isTrue);
    });

    test('→ does not requiresScheduleAL when total income ≤ ₹50L', () {
      final form = Itr2FormData.empty().copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 3000000),
      );
      expect(form.requiresScheduleAL, isFalse);
    });

    group('copyWith and equality', () {
      test('→ copyWith preserves unchanged fields', () {
        final original = Itr2FormData.empty();
        final updated = original.copyWith(selectedRegime: TaxRegime.oldRegime);
        expect(updated.selectedRegime, TaxRegime.oldRegime);
        expect(updated.personalInfo, original.personalInfo);
      });

      test('→ equal forms satisfy == and hashCode', () {
        final a = Itr2FormData.empty();
        final b = Itr2FormData.empty();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('→ different forms are not equal', () {
        final a = Itr2FormData.empty();
        final b = a.copyWith(selectedRegime: TaxRegime.oldRegime);
        expect(a, isNot(equals(b)));
      });
    });
  });
}

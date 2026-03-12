import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';
import 'package:ca_app/features/filing/domain/models/itr4/goods_carriage_income_44ae.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Itr4FormData — computed properties', () {
    test('totalPresumptiveIncome sums all three heads', () {
      final form = Itr4FormData.empty().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty().copyWith(
          cashTurnover: 1000000,
          nonCashTurnover: 2000000,
        ),
        professionIncome44ADA: ProfessionIncome44ADA.empty().copyWith(
          grossReceipts: 500000,
        ),
        goodsCarriageIncome44AE: const GoodsCarriageIncome44AE(
          numberOfVehicles: 2,
          monthsOperatedPerVehicle: [12, 6],
        ),
      );
      // 44AD: 2000000*0.06 + 1000000*0.08 = 120000 + 80000 = 200000
      // 44ADA: 500000*0.50 = 250000
      // 44AE: 7500*12 + 7500*6 = 90000 + 45000 = 135000
      expect(form.totalPresumptiveIncome, 200000 + 250000 + 135000);
    });

    test('grossTotalIncome includes presumptive + other sources', () {
      final form = Itr4FormData.empty().copyWith(
        businessIncome44AD: BusinessIncome44AD.empty().copyWith(
          cashTurnover: 500000,
        ),
        otherSourceIncome: OtherSourceIncome.empty().copyWith(
          savingsAccountInterest: 10000,
          fixedDepositInterest: 20000,
        ),
      );
      // Presumptive: 500000*0.08 = 40000, Other: 30000
      expect(form.grossTotalIncome, 40000 + 30000);
    });

    test('allowableDeductions returns 0 under new regime', () {
      final form = Itr4FormData.empty().copyWith(
        selectedRegime: TaxRegime.newRegime,
        deductions: ChapterViaDeductions.empty().copyWith(section80C: 150000),
      );
      expect(form.allowableDeductions, 0);
    });

    test('allowableDeductions returns totalDeductions under old regime', () {
      final form = Itr4FormData.empty().copyWith(
        selectedRegime: TaxRegime.oldRegime,
        deductions: ChapterViaDeductions.empty().copyWith(section80C: 100000),
      );
      expect(form.allowableDeductions, 100000);
    });

    test('taxableIncome is grossTotalIncome minus allowableDeductions', () {
      final form = Itr4FormData.empty().copyWith(
        selectedRegime: TaxRegime.oldRegime,
        businessIncome44AD: BusinessIncome44AD.empty().copyWith(
          cashTurnover: 5000000,
        ),
        deductions: ChapterViaDeductions.empty().copyWith(section80C: 150000),
      );
      // Presumptive: 5000000*0.08 = 400000, Deductions: 150000
      expect(form.taxableIncome, 400000 - 150000);
    });

    test('taxableIncome floors at zero when deductions exceed income', () {
      final form = Itr4FormData.empty().copyWith(
        selectedRegime: TaxRegime.oldRegime,
        businessIncome44AD: BusinessIncome44AD.empty().copyWith(
          cashTurnover: 100000,
        ),
        deductions: ChapterViaDeductions.empty().copyWith(section80C: 150000),
      );
      // Presumptive: 100000*0.08 = 8000, Deductions: 150000 → floor 0
      expect(form.taxableIncome, 0);
    });
  });

  group('Itr4FormData — copyWith immutability', () {
    test('copyWith returns a new instance, original unchanged', () {
      final original = Itr4FormData.empty();
      final modified = original.copyWith(selectedRegime: TaxRegime.oldRegime);
      expect(original.selectedRegime, TaxRegime.newRegime);
      expect(modified.selectedRegime, TaxRegime.oldRegime);
      expect(identical(original, modified), isFalse);
    });
  });

  group('Itr4FormData — equality', () {
    test('two empty forms are equal', () {
      expect(Itr4FormData.empty(), equals(Itr4FormData.empty()));
    });

    test('forms with different regimes are not equal', () {
      final a = Itr4FormData.empty();
      final b = a.copyWith(selectedRegime: TaxRegime.oldRegime);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      final a = Itr4FormData.empty();
      final b = Itr4FormData.empty();
      expect(a.hashCode, b.hashCode);
    });
  });
}

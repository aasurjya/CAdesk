import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr4/business_income_44ad.dart';
import 'package:ca_app/features/filing/domain/models/itr4/goods_carriage_income_44ae.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/profession_income_44ada.dart';
import 'package:ca_app/features/filing/domain/services/itr4_tax_computation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to build an [Itr4FormData] with only the fields under test.
Itr4FormData _makeForm({
  double cashTurnover = 0,
  double nonCashTurnover = 0,
  double grossReceipts = 0,
  int numberOfVehicles = 0,
  List<int> monthsPerVehicle = const [],
  double otherIncome = 0,
  double deductions80C = 0,
  TaxRegime regime = TaxRegime.newRegime,
}) {
  return Itr4FormData.empty().copyWith(
    businessIncome44AD: BusinessIncome44AD.empty().copyWith(
      cashTurnover: cashTurnover,
      nonCashTurnover: nonCashTurnover,
    ),
    professionIncome44ADA: ProfessionIncome44ADA.empty().copyWith(
      grossReceipts: grossReceipts,
    ),
    goodsCarriageIncome44AE: GoodsCarriageIncome44AE(
      numberOfVehicles: numberOfVehicles,
      monthsOperatedPerVehicle: monthsPerVehicle,
    ),
    otherSourceIncome: OtherSourceIncome.empty().copyWith(
      otherIncome: otherIncome,
    ),
    deductions: ChapterViaDeductions.empty().copyWith(
      section80C: deductions80C,
    ),
    selectedRegime: regime,
  );
}

void main() {
  group('Itr4TaxComputationEngine — New Regime', () {
    test('zero income produces zero tax', () {
      final data = _makeForm();
      expect(Itr4TaxComputationEngine.computeNewRegimeTax(data), 0);
    });

    test('presumptive income within rebate 87A (<=12L) produces zero tax', () {
      // nonCashTurnover: 20_000_000 => presumptive = 20M * 0.06 = 1_200_000
      final data = _makeForm(nonCashTurnover: 20000000);
      expect(Itr4TaxComputationEngine.computeNewRegimeTax(data), 0);
    });

    test('income just above 12L rebate boundary produces positive tax', () {
      // nonCashTurnover: 20_000_017 => presumptive = 1_200_001.02
      final data = _makeForm(nonCashTurnover: 20000017);
      expect(
        Itr4TaxComputationEngine.computeNewRegimeTax(data),
        greaterThan(0),
      );
    });

    test('income 16L computes correct new regime slabs', () {
      // Need taxable = 16,00,000
      // Use cashTurnover: 16_00_000 / 0.08 = 20_000_000
      final data = _makeForm(cashTurnover: 20000000);
      // Taxable = 20M * 0.08 = 1_600_000
      // 0-4L: 0, 4-8L: 20k, 8-12L: 40k, 12-16L: 60k = 1,20,000
      expect(Itr4TaxComputationEngine.computeNewRegimeTax(data), 120000);
    });

    test('income 25L computes all slabs including 30%', () {
      // Taxable = 25,00,000 via cashTurnover = 25L/0.08 = 31_250_000
      final data = _makeForm(cashTurnover: 31250000);
      // 0-4L:0, 4-8L:20k, 8-12L:40k, 12-16L:60k, 16-20L:80k, 20-24L:100k, 24-25L:30k = 3,30,000
      expect(Itr4TaxComputationEngine.computeNewRegimeTax(data), 330000);
    });

    test('new regime ignores Chapter VI-A deductions', () {
      final withDed = _makeForm(cashTurnover: 20000000, deductions80C: 150000);
      final noDed = _makeForm(cashTurnover: 20000000);
      expect(
        Itr4TaxComputationEngine.computeNewRegimeTax(withDed),
        Itr4TaxComputationEngine.computeNewRegimeTax(noDed),
      );
    });
  });

  group('Itr4TaxComputationEngine — Old Regime', () {
    test('zero income produces zero tax', () {
      final data = _makeForm();
      expect(Itr4TaxComputationEngine.computeOldRegimeTax(data), 0);
    });

    test('income <=5L produces zero tax (rebate 87A)', () {
      // cashTurnover: 5_00_000 / 0.08 = 6_250_000 => taxable 500000
      final data = _makeForm(cashTurnover: 6250000);
      expect(Itr4TaxComputationEngine.computeOldRegimeTax(data), 0);
    });

    test('income 10L computes correct old regime slabs', () {
      // cashTurnover: 10L / 0.08 = 12_500_000 => taxable = 1_000_000
      final data = _makeForm(cashTurnover: 12500000);
      // 0-2.5L:0, 2.5-5L:12500, 5-10L:100000 = 112500
      expect(Itr4TaxComputationEngine.computeOldRegimeTax(data), 112500);
    });

    test('old regime respects Chapter VI-A deductions', () {
      // cashTurnover => taxable = 15L before deductions, 13.5L after
      final data = _makeForm(
        cashTurnover: 187500000 / 10, // 18_750_000 => 1_500_000
        deductions80C: 150000,
      );
      // Taxable: 1_500_000 - 150_000 = 1_350_000
      // 0-2.5L:0, 2.5-5L:12500, 5-10L:100000, 10-13.5L:105000 = 217500
      expect(Itr4TaxComputationEngine.computeOldRegimeTax(data), 217500);
    });
  });

  group('Itr4TaxComputationEngine — compare()', () {
    test('returns valid TaxRegimeResult with all fields', () {
      final data = _makeForm(cashTurnover: 12500000);
      final result = Itr4TaxComputationEngine.compare(data);

      expect(result.oldRegimeTaxableIncome, greaterThan(0));
      expect(result.newRegimeTaxableIncome, greaterThan(0));
      expect(
        result.recommendedRegime,
        anyOf(TaxRegime.oldRegime, TaxRegime.newRegime),
      );
      expect(result.savings, greaterThanOrEqualTo(0));
    });

    test('savings equals absolute difference of totals', () {
      final data = _makeForm(cashTurnover: 20000000, deductions80C: 150000);
      final result = Itr4TaxComputationEngine.compare(data);
      expect(result.savings, (result.oldRegimeTax - result.newRegimeTax).abs());
    });

    test('includes surcharge and cess in totals', () {
      // High income to trigger surcharge: taxable ~5_000_000
      final data = _makeForm(cashTurnover: 62500000);
      final result = Itr4TaxComputationEngine.compare(data);

      final expectedOld =
          result.oldRegimeTaxBeforeCess +
          result.oldRegimeSurcharge +
          result.oldRegimeCess;
      expect(result.oldRegimeTax, closeTo(expectedOld, 0.01));

      final expectedNew =
          result.newRegimeTaxBeforeCess +
          result.newRegimeSurcharge +
          result.newRegimeCess;
      expect(result.newRegimeTax, closeTo(expectedNew, 0.01));
    });

    test('recommends regime with lower tax', () {
      final data = _makeForm(cashTurnover: 12500000);
      final result = Itr4TaxComputationEngine.compare(data);
      if (result.newRegimeTax <= result.oldRegimeTax) {
        expect(result.recommendedRegime, TaxRegime.newRegime);
      } else {
        expect(result.recommendedRegime, TaxRegime.oldRegime);
      }
    });
  });
}

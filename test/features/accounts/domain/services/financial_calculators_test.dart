import 'package:ca_app/features/accounts/domain/services/financial_calculators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialRatioCalculator', () {
    group('currentRatio', () {
      test('divides current assets by current liabilities', () {
        final result = FinancialRatioCalculator.currentRatio(300000, 100000);
        expect(result, closeTo(3.0, 0.001));
      });

      test('returns 0 when current liabilities are zero', () {
        final result = FinancialRatioCalculator.currentRatio(100000, 0);
        expect(result, 0.0);
      });

      test('returns less than 1 when assets < liabilities', () {
        final result = FinancialRatioCalculator.currentRatio(50000, 100000);
        expect(result, closeTo(0.5, 0.001));
      });
    });

    group('quickRatio', () {
      test('excludes inventory from current assets', () {
        // (300000 - 60000) / 100000 = 2.4
        final result = FinancialRatioCalculator.quickRatio(300000, 60000, 100000);
        expect(result, closeTo(2.4, 0.001));
      });

      test('returns 0 when current liabilities are zero', () {
        final result = FinancialRatioCalculator.quickRatio(300000, 60000, 0);
        expect(result, 0.0);
      });

      test('returns 0 when no inventory', () {
        final result = FinancialRatioCalculator.quickRatio(200000, 0, 200000);
        expect(result, closeTo(1.0, 0.001));
      });
    });

    group('grossMarginPercent', () {
      test('computes (revenue - cogs) / revenue * 100', () {
        // (1000000 - 600000) / 1000000 * 100 = 40%
        final result = FinancialRatioCalculator.grossMarginPercent(1000000, 600000);
        expect(result, closeTo(40.0, 0.001));
      });

      test('returns 0 when revenue is zero', () {
        final result = FinancialRatioCalculator.grossMarginPercent(0, 0);
        expect(result, 0.0);
      });

      test('returns 100% when COGS is zero', () {
        final result = FinancialRatioCalculator.grossMarginPercent(1000000, 0);
        expect(result, closeTo(100.0, 0.001));
      });

      test('returns negative margin when COGS exceeds revenue', () {
        final result = FinancialRatioCalculator.grossMarginPercent(500000, 700000);
        expect(result, closeTo(-40.0, 0.001));
      });
    });

    group('netMarginPercent', () {
      test('computes net profit / revenue * 100', () {
        // 150000 / 1000000 * 100 = 15%
        final result = FinancialRatioCalculator.netMarginPercent(1000000, 150000);
        expect(result, closeTo(15.0, 0.001));
      });

      test('returns 0 when revenue is zero', () {
        final result = FinancialRatioCalculator.netMarginPercent(0, 0);
        expect(result, 0.0);
      });

      test('returns negative margin on loss', () {
        final result = FinancialRatioCalculator.netMarginPercent(1000000, -50000);
        expect(result, closeTo(-5.0, 0.001));
      });
    });

    group('ebitdaMarginPercent', () {
      test('computes ebitda / revenue * 100', () {
        final result = FinancialRatioCalculator.ebitdaMarginPercent(1000000, 250000);
        expect(result, closeTo(25.0, 0.001));
      });

      test('returns 0 when revenue is zero', () {
        final result = FinancialRatioCalculator.ebitdaMarginPercent(0, 100000);
        expect(result, 0.0);
      });
    });

    group('returnOnEquity', () {
      test('computes net profit / equity * 100', () {
        // 200000 / 1000000 * 100 = 20%
        final result = FinancialRatioCalculator.returnOnEquity(200000, 1000000);
        expect(result, closeTo(20.0, 0.001));
      });

      test('returns 0 when equity is zero', () {
        final result = FinancialRatioCalculator.returnOnEquity(200000, 0);
        expect(result, 0.0);
      });

      test('returns negative ROE on loss', () {
        final result = FinancialRatioCalculator.returnOnEquity(-100000, 500000);
        expect(result, closeTo(-20.0, 0.001));
      });
    });

    group('returnOnAssets', () {
      test('computes net profit / total assets * 100', () {
        // 300000 / 3000000 * 100 = 10%
        final result = FinancialRatioCalculator.returnOnAssets(300000, 3000000);
        expect(result, closeTo(10.0, 0.001));
      });

      test('returns 0 when total assets are zero', () {
        final result = FinancialRatioCalculator.returnOnAssets(100000, 0);
        expect(result, 0.0);
      });
    });

    group('debtToEquity', () {
      test('computes total debt / equity', () {
        final result = FinancialRatioCalculator.debtToEquity(400000, 1000000);
        expect(result, closeTo(0.4, 0.001));
      });

      test('returns 0 when equity is zero', () {
        final result = FinancialRatioCalculator.debtToEquity(400000, 0);
        expect(result, 0.0);
      });

      test('returns high ratio for highly leveraged entity', () {
        final result = FinancialRatioCalculator.debtToEquity(5000000, 500000);
        expect(result, closeTo(10.0, 0.001));
      });
    });

    group('interestCoverageRatio', () {
      test('computes EBIT / interest expense', () {
        // 500000 / 100000 = 5
        final result = FinancialRatioCalculator.interestCoverageRatio(500000, 100000);
        expect(result, closeTo(5.0, 0.001));
      });

      test('returns infinity when interest expense is zero', () {
        final result = FinancialRatioCalculator.interestCoverageRatio(500000, 0);
        expect(result, double.infinity);
      });

      test('returns negative when EBIT is negative (cannot service debt)', () {
        final result = FinancialRatioCalculator.interestCoverageRatio(-100000, 50000);
        expect(result, closeTo(-2.0, 0.001));
      });
    });

    group('debtorDays', () {
      test('computes trade receivables / revenue * 365', () {
        // 365000 / 3650000 * 365 = 36.5 days
        final result = FinancialRatioCalculator.debtorDays(365000, 3650000);
        expect(result, closeTo(36.5, 0.01));
      });

      test('returns 0 when revenue is zero', () {
        final result = FinancialRatioCalculator.debtorDays(100000, 0);
        expect(result, 0.0);
      });
    });

    group('creditorDays', () {
      test('computes trade payables / COGS * 365', () {
        final result = FinancialRatioCalculator.creditorDays(100000, 1000000);
        expect(result, closeTo(36.5, 0.01));
      });

      test('returns 0 when COGS is zero', () {
        final result = FinancialRatioCalculator.creditorDays(100000, 0);
        expect(result, 0.0);
      });
    });

    group('inventoryDays', () {
      test('computes inventory / COGS * 365', () {
        final result = FinancialRatioCalculator.inventoryDays(200000, 2000000);
        expect(result, closeTo(36.5, 0.01));
      });

      test('returns 0 when COGS is zero', () {
        final result = FinancialRatioCalculator.inventoryDays(200000, 0);
        expect(result, 0.0);
      });
    });
  });

  group('DepreciationCalculator', () {
    group('rates map', () {
      test('contains standard IT Act asset blocks', () {
        expect(DepreciationCalculator.rates, containsPair('Computers & Software', 40.0));
        expect(DepreciationCalculator.rates, containsPair('Buildings (Residential)', 5.0));
        expect(DepreciationCalculator.rates, containsPair('Plant & Machinery (General)', 15.0));
        expect(DepreciationCalculator.rates, containsPair('Furniture & Fittings', 10.0));
        expect(DepreciationCalculator.rates, containsPair('Motor Vehicles (Heavy)', 30.0));
        expect(DepreciationCalculator.rates, containsPair('Intangibles (Patents/Know-how)', 25.0));
      });

      test('has 9 asset blocks', () {
        expect(DepreciationCalculator.rates.length, 9);
      });
    });

    group('annualDepreciation', () {
      test('full-year addition: depreciation on opening + full addition', () {
        // (1000000 + 200000 - 0) * 15% = 180000
        final dep = DepreciationCalculator.annualDepreciation(
          openingWdv: 1000000,
          additionsDuringYear: 200000,
          disposalsDuringYear: 0,
          ratePercent: 15.0,
          isAdditionAfterOct3: false,
        );
        expect(dep, closeTo(180000.0, 0.01));
      });

      test('half-year convention: addition after Oct 3 is halved', () {
        // (1000000 + 200000/2 - 0) * 15% = (1000000 + 100000) * 15% = 165000
        final dep = DepreciationCalculator.annualDepreciation(
          openingWdv: 1000000,
          additionsDuringYear: 200000,
          disposalsDuringYear: 0,
          ratePercent: 15.0,
          isAdditionAfterOct3: true,
        );
        expect(dep, closeTo(165000.0, 0.01));
      });

      test('disposal reduces net block before applying rate', () {
        // (1000000 + 0 - 300000) * 15% = 700000 * 15% = 105000
        final dep = DepreciationCalculator.annualDepreciation(
          openingWdv: 1000000,
          additionsDuringYear: 0,
          disposalsDuringYear: 300000,
          ratePercent: 15.0,
          isAdditionAfterOct3: false,
        );
        expect(dep, closeTo(105000.0, 0.01));
      });

      test('returns 0 when net block is zero or negative', () {
        final dep = DepreciationCalculator.annualDepreciation(
          openingWdv: 200000,
          additionsDuringYear: 0,
          disposalsDuringYear: 200000,
          ratePercent: 15.0,
          isAdditionAfterOct3: false,
        );
        expect(dep, 0.0);
      });

      test('40% rate for computers', () {
        // 500000 * 40% = 200000
        final dep = DepreciationCalculator.annualDepreciation(
          openingWdv: 500000,
          additionsDuringYear: 0,
          disposalsDuringYear: 0,
          ratePercent: 40.0,
          isAdditionAfterOct3: false,
        );
        expect(dep, closeTo(200000.0, 0.01));
      });
    });

    group('closingWdv', () {
      test('computes opening + additions - disposals - depreciation', () {
        // 1000000 + 200000 - 50000 - 180000 = 970000
        final closing = DepreciationCalculator.closingWdv(
          openingWdv: 1000000,
          additions: 200000,
          disposals: 50000,
          depreciation: 180000,
        );
        expect(closing, closeTo(970000.0, 0.01));
      });

      test('is clamped at zero — never negative', () {
        final closing = DepreciationCalculator.closingWdv(
          openingWdv: 100000,
          additions: 0,
          disposals: 200000,
          depreciation: 50000,
        );
        expect(closing, 0.0);
      });

      test('equals opening when no change', () {
        final closing = DepreciationCalculator.closingWdv(
          openingWdv: 500000,
          additions: 0,
          disposals: 0,
          depreciation: 0,
        );
        expect(closing, 500000.0);
      });
    });
  });
}

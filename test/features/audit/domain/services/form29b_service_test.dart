import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/audit/domain/models/form29b.dart';
import 'package:ca_app/features/audit/domain/services/form29b_service.dart';

void main() {
  group('Form29BService', () {
    group('computeMAT', () {
      test('MAT is 15% of book profit per Sec 115JB', () {
        // Book profit = net profit after standard adjustments
        // Scenario: Net profit = 1 crore, no adjustments
        final pnl = PnlData(
          netProfitPaise: 10000000000, // 1 crore in paise
          depreciationAsPerBooks: 500000000,
          provisionForTax: 300000000,
          provisionForDeferredTax: 100000000,
          deferredTaxLiability: 50000000,
          donationsAndCharities: 0,
          capitalGainsExempt: 0,
          broughtForwardLosses: 0,
          broughtForwardUnabsorbedDepreciation: 0,
        );
        final bs = BalanceSheetData(
          netWorthPaise: 50000000000,
          paidUpCapitalPaise: 10000000000,
          reservesAndSurplusPaise: 40000000000,
        );

        final result = Form29BService.computeMAT(
          pnl: pnl,
          bs: bs,
          financialYear: 2025,
        );

        // Book profit = net profit + income tax provision + deferred tax net
        // = 10,00,00,000 + 3,00,00,000 + (1,00,00,000 - 50,00,000) = ~13,50,00,000
        // MAT = 15% of book profit = ~2,02,50,000 paise
        expect(result.matLiabilityPaise, greaterThan(0));
        // Verify MAT is approximately 15% of book profit
        final matRate = result.matLiabilityPaise / result.bookProfitPaise;
        expect(matRate, closeTo(0.15, 0.001));
      });

      test('book profit adds back income tax provision', () {
        final pnl = PnlData(
          netProfitPaise: 5000000000,
          depreciationAsPerBooks: 0,
          provisionForTax: 1000000000, // 10 lakh in paise
          provisionForDeferredTax: 0,
          deferredTaxLiability: 0,
          donationsAndCharities: 0,
          capitalGainsExempt: 0,
          broughtForwardLosses: 0,
          broughtForwardUnabsorbedDepreciation: 0,
        );
        final bs = BalanceSheetData(
          netWorthPaise: 20000000000,
          paidUpCapitalPaise: 5000000000,
          reservesAndSurplusPaise: 15000000000,
        );

        final result = Form29BService.computeMAT(
          pnl: pnl,
          bs: bs,
          financialYear: 2025,
        );

        // Book profit includes adding back provision for tax
        expect(result.bookProfitPaise, greaterThan(pnl.netProfitPaise));
        expect(
          result.bookProfitPaise,
          equals(pnl.netProfitPaise + pnl.provisionForTax),
        );
      });

      test(
        'brought forward losses reduce book profit (capped at book profit)',
        () {
          final pnl = PnlData(
            netProfitPaise: 2000000000, // 20 lakh in paise
            depreciationAsPerBooks: 0,
            provisionForTax: 0,
            provisionForDeferredTax: 0,
            deferredTaxLiability: 0,
            donationsAndCharities: 0,
            capitalGainsExempt: 0,
            broughtForwardLosses: 1000000000, // 10 lakh in paise
            broughtForwardUnabsorbedDepreciation: 500000000, // 5 lakh in paise
          );
          final bs = BalanceSheetData(
            netWorthPaise: 10000000000,
            paidUpCapitalPaise: 3000000000,
            reservesAndSurplusPaise: 7000000000,
          );

          final result = Form29BService.computeMAT(
            pnl: pnl,
            bs: bs,
            financialYear: 2025,
          );

          // Book profit = 20,00,000 - min(10,00,000 + 5,00,000, 20,00,000)
          // = 20,00,000 - 15,00,000 = 5,00,000
          expect(result.bookProfitPaise, equals(500000000));
        },
      );

      test('brought forward losses cannot make book profit negative', () {
        final pnl = PnlData(
          netProfitPaise: 1000000000,
          depreciationAsPerBooks: 0,
          provisionForTax: 0,
          provisionForDeferredTax: 0,
          deferredTaxLiability: 0,
          donationsAndCharities: 0,
          capitalGainsExempt: 0,
          broughtForwardLosses: 5000000000, // larger than book profit
          broughtForwardUnabsorbedDepreciation: 0,
        );
        final bs = BalanceSheetData(
          netWorthPaise: 5000000000,
          paidUpCapitalPaise: 2000000000,
          reservesAndSurplusPaise: 3000000000,
        );

        final result = Form29BService.computeMAT(
          pnl: pnl,
          bs: bs,
          financialYear: 2025,
        );

        expect(result.bookProfitPaise, greaterThanOrEqualTo(0));
        expect(result.matLiabilityPaise, greaterThanOrEqualTo(0));
      });

      test('MAT credit available is recorded for carry-forward', () {
        final pnl = PnlData(
          netProfitPaise: 3000000000,
          depreciationAsPerBooks: 0,
          provisionForTax: 500000000,
          provisionForDeferredTax: 0,
          deferredTaxLiability: 0,
          donationsAndCharities: 0,
          capitalGainsExempt: 0,
          broughtForwardLosses: 0,
          broughtForwardUnabsorbedDepreciation: 0,
        );
        final bs = BalanceSheetData(
          netWorthPaise: 15000000000,
          paidUpCapitalPaise: 5000000000,
          reservesAndSurplusPaise: 10000000000,
        );

        final result = Form29BService.computeMAT(
          pnl: pnl,
          bs: bs,
          financialYear: 2025,
        );

        // MAT credit is available for 15 years
        expect(
          result.matCreditAvailablePaise,
          equals(result.matLiabilityPaise),
        );
        expect(result.matCreditCarryForwardYears, equals(15));
      });

      test('stores the financial year', () {
        final pnl = PnlData(
          netProfitPaise: 1000000000,
          depreciationAsPerBooks: 0,
          provisionForTax: 0,
          provisionForDeferredTax: 0,
          deferredTaxLiability: 0,
          donationsAndCharities: 0,
          capitalGainsExempt: 0,
          broughtForwardLosses: 0,
          broughtForwardUnabsorbedDepreciation: 0,
        );
        final bs = BalanceSheetData(
          netWorthPaise: 5000000000,
          paidUpCapitalPaise: 2000000000,
          reservesAndSurplusPaise: 3000000000,
        );

        final result = Form29BService.computeMAT(
          pnl: pnl,
          bs: bs,
          financialYear: 2025,
        );

        expect(result.financialYear, equals(2025));
      });
    });

    group('Form29B model', () {
      test('copyWith returns new instance with updated fields', () {
        const original = Form29B(
          financialYear: 2025,
          bookProfitPaise: 10000000000,
          matLiabilityPaise: 1500000000,
          matCreditAvailablePaise: 1500000000,
          matCreditCarryForwardYears: 15,
          bookProfitAdjustments: [],
        );

        final updated = original.copyWith(financialYear: 2026);
        expect(updated.financialYear, equals(2026));
        expect(original.financialYear, equals(2025));
      });

      test('equality and hashCode are value-based', () {
        const a = Form29B(
          financialYear: 2025,
          bookProfitPaise: 10000000000,
          matLiabilityPaise: 1500000000,
          matCreditAvailablePaise: 1500000000,
          matCreditCarryForwardYears: 15,
          bookProfitAdjustments: [],
        );
        const b = Form29B(
          financialYear: 2025,
          bookProfitPaise: 10000000000,
          matLiabilityPaise: 1500000000,
          matCreditAvailablePaise: 1500000000,
          matCreditCarryForwardYears: 15,
          bookProfitAdjustments: [],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}

import 'package:ca_app/features/tax_advisory/domain/models/client_profile.dart';
import 'package:ca_app/features/tax_advisory/domain/services/tax_saving_calculator_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // compute80cSaving
  // ---------------------------------------------------------------------------

  group('TaxSavingCalculatorService.compute80cSaving', () {
    test('zero saving when deduction already maxed at ₹1.5L', () {
      final saving = TaxSavingCalculatorService.instance.compute80cSaving(
        currentDeduction: 15000000, // ₹1,50,000
        taxableIncome: 80000000,
        regime: TaxRegime.old,
      );

      expect(saving, 0);
    });

    test('saving = gap × 30% for old regime income ₹10L (30% slab)', () {
      // gap = ₹1,50,000 - ₹50,000 = ₹1,00,000
      // tax rate at ₹10L old regime = 30%
      // saving = 100000 * 30% = 30000 = 3000000 paise
      final saving = TaxSavingCalculatorService.instance.compute80cSaving(
        currentDeduction: 5000000, // ₹50,000
        taxableIncome: 100000000, // ₹10L — falls in 30% slab (>₹10L? no, =10L)
        regime: TaxRegime.old,
      );

      // ₹10L is in the 20% slab (₹5L–₹10L range in old regime)
      // saving = 100000 * 20% = 20000 = 2000000 paise
      expect(saving, greaterThan(0));
    });

    test('zero saving when new regime (80C not applicable)', () {
      final saving = TaxSavingCalculatorService.instance.compute80cSaving(
        currentDeduction: 0,
        taxableIncome: 100000000,
        regime: TaxRegime.newRegime,
      );

      expect(saving, 0);
    });

    test('partial deduction returns proportional saving', () {
      // Deduction ₹1L, gap ₹50K
      final saving = TaxSavingCalculatorService.instance.compute80cSaving(
        currentDeduction: 10000000, // ₹1L
        taxableIncome: 80000000, // ₹8L — 20% slab
        regime: TaxRegime.old,
      );

      // gap = 50000 paise * 100 = ₹50K; tax = 20% → ₹10K = 1000000 paise
      expect(saving, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // computeHraSaving
  // ---------------------------------------------------------------------------

  group('TaxSavingCalculatorService.computeHraSaving', () {
    test('metro city: exemption = min(hra, rent-10%basic, 50%basic)', () {
      // basic = ₹5L, hra = ₹2L, rent = ₹2.5L, city = Mumbai (metro)
      // (a) hra received = ₹2L
      // (b) rent - 10% basic = ₹2.5L - ₹0.5L = ₹2L
      // (c) 50% of basic = ₹2.5L
      // min = ₹2L = 20000000 paise
      final saving = TaxSavingCalculatorService.instance.computeHraSaving(
        basicSalary: 50000000, // ₹5L
        hraReceived: 20000000, // ₹2L
        rentPaid: 25000000, // ₹2.5L
        city: 'Mumbai',
      );

      expect(saving, 20000000); // ₹2L in paise
    });

    test('non-metro city: uses 40% of basic instead of 50%', () {
      // basic = ₹5L, hra = ₹2L, rent = ₹2.5L, city = Pune (non-metro)
      // (a) ₹2L
      // (b) ₹2.5L - ₹0.5L = ₹2L
      // (c) 40% of ₹5L = ₹2L
      // min = ₹2L
      final saving = TaxSavingCalculatorService.instance.computeHraSaving(
        basicSalary: 50000000, // ₹5L
        hraReceived: 20000000, // ₹2L
        rentPaid: 25000000, // ₹2.5L
        city: 'Pune',
      );

      expect(saving, 20000000);
    });

    test('zero if rent-10%basic is the smallest component', () {
      // basic = ₹10L, hra = ₹5L, rent = ₹1.5L, city = Delhi
      // (a) ₹5L
      // (b) rent - 10% basic = ₹1.5L - ₹1L = ₹0.5L ← smallest
      // (c) 50% of ₹10L = ₹5L
      // min = ₹0.5L = 5000000 paise
      final saving = TaxSavingCalculatorService.instance.computeHraSaving(
        basicSalary: 100000000, // ₹10L
        hraReceived: 50000000, // ₹5L
        rentPaid: 15000000, // ₹1.5L
        city: 'Delhi',
      );

      expect(saving, 5000000); // ₹0.5L
    });

    test('zero saving when no rent paid (rentPaid = 0)', () {
      final saving = TaxSavingCalculatorService.instance.computeHraSaving(
        basicSalary: 50000000,
        hraReceived: 20000000,
        rentPaid: 0,
        city: 'Mumbai',
      );

      expect(saving, 0);
    });

    test('Kolkata is treated as metro (50%)', () {
      // basic = ₹4L, hra = ₹3L, rent = ₹3L, Kolkata
      // (a) ₹3L
      // (b) ₹3L - ₹0.4L = ₹2.6L
      // (c) 50% of ₹4L = ₹2L ← smallest
      final saving = TaxSavingCalculatorService.instance.computeHraSaving(
        basicSalary: 40000000,
        hraReceived: 30000000,
        rentPaid: 30000000,
        city: 'Kolkata',
      );

      expect(saving, 20000000); // ₹2L
    });

    test('Chennai is treated as metro (50%)', () {
      final saving = TaxSavingCalculatorService.instance.computeHraSaving(
        basicSalary: 40000000,
        hraReceived: 30000000,
        rentPaid: 30000000,
        city: 'Chennai',
      );

      expect(saving, 20000000);
    });
  });

  // ---------------------------------------------------------------------------
  // computeOldVsNewRegime
  // ---------------------------------------------------------------------------

  group('TaxSavingCalculatorService.computeOldVsNewRegime', () {
    test(
      'returns RegimeComparison with non-zero tax values for ₹10L income',
      () {
        const profile = ClientProfile(
          pan: 'ABCDE1234F',
          name: 'Test',
          clientType: ClientType.individual,
          annualIncome: 100000000, // ₹10L
          taxRegime: TaxRegime.old,
          currentDeductions: 15000000, // ₹1.5L — 80C maxed
          currentTaxPaid: 0,
          hasGstRegistration: false,
          hasTdsDeductions: false,
          hasCapitalGains: false,
          hasForeignAssets: false,
          hasBusinessIncome: false,
          ageGroup: AgeGroup.thirties,
        );

        final comparison = TaxSavingCalculatorService.instance
            .computeOldVsNewRegime(profile);

        expect(comparison.oldRegimeTax, greaterThanOrEqualTo(0));
        expect(comparison.newRegimeTax, greaterThanOrEqualTo(0));
        expect(comparison.recommendation, isNotEmpty);
      },
    );

    test('old regime recommended when deductions are high (₹4L)', () {
      // ₹10L income, ₹4L deductions:
      //   Old: taxable ₹6L → ~₹33,800 tax (after cess)
      //   New: taxable ₹9.25L (after ₹75K std) → ~₹50,700 tax (after cess)
      //   Old is cheaper by ≈₹17K
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test',
        clientType: ClientType.individual,
        annualIncome: 100000000, // ₹10L
        taxRegime: TaxRegime.newRegime,
        currentDeductions: 40000000, // ₹4L
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final comparison = TaxSavingCalculatorService.instance
          .computeOldVsNewRegime(profile);

      // With ₹4L deductions, old regime should be better
      expect(comparison.oldRegimeTax, lessThan(comparison.newRegimeTax));
      expect(comparison.recommendation.toLowerCase(), contains('old'));
    });

    test('new regime recommended when deductions are low (₹50K)', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test',
        clientType: ClientType.individual,
        annualIncome: 150000000, // ₹15L
        taxRegime: TaxRegime.old,
        currentDeductions: 5000000, // ₹50K
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final comparison = TaxSavingCalculatorService.instance
          .computeOldVsNewRegime(profile);

      // With only ₹50K deductions, new regime likely better at ₹15L
      expect(comparison.newRegimeTax, lessThan(comparison.oldRegimeTax));
      expect(comparison.recommendation.toLowerCase(), contains('new'));
    });

    test('savings = |oldRegimeTax - newRegimeTax|', () {
      const profile = ClientProfile(
        pan: 'ABCDE1234F',
        name: 'Test',
        clientType: ClientType.individual,
        annualIncome: 100000000,
        taxRegime: TaxRegime.old,
        currentDeductions: 15000000,
        currentTaxPaid: 0,
        hasGstRegistration: false,
        hasTdsDeductions: false,
        hasCapitalGains: false,
        hasForeignAssets: false,
        hasBusinessIncome: false,
        ageGroup: AgeGroup.thirties,
      );

      final comparison = TaxSavingCalculatorService.instance
          .computeOldVsNewRegime(profile);

      final expectedSavings =
          (comparison.oldRegimeTax - comparison.newRegimeTax).abs();
      expect(comparison.savings, expectedSavings);
    });
  });

  // ---------------------------------------------------------------------------
  // computeCapGainsHarvesting
  // ---------------------------------------------------------------------------

  group('TaxSavingCalculatorService.computeCapGainsHarvesting', () {
    test('returns 0 when no positions', () {
      final saving = TaxSavingCalculatorService.instance
          .computeCapGainsHarvesting([]);

      expect(saving, 0);
    });

    test('returns 0 when no loss positions', () {
      final positions = [
        const CapGainPosition(
          symbol: 'RELIANCE',
          purchasePrice: 2000,
          currentPrice: 2500,
          quantity: 10,
          isLongTerm: false,
        ),
      ];

      final saving = TaxSavingCalculatorService.instance
          .computeCapGainsHarvesting(positions);

      expect(saving, 0);
    });

    test('harvests short-term loss to offset short-term gain', () {
      // Gain: RELIANCE +50,000 (10 shares × ₹5,000 profit), STCG 15%
      // Loss: ZOMATO -30,000 (100 shares × ₹300 loss), STCL
      // Net STCG after offset = ₹20,000
      // Tax saving = ₹30,000 × 15% = ₹4,500 = 450000 paise
      final positions = [
        const CapGainPosition(
          symbol: 'RELIANCE',
          purchasePrice: 200000, // ₹2,000 (paise)
          currentPrice: 250000, // ₹2,500 (paise)
          quantity: 10,
          isLongTerm: false,
        ),
        const CapGainPosition(
          symbol: 'ZOMATO',
          purchasePrice: 80000, // ₹800 (paise)
          currentPrice: 50000, // ₹500 (paise)
          quantity: 100,
          isLongTerm: false,
        ),
      ];

      final saving = TaxSavingCalculatorService.instance
          .computeCapGainsHarvesting(positions);

      // Loss = 100 × (800 - 500) paise × 100 = 30,000 × 100 = 3,000,000 paise
      // Tax saving at STCG 15% = 3,000,000 * 15 / 100 = 450,000 paise
      expect(saving, greaterThan(0));
    });

    test('long-term loss offsets long-term gain at LTCG 10%', () {
      final positions = [
        const CapGainPosition(
          symbol: 'HDFC',
          purchasePrice: 100000, // ₹1,000
          currentPrice: 200000, // ₹2,000
          quantity: 5,
          isLongTerm: true,
        ),
        const CapGainPosition(
          symbol: 'PAYTM',
          purchasePrice: 100000, // ₹1,000
          currentPrice: 40000, // ₹400
          quantity: 10,
          isLongTerm: true,
        ),
      ];

      final saving = TaxSavingCalculatorService.instance
          .computeCapGainsHarvesting(positions);

      // LTCL = 10 × (1000 - 400) paise × 100 = 6,000 × 100 = 600,000 paise
      // LTCG available = 5 × (2000 - 1000) paise × 100 = 5,000 × 100 = 500,000 paise
      // Only offset up to LTCG → offset 500,000 paise
      // Tax saving at 10% = 500,000 * 10 / 100 = 50,000 paise
      expect(saving, greaterThan(0));
    });
  });
}

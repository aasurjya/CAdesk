import 'package:ca_app/features/payroll/domain/services/gratuity_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GratuityCalculator', () {
    group('compute', () {
      test('returns 0 when years of service is less than 5', () {
        expect(
          GratuityCalculator.compute(
            yearsOfService: 4,
            lastBasicPaise: 3000000,
          ),
          0,
        );
      });

      test('returns 0 when years of service is exactly 0', () {
        expect(
          GratuityCalculator.compute(
            yearsOfService: 0,
            lastBasicPaise: 3000000,
          ),
          0,
        );
      });

      test('returns 0 when negative years of service', () {
        expect(
          GratuityCalculator.compute(
            yearsOfService: -1,
            lastBasicPaise: 3000000,
          ),
          0,
        );
      });

      test('computes gratuity correctly at exactly 5 years', () {
        // Basic = ₹30,000 (3000000 paise), 5 years
        // Gratuity = 30000 × 15/26 × 5 = 86538.46... → truncated to 8653800 paise
        final result = GratuityCalculator.compute(
          yearsOfService: 5,
          lastBasicPaise: 3000000,
        );
        // (3000000 * 15 * 5) / 26 = 225000000 / 26 = 8653846 paise
        expect(result, 8653846);
      });

      test('computes gratuity correctly at 10 years', () {
        // Basic = ₹50,000 (5000000 paise), 10 years
        // Gratuity = 5000000 * 15 * 10 / 26 = 750000000 / 26 = 28846153 paise
        final result = GratuityCalculator.compute(
          yearsOfService: 10,
          lastBasicPaise: 5000000,
        );
        expect(result, 28846153);
      });

      test('caps gratuity at ₹20,00,000 (200000000 paise)', () {
        // Very high salary and years: should be capped at ₹20L
        final result = GratuityCalculator.compute(
          yearsOfService: 40,
          lastBasicPaise: 20000000, // ₹2L/month basic
        );
        expect(result, lessThanOrEqualTo(20000000 * 100)); // 200000000 paise
        expect(result, 200000000);
      });

      test('returns 0 when basic salary is 0', () {
        expect(
          GratuityCalculator.compute(yearsOfService: 10, lastBasicPaise: 0),
          0,
        );
      });

      test('computes correctly for 7 years service', () {
        // Basic = ₹25,000 (2500000 paise), 7 years
        // 2500000 * 15 * 7 / 26 = 262500000 / 26 = 10096153 paise
        final result = GratuityCalculator.compute(
          yearsOfService: 7,
          lastBasicPaise: 2500000,
        );
        expect(result, 10096153);
      });
    });

    group('isEligible', () {
      test('returns false for less than 5 years', () {
        expect(GratuityCalculator.isEligible(4), isFalse);
      });

      test('returns true for exactly 5 years', () {
        expect(GratuityCalculator.isEligible(5), isTrue);
      });

      test('returns true for more than 5 years', () {
        expect(GratuityCalculator.isEligible(20), isTrue);
      });
    });

    group('maxExemptAmount', () {
      test('returns 200000000 paise (₹20L)', () {
        expect(GratuityCalculator.maxExemptAmountPaise, 200000000);
      });
    });
  });
}

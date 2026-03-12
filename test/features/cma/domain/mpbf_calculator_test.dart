import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/cma/domain/models/cma_balance_sheet.dart';
import 'package:ca_app/features/cma/domain/services/mpbf_calculator.dart';

void main() {
  group('MpbfCalculator — Method 1 (Tandon)', () {
    // Method 1: MPBF = 75% × (CA - CL excl bank borrowings)
    test('computes method1 with positive working capital gap', () {
      // CA = 1,000,000 (₹10L), CL excl bank = 400,000 (₹4L)
      // WCG = 600,000, MPBF = 75% × 600,000 = 450,000
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 100000000, // 10L in paise
        currentLiabilitiesExclBank: 40000000, // 4L in paise
      );
      expect(MpbfCalculator.instance.computeMethod1(bs), 45000000);
    });

    test('returns zero when CL >= CA (no working capital gap)', () {
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 40000000,
        currentLiabilitiesExclBank: 40000000,
      );
      expect(MpbfCalculator.instance.computeMethod1(bs), 0);
    });

    test('returns zero when CL exceeds CA', () {
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 20000000,
        currentLiabilitiesExclBank: 40000000,
      );
      expect(MpbfCalculator.instance.computeMethod1(bs), 0);
    });

    test('rounds down to nearest paisa', () {
      // CA = 100, CL = 0 → WCG = 100, 75% × 100 = 75 (exact)
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 100,
        currentLiabilitiesExclBank: 0,
      );
      expect(MpbfCalculator.instance.computeMethod1(bs), 75);
    });
  });

  group('MpbfCalculator — Method 2 (Tandon)', () {
    // Method 2: MPBF = 75% × CA - CL excl bank
    test('computes method2 correctly', () {
      // CA = 1,000,000 (₹10L), CL = 400,000 (₹4L)
      // MPBF = 75% × 1,000,000 - 400,000 = 750,000 - 400,000 = 350,000
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 100000000,
        currentLiabilitiesExclBank: 40000000,
      );
      expect(MpbfCalculator.instance.computeMethod2(bs), 35000000);
    });

    test('returns zero when 75% CA <= CL', () {
      // 75% × CA = 75 < CL = 100
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 100,
        currentLiabilitiesExclBank: 100,
      );
      expect(MpbfCalculator.instance.computeMethod2(bs), 0);
    });

    test('method2 is always less than or equal to method1', () {
      // Method 1 ≥ Method 2 is a known Tandon property
      final bs = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 100000000,
        currentLiabilitiesExclBank: 40000000,
      );
      final m1 = MpbfCalculator.instance.computeMethod1(bs);
      final m2 = MpbfCalculator.instance.computeMethod2(bs);
      expect(m1, greaterThanOrEqualTo(m2));
    });
  });

  group('MpbfCalculator — Turnover Method (< ₹5 Cr)', () {
    // Turnover Method: MPBF = 20% of projected annual sales
    test('computes 20% of annual sales', () {
      // Sales = ₹5,00,00,000 (5 Cr) → MPBF = ₹1,00,00,000 (1 Cr)
      // In paise: 500000000_00 paise → 20% = 100000000_00
      final salesPaise = 50000000000; // ₹5Cr in paise
      expect(
        MpbfCalculator.instance.computeTurnoverMethod(salesPaise),
        10000000000,
      );
    });

    test('computes 20% for small amount', () {
      // Sales = ₹1,00,000 in paise = 10000000 paise
      // MPBF = 20% = 2000000 paise
      expect(MpbfCalculator.instance.computeTurnoverMethod(10000000), 2000000);
    });

    test('zero sales gives zero MPBF', () {
      expect(MpbfCalculator.instance.computeTurnoverMethod(0), 0);
    });
  });

  group('MpbfCalculator — Drawing Power', () {
    // DP = (Stock × 75%) + (Debtors × 75%) - Creditors
    test('computes drawing power with stock, debtors, creditors', () {
      // Stock = ₹10L, Debtors = ₹5L, Creditors = ₹2L
      // DP = (10L × 75%) + (5L × 75%) - 2L
      //    = 7.5L + 3.75L - 2L = 9.25L
      // In paise: 100000000 stock, 50000000 debtors, 20000000 creditors
      // DP = 75000000 + 37500000 - 20000000 = 92500000
      final dp = MpbfCalculator.instance.computeDrawingPower(
        100000000,
        50000000,
        20000000,
      );
      expect(dp, 92500000);
    });

    test('drawing power floored at zero when creditors exceed funded assets', () {
      final dp = MpbfCalculator.instance.computeDrawingPower(
        0,
        0,
        100000000,
      );
      expect(dp, 0);
    });

    test('zero stock and debtors gives zero DP before deducting creditors', () {
      final dp = MpbfCalculator.instance.computeDrawingPower(0, 0, 0);
      expect(dp, 0);
    });
  });

  group('MpbfCalculator — singleton', () {
    test('instance returns same object each time', () {
      expect(
        identical(MpbfCalculator.instance, MpbfCalculator.instance),
        isTrue,
      );
    });
  });
}

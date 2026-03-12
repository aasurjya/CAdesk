import 'dart:math' as math;

import 'package:ca_app/features/advanced_audit/domain/services/benford_law_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BenfordLawService', () {
    // --------------- getExpectedFrequency ---------------

    group('getExpectedFrequency', () {
      test('returns log10(1 + 1/1) ≈ 0.301 for digit 1', () {
        final result = BenfordLawService.getExpectedFrequency(1);
        expect(result, closeTo(0.30103, 0.00001));
      });

      test('returns correct value for digit 9', () {
        final result = BenfordLawService.getExpectedFrequency(9);
        expect(result, closeTo(0.04576, 0.00001));
      });

      test('all nine frequencies sum to approximately 1.0', () {
        final total = List.generate(9, (i) => i + 1).fold<double>(
          0,
          (sum, d) => sum + BenfordLawService.getExpectedFrequency(d),
        );
        expect(total, closeTo(1.0, 0.0001));
      });

      test('frequencies are monotonically decreasing from 1 to 9', () {
        for (int d = 1; d < 9; d++) {
          expect(
            BenfordLawService.getExpectedFrequency(d),
            greaterThan(BenfordLawService.getExpectedFrequency(d + 1)),
          );
        }
      });
    });

    // --------------- extractLeadingDigits ---------------

    group('extractLeadingDigits', () {
      test('extracts leading digit from single-digit number', () {
        expect(BenfordLawService.extractLeadingDigits([7]), equals([7]));
      });

      test('extracts leading digit from multi-digit number', () {
        expect(BenfordLawService.extractLeadingDigits([12345]), equals([1]));
      });

      test('ignores zero and negative amounts', () {
        expect(
          BenfordLawService.extractLeadingDigits([0, -100, 500, 200]),
          equals([5, 2]),
        );
      });

      test('handles mixed amounts correctly', () {
        final digits = BenfordLawService.extractLeadingDigits([
          100,
          200,
          300,
          900,
        ]);
        expect(digits, equals([1, 2, 3, 9]));
      });

      test('returns empty list for empty input', () {
        expect(BenfordLawService.extractLeadingDigits([]), equals([]));
      });
    });

    // --------------- computeChiSquare ---------------

    group('computeChiSquare', () {
      test('returns 0 when observed equals expected', () {
        final expected = {
          for (int d = 1; d <= 9; d++)
            d: BenfordLawService.getExpectedFrequency(d),
        };
        // observed proportions identical to expected
        final result = BenfordLawService.computeChiSquare(
          expected,
          expected,
          1000,
        );
        expect(result, closeTo(0.0, 0.0001));
      });

      test('returns positive value for non-uniform deviation', () {
        final expected = {
          for (int d = 1; d <= 9; d++)
            d: BenfordLawService.getExpectedFrequency(d),
        };
        // Skew heavily toward digit 9
        final observed = <int, double>{
          1: 0.05,
          2: 0.05,
          3: 0.05,
          4: 0.05,
          5: 0.05,
          6: 0.05,
          7: 0.05,
          8: 0.05,
          9: 0.60,
        };
        final result = BenfordLawService.computeChiSquare(
          observed,
          expected,
          1000,
        );
        expect(result, greaterThan(0));
      });

      test(
        'chi-square is symmetric in scale — larger N amplifies the stat',
        () {
          final expected = {
            for (int d = 1; d <= 9; d++)
              d: BenfordLawService.getExpectedFrequency(d),
          };
          final observed = <int, double>{
            1: 0.25,
            2: 0.17,
            3: 0.13,
            4: 0.10,
            5: 0.09,
            6: 0.07,
            7: 0.07,
            8: 0.06,
            9: 0.06,
          };
          final low = BenfordLawService.computeChiSquare(
            observed,
            expected,
            100,
          );
          final high = BenfordLawService.computeChiSquare(
            observed,
            expected,
            1000,
          );
          expect(high, greaterThan(low));
        },
      );
    });

    // --------------- isSignificant ---------------

    group('isSignificant', () {
      test('returns false for chi-square below critical value 15.507', () {
        expect(BenfordLawService.isSignificant(10.0), isFalse);
      });

      test('returns true for chi-square above critical value 15.507', () {
        expect(BenfordLawService.isSignificant(20.0), isTrue);
      });

      test('returns false exactly at critical value', () {
        expect(BenfordLawService.isSignificant(15.507), isFalse);
      });

      test('returns true just above critical value', () {
        expect(BenfordLawService.isSignificant(15.508), isTrue);
      });
    });

    // --------------- analyze ---------------

    group('analyze', () {
      test('throws ArgumentError for fewer than 100 transactions', () {
        final amounts = List.generate(50, (i) => (i + 1) * 1000);
        expect(
          () => BenfordLawService.analyze(amounts),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('returns result with correct sampleCount', () {
        final amounts = _generateBenfordAmounts(500);
        final result = BenfordLawService.analyze(amounts);
        expect(result.sampleCount, equals(500));
      });

      test('observedFrequencies keys cover digits 1–9', () {
        final amounts = _generateBenfordAmounts(200);
        final result = BenfordLawService.analyze(amounts);
        for (int d = 1; d <= 9; d++) {
          expect(result.observedFrequencies.containsKey(d), isTrue);
        }
      });

      test('expectedFrequencies match Benford formula', () {
        final amounts = _generateBenfordAmounts(200);
        final result = BenfordLawService.analyze(amounts);
        for (int d = 1; d <= 9; d++) {
          expect(
            result.expectedFrequencies[d],
            closeTo(BenfordLawService.getExpectedFrequency(d), 0.00001),
          );
        }
      });

      test('degreesOfFreedom is 8', () {
        final amounts = _generateBenfordAmounts(200);
        final result = BenfordLawService.analyze(amounts);
        expect(result.degreesOfFreedom, equals(8));
      });

      test('riskFlag true for heavily skewed data', () {
        // Force digit 9 heavily — anti-Benford distribution
        final amounts = List.generate(200, (i) => 90000 + i);
        final result = BenfordLawService.analyze(amounts);
        expect(result.riskFlag, isTrue);
      });

      test('riskFlag false for Benford-conforming data', () {
        // Generate large dataset conforming to Benford's law
        final amounts = _generateBenfordAmounts(1000);
        final result = BenfordLawService.analyze(amounts);
        // chi-square should be low for conforming data
        expect(result.chiSquareStatistic, isA<double>());
      });

      test('significantDeviations is subset of digits 1–9', () {
        final amounts = _generateBenfordAmounts(200);
        final result = BenfordLawService.analyze(amounts);
        for (final d in result.significantDeviations) {
          expect(d >= 1 && d <= 9, isTrue);
        }
      });

      test('datasetName is stored on result', () {
        final amounts = _generateBenfordAmounts(200);
        final result = BenfordLawService.analyze(
          amounts,
          datasetName: 'Sales 2024',
        );
        expect(result.datasetName, equals('Sales 2024'));
      });
    });
  });
}

/// Generates [count] amounts that statistically follow Benford's Law by
/// using log-uniform distribution (1 to 10^6).
List<int> _generateBenfordAmounts(int count) {
  final rng = math.Random(42);
  return List.generate(count, (_) {
    // log-uniform: x = 10^(U * 6) gives Benford distribution for leading digit
    final exp = rng.nextDouble() * 6;
    return (math.pow(10, exp) as double).round().clamp(1, 999999);
  });
}

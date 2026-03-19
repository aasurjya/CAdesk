import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/anomaly/benfords_law_engine.dart';

void main() {
  group('BenfordsLawEngine', () {
    late BenfordsLawEngine engine;

    setUp(() {
      engine = const BenfordsLawEngine();
    });

    group('analyze — return type and field ranges', () {
      test('returns BenfordsResult with conformanceScore in [0,100]', () {
        final result = engine.analyze([1, 1, 1, 2, 3, 4, 5, 6, 7]);

        expect(result.conformanceScore, inInclusiveRange(0.0, 100.0));
      });

      test('result has all required fields populated', () {
        final result = engine.analyze([1000, 2000, 3000]);

        expect(result.chiSquaredStatistic, isNonNegative);
        expect(result.observedFrequencies, isNotEmpty);
        expect(result.expectedFrequencies, isNotEmpty);
        expect(result.interpretation, isNotEmpty);
        expect(result.sampleSize, equals(3));
      });

      test('observedFrequencies has keys 1 through 9', () {
        final result = engine.analyze([1, 2, 3, 4, 5, 6, 7, 8, 9]);

        for (var d = 1; d <= 9; d++) {
          expect(
            result.observedFrequencies.containsKey(d),
            isTrue,
            reason: 'Missing key $d in observedFrequencies',
          );
        }
      });

      test('expectedFrequencies has keys 1 through 9', () {
        final result = engine.analyze([1, 2, 3, 4, 5, 6, 7, 8, 9]);

        for (var d = 1; d <= 9; d++) {
          expect(result.expectedFrequencies.containsKey(d), isTrue);
        }
      });
    });

    group('analyze — Benford-conforming natural data', () {
      test('revenue-like numbers give high conformance score (>=50)', () {
        // These start with 1,1,1,2,2,3,4,5,6,7,8,9 — first digit heavy on 1s
        // consistent with Benford's Law.
        final naturalAmounts = [
          1000.0,
          1100.0,
          1500.0,
          2000.0,
          2500.0,
          3000.0,
          4000.0,
          5000.0,
          6000.0,
          7000.0,
          8000.0,
          9000.0,
        ];

        final result = engine.analyze(naturalAmounts);

        expect(
          result.conformanceScore,
          greaterThanOrEqualTo(50.0),
          reason: 'Natural revenue data should conform to Benford\'s Law',
        );
      });

      test('isAnomaly is false for Benford-conforming data', () {
        final naturalAmounts = [
          1000.0,
          1100.0,
          1500.0,
          1200.0,
          1300.0,
          2000.0,
          2500.0,
          3000.0,
          4000.0,
          5000.0,
          6000.0,
          7000.0,
          8000.0,
          9000.0,
          1050.0,
          1150.0,
          1250.0,
          2100.0,
          3100.0,
          4100.0,
          5100.0,
          6100.0,
          7100.0,
          8100.0,
          9100.0,
          1600.0,
          1700.0,
          1800.0,
          1900.0,
          2200.0,
        ];

        final result = engine.analyze(naturalAmounts);

        expect(result.isAnomaly, isFalse);
      });
    });

    group('analyze — uniform distribution gives lower score', () {
      test('uniform first-digit distribution gives score < natural data', () {
        // Uniform: exactly equal counts for digits 1-9 violates Benford's Law
        // because Benford expects ~30% to start with 1, not ~11%.
        final uniformAmounts = <double>[];
        for (var d = 1; d <= 9; d++) {
          for (var i = 0; i < 10; i++) {
            uniformAmounts.add(d * 1000.0);
          }
        }

        final naturalAmounts = [
          1000.0,
          1100.0,
          1200.0,
          1300.0,
          1400.0,
          1500.0,
          1600.0,
          1700.0,
          1800.0,
          1900.0,
          2000.0,
          2500.0,
          3000.0,
          4000.0,
          5000.0,
          6000.0,
          7000.0,
          8000.0,
          9000.0,
          1050.0,
          1150.0,
          1250.0,
          2100.0,
          3100.0,
          4100.0,
          5100.0,
          6100.0,
          7100.0,
          8100.0,
          9100.0,
        ];

        final uniformResult = engine.analyze(uniformAmounts);
        final naturalResult = engine.analyze(naturalAmounts);

        expect(
          uniformResult.conformanceScore,
          lessThan(naturalResult.conformanceScore),
          reason: 'Uniform distribution should score lower than natural data',
        );
      });
    });

    group('analyze — empty input', () {
      test('empty list returns sampleSize of 0', () {
        final result = engine.analyze([]);

        expect(result.sampleSize, equals(0));
      });

      test('empty list returns isAnomaly false', () {
        final result = engine.analyze([]);

        expect(result.isAnomaly, isFalse);
      });

      test('empty list returns a non-null interpretation', () {
        final result = engine.analyze([]);

        expect(result.interpretation, isNotEmpty);
      });

      test('empty list chiSquaredStatistic is 0', () {
        final result = engine.analyze([]);

        expect(result.chiSquaredStatistic, equals(0.0));
      });
    });

    group('analyze — non-positive number filtering', () {
      test('negative numbers are excluded from analysis', () {
        final withNegatives = [-500.0, -200.0, 1000.0, 2000.0, 3000.0];
        final withoutNegatives = [1000.0, 2000.0, 3000.0];

        final r1 = engine.analyze(withNegatives);
        final r2 = engine.analyze(withoutNegatives);

        expect(
          r1.sampleSize,
          equals(r2.sampleSize),
          reason: 'Negative values should be filtered out',
        );
      });

      test('zero values are excluded from analysis', () {
        final withZeros = [0.0, 0.0, 1000.0, 2000.0];
        final withoutZeros = [1000.0, 2000.0];

        final r1 = engine.analyze(withZeros);
        final r2 = engine.analyze(withoutZeros);

        expect(r1.sampleSize, equals(r2.sampleSize));
      });

      test('all non-positive values returns empty-like result', () {
        final result = engine.analyze([-100.0, -200.0, 0.0]);

        expect(result.sampleSize, equals(0));
        expect(result.isAnomaly, isFalse);
      });
    });

    group('BenfordsResult — copyWith', () {
      test('copyWith creates new instance with updated field', () {
        final original = engine.analyze([1000.0, 2000.0, 3000.0]);
        final updated = original.copyWith(conformanceScore: 42.0);

        expect(updated.conformanceScore, equals(42.0));
        expect(
          updated.chiSquaredStatistic,
          equals(original.chiSquaredStatistic),
        );
        expect(identical(original, updated), isFalse);
      });

      test('copyWith without args produces equal but distinct object', () {
        final original = engine.analyze([1000.0, 2000.0, 3000.0]);
        final copy = original.copyWith();

        expect(copy.conformanceScore, equals(original.conformanceScore));
        expect(copy.chiSquaredStatistic, equals(original.chiSquaredStatistic));
      });
    });

    group('BenfordsLawEngine — minSampleSize configuration', () {
      test('interpretation mentions low sample size when below threshold', () {
        const smallEngine = BenfordsLawEngine(minSampleSize: 30);
        final result = smallEngine.analyze([1000.0, 2000.0, 3000.0]);

        expect(result.interpretation.toLowerCase(), contains('sample size'));
      });

      test(
        'interpretation does not mention low sample when above threshold',
        () {
          const smallEngine = BenfordsLawEngine(minSampleSize: 2);
          final result = smallEngine.analyze([1000.0, 2000.0, 3000.0]);

          expect(
            result.interpretation.toLowerCase(),
            isNot(contains('below the recommended minimum')),
          );
        },
      );
    });

    group('analyze — sampleSize accuracy', () {
      test('sampleSize equals count of positive input values', () {
        final amounts = [100.0, 200.0, 300.0, 400.0, 500.0];
        final result = engine.analyze(amounts);

        expect(result.sampleSize, equals(5));
      });

      test('sampleSize excludes non-positive values', () {
        final amounts = [-100.0, 0.0, 100.0, 200.0, 300.0];
        final result = engine.analyze(amounts);

        expect(result.sampleSize, equals(3));
      });
    });
  });
}

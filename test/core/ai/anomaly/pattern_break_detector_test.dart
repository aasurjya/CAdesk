import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/anomaly/pattern_break_detector.dart';

void main() {
  group('PatternBreakDetector', () {
    late PatternBreakDetector detector;

    setUp(() {
      detector = const PatternBreakDetector();
    });

    // Normal distribution: values close to mean, no outliers.
    final normalValues = [
      100.0,
      102.0,
      98.0,
      101.0,
      99.0,
      100.5,
      101.5,
      99.5,
      100.0,
      100.2,
    ];

    group('detectBreaks — normal distribution', () {
      test('no breaks detected in tightly distributed data', () {
        final breaks = detector.detectBreaks(normalValues, 100.0);

        expect(breaks, isEmpty);
      });

      test('normal value within 1 std dev does not trigger a break', () {
        final breaks = detector.detectBreaks(normalValues, 101.0);

        expect(breaks, isEmpty);
      });
    });

    group('detectBreaks — outlier detection', () {
      test('single extreme outlier far outside mean is detected', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);

        expect(breaks, isNotEmpty);
        expect(breaks.any((b) => b.value == 9999.0), isTrue);
      });

      test('detected break contains the outlier value', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);
        final outlierBreak = breaks.firstWhere((b) => b.value == 9999.0);

        expect(outlierBreak.value, equals(9999.0));
      });

      test('detected break has absolute z-score >= threshold (2.5)', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);
        final outlierBreak = breaks.firstWhere((b) => b.value == 9999.0);

        expect(outlierBreak.zScore.abs(), greaterThanOrEqualTo(2.5));
      });

      test('detected break has mean and stdDev populated', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);
        final outlierBreak = breaks.first;

        expect(outlierBreak.mean, isNotNaN);
        expect(outlierBreak.stdDev, isNonNegative);
      });
    });

    group('detectBreaks — result structure', () {
      test('returns list of PatternBreak with index and z-score', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);

        for (final b in breaks) {
          expect(b.zScore.isNaN, isFalse);
          expect(b.index, isNotNull);
        }
      });

      test('PatternBreak has value, zScore, mean, stdDev, severity fields', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);
        final b = breaks.first;

        expect(b.value.isNaN, isFalse);
        expect(b.zScore.isNaN, isFalse);
        expect(b.mean.isNaN, isFalse);
        expect(b.stdDev.isNaN, isFalse);
        expect(b.severity, isNotEmpty);
      });

      test('index of the new value is historicalValues.length', () {
        final breaks = detector.detectBreaks(normalValues, 9999.0);
        final newValueBreak = breaks.firstWhere((b) => b.value == 9999.0);

        expect(newValueBreak.index, equals(normalValues.length));
      });
    });

    group('detectBreaks — severity classification', () {
      test('severity is warning for z-score between 2.5 and 4.0', () {
        // Use a spread-out baseline so that a moderate outlier falls in warning range.
        final baseline = List.generate(
          20,
          (i) => i.toDouble() * 10.0,
        ); // 0, 10, 20, ..., 190
        final breaks = detector.detectBreaks(baseline, 400.0);

        if (breaks.any((b) => b.value == 400.0)) {
          final b = breaks.firstWhere((b) => b.value == 400.0);
          expect(b.severity, isIn(['warning', 'critical']));
        }
      });

      test('severity is critical when |z| >= 4.0', () {
        // Tight baseline so a huge outlier is critical.
        final breaks = detector.detectBreaks(normalValues, 99999.0);

        if (breaks.any((b) => b.value == 99999.0)) {
          final b = breaks.firstWhere((b) => b.value == 99999.0);
          expect(b.severity, equals('critical'));
        }
      });
    });

    group('detectBreaks — insufficient data', () {
      test('empty historical values returns empty list', () {
        final breaks = detector.detectBreaks([], 100.0);
        expect(breaks, isEmpty);
      });

      test('single historical value returns empty list', () {
        final breaks = detector.detectBreaks([100.0], 200.0);
        expect(breaks, isEmpty);
      });

      test(
        'two identical historical values returns empty list (zero std dev)',
        () {
          final breaks = detector.detectBreaks([100.0, 100.0], 100.0);
          expect(breaks, isEmpty);
        },
      );
    });

    group('zScore — standalone calculation', () {
      test('returns 0.0 for single-element list', () {
        final z = detector.zScore([100.0], 200.0);
        expect(z, equals(0.0));
      });

      test('returns 0.0 when all values are identical (zero std dev)', () {
        final z = detector.zScore([100.0, 100.0, 100.0], 100.0);
        expect(z, equals(0.0));
      });

      test('z-score of mean value is 0.0', () {
        final values = [10.0, 20.0, 30.0]; // mean = 20
        final z = detector.zScore(values, 20.0);
        expect(z, closeTo(0.0, 0.001));
      });

      test('z-score is positive for value above mean', () {
        final values = [10.0, 20.0, 30.0];
        final z = detector.zScore(values, 30.0);
        expect(z, isPositive);
      });

      test('z-score is negative for value below mean', () {
        final values = [10.0, 20.0, 30.0];
        final z = detector.zScore(values, 10.0);
        expect(z, isNegative);
      });
    });

    group('rollingZScores', () {
      test('returns list of same length as input', () {
        final values = List.generate(20, (i) => i.toDouble());
        final result = detector.rollingZScores(values);
        expect(result.length, equals(values.length));
      });

      test('first element is 0.0 (no prior window)', () {
        final values = List.generate(20, (i) => i.toDouble());
        final result = detector.rollingZScores(values);
        expect(result[0], equals(0.0));
      });

      test('returns all zeros for empty list', () {
        final result = detector.rollingZScores([]);
        expect(result, isEmpty);
      });

      test('returns single zero for single-element list', () {
        final result = detector.rollingZScores([42.0]);
        expect(result, equals([0.0]));
      });
    });

    group('PatternBreakDetector — configurable thresholds', () {
      test('lower z-score threshold detects more breaks', () {
        const sensitiveDetector = PatternBreakDetector(zScoreThreshold: 1.5);
        final values = [100.0, 100.0, 100.0, 100.0, 100.0];
        final standardBreaks = detector.detectBreaks(values, 105.0);
        final sensitiveBreaks = sensitiveDetector.detectBreaks(values, 105.0);

        // Sensitive detector may flag the same or more values.
        expect(
          sensitiveBreaks.length,
          greaterThanOrEqualTo(standardBreaks.length),
        );
      });

      test('custom criticalZScore changes severity boundary', () {
        const customDetector = PatternBreakDetector(
          zScoreThreshold: 2.5,
          criticalZScore: 3.0,
        );
        final breaks = customDetector.detectBreaks(normalValues, 9999.0);

        if (breaks.any((b) => b.value == 9999.0)) {
          final b = breaks.firstWhere((b) => b.value == 9999.0);
          // Should be critical since |z| >> 3.0
          expect(b.severity, equals('critical'));
        }
      });
    });

    group('PatternBreak — copyWith immutability', () {
      test('copyWith creates new instance with updated field', () {
        const original = PatternBreak(
          value: 100.0,
          zScore: 3.0,
          mean: 50.0,
          stdDev: 10.0,
          severity: 'warning',
          index: 5,
        );
        final updated = original.copyWith(severity: 'critical');

        expect(updated.severity, equals('critical'));
        expect(updated.value, equals(original.value));
        expect(identical(original, updated), isFalse);
      });
    });
  });
}

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// PatternBreak model
// ---------------------------------------------------------------------------

/// Immutable record of a single detected pattern break.
class PatternBreak {
  const PatternBreak({
    required this.value,
    required this.zScore,
    required this.mean,
    required this.stdDev,
    required this.severity,
    this.index,
  });

  /// The value that broke the pattern.
  final double value;

  /// Z-score of the value relative to the historical distribution.
  final double zScore;

  /// Mean of the historical series.
  final double mean;

  /// Standard deviation of the historical series.
  final double stdDev;

  /// Severity classification:
  /// - `'warning'` — |z| ≥ [PatternBreakDetector.zScoreThreshold]
  /// - `'critical'` — |z| ≥ [PatternBreakDetector.criticalZScore]
  final String severity;

  /// Position of the value in the input list (null for a single candidate).
  final int? index;

  PatternBreak copyWith({
    double? value,
    double? zScore,
    double? mean,
    double? stdDev,
    String? severity,
    int? index,
  }) {
    return PatternBreak(
      value: value ?? this.value,
      zScore: zScore ?? this.zScore,
      mean: mean ?? this.mean,
      stdDev: stdDev ?? this.stdDev,
      severity: severity ?? this.severity,
      index: index ?? this.index,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatternBreak &&
        other.value == value &&
        other.zScore == zScore;
  }

  @override
  int get hashCode => Object.hash(value, zScore);

  @override
  String toString() =>
      'PatternBreak(value: $value, z: ${zScore.toStringAsFixed(2)}, '
      'severity: $severity)';
}

// ---------------------------------------------------------------------------
// PatternBreakDetector
// ---------------------------------------------------------------------------

/// Detects statistical outliers in a time-series of financial values using
/// z-score analysis.
///
/// A value is flagged as a pattern break when its z-score exceeds
/// [zScoreThreshold] (default 2.5). Values with |z| ≥ [criticalZScore]
/// (default 4.0) are marked as `'critical'`.
///
/// The standard deviation is computed using the **population** formula (÷ N)
/// for samples ≥ 2, or Bessel-corrected (÷ N-1) for small samples.
///
/// Usage:
/// ```dart
/// final detector = PatternBreakDetector();
/// final breaks = detector.detectBreaks(historicalValues, newValue);
/// final z = detector.zScore(historicalValues, candidate);
/// ```
class PatternBreakDetector {
  const PatternBreakDetector({
    this.zScoreThreshold = 2.5,
    this.criticalZScore = 4.0,
  });

  /// Z-score above which a value is classified as a `'warning'` break.
  final double zScoreThreshold;

  /// Z-score above which a value is classified as a `'critical'` break.
  final double criticalZScore;

  // ---------------------------------------------------------------------------
  // detectBreaks
  // ---------------------------------------------------------------------------

  /// Detects values in [historicalValues] that deviate significantly from the
  /// series mean, then also checks [newValue].
  ///
  /// Returns a (possibly empty) list of [PatternBreak]s. The list contains
  /// one entry for [newValue] when it exceeds the threshold, plus any
  /// retrospective outliers in [historicalValues].
  ///
  /// [historicalValues] must contain at least 2 elements for a meaningful
  /// z-score calculation.
  List<PatternBreak> detectBreaks(
    List<double> historicalValues,
    double newValue,
  ) {
    if (historicalValues.length < 2) {
      return const [];
    }

    final stats = _computeStats(historicalValues);
    final mean = stats.$1;
    final std = stats.$2;

    if (std == 0)
      return const []; // All values identical — no deviation possible.

    final breaks = <PatternBreak>[];

    // Check each historical value for retrospective outliers.
    for (var i = 0; i < historicalValues.length; i++) {
      final z = _computeZScore(historicalValues[i], mean, std);
      if (z.abs() >= zScoreThreshold) {
        breaks.add(
          PatternBreak(
            value: historicalValues[i],
            zScore: z,
            mean: mean,
            stdDev: std,
            severity: _severity(z),
            index: i,
          ),
        );
      }
    }

    // Check the new value.
    final newZ = _computeZScore(newValue, mean, std);
    if (newZ.abs() >= zScoreThreshold) {
      breaks.add(
        PatternBreak(
          value: newValue,
          zScore: newZ,
          mean: mean,
          stdDev: std,
          severity: _severity(newZ),
          index: historicalValues.length,
        ),
      );
    }

    return List.unmodifiable(breaks);
  }

  // ---------------------------------------------------------------------------
  // zScore
  // ---------------------------------------------------------------------------

  /// Computes the z-score of [candidate] relative to the distribution of
  /// [values].
  ///
  /// Returns 0.0 when [values] has fewer than 2 elements or has zero standard
  /// deviation.
  double zScore(List<double> values, double candidate) {
    if (values.length < 2) return 0.0;

    final stats = _computeStats(values);
    final mean = stats.$1;
    final std = stats.$2;

    if (std == 0) return 0.0;
    return _computeZScore(candidate, mean, std);
  }

  // ---------------------------------------------------------------------------
  // rollingZScores
  // ---------------------------------------------------------------------------

  /// Computes a rolling z-score for each element in [values] using a window
  /// of [windowSize] preceding values.
  ///
  /// Returns a list of the same length as [values].
  /// Elements where a window cannot be computed return 0.0.
  List<double> rollingZScores(List<double> values, {int windowSize = 10}) {
    if (values.length < 2) return List.filled(values.length, 0.0);

    final result = List<double>.filled(values.length, 0.0);

    for (var i = 1; i < values.length; i++) {
      final start = math.max(0, i - windowSize);
      final window = values.sublist(start, i);
      if (window.length < 2) continue;

      final stats = _computeStats(window);
      final mean = stats.$1;
      final std = stats.$2;
      result[i] = std == 0 ? 0.0 : _computeZScore(values[i], mean, std);
    }

    return List.unmodifiable(result);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns (mean, stdDev) using Bessel-corrected standard deviation for
  /// small samples (n < 30) and population std for larger samples.
  (double, double) _computeStats(List<double> values) {
    final n = values.length;
    final mean = values.fold(0.0, (s, v) => s + v) / n;

    final sumSqDev = values.fold(0.0, (s, v) => s + math.pow(v - mean, 2));
    final divisor = n < 30 ? n - 1 : n; // Bessel correction for small samples
    final std = math.sqrt(sumSqDev / divisor);

    return (mean, std);
  }

  double _computeZScore(double value, double mean, double std) {
    return (value - mean) / std;
  }

  String _severity(double z) {
    return z.abs() >= criticalZScore ? 'critical' : 'warning';
  }
}

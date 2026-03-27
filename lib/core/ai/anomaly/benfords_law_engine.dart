import 'dart:math' as math;

// ---------------------------------------------------------------------------
// BenfordsResult
// ---------------------------------------------------------------------------

/// Immutable result of a Benford's Law analysis.
class BenfordsResult {
  const BenfordsResult({
    required this.chiSquaredStatistic,
    required this.conformanceScore,
    required this.isAnomaly,
    required this.observedFrequencies,
    required this.expectedFrequencies,
    required this.interpretation,
    required this.sampleSize,
  });

  /// Chi-squared goodness-of-fit statistic against Benford distribution.
  final double chiSquaredStatistic;

  /// Conformance score in range [0, 100].
  /// 100 = perfectly follows Benford's Law. Lower = more anomalous.
  final double conformanceScore;

  /// `true` when the chi-squared p-value is below 0.05
  /// (i.e., the data significantly deviates from Benford's Law).
  final bool isAnomaly;

  /// Observed first-digit frequencies keyed by digit (1–9).
  final Map<int, double> observedFrequencies;

  /// Expected first-digit frequencies according to Benford's Law.
  final Map<int, double> expectedFrequencies;

  /// Human-readable summary of the analysis result.
  final String interpretation;

  /// Number of amounts used in the analysis.
  final int sampleSize;

  BenfordsResult copyWith({
    double? chiSquaredStatistic,
    double? conformanceScore,
    bool? isAnomaly,
    Map<int, double>? observedFrequencies,
    Map<int, double>? expectedFrequencies,
    String? interpretation,
    int? sampleSize,
  }) {
    return BenfordsResult(
      chiSquaredStatistic: chiSquaredStatistic ?? this.chiSquaredStatistic,
      conformanceScore: conformanceScore ?? this.conformanceScore,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      observedFrequencies: observedFrequencies ?? this.observedFrequencies,
      expectedFrequencies: expectedFrequencies ?? this.expectedFrequencies,
      interpretation: interpretation ?? this.interpretation,
      sampleSize: sampleSize ?? this.sampleSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BenfordsResult &&
        other.chiSquaredStatistic == chiSquaredStatistic &&
        other.conformanceScore == conformanceScore;
  }

  @override
  int get hashCode => Object.hash(chiSquaredStatistic, conformanceScore);

  @override
  String toString() =>
      'BenfordsResult(score: ${conformanceScore.toStringAsFixed(1)}, '
      'anomaly: $isAnomaly, chi2: ${chiSquaredStatistic.toStringAsFixed(2)})';
}

// ---------------------------------------------------------------------------
// BenfordsLawEngine
// ---------------------------------------------------------------------------

/// Runs a Benford's Law chi-squared goodness-of-fit test on a collection of
/// monetary amounts to detect possible financial anomalies.
///
/// Benford's Law predicts that in naturally occurring datasets the leading
/// digit d (1–9) appears with frequency log₁₀(1 + 1/d).
///
/// A chi-squared statistic significantly above the 0.05 critical value
/// (15.51 for 8 degrees of freedom) indicates the data may be fabricated,
/// rounded, or otherwise manipulated.
///
/// Usage:
/// ```dart
/// final engine = BenfordsLawEngine();
/// final result = engine.analyze(amounts);
/// if (result.isAnomaly) print('Potential anomaly: ${result.interpretation}');
/// ```
class BenfordsLawEngine {
  const BenfordsLawEngine({this.minSampleSize = 30});

  /// Minimum sample size for a statistically meaningful test.
  /// Results for smaller samples are returned with a warning interpretation.
  final int minSampleSize;

  // ---------------------------------------------------------------------------
  // Benford expected frequencies
  // ---------------------------------------------------------------------------

  static const Map<int, double> _expectedFrequencies = {
    1: 0.30103, // log10(1 + 1/1)
    2: 0.17609,
    3: 0.12494,
    4: 0.09691,
    5: 0.07918,
    6: 0.06695,
    7: 0.05799,
    8: 0.05115,
    9: 0.04576,
  };

  // Chi-squared critical value at p=0.05 with 8 degrees of freedom.
  static const double _criticalValue005 = 15.507;

  // ---------------------------------------------------------------------------
  // analyze
  // ---------------------------------------------------------------------------

  /// Runs Benford's Law analysis on [amounts].
  ///
  /// Negative values and zero are excluded (they have no meaningful first
  /// digit). Returns a result with a warning interpretation if the usable
  /// sample size is below [minSampleSize].
  BenfordsResult analyze(List<double> amounts) {
    // Filter: only positive, non-zero values
    final usable = amounts.where((a) => a > 0).toList();

    if (usable.isEmpty) {
      return _emptyResult('No positive amounts to analyse.');
    }

    // Count first-digit occurrences
    final counts = <int, int>{for (var d = 1; d <= 9; d++) d: 0};
    for (final amount in usable) {
      final digit = _firstDigit(amount);
      if (digit >= 1 && digit <= 9) {
        counts[digit] = (counts[digit] ?? 0) + 1;
      }
    }

    final n = usable.length;

    // Observed frequencies
    final observed = <int, double>{};
    for (var d = 1; d <= 9; d++) {
      observed[d] = (counts[d] ?? 0) / n;
    }

    // Chi-squared statistic: Σ (O - E)² / E   where O = n * observedFreq
    var chiSq = 0.0;
    for (var d = 1; d <= 9; d++) {
      final observedCount = (counts[d] ?? 0).toDouble();
      final expectedCount = (_expectedFrequencies[d] ?? 0) * n;
      if (expectedCount > 0) {
        chiSq += math.pow(observedCount - expectedCount, 2) / expectedCount;
      }
    }

    final isAnomaly = chiSq > _criticalValue005;

    // Conformance score: scale chi-sq inversely to 0-100
    // At chi2 = 0 → score = 100; at chi2 = criticalValue → score = 50;
    // beyond critical → score decreases toward 0.
    final score = math.max(0.0, 100.0 - (chiSq / _criticalValue005) * 50.0);

    final interpretation = _buildInterpretation(
      chiSq: chiSq,
      isAnomaly: isAnomaly,
      sampleSize: n,
      lowSample: n < minSampleSize,
    );

    return BenfordsResult(
      chiSquaredStatistic: chiSq,
      conformanceScore: math.min(score, 100.0),
      isAnomaly: isAnomaly,
      observedFrequencies: Map.unmodifiable(observed),
      expectedFrequencies: Map.unmodifiable(_expectedFrequencies),
      interpretation: interpretation,
      sampleSize: n,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  int _firstDigit(double amount) {
    // Remove decimals and sign, then read the first character.
    final s = amount.abs().toStringAsFixed(0).replaceAll(RegExp(r'^0+'), '');
    if (s.isEmpty) return 0;
    return int.tryParse(s[0]) ?? 0;
  }

  String _buildInterpretation({
    required double chiSq,
    required bool isAnomaly,
    required int sampleSize,
    required bool lowSample,
  }) {
    final buffer = StringBuffer();

    if (lowSample) {
      buffer.write(
        'Sample size ($sampleSize) is below the recommended minimum '
        '($minSampleSize) for reliable Benford analysis. ',
      );
    }

    if (isAnomaly) {
      buffer.write(
        'ANOMALY DETECTED: chi-squared statistic (${chiSq.toStringAsFixed(2)}) '
        'exceeds the 0.05 significance threshold '
        '(${_criticalValue005.toStringAsFixed(2)}). '
        'The dataset does not follow Benford\'s Law — possible fabrication, '
        'systematic rounding, or non-naturally-occurring data.',
      );
    } else {
      buffer.write(
        'CONFORMS: chi-squared statistic (${chiSq.toStringAsFixed(2)}) is '
        'within the expected range. The first-digit distribution is consistent '
        'with Benford\'s Law.',
      );
    }

    return buffer.toString();
  }

  BenfordsResult _emptyResult(String message) {
    return BenfordsResult(
      chiSquaredStatistic: 0,
      conformanceScore: 0,
      isAnomaly: false,
      observedFrequencies: const {},
      expectedFrequencies: Map.unmodifiable(_expectedFrequencies),
      interpretation: message,
      sampleSize: 0,
    );
  }
}

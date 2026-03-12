import 'dart:math' as math;

import 'package:ca_app/features/advanced_audit/domain/models/benford_analysis_result.dart';

/// Stateless service implementing Benford's Law analysis for audit data.
///
/// Benford's Law: the leading digit d in naturally occurring data appears with
/// probability P(d) = log₁₀(1 + 1/d).  A significant chi-square deviation
/// (α = 0.05, df = 8, critical value 15.507) is flagged as a risk.
///
/// Minimum sample required: 100 transactions.
class BenfordLawService {
  BenfordLawService._();

  /// Critical value for chi-square with 8 degrees of freedom at α = 0.05.
  static const double _criticalValue = 15.507;

  /// Minimum sample size before analysis is considered meaningful.
  static const int _minimumSample = 100;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Performs a full Benford's Law analysis on [amounts].
  ///
  /// Throws [ArgumentError] if [amounts] contains fewer than
  /// [_minimumSample] positive values.
  ///
  /// [datasetName] is an optional label stored on the result.
  static BenfordAnalysisResult analyze(
    List<int> amounts, {
    String datasetName = 'Dataset',
  }) {
    final digits = extractLeadingDigits(amounts);

    if (digits.length < _minimumSample) {
      throw ArgumentError(
        'Benford analysis requires at least $_minimumSample positive '
        'transactions; got ${digits.length}.',
      );
    }

    final n = digits.length;

    // Count occurrences of each digit
    final counts = <int, int>{for (int d = 1; d <= 9; d++) d: 0};
    for (final d in digits) {
      counts[d] = (counts[d] ?? 0) + 1;
    }

    // Observed proportions
    final observed = <int, double>{
      for (final entry in counts.entries) entry.key: entry.value / n,
    };

    // Expected Benford proportions
    final expected = <int, double>{
      for (int d = 1; d <= 9; d++) d: getExpectedFrequency(d),
    };

    final chiSq = computeChiSquare(observed, expected, n);
    final significant = isSignificant(chiSq);

    // Identify digits with the largest individual deviations
    final deviations = <MapEntry<int, double>>[];
    for (int d = 1; d <= 9; d++) {
      final obs = observed[d] ?? 0;
      final exp = expected[d]!;
      final deviation = (obs - exp).abs() / exp;
      deviations.add(MapEntry(d, deviation));
    }
    deviations.sort((a, b) => b.value.compareTo(a.value));

    // Flag digits whose deviation exceeds 25% relative to expected
    final significantDigits = deviations
        .where((e) => e.value > 0.25)
        .map((e) => e.key)
        .toList();

    return BenfordAnalysisResult(
      datasetName: datasetName,
      sampleCount: n,
      observedFrequencies: Map.unmodifiable(observed),
      expectedFrequencies: Map.unmodifiable(expected),
      chiSquareStatistic: chiSq,
      degreesOfFreedom: 8,
      pValue: _approximatePValue(chiSq),
      significantDeviations: List.unmodifiable(significantDigits),
      riskFlag: significant,
    );
  }

  /// Returns the Benford expected frequency for [digit] (1–9).
  ///
  /// Formula: log₁₀(1 + 1/d)
  static double getExpectedFrequency(int digit) {
    assert(digit >= 1 && digit <= 9, 'digit must be 1–9');
    return math.log(1 + 1 / digit) / math.ln10;
  }

  /// Computes the Pearson chi-square statistic.
  ///
  /// Formula: n × Σ [(O_d − E_d)² / E_d]
  ///
  /// [observed] and [expected] map digits 1–9 to proportions.
  /// [n] is the total sample size.
  static double computeChiSquare(
    Map<int, double> observed,
    Map<int, double> expected,
    int n,
  ) {
    var chiSq = 0.0;
    for (int d = 1; d <= 9; d++) {
      final obs = observed[d] ?? 0;
      final exp = expected[d] ?? 0;
      if (exp > 0) {
        chiSq += math.pow(obs - exp, 2) / exp;
      }
    }
    return chiSq * n;
  }

  /// Returns true when [chiSquare] exceeds the critical value for df = 8
  /// at the given [alpha] level (default 0.05, critical value 15.507).
  static bool isSignificant(double chiSquare, {double alpha = 0.05}) {
    // Only α = 0.05 is supported; the critical value is pre-computed.
    assert(alpha == 0.05, 'Only alpha = 0.05 is supported');
    return chiSquare > _criticalValue;
  }

  /// Extracts the leading (first significant) digit from each amount.
  ///
  /// Amounts ≤ 0 are ignored.
  static List<int> extractLeadingDigits(List<int> amounts) {
    final result = <int>[];
    for (final amount in amounts) {
      if (amount <= 0) continue;
      final firstChar = amount.abs().toString()[0];
      result.add(int.parse(firstChar));
    }
    return result;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Very rough approximation of the chi-square p-value for df = 8.
  ///
  /// Uses Wilson–Hilferty normal approximation:
  ///   Z = (x/k)^(1/3) − (1 − 2/(9k)) / sqrt(2/(9k))
  /// where k = degrees of freedom.
  ///
  /// This is approximate but sufficient for audit risk flagging purposes.
  static double _approximatePValue(double chiSq) {
    const k = 8.0;
    final x = chiSq / k;
    final cbrtX = math.pow(x, 1 / 3).toDouble();
    final mu = 1 - 2 / (9 * k);
    final sigma = math.sqrt(2 / (9 * k));
    final z = (cbrtX - mu) / sigma;
    // One-tailed upper: p ≈ 1 - Φ(z)
    return _normalCdfComplement(z);
  }

  /// Complementary CDF of the standard normal using Abramowitz & Stegun
  /// rational approximation (max error ≈ 7.5e-8).
  static double _normalCdfComplement(double z) {
    if (z < -6) return 1.0;
    if (z > 6) return 0.0;
    const p = 0.2316419;
    const b1 = 0.319381530;
    const b2 = -0.356563782;
    const b3 = 1.781477937;
    const b4 = -1.821255978;
    const b5 = 1.330274429;
    final t = 1 / (1 + p * z.abs());
    final poly = t * (b1 + t * (b2 + t * (b3 + t * (b4 + t * b5))));
    final phi = math.exp(-0.5 * z * z) / math.sqrt(2 * math.pi);
    final upper = phi * poly;
    return z >= 0 ? upper : 1 - upper;
  }
}

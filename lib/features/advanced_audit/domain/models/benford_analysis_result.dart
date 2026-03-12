/// Immutable result of applying Benford's Law analysis to a transaction dataset.
///
/// Benford's Law states that in naturally occurring data the leading digit d
/// appears with probability P(d) = log₁₀(1 + 1/d).  Significant deviation
/// from these expected frequencies can indicate data manipulation.
class BenfordAnalysisResult {
  const BenfordAnalysisResult({
    required this.datasetName,
    required this.sampleCount,
    required this.observedFrequencies,
    required this.expectedFrequencies,
    required this.chiSquareStatistic,
    required this.degreesOfFreedom,
    required this.pValue,
    required this.significantDeviations,
    required this.riskFlag,
  });

  /// Human-readable label for the dataset that was analysed.
  final String datasetName;

  /// Number of transactions included in the analysis.
  final int sampleCount;

  /// Observed leading-digit frequencies: digit (1–9) → proportion [0, 1].
  final Map<int, double> observedFrequencies;

  /// Expected Benford frequencies: digit (1–9) → log₁₀(1 + 1/d).
  final Map<int, double> expectedFrequencies;

  /// Pearson chi-square statistic Σ [(O − E)² / E] × n.
  final double chiSquareStatistic;

  /// Degrees of freedom for the chi-square test (always 8 for digits 1–9).
  final int degreesOfFreedom;

  /// Approximate p-value derived from the chi-square statistic.
  final double pValue;

  /// Digits whose individual deviation from Benford expectation is largest.
  final List<int> significantDeviations;

  /// True when [chiSquareStatistic] exceeds the critical value at α = 0.05
  /// (15.507 for 8 degrees of freedom).
  final bool riskFlag;

  BenfordAnalysisResult copyWith({
    String? datasetName,
    int? sampleCount,
    Map<int, double>? observedFrequencies,
    Map<int, double>? expectedFrequencies,
    double? chiSquareStatistic,
    int? degreesOfFreedom,
    double? pValue,
    List<int>? significantDeviations,
    bool? riskFlag,
  }) {
    return BenfordAnalysisResult(
      datasetName: datasetName ?? this.datasetName,
      sampleCount: sampleCount ?? this.sampleCount,
      observedFrequencies: observedFrequencies ?? this.observedFrequencies,
      expectedFrequencies: expectedFrequencies ?? this.expectedFrequencies,
      chiSquareStatistic: chiSquareStatistic ?? this.chiSquareStatistic,
      degreesOfFreedom: degreesOfFreedom ?? this.degreesOfFreedom,
      pValue: pValue ?? this.pValue,
      significantDeviations:
          significantDeviations ?? this.significantDeviations,
      riskFlag: riskFlag ?? this.riskFlag,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BenfordAnalysisResult &&
        other.datasetName == datasetName &&
        other.sampleCount == sampleCount &&
        other.chiSquareStatistic == chiSquareStatistic &&
        other.degreesOfFreedom == degreesOfFreedom &&
        other.riskFlag == riskFlag;
  }

  @override
  int get hashCode => Object.hash(
    datasetName,
    sampleCount,
    chiSquareStatistic,
    degreesOfFreedom,
    riskFlag,
  );
}

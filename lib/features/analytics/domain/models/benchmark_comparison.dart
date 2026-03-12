/// Compares a firm's metric against industry benchmarks.
///
/// Use this to surface whether the firm is above or below peer averages,
/// and to identify gap-to-top-quartile improvement opportunities.
class BenchmarkComparison {
  const BenchmarkComparison({
    required this.firmId,
    required this.period,
    required this.firmMetric,
    required this.industryAverage,
    required this.topQuartile,
    required this.metricName,
    required this.unit,
    required this.percentile,
  });

  /// Identifier of the CA firm being compared.
  final String firmId;

  /// Fiscal period this comparison covers, e.g. "FY2024-25".
  final String period;

  /// The firm's actual metric value.
  final double firmMetric;

  /// Average metric value across comparable firms.
  final double industryAverage;

  /// Metric value at the 75th percentile of comparable firms.
  final double topQuartile;

  /// Human-readable metric name, e.g. "Revenue per client".
  final String metricName;

  /// Unit label for display, e.g. "paise", "%", "hours".
  final String unit;

  /// Where this firm stands among peers (0–100).
  ///
  /// A value of 70 means the firm performs better than 70% of comparable firms.
  final double percentile;

  /// Returns true when [firmMetric] exceeds [industryAverage].
  bool get isAboveAverage => firmMetric > industryAverage;

  BenchmarkComparison copyWith({
    String? firmId,
    String? period,
    double? firmMetric,
    double? industryAverage,
    double? topQuartile,
    String? metricName,
    String? unit,
    double? percentile,
  }) {
    return BenchmarkComparison(
      firmId: firmId ?? this.firmId,
      period: period ?? this.period,
      firmMetric: firmMetric ?? this.firmMetric,
      industryAverage: industryAverage ?? this.industryAverage,
      topQuartile: topQuartile ?? this.topQuartile,
      metricName: metricName ?? this.metricName,
      unit: unit ?? this.unit,
      percentile: percentile ?? this.percentile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BenchmarkComparison &&
        other.firmId == firmId &&
        other.period == period &&
        other.firmMetric == firmMetric &&
        other.industryAverage == industryAverage &&
        other.topQuartile == topQuartile &&
        other.metricName == metricName &&
        other.unit == unit &&
        other.percentile == percentile;
  }

  @override
  int get hashCode => Object.hash(
    firmId,
    period,
    firmMetric,
    industryAverage,
    topQuartile,
    metricName,
    unit,
    percentile,
  );
}

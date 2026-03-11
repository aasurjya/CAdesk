/// A single benchmark metric comparing a firm's performance against peers.
class BenchmarkMetric {
  const BenchmarkMetric({
    required this.id,
    required this.metricName,
    required this.category,
    required this.yourValue,
    required this.peerMedian,
    required this.topQuartile,
    required this.unit,
    required this.trend,
    required this.trendPercent,
  });

  final String id;

  /// e.g. "Revenue per Partner", "Client Retention Rate"
  final String metricName;

  /// Financial, Operational, Client, Technology, Team
  final String category;

  /// Your firm's value
  final double yourValue;

  /// Anonymous peer median
  final double peerMedian;

  /// Top 25% value
  final double topQuartile;

  /// "₹L", "%", "days", "clients", "hrs", "ratio"
  final String unit;

  /// Up, Down, Stable
  final String trend;

  /// Year-over-year change percentage
  final double trendPercent;

  /// Whether your value is above the peer median.
  bool get isAboveMedian => yourValue >= peerMedian;

  /// Whether your value is significantly below median (>15% gap).
  bool get isSignificantlyBelowMedian {
    if (peerMedian == 0) {
      return false;
    }
    final gap = (peerMedian - yourValue) / peerMedian;
    return gap > 0.15;
  }

  /// Normalised position of your value on the scale [0, topQuartile].
  double get yourPosition {
    if (topQuartile == 0) {
      return 0;
    }
    return (yourValue / topQuartile).clamp(0.0, 1.0);
  }

  /// Normalised position of the peer median on the scale [0, topQuartile].
  double get medianPosition {
    if (topQuartile == 0) {
      return 0;
    }
    return (peerMedian / topQuartile).clamp(0.0, 1.0);
  }

  BenchmarkMetric copyWith({
    String? id,
    String? metricName,
    String? category,
    double? yourValue,
    double? peerMedian,
    double? topQuartile,
    String? unit,
    String? trend,
    double? trendPercent,
  }) {
    return BenchmarkMetric(
      id: id ?? this.id,
      metricName: metricName ?? this.metricName,
      category: category ?? this.category,
      yourValue: yourValue ?? this.yourValue,
      peerMedian: peerMedian ?? this.peerMedian,
      topQuartile: topQuartile ?? this.topQuartile,
      unit: unit ?? this.unit,
      trend: trend ?? this.trend,
      trendPercent: trendPercent ?? this.trendPercent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BenchmarkMetric && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

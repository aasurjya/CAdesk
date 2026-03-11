/// Category grouping for KPI metrics in a CA firm.
enum KpiCategory {
  firm('Firm'),
  engagement('Engagement'),
  compliance('Compliance'),
  staff('Staff');

  const KpiCategory(this.label);

  final String label;
}

/// Direction of change compared to the previous period.
enum KpiTrend {
  up('Up'),
  down('Down'),
  flat('Flat');

  const KpiTrend(this.label);

  final String label;
}

/// A single Key Performance Indicator tracked on the analytics dashboard.
class KpiMetric {
  const KpiMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.currentValue,
    required this.previousValue,
    required this.target,
    required this.unit,
    required this.trend,
    required this.periodLabel,
  });

  final String id;
  final String name;
  final KpiCategory category;
  final double currentValue;
  final double previousValue;
  final double target;
  final String unit;
  final KpiTrend trend;
  final String periodLabel;

  /// Percentage change from previous to current value.
  double get changePercent {
    if (previousValue == 0) return 0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }

  /// Progress toward the target as a 0-1 fraction.
  double get progressFraction {
    if (target == 0) return 0;
    return (currentValue / target).clamp(0.0, 1.0);
  }

  KpiMetric copyWith({
    String? id,
    String? name,
    KpiCategory? category,
    double? currentValue,
    double? previousValue,
    double? target,
    String? unit,
    KpiTrend? trend,
    String? periodLabel,
  }) {
    return KpiMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentValue: currentValue ?? this.currentValue,
      previousValue: previousValue ?? this.previousValue,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      trend: trend ?? this.trend,
      periodLabel: periodLabel ?? this.periodLabel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KpiMetric && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

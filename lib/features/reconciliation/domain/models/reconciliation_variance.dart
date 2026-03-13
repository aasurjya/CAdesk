/// Status of a reconciliation variance between two data sources.
enum VarianceStatus {
  /// Variance is within the acceptable threshold (typically ≤ ₹1,000).
  matched('Matched'),

  /// Variance is between ₹1,001 and ₹10,000 — likely a timing or rounding issue.
  minorVariance('Minor Variance'),

  /// Variance exceeds ₹10,000 — must be investigated before filing.
  majorVariance('Major Variance'),

  /// One source shows zero while the other has a non-zero amount.
  unmatched('Unmatched');

  const VarianceStatus(this.label);

  /// Human-readable label for UI display.
  final String label;
}

/// Immutable model representing the variance between two income/tax data sources
/// (e.g. Form 26AS vs AIS, or AIS vs ITR).
///
/// All monetary amounts are stored in **paise** (1 INR = 100 paise) to avoid
/// floating-point precision issues.
class ReconciliationVariance {
  const ReconciliationVariance({
    required this.source1Label,
    required this.source2Label,
    required this.source1Amount,
    required this.source2Amount,
    required this.variance,
    required this.variancePercent,
    required this.status,
    required this.threshold,
  });

  /// Human-readable label for the first data source (e.g. 'Form 26AS').
  final String source1Label;

  /// Human-readable label for the second data source (e.g. 'AIS').
  final String source2Label;

  /// Amount from the first source, in paise.
  final int source1Amount;

  /// Amount from the second source, in paise.
  final int source2Amount;

  /// Computed variance: source1Amount − source2Amount, in paise.
  final int variance;

  /// Variance as a percentage of source1Amount.
  ///
  /// Negative means source2 is higher; positive means source1 is higher.
  final double variancePercent;

  /// Match status based on [variance] and [threshold].
  final VarianceStatus status;

  /// Variance threshold in paise; amounts within this are considered matched.
  final int threshold;

  ReconciliationVariance copyWith({
    String? source1Label,
    String? source2Label,
    int? source1Amount,
    int? source2Amount,
    int? variance,
    double? variancePercent,
    VarianceStatus? status,
    int? threshold,
  }) {
    return ReconciliationVariance(
      source1Label: source1Label ?? this.source1Label,
      source2Label: source2Label ?? this.source2Label,
      source1Amount: source1Amount ?? this.source1Amount,
      source2Amount: source2Amount ?? this.source2Amount,
      variance: variance ?? this.variance,
      variancePercent: variancePercent ?? this.variancePercent,
      status: status ?? this.status,
      threshold: threshold ?? this.threshold,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReconciliationVariance &&
        other.source1Label == source1Label &&
        other.source2Label == source2Label &&
        other.source1Amount == source1Amount &&
        other.source2Amount == source2Amount &&
        other.variance == variance &&
        other.variancePercent == variancePercent &&
        other.status == status &&
        other.threshold == threshold;
  }

  @override
  int get hashCode => Object.hash(
    source1Label,
    source2Label,
    source1Amount,
    source2Amount,
    variance,
    variancePercent,
    status,
    threshold,
  );
}

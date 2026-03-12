/// Classification of a detected fraud indicator pattern.
enum FraudIndicatorType {
  roundNumberBias('Round Number Bias'),
  justBelowThreshold('Just-Below-Threshold'),
  unusualTiming('Unusual Timing'),
  duplicateAmount('Duplicate Amount'),
  velocityAnomaly('Velocity Anomaly');

  const FraudIndicatorType(this.label);
  final String label;
}

/// Severity of a fraud indicator.
enum FraudIndicatorSeverity {
  low('Low'),
  medium('Medium'),
  high('High');

  const FraudIndicatorSeverity(this.label);
  final String label;
}

/// Immutable model representing a detected fraud indicator.
///
/// Based on the ACFE Fraud Triangle: Pressure, Opportunity, Rationalisation.
class FraudIndicator {
  const FraudIndicator({
    required this.indicatorType,
    required this.description,
    required this.transactions,
    required this.severity,
  });

  final FraudIndicatorType indicatorType;
  final String description;

  /// Transaction IDs that contributed to this indicator.
  final List<String> transactions;
  final FraudIndicatorSeverity severity;

  FraudIndicator copyWith({
    FraudIndicatorType? indicatorType,
    String? description,
    List<String>? transactions,
    FraudIndicatorSeverity? severity,
  }) {
    return FraudIndicator(
      indicatorType: indicatorType ?? this.indicatorType,
      description: description ?? this.description,
      transactions: transactions ?? this.transactions,
      severity: severity ?? this.severity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FraudIndicator &&
        other.indicatorType == indicatorType &&
        other.description == description &&
        other.severity == severity;
  }

  @override
  int get hashCode => Object.hash(indicatorType, description, severity);
}

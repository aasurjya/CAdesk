/// Category of information reported in the Annual Information Statement.
enum AisCategory {
  /// Salary income reported by employer.
  salary('Salary'),

  /// Interest income from banks / deposits.
  interest('Interest'),

  /// Dividend income from shares / mutual funds.
  dividend('Dividend'),

  /// Sale of securities (shares, mutual funds, bonds).
  saleOfSecurities('Sale of Securities'),

  /// Purchase transactions (high-value).
  purchase('Purchase'),

  /// Other income not classified above.
  otherIncome('Other Income');

  const AisCategory(this.label);
  final String label;
}

/// Immutable model for a single entry from the Annual Information
/// Statement (AIS).
///
/// AIS is issued by the Income Tax Department and contains financial
/// transactions reported by various entities (banks, mutual funds,
/// employers, etc.). The assessee can accept, provide feedback, or
/// declare a different amount.
class AisEntry {
  const AisEntry({
    required this.category,
    required this.informationSource,
    required this.reportedAmount,
    this.declaredAmount,
  });

  /// Category of the AIS information.
  final AisCategory category;

  /// Name of the reporting entity (bank, employer, broker, etc.).
  final String informationSource;

  /// Amount reported by the information source.
  final double reportedAmount;

  /// Amount declared by the assessee (null if not yet responded).
  final double? declaredAmount;

  /// Whether there is a discrepancy between reported and declared amounts.
  ///
  /// A tolerance of ₹1 is used to account for rounding differences.
  bool get hasDiscrepancy =>
      declaredAmount != null && (declaredAmount! - reportedAmount).abs() > 1;

  AisEntry copyWith({
    AisCategory? category,
    String? informationSource,
    double? reportedAmount,
    double? declaredAmount,
  }) {
    return AisEntry(
      category: category ?? this.category,
      informationSource: informationSource ?? this.informationSource,
      reportedAmount: reportedAmount ?? this.reportedAmount,
      declaredAmount: declaredAmount ?? this.declaredAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AisEntry &&
        other.category == category &&
        other.informationSource == informationSource &&
        other.reportedAmount == reportedAmount &&
        other.declaredAmount == declaredAmount;
  }

  @override
  int get hashCode =>
      Object.hash(category, informationSource, reportedAmount, declaredAmount);
}

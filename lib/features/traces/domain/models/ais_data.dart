/// A single income entry in the Annual Information Statement.
class AisIncome {
  const AisIncome({
    required this.sourceType,
    required this.sourceName,
    required this.amount,
    required this.taxDeducted,
  });

  /// Category of income (e.g. "Salary", "Interest", "Dividend").
  final String sourceType;

  /// Name of the paying entity / payer.
  final String sourceName;

  /// Gross income amount in paise.
  final int amount;

  /// Tax deducted / withheld in paise.
  final int taxDeducted;

  AisIncome copyWith({
    String? sourceType,
    String? sourceName,
    int? amount,
    int? taxDeducted,
  }) {
    return AisIncome(
      sourceType: sourceType ?? this.sourceType,
      sourceName: sourceName ?? this.sourceName,
      amount: amount ?? this.amount,
      taxDeducted: taxDeducted ?? this.taxDeducted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisIncome &&
          runtimeType == other.runtimeType &&
          sourceType == other.sourceType &&
          sourceName == other.sourceName &&
          amount == other.amount &&
          taxDeducted == other.taxDeducted;

  @override
  int get hashCode =>
      Object.hash(sourceType, sourceName, amount, taxDeducted);
}

/// Immutable Annual Information Statement for a PAN and assessment year.
class AisData {
  const AisData({
    required this.pan,
    required this.assessmentYear,
    required this.incomeDetails,
  });

  /// 10-character PAN for which the AIS was downloaded.
  final String pan;

  /// Assessment year in YYYY-YY format, e.g. "2024-25".
  final String assessmentYear;

  final List<AisIncome> incomeDetails;

  /// Derived: total gross income across all sources in paise.
  int get totalIncome =>
      incomeDetails.fold(0, (sum, e) => sum + e.amount);

  AisData copyWith({
    String? pan,
    String? assessmentYear,
    List<AisIncome>? incomeDetails,
  }) {
    return AisData(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      incomeDetails: incomeDetails ?? this.incomeDetails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          assessmentYear == other.assessmentYear;

  @override
  int get hashCode => Object.hash(pan, assessmentYear);
}

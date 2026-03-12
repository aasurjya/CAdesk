/// Immutable model for FLA Return (Foreign Liabilities and Assets Annual Return).
///
/// The FLA Return must be submitted annually to RBI by Indian entities
/// that have received FDI or made overseas investments.
///
/// Filing deadline: July 15 of every year for the preceding financial year.
/// Non-filing attracts penalty under FEMA.
class FlaReturn {
  const FlaReturn({
    required this.entityName,
    required this.pan,
    required this.reportingYear,
    required this.totalForeignEquityLiabilitiesPaise,
    required this.totalForeignDebtLiabilitiesPaise,
    required this.totalForeignAssetsPaise,
  });

  final String entityName;

  /// PAN of the Indian entity.
  final String pan;

  /// Calendar year for which this return is being filed (e.g., 2024).
  final int reportingYear;

  /// Total foreign equity liabilities (FDI received) in paise.
  final int totalForeignEquityLiabilitiesPaise;

  /// Total foreign debt liabilities (ECB, etc.) in paise.
  final int totalForeignDebtLiabilitiesPaise;

  /// Total foreign assets (overseas direct investment, etc.) in paise.
  final int totalForeignAssetsPaise;

  FlaReturn copyWith({
    String? entityName,
    String? pan,
    int? reportingYear,
    int? totalForeignEquityLiabilitiesPaise,
    int? totalForeignDebtLiabilitiesPaise,
    int? totalForeignAssetsPaise,
  }) {
    return FlaReturn(
      entityName: entityName ?? this.entityName,
      pan: pan ?? this.pan,
      reportingYear: reportingYear ?? this.reportingYear,
      totalForeignEquityLiabilitiesPaise:
          totalForeignEquityLiabilitiesPaise ??
          this.totalForeignEquityLiabilitiesPaise,
      totalForeignDebtLiabilitiesPaise:
          totalForeignDebtLiabilitiesPaise ??
          this.totalForeignDebtLiabilitiesPaise,
      totalForeignAssetsPaise:
          totalForeignAssetsPaise ?? this.totalForeignAssetsPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlaReturn &&
        other.entityName == entityName &&
        other.pan == pan &&
        other.reportingYear == reportingYear &&
        other.totalForeignEquityLiabilitiesPaise ==
            totalForeignEquityLiabilitiesPaise &&
        other.totalForeignDebtLiabilitiesPaise ==
            totalForeignDebtLiabilitiesPaise &&
        other.totalForeignAssetsPaise == totalForeignAssetsPaise;
  }

  @override
  int get hashCode => Object.hash(
    entityName,
    pan,
    reportingYear,
    totalForeignEquityLiabilitiesPaise,
    totalForeignDebtLiabilitiesPaise,
    totalForeignAssetsPaise,
  );
}

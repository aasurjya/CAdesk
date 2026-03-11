/// Immutable model representing a greenhouse-gas emission metric for a client.
class CarbonMetric {
  const CarbonMetric({
    required this.id,
    required this.clientName,
    required this.scope,
    required this.emissionsTonnes,
    required this.reductionTargetPercent,
    required this.achievedPercent,
    required this.reportingYear,
    required this.unit,
  });

  /// Unique identifier for the carbon metric record.
  final String id;

  /// Full legal name of the client entity.
  final String clientName;

  /// GHG Protocol scope:
  /// Scope 1 (Direct) | Scope 2 (Electricity) | Scope 3 (Value Chain).
  final String scope;

  /// Total CO₂-equivalent emissions in tonnes for the reporting period.
  final double emissionsTonnes;

  /// Percentage reduction target vs. the baseline year.
  final double reductionTargetPercent;

  /// Percentage of the reduction target achieved in the current year.
  final double achievedPercent;

  /// Financial year of the report, e.g. "FY 2024-25".
  final String reportingYear;

  /// Measurement unit — typically "tCO2e".
  final String unit;

  CarbonMetric copyWith({
    String? id,
    String? clientName,
    String? scope,
    double? emissionsTonnes,
    double? reductionTargetPercent,
    double? achievedPercent,
    String? reportingYear,
    String? unit,
  }) {
    return CarbonMetric(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      scope: scope ?? this.scope,
      emissionsTonnes: emissionsTonnes ?? this.emissionsTonnes,
      reductionTargetPercent:
          reductionTargetPercent ?? this.reductionTargetPercent,
      achievedPercent: achievedPercent ?? this.achievedPercent,
      reportingYear: reportingYear ?? this.reportingYear,
      unit: unit ?? this.unit,
    );
  }
}

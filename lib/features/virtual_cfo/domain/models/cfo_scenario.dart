/// Immutable model representing a what-if financial scenario prepared by the
/// Virtual CFO for a client.
class CfoScenario {
  const CfoScenario({
    required this.id,
    required this.clientName,
    required this.scenarioName,
    required this.category,
    required this.baselineValue,
    required this.projectedValue,
    required this.impactPercent,
    required this.timeHorizon,
    required this.assumption,
  });

  final String id;
  final String clientName;

  /// E.g. Best Case, Base Case, Worst Case, Expansion Plan, Cost Optimization
  final String scenarioName;

  /// One of: Revenue | Cost | Funding | Tax | Working Capital
  final String category;

  /// Baseline value in Indian Rupee lakhs.
  final double baselineValue;

  /// Projected value in lakhs after applying the scenario.
  final double projectedValue;

  /// Percentage change from baseline to projected (positive = improvement).
  final double impactPercent;

  /// Time horizon label, e.g. "Q1 FY26", "FY26", "3-year".
  final String timeHorizon;

  /// Key assumption that drives the scenario.
  final String assumption;

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  /// Whether the projected outcome is an improvement over baseline.
  bool get isPositive => impactPercent >= 0;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  CfoScenario copyWith({
    String? id,
    String? clientName,
    String? scenarioName,
    String? category,
    double? baselineValue,
    double? projectedValue,
    double? impactPercent,
    String? timeHorizon,
    String? assumption,
  }) {
    return CfoScenario(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      scenarioName: scenarioName ?? this.scenarioName,
      category: category ?? this.category,
      baselineValue: baselineValue ?? this.baselineValue,
      projectedValue: projectedValue ?? this.projectedValue,
      impactPercent: impactPercent ?? this.impactPercent,
      timeHorizon: timeHorizon ?? this.timeHorizon,
      assumption: assumption ?? this.assumption,
    );
  }
}

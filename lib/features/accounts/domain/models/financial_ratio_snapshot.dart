/// Immutable snapshot of computed financial ratios for a client and period.
class FinancialRatioSnapshot {
  const FinancialRatioSnapshot({
    required this.clientId,
    required this.clientName,
    required this.period,
    required this.currentRatio,
    required this.quickRatio,
    required this.grossMargin,
    required this.netMargin,
    required this.roe,
    required this.debtToEquity,
    required this.debtorDays,
    required this.creditorDays,
    required this.inventoryDays,
    required this.ebitdaMargin,
    required this.interestCoverage,
    this.isServiceBusiness = false,
  });

  final String clientId;
  final String clientName;

  /// e.g. "FY 2024-25"
  final String period;
  final double currentRatio;
  final double quickRatio;
  final double grossMargin;
  final double netMargin;
  final double roe;
  final double debtToEquity;
  final double debtorDays;
  final double creditorDays;
  final double inventoryDays;
  final double ebitdaMargin;
  final double interestCoverage;

  /// When true, inventory-related ratios show N/A in the UI.
  final bool isServiceBusiness;

  /// Returns "Healthy", "Watch", or "Concern" based on ratio benchmarks.
  String get overallRating {
    int concerns = 0;
    if (currentRatio < 1.0) concerns++;
    if (netMargin < 5.0) concerns++;
    if (debtToEquity > 2.0) concerns++;
    if (roe < 8.0) concerns++;
    if (concerns == 0) return 'Healthy';
    if (concerns <= 2) return 'Watch';
    return 'Concern';
  }

  FinancialRatioSnapshot copyWith({
    String? clientId,
    String? clientName,
    String? period,
    double? currentRatio,
    double? quickRatio,
    double? grossMargin,
    double? netMargin,
    double? roe,
    double? debtToEquity,
    double? debtorDays,
    double? creditorDays,
    double? inventoryDays,
    double? ebitdaMargin,
    double? interestCoverage,
    bool? isServiceBusiness,
  }) {
    return FinancialRatioSnapshot(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      period: period ?? this.period,
      currentRatio: currentRatio ?? this.currentRatio,
      quickRatio: quickRatio ?? this.quickRatio,
      grossMargin: grossMargin ?? this.grossMargin,
      netMargin: netMargin ?? this.netMargin,
      roe: roe ?? this.roe,
      debtToEquity: debtToEquity ?? this.debtToEquity,
      debtorDays: debtorDays ?? this.debtorDays,
      creditorDays: creditorDays ?? this.creditorDays,
      inventoryDays: inventoryDays ?? this.inventoryDays,
      ebitdaMargin: ebitdaMargin ?? this.ebitdaMargin,
      interestCoverage: interestCoverage ?? this.interestCoverage,
      isServiceBusiness: isServiceBusiness ?? this.isServiceBusiness,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialRatioSnapshot &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          period == other.period;

  @override
  int get hashCode => Object.hash(clientId, period);
}

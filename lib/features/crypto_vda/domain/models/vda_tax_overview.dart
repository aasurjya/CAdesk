/// Immutable aggregate VDA tax overview across all clients.
class VdaTaxOverview {
  const VdaTaxOverview({
    required this.totalGains,
    required this.totalLosses,
    required this.totalTaxLiability,
    required this.totalTdsCollected,
    required this.totalTdsShortfall,
    required this.lossRestrictionViolations,
  });

  final double totalGains;
  final double totalLosses;
  final double totalTaxLiability;
  final double totalTdsCollected;
  final double totalTdsShortfall;
  final int lossRestrictionViolations;
}

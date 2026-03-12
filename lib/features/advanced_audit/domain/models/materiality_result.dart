/// Immutable result of a materiality computation for a statutory audit.
///
/// Follows ISA 320 — Materiality in Planning and Performing an Audit.
/// All amounts are in paise (1 paise = 1/100 rupee).
class MaterialityResult {
  const MaterialityResult({
    required this.planningMateriality,
    required this.performanceMateriality,
    required this.revenueBasis,
    required this.assetBasis,
    required this.profitBasis,
  });

  /// Planning materiality: the lowest of the three basis amounts.
  final int planningMateriality;

  /// Performance materiality: 75% of [planningMateriality] (ISA 320.11).
  final int performanceMateriality;

  /// 0.5% of total revenue.
  final int revenueBasis;

  /// 1% of total assets.
  final int assetBasis;

  /// 5% of profit before tax (or 0 when PBT is negative).
  final int profitBasis;

  MaterialityResult copyWith({
    int? planningMateriality,
    int? performanceMateriality,
    int? revenueBasis,
    int? assetBasis,
    int? profitBasis,
  }) {
    return MaterialityResult(
      planningMateriality: planningMateriality ?? this.planningMateriality,
      performanceMateriality:
          performanceMateriality ?? this.performanceMateriality,
      revenueBasis: revenueBasis ?? this.revenueBasis,
      assetBasis: assetBasis ?? this.assetBasis,
      profitBasis: profitBasis ?? this.profitBasis,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialityResult &&
        other.planningMateriality == planningMateriality &&
        other.performanceMateriality == performanceMateriality &&
        other.revenueBasis == revenueBasis &&
        other.assetBasis == assetBasis &&
        other.profitBasis == profitBasis;
  }

  @override
  int get hashCode => Object.hash(
    planningMateriality,
    performanceMateriality,
    revenueBasis,
    assetBasis,
    profitBasis,
  );
}

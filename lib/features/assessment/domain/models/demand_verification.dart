/// Represents the verification of a specific tax demand raised in an order.
///
/// A demand may be partly agreed (arithmetical error accepted) and partly
/// disputed (e.g., disallowance contested before CIT(A)).
///
/// All monetary amounts are in **paise** (integer).
class DemandVerification {
  const DemandVerification({
    required this.demandId,
    required this.section,
    required this.originalDemand,
    required this.rectificationClaim,
    required this.agreedAmount,
    required this.disputedAmount,
  });

  /// Unique demand reference number from the notice.
  final String demandId;

  /// Section under which the demand was raised, e.g. "143(1)", "156".
  final String section;

  /// Original demand as per the order (paise).
  final int originalDemand;

  /// Amount the taxpayer claims should be rectified / withdrawn (paise).
  final int rectificationClaim;

  /// Amount the taxpayer concedes is correct (paise).
  final int agreedAmount;

  /// Amount the taxpayer is disputing before appellate authorities (paise).
  final int disputedAmount;

  DemandVerification copyWith({
    String? demandId,
    String? section,
    int? originalDemand,
    int? rectificationClaim,
    int? agreedAmount,
    int? disputedAmount,
  }) {
    return DemandVerification(
      demandId: demandId ?? this.demandId,
      section: section ?? this.section,
      originalDemand: originalDemand ?? this.originalDemand,
      rectificationClaim: rectificationClaim ?? this.rectificationClaim,
      agreedAmount: agreedAmount ?? this.agreedAmount,
      disputedAmount: disputedAmount ?? this.disputedAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DemandVerification &&
        other.demandId == demandId &&
        other.section == section &&
        other.originalDemand == originalDemand &&
        other.rectificationClaim == rectificationClaim &&
        other.agreedAmount == agreedAmount &&
        other.disputedAmount == disputedAmount;
  }

  @override
  int get hashCode => Object.hash(
    demandId,
    section,
    originalDemand,
    rectificationClaim,
    agreedAmount,
    disputedAmount,
  );
}

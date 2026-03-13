/// Status of a charge registered with the MCA.
enum ChargeStatus { open, satisfied, modifiedSatisfied }

/// Immutable record of a charge registered against a company.
class ChargeRecord {
  const ChargeRecord({
    required this.chargeId,
    required this.holderName,
    required this.amount,
    required this.dateOfCreation,
    required this.status,
    this.dateOfSatisfaction,
    this.assets,
  });

  /// Unique charge ID assigned by MCA.
  final String chargeId;

  /// Name of the charge holder (lender / bank).
  final String holderName;

  /// Charge amount in paise.
  final int amount;

  final DateTime dateOfCreation;

  final ChargeStatus status;

  final DateTime? dateOfSatisfaction;

  /// Brief description of assets charged (optional).
  final String? assets;

  bool get isSatisfied =>
      status == ChargeStatus.satisfied ||
      status == ChargeStatus.modifiedSatisfied;

  ChargeRecord copyWith({
    String? chargeId,
    String? holderName,
    int? amount,
    DateTime? dateOfCreation,
    ChargeStatus? status,
    DateTime? dateOfSatisfaction,
    String? assets,
  }) {
    return ChargeRecord(
      chargeId: chargeId ?? this.chargeId,
      holderName: holderName ?? this.holderName,
      amount: amount ?? this.amount,
      dateOfCreation: dateOfCreation ?? this.dateOfCreation,
      status: status ?? this.status,
      dateOfSatisfaction: dateOfSatisfaction ?? this.dateOfSatisfaction,
      assets: assets ?? this.assets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChargeRecord &&
          runtimeType == other.runtimeType &&
          chargeId == other.chargeId &&
          holderName == other.holderName &&
          amount == other.amount &&
          dateOfCreation == other.dateOfCreation &&
          status == other.status &&
          dateOfSatisfaction == other.dateOfSatisfaction &&
          assets == other.assets;

  @override
  int get hashCode => Object.hash(
        chargeId,
        holderName,
        amount,
        dateOfCreation,
        status,
        dateOfSatisfaction,
        assets,
      );
}

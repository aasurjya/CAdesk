/// Classification of VDA holding period.
///
/// Under the Finance Act 2022 (Section 115BBH), all VDA gains are taxed
/// at a flat 30% rate regardless of holding period. The period classification
/// is maintained for record-keeping but does not affect the tax rate.
enum VdaPeriod {
  /// Held for less than or equal to 36 months.
  shortTerm,

  /// Held for more than 36 months.
  longTerm,
}

/// Immutable model representing a single Virtual Digital Asset (VDA) transaction.
///
/// Under Section 115BBH (effective FY 2022-23):
/// - Tax at 30% flat rate (no deductions allowed except cost of acquisition)
/// - Losses from VDA cannot be set off against any other income
/// - VDA losses cannot be set off against VDA gains
/// - No indexation benefit
/// - 1% TDS deducted by buyer on seller (Section 194S)
class VdaTransaction {
  VdaTransaction({
    required this.assetName,
    required this.acquisitionDate,
    required this.transferDate,
    required this.acquisitionCostPaise,
    required this.saleConsiderationPaise,
  }) : period = transferDate.difference(acquisitionDate).inDays > 1095
           ? VdaPeriod.longTerm
           : VdaPeriod.shortTerm;

  /// Name or description of the VDA (e.g., 'Bitcoin', 'Ethereum', 'NFT #123').
  final String assetName;
  final DateTime acquisitionDate;
  final DateTime transferDate;

  /// Cost of acquisition in paise.
  final int acquisitionCostPaise;

  /// Sale consideration received in paise.
  final int saleConsiderationPaise;

  /// Holding period classification (computed from dates).
  final VdaPeriod period;

  /// Gain or loss in paise (positive = gain, negative = loss).
  int get gainPaise => saleConsiderationPaise - acquisitionCostPaise;

  VdaTransaction copyWith({
    String? assetName,
    DateTime? acquisitionDate,
    DateTime? transferDate,
    int? acquisitionCostPaise,
    int? saleConsiderationPaise,
  }) {
    return VdaTransaction(
      assetName: assetName ?? this.assetName,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      transferDate: transferDate ?? this.transferDate,
      acquisitionCostPaise: acquisitionCostPaise ?? this.acquisitionCostPaise,
      saleConsiderationPaise:
          saleConsiderationPaise ?? this.saleConsiderationPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VdaTransaction &&
        other.assetName == assetName &&
        other.acquisitionDate == acquisitionDate &&
        other.transferDate == transferDate &&
        other.acquisitionCostPaise == acquisitionCostPaise &&
        other.saleConsiderationPaise == saleConsiderationPaise;
  }

  @override
  int get hashCode => Object.hash(
    assetName,
    acquisitionDate,
    transferDate,
    acquisitionCostPaise,
    saleConsiderationPaise,
  );
}

/// Immutable model for Schedule AL (Assets and Liabilities) in ITR-2.
///
/// Schedule AL is mandatory when total income exceeds ₹50,00,000 for the
/// assessment year. It captures the assets and liabilities of the taxpayer
/// as at the end of the previous year (31 March).
///
/// Categories:
/// - Immovable property (land, buildings, flats)
/// - Movable property (vehicles, jewellery, art, etc.)
/// - Financial assets (shares, MF units, bank balances, etc.)
/// - Liabilities (mortgages, loans, other payables)
class ScheduleAl {
  const ScheduleAl({
    required this.immovablePropertyValue,
    required this.movablePropertyValue,
    required this.financialAssetValue,
    required this.totalLiabilities,
  });

  factory ScheduleAl.empty() => const ScheduleAl(
    immovablePropertyValue: 0,
    movablePropertyValue: 0,
    financialAssetValue: 0,
    totalLiabilities: 0,
  );

  /// Value of all immovable properties as at 31 March (in INR).
  ///
  /// Includes land, residential flats, commercial property, etc.
  /// Use the cost of acquisition or stamp duty value, as applicable.
  final double immovablePropertyValue;

  /// Value of movable assets as at 31 March (in INR).
  ///
  /// Includes jewellery, vehicles, paintings, sculptures, and other
  /// high-value movable property.
  final double movablePropertyValue;

  /// Value of financial assets as at 31 March (in INR).
  ///
  /// Includes shares, debentures, MF units, bank FDs, bonds, and other
  /// financial instruments.
  final double financialAssetValue;

  /// Total liabilities corresponding to the assets declared above (in INR).
  ///
  /// Includes housing loans, vehicle loans, personal loans, and any other
  /// borrowings secured or unsecured.
  final double totalLiabilities;

  /// Total aggregate value of all assets.
  double get totalAssets =>
      immovablePropertyValue + movablePropertyValue + financialAssetValue;

  /// Net worth = totalAssets - totalLiabilities.
  ///
  /// Can be negative if liabilities exceed assets.
  double get netWorth => totalAssets - totalLiabilities;

  ScheduleAl copyWith({
    double? immovablePropertyValue,
    double? movablePropertyValue,
    double? financialAssetValue,
    double? totalLiabilities,
  }) {
    return ScheduleAl(
      immovablePropertyValue:
          immovablePropertyValue ?? this.immovablePropertyValue,
      movablePropertyValue: movablePropertyValue ?? this.movablePropertyValue,
      financialAssetValue: financialAssetValue ?? this.financialAssetValue,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleAl &&
        other.immovablePropertyValue == immovablePropertyValue &&
        other.movablePropertyValue == movablePropertyValue &&
        other.financialAssetValue == financialAssetValue &&
        other.totalLiabilities == totalLiabilities;
  }

  @override
  int get hashCode => Object.hash(
    immovablePropertyValue,
    movablePropertyValue,
    financialAssetValue,
    totalLiabilities,
  );
}

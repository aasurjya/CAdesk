/// Asset block classifications per the Income Tax Act.
enum AssetBlock {
  building(label: 'Building', defaultRate: 10.0),
  plant(label: 'Plant & Machinery', defaultRate: 15.0),
  furniture(label: 'Furniture', defaultRate: 10.0),
  computer(label: 'Computer', defaultRate: 40.0),
  vehicle(label: 'Vehicle', defaultRate: 15.0),
  intangible(label: 'Intangible', defaultRate: 25.0);

  const AssetBlock({required this.label, required this.defaultRate});

  final String label;

  /// Default WDV rate (%) per IT Act.
  final double defaultRate;
}

/// Immutable depreciation entry for an asset under the Written Down Value method.
class DepreciationEntry {
  const DepreciationEntry({
    required this.id,
    required this.clientId,
    required this.assetName,
    required this.assetBlock,
    required this.openingWDV,
    required this.additions,
    required this.disposals,
    required this.rate,
    required this.depreciation,
    required this.closingWDV,
    required this.financialYear,
  });

  final String id;
  final String clientId;
  final String assetName;
  final AssetBlock assetBlock;

  /// Opening written-down value at start of year (INR).
  final double openingWDV;

  /// Additions during the year (INR).
  final double additions;

  /// Disposals / sales during the year (INR).
  final double disposals;

  /// Depreciation rate applied (%).
  final double rate;

  /// Calculated depreciation for the year (INR).
  final double depreciation;

  /// Closing WDV at end of year (INR).
  final double closingWDV;

  /// e.g. "FY 2024-25"
  final String financialYear;

  DepreciationEntry copyWith({
    String? id,
    String? clientId,
    String? assetName,
    AssetBlock? assetBlock,
    double? openingWDV,
    double? additions,
    double? disposals,
    double? rate,
    double? depreciation,
    double? closingWDV,
    String? financialYear,
  }) {
    return DepreciationEntry(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      assetName: assetName ?? this.assetName,
      assetBlock: assetBlock ?? this.assetBlock,
      openingWDV: openingWDV ?? this.openingWDV,
      additions: additions ?? this.additions,
      disposals: disposals ?? this.disposals,
      rate: rate ?? this.rate,
      depreciation: depreciation ?? this.depreciation,
      closingWDV: closingWDV ?? this.closingWDV,
      financialYear: financialYear ?? this.financialYear,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepreciationEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

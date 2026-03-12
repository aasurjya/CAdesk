/// Asset category per Companies Act Schedule II.
enum AssetCategory {
  /// Buildings — useful life 30 years (non-residential factory) or 60 years.
  building,

  /// Plant and machinery — useful life 15 years.
  plantAndMachinery,

  /// Furniture and fittings — useful life 10 years.
  furnitureAndFittings,

  /// Computers, servers, peripherals — useful life 3 years.
  computerAndPeripherals,

  /// Motor vehicles — useful life 8 years.
  motorVehicle,

  /// Office equipment — useful life 5 years.
  officeEquipment,

  /// Intangible assets (patents, trademarks) — useful life 10 years.
  intangibleAsset,
}

/// Depreciation method.
enum DepreciationMethod {
  /// Straight Line Method — equal annual charge over useful life.
  slm,

  /// Written Down Value — declining balance method.
  wdv,
}

/// Useful life (in years) per Companies Act Schedule II for SLM computation.
const Map<AssetCategory, int> scheduleIIUsefulLifeYears = {
  AssetCategory.building: 30,
  AssetCategory.plantAndMachinery: 15,
  AssetCategory.furnitureAndFittings: 10,
  AssetCategory.computerAndPeripherals: 3,
  AssetCategory.motorVehicle: 8,
  AssetCategory.officeEquipment: 5,
  AssetCategory.intangibleAsset: 10,
};

/// WDV rates (%) for each asset category (approximate IT-Act-aligned rates
/// used when WDV method is chosen).
const Map<AssetCategory, double> wdvRates = {
  AssetCategory.building: 10.0,
  AssetCategory.plantAndMachinery: 15.0,
  AssetCategory.furnitureAndFittings: 10.0,
  AssetCategory.computerAndPeripherals: 40.0,
  AssetCategory.motorVehicle: 25.89,
  AssetCategory.officeEquipment: 20.0,
  AssetCategory.intangibleAsset: 25.0,
};

/// An asset block for depreciation computation.
///
/// All amounts are in paise (int).
class AssetBlock {
  const AssetBlock({
    required this.id,
    required this.assetName,
    required this.category,
    required this.openingWdvPaise,
    required this.additionsPaise,
    required this.additionDate,
    required this.disposalsPaise,
    required this.disposalDate,
    required this.depreciationMethod,
  });

  final String id;
  final String assetName;
  final AssetCategory category;

  /// Opening WDV at start of financial year (paise).
  final int openingWdvPaise;

  /// Cost of additions during the year (paise).
  final int additionsPaise;

  /// Date of addition (null if no addition).
  final DateTime? additionDate;

  /// Cost of assets disposed during the year (paise).
  final int disposalsPaise;

  /// Date of disposal (null if no disposal).
  final DateTime? disposalDate;

  final DepreciationMethod depreciationMethod;

  AssetBlock copyWith({
    String? id,
    String? assetName,
    AssetCategory? category,
    int? openingWdvPaise,
    int? additionsPaise,
    DateTime? additionDate,
    int? disposalsPaise,
    DateTime? disposalDate,
    DepreciationMethod? depreciationMethod,
  }) {
    return AssetBlock(
      id: id ?? this.id,
      assetName: assetName ?? this.assetName,
      category: category ?? this.category,
      openingWdvPaise: openingWdvPaise ?? this.openingWdvPaise,
      additionsPaise: additionsPaise ?? this.additionsPaise,
      additionDate: additionDate ?? this.additionDate,
      disposalsPaise: disposalsPaise ?? this.disposalsPaise,
      disposalDate: disposalDate ?? this.disposalDate,
      depreciationMethod: depreciationMethod ?? this.depreciationMethod,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetBlock &&
        other.id == id &&
        other.assetName == assetName &&
        other.category == category &&
        other.openingWdvPaise == openingWdvPaise &&
        other.additionsPaise == additionsPaise &&
        other.additionDate == additionDate &&
        other.disposalsPaise == disposalsPaise &&
        other.disposalDate == disposalDate &&
        other.depreciationMethod == depreciationMethod;
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetName,
    category,
    openingWdvPaise,
    additionsPaise,
    additionDate,
    disposalsPaise,
    disposalDate,
    depreciationMethod,
  );
}

/// Immutable result of a Schedule II depreciation computation for one asset.
///
/// All amounts are in paise (int).
class ScheduleIIDepreciation {
  const ScheduleIIDepreciation({
    required this.assetBlock,
    required this.depreciationForYearPaise,
    required this.closingWdvPaise,
    required this.financialYear,
    required this.usefulLifeYears,
    required this.slmRatePercent,
  });

  final AssetBlock assetBlock;

  /// Depreciation charged for the year (paise).
  final int depreciationForYearPaise;

  /// Closing WDV at year end (paise), floored at zero.
  final int closingWdvPaise;

  /// Financial year (e.g. 2025 = FY 2024-25).
  final int financialYear;

  /// Useful life used for SLM computation (years).
  final int usefulLifeYears;

  /// SLM rate as a percentage (100 / usefulLifeYears).
  final double slmRatePercent;

  ScheduleIIDepreciation copyWith({
    AssetBlock? assetBlock,
    int? depreciationForYearPaise,
    int? closingWdvPaise,
    int? financialYear,
    int? usefulLifeYears,
    double? slmRatePercent,
  }) {
    return ScheduleIIDepreciation(
      assetBlock: assetBlock ?? this.assetBlock,
      depreciationForYearPaise:
          depreciationForYearPaise ?? this.depreciationForYearPaise,
      closingWdvPaise: closingWdvPaise ?? this.closingWdvPaise,
      financialYear: financialYear ?? this.financialYear,
      usefulLifeYears: usefulLifeYears ?? this.usefulLifeYears,
      slmRatePercent: slmRatePercent ?? this.slmRatePercent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleIIDepreciation &&
        other.assetBlock == assetBlock &&
        other.depreciationForYearPaise == depreciationForYearPaise &&
        other.closingWdvPaise == closingWdvPaise &&
        other.financialYear == financialYear &&
        other.usefulLifeYears == usefulLifeYears &&
        other.slmRatePercent == slmRatePercent;
  }

  @override
  int get hashCode => Object.hash(
    assetBlock,
    depreciationForYearPaise,
    closingWdvPaise,
    financialYear,
    usefulLifeYears,
    slmRatePercent,
  );
}

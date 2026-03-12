import 'dart:math' show max;

// ---------------------------------------------------------------------------
// Short-term capital gain entry models
// ---------------------------------------------------------------------------

/// Immutable model for a short-term capital gain on listed equity/MF
/// (Section 111A — STT paid transactions).
class EquityStcgEntry {
  const EquityStcgEntry({
    required this.description,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.transferExpenses,
  });

  /// Description of the asset (e.g., 'HDFC Bank shares', 'Nifty 50 ETF').
  final String description;

  /// Full sale consideration received.
  final double salePrice;

  /// Original cost of acquisition (no indexation for STCG).
  final double costOfAcquisition;

  /// Expenses incurred in connection with the transfer (brokerage, STT, etc.).
  final double transferExpenses;

  /// Net short-term capital gain (positive = gain, negative = loss).
  double get gain => salePrice - costOfAcquisition - transferExpenses;

  EquityStcgEntry copyWith({
    String? description,
    double? salePrice,
    double? costOfAcquisition,
    double? transferExpenses,
  }) {
    return EquityStcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      transferExpenses: transferExpenses ?? this.transferExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EquityStcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.transferExpenses == transferExpenses;
  }

  @override
  int get hashCode =>
      Object.hash(description, salePrice, costOfAcquisition, transferExpenses);
}

/// Immutable model for a long-term capital gain on listed equity/MF
/// (Section 112A — STT paid; includes grandfathering as of 31-Jan-2018).
class EquityLtcgEntry {
  const EquityLtcgEntry({
    required this.description,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.fmvOn31Jan2018,
    required this.transferExpenses,
  });

  /// Description of the asset.
  final String description;

  /// Full sale consideration received.
  final double salePrice;

  /// Actual cost of acquisition.
  final double costOfAcquisition;

  /// Fair market value as on 31 January 2018 (grandfathering per Section 112A).
  ///
  /// For assets acquired before 31-Jan-2018, the effective CoA is
  /// max(actual cost, FMV on 31-Jan-2018), ensuring legacy gains are protected.
  final double fmvOn31Jan2018;

  /// Expenses incurred in connection with the transfer.
  final double transferExpenses;

  /// Effective cost of acquisition after applying grandfathering rule.
  ///
  /// Grandfathering: CoA = max(actual cost, FMV on 31-Jan-2018).
  double get effectiveCostOfAcquisition =>
      max(costOfAcquisition, fmvOn31Jan2018);

  /// Net long-term capital gain using grandfathered CoA.
  double get gain => salePrice - effectiveCostOfAcquisition - transferExpenses;

  EquityLtcgEntry copyWith({
    String? description,
    double? salePrice,
    double? costOfAcquisition,
    double? fmvOn31Jan2018,
    double? transferExpenses,
  }) {
    return EquityLtcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      fmvOn31Jan2018: fmvOn31Jan2018 ?? this.fmvOn31Jan2018,
      transferExpenses: transferExpenses ?? this.transferExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EquityLtcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.fmvOn31Jan2018 == fmvOn31Jan2018 &&
        other.transferExpenses == transferExpenses;
  }

  @override
  int get hashCode => Object.hash(
    description,
    salePrice,
    costOfAcquisition,
    fmvOn31Jan2018,
    transferExpenses,
  );
}

/// Immutable model for STCG on debt mutual funds/bonds (slab rate).
class DebtStcgEntry {
  const DebtStcgEntry({
    required this.description,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.transferExpenses,
  });

  final String description;
  final double salePrice;
  final double costOfAcquisition;
  final double transferExpenses;

  double get gain => salePrice - costOfAcquisition - transferExpenses;

  DebtStcgEntry copyWith({
    String? description,
    double? salePrice,
    double? costOfAcquisition,
    double? transferExpenses,
  }) {
    return DebtStcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      transferExpenses: transferExpenses ?? this.transferExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DebtStcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.transferExpenses == transferExpenses;
  }

  @override
  int get hashCode =>
      Object.hash(description, salePrice, costOfAcquisition, transferExpenses);
}

/// Immutable model for LTCG on debt mutual funds/bonds (Section 112, slab rate
/// post Finance Act 2023 — debt MF LTCG is now taxed at slab rates).
class DebtLtcgEntry {
  const DebtLtcgEntry({
    required this.description,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.transferExpenses,
  });

  final String description;
  final double salePrice;
  final double costOfAcquisition;
  final double transferExpenses;

  double get gain => salePrice - costOfAcquisition - transferExpenses;

  DebtLtcgEntry copyWith({
    String? description,
    double? salePrice,
    double? costOfAcquisition,
    double? transferExpenses,
  }) {
    return DebtLtcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      transferExpenses: transferExpenses ?? this.transferExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DebtLtcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.transferExpenses == transferExpenses;
  }

  @override
  int get hashCode =>
      Object.hash(description, salePrice, costOfAcquisition, transferExpenses);
}

/// Immutable model for LTCG on immovable property (Section 112 — 20%
/// with indexation for acquisitions on or before 23-Jul-2024;
/// 12.5% without indexation for new acquisitions after 23-Jul-2024
/// per Budget 2024).
///
/// The [indexedCostOfAcquisition] field stores the already-computed
/// indexed cost (caller is responsible for CII-based indexation).
class PropertyLtcgEntry {
  const PropertyLtcgEntry({
    required this.description,
    required this.salePrice,
    required this.indexedCostOfAcquisition,
    required this.improvementCost,
    required this.transferExpenses,
    required this.acquisitionDate,
  });

  /// Description of the property (e.g., 'Flat in Mumbai').
  final String description;

  /// Full sale consideration or stamp duty value, whichever is higher.
  final double salePrice;

  /// Cost of acquisition already indexed using Cost Inflation Index (CII).
  ///
  /// For acquisitions after 23-Jul-2024, use actual cost (no indexation).
  final double indexedCostOfAcquisition;

  /// Cost of improvement (indexed or actual, per Budget 2024 provisions).
  final double improvementCost;

  /// Brokerage, legal fees, and other transfer expenses.
  final double transferExpenses;

  /// Date of acquisition (determines indexation eligibility).
  final DateTime acquisitionDate;

  /// Net LTCG on property after all deductions.
  double get gain =>
      salePrice - indexedCostOfAcquisition - improvementCost - transferExpenses;

  PropertyLtcgEntry copyWith({
    String? description,
    double? salePrice,
    double? indexedCostOfAcquisition,
    double? improvementCost,
    double? transferExpenses,
    DateTime? acquisitionDate,
  }) {
    return PropertyLtcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      indexedCostOfAcquisition:
          indexedCostOfAcquisition ?? this.indexedCostOfAcquisition,
      improvementCost: improvementCost ?? this.improvementCost,
      transferExpenses: transferExpenses ?? this.transferExpenses,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyLtcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.indexedCostOfAcquisition == indexedCostOfAcquisition &&
        other.improvementCost == improvementCost &&
        other.transferExpenses == transferExpenses &&
        other.acquisitionDate == acquisitionDate;
  }

  @override
  int get hashCode => Object.hash(
    description,
    salePrice,
    indexedCostOfAcquisition,
    improvementCost,
    transferExpenses,
    acquisitionDate,
  );
}

/// Immutable model for STCG on other assets (unlisted shares, jewellery,
/// paintings, etc.) — taxable at slab rates.
class OtherStcgEntry {
  const OtherStcgEntry({
    required this.description,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.transferExpenses,
  });

  final String description;
  final double salePrice;
  final double costOfAcquisition;
  final double transferExpenses;

  double get gain => salePrice - costOfAcquisition - transferExpenses;

  OtherStcgEntry copyWith({
    String? description,
    double? salePrice,
    double? costOfAcquisition,
    double? transferExpenses,
  }) {
    return OtherStcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      transferExpenses: transferExpenses ?? this.transferExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtherStcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.transferExpenses == transferExpenses;
  }

  @override
  int get hashCode =>
      Object.hash(description, salePrice, costOfAcquisition, transferExpenses);
}

/// Immutable model for LTCG on other assets (Section 112 — 20% with
/// indexation or 10% without indexation, whichever is lower).
class OtherLtcgEntry {
  const OtherLtcgEntry({
    required this.description,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.indexedCostOfAcquisition,
    required this.transferExpenses,
  });

  final String description;
  final double salePrice;

  /// Actual (unindexed) cost of acquisition.
  final double costOfAcquisition;

  /// CII-indexed cost of acquisition.
  final double indexedCostOfAcquisition;

  final double transferExpenses;

  /// LTCG with indexation (used for 20% rate computation).
  double get gainWithIndexation =>
      salePrice - indexedCostOfAcquisition - transferExpenses;

  /// LTCG without indexation (used for 10% rate computation).
  double get gainWithoutIndexation =>
      salePrice - costOfAcquisition - transferExpenses;

  OtherLtcgEntry copyWith({
    String? description,
    double? salePrice,
    double? costOfAcquisition,
    double? indexedCostOfAcquisition,
    double? transferExpenses,
  }) {
    return OtherLtcgEntry(
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      indexedCostOfAcquisition:
          indexedCostOfAcquisition ?? this.indexedCostOfAcquisition,
      transferExpenses: transferExpenses ?? this.transferExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtherLtcgEntry &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.indexedCostOfAcquisition == indexedCostOfAcquisition &&
        other.transferExpenses == transferExpenses;
  }

  @override
  int get hashCode => Object.hash(
    description,
    salePrice,
    costOfAcquisition,
    indexedCostOfAcquisition,
    transferExpenses,
  );
}

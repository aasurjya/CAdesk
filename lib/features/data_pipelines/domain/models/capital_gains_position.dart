import 'package:ca_app/features/data_pipelines/domain/models/broker_transaction.dart';

/// Tax category under Indian Income Tax Act for capital gains reporting.
///
/// - [stcg111a]: Short-term capital gains on listed equity/equity-MF (Sec 111A, 15%)
/// - [ltcg112a]: Long-term capital gains on listed equity/equity-MF (Sec 112A, 10% above ₹1 lakh)
/// - [stcgOther]: Short-term capital gains — other assets (slab rate)
/// - [ltcgOther]: Long-term capital gains — other assets (Sec 112, 20% with indexation)
/// - [exempt]: Exempt income (e.g. Equity LTCG within ₹1 lakh threshold)
enum TaxCategory {
  stcg111a,
  ltcg112a,
  stcgOther,
  ltcgOther,
  exempt,
}

/// Immutable model representing a matched buy-sell capital gains position.
///
/// Each [CapitalGainsPosition] corresponds to a **single lot** matched by the
/// FIFO algorithm: one acquisition date / cost paired with a specific portion
/// of a sell transaction.
///
/// All monetary amounts are in **paise** (₹1 = 100 paise).
class CapitalGainsPosition {
  const CapitalGainsPosition({
    required this.isin,
    required this.scripName,
    required this.assetType,
    required this.acquisitionDate,
    required this.acquisitionCost,
    required this.saleDate,
    required this.saleProceeds,
    required this.quantity,
    required this.indexedCost,
    required this.gainLoss,
    required this.holdingPeriod,
    required this.isLongTerm,
    required this.taxCategory,
  });

  /// ISIN of the instrument.
  final String isin;

  /// Human-readable name of the instrument.
  final String scripName;

  /// Asset class.
  final AssetType assetType;

  /// Date of original acquisition (buy date).
  final DateTime acquisitionDate;

  /// Total cost of acquisition in paise for this lot.
  final int acquisitionCost;

  /// Date of sale / redemption.
  final DateTime saleDate;

  /// Total sale proceeds in paise for this lot.
  final int saleProceeds;

  /// Quantity of units in this lot.
  final double quantity;

  /// CII-indexed cost in paise (null if indexation not applicable).
  ///
  /// Relevant for assets eligible for indexation under Section 48 of the IT Act.
  /// Note: Indexation for debt MFs was abolished from 1 April 2023, and for
  /// property LTCG from 23 July 2024 (subject to transitional rules).
  final int? indexedCost;

  /// Net gain (positive) or loss (negative) in paise.
  ///
  /// Computed as [saleProceeds] − [acquisitionCost] (without indexation).
  final int gainLoss;

  /// Holding period in calendar days.
  final int holdingPeriod;

  /// Whether this lot qualifies as long-term under the applicable rules.
  ///
  /// - Equity / equity-oriented MF / ETF: long-term if > 12 months
  /// - Debt instruments (bonds, NCD): long-term if > 36 months
  /// - Debt MF: all treated as short-term (LTCG abolished April 2023)
  final bool isLongTerm;

  /// Tax classification for Schedule CG reporting.
  final TaxCategory taxCategory;

  /// Returns a new [CapitalGainsPosition] with specified fields replaced.
  CapitalGainsPosition copyWith({
    String? isin,
    String? scripName,
    AssetType? assetType,
    DateTime? acquisitionDate,
    int? acquisitionCost,
    DateTime? saleDate,
    int? saleProceeds,
    double? quantity,
    int? indexedCost,
    int? gainLoss,
    int? holdingPeriod,
    bool? isLongTerm,
    TaxCategory? taxCategory,
  }) {
    return CapitalGainsPosition(
      isin: isin ?? this.isin,
      scripName: scripName ?? this.scripName,
      assetType: assetType ?? this.assetType,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      saleDate: saleDate ?? this.saleDate,
      saleProceeds: saleProceeds ?? this.saleProceeds,
      quantity: quantity ?? this.quantity,
      indexedCost: indexedCost ?? this.indexedCost,
      gainLoss: gainLoss ?? this.gainLoss,
      holdingPeriod: holdingPeriod ?? this.holdingPeriod,
      isLongTerm: isLongTerm ?? this.isLongTerm,
      taxCategory: taxCategory ?? this.taxCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapitalGainsPosition &&
        other.isin == isin &&
        other.scripName == scripName &&
        other.assetType == assetType &&
        other.acquisitionDate == acquisitionDate &&
        other.acquisitionCost == acquisitionCost &&
        other.saleDate == saleDate &&
        other.saleProceeds == saleProceeds &&
        other.quantity == quantity &&
        other.indexedCost == indexedCost &&
        other.gainLoss == gainLoss &&
        other.holdingPeriod == holdingPeriod &&
        other.isLongTerm == isLongTerm &&
        other.taxCategory == taxCategory;
  }

  @override
  int get hashCode => Object.hash(
    isin,
    scripName,
    assetType,
    acquisitionDate,
    acquisitionCost,
    saleDate,
    saleProceeds,
    quantity,
    indexedCost,
    gainLoss,
    holdingPeriod,
    isLongTerm,
    taxCategory,
  );
}

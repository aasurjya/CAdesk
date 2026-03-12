import 'package:ca_app/features/data_pipelines/domain/models/broker_transaction.dart';
import 'package:ca_app/features/data_pipelines/domain/models/capital_gains_position.dart';

/// Service for computing capital gains positions from broker transactions.
///
/// Implements:
/// - FIFO lot matching algorithm (Section 48, Income Tax Act)
/// - Long-term / short-term classification per asset type
/// - CII-based indexed cost computation (Schedule CII, Finance Act)
///
/// Singleton — access via [CapitalGainsPipelineService.instance].
class CapitalGainsPipelineService {
  CapitalGainsPipelineService._();

  static final CapitalGainsPipelineService instance =
      CapitalGainsPipelineService._();

  // ---------------------------------------------------------------------------
  // Cost Inflation Index (CII) — Finance Act notified values
  // ---------------------------------------------------------------------------

  /// CII table keyed by financial year start (e.g. 2001 → FY 2001-02 = 100).
  ///
  /// Source: CBDT notifications up to FY 2024-25.
  static const Map<int, int> _cii = {
    2001: 100,
    2002: 105,
    2003: 109,
    2004: 113,
    2005: 117,
    2006: 122,
    2007: 129,
    2008: 137,
    2009: 148,
    2010: 167,
    2011: 184,
    2012: 200,
    2013: 220,
    2014: 240,
    2015: 254,
    2016: 264,
    2017: 272,
    2018: 280,
    2019: 289,
    2020: 301,
    2021: 317,
    2022: 331,
    2023: 348,
    2024: 363,
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Groups [transactions] by ISIN, separates buys and sells per ISIN, and
  /// applies [applyFifo] to compute [CapitalGainsPosition] objects.
  ///
  /// Non-buy/sell transaction types (dividend, bonus, etc.) are excluded from
  /// FIFO computation.
  List<CapitalGainsPosition> computeCapGains(
    List<BrokerTransaction> transactions,
  ) {
    // Group by ISIN (fall back to scripName if ISIN is null)
    final grouped = <String, List<BrokerTransaction>>{};
    for (final tx in transactions) {
      final key = tx.isin ?? tx.scripName;
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final allPositions = <CapitalGainsPosition>[];
    for (final txList in grouped.values) {
      final buys =
          txList
              .where((t) => t.transactionType == TransactionType.buy)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      final sells =
          txList
              .where((t) => t.transactionType == TransactionType.sell)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      allPositions.addAll(applyFifo(buys, sells));
    }
    return allPositions;
  }

  /// Matches sell lots against buy lots using the FIFO (First-In First-Out)
  /// method as mandated under Indian capital gains computation rules.
  ///
  /// For each sell transaction, oldest buy lots are consumed first. If a sell
  /// spans multiple buy lots, a separate [CapitalGainsPosition] is created for
  /// each consumed lot to preserve distinct holding periods and costs.
  ///
  /// Both [buys] and [sells] must be sorted by date (ascending) before calling.
  List<CapitalGainsPosition> applyFifo(
    List<BrokerTransaction> buys,
    List<BrokerTransaction> sells,
  ) {
    if (buys.isEmpty || sells.isEmpty) return const [];

    // Mutable lot tracker: (buy transaction, remaining quantity)
    final lots = buys.map((b) => _Lot(b, b.quantity)).toList();
    final positions = <CapitalGainsPosition>[];

    for (final sell in sells) {
      var remainingToSell = sell.quantity;
      var lotIndex = 0;

      while (remainingToSell > 0 && lotIndex < lots.length) {
        final lot = lots[lotIndex];
        if (lot.remaining <= 0) {
          lotIndex++;
          continue;
        }

        final consumed =
            remainingToSell < lot.remaining ? remainingToSell : lot.remaining;

        final acqCost = (lot.buy.price * consumed).round();
        final saleProceeds = (sell.price * consumed).round();
        final gainLoss = saleProceeds - acqCost;
        final holdingDays = sell.date.difference(lot.buy.date).inDays;
        final isLt = _isLongTerm(lot.buy.assetType, holdingDays);

        positions.add(
          CapitalGainsPosition(
            isin: lot.buy.isin ?? sell.isin ?? lot.buy.scripName,
            scripName: lot.buy.scripName,
            assetType: lot.buy.assetType,
            acquisitionDate: lot.buy.date,
            acquisitionCost: acqCost,
            saleDate: sell.date,
            saleProceeds: saleProceeds,
            quantity: consumed,
            indexedCost: null, // caller can invoke computeIndexedCost separately
            gainLoss: gainLoss,
            holdingPeriod: holdingDays,
            isLongTerm: isLt,
            taxCategory: _defaultCategory(lot.buy.assetType, isLt),
          ),
        );

        lots[lotIndex] = _Lot(lot.buy, lot.remaining - consumed);
        remainingToSell -= consumed;
        if (lots[lotIndex].remaining <= 0) lotIndex++;
      }
    }

    return positions;
  }

  /// Classifies a [CapitalGainsPosition] into the appropriate [TaxCategory].
  ///
  /// Rules (as at FY 2024-25):
  /// - Listed equity / equity ETF / equity-oriented MF:
  ///   - STCG: Section 111A (15%)
  ///   - LTCG: Section 112A (10% above ₹1 lakh)
  /// - Debt MF: LTCG abolished from 1 April 2023 → all STCG (slab rate)
  /// - Bonds / NCD / other:
  ///   - STCG: slab rate
  ///   - LTCG: Section 112 (20% with indexation, where applicable)
  TaxCategory classifyGain(CapitalGainsPosition position) {
    final type = position.assetType;
    final isLt = position.isLongTerm;

    if (type == AssetType.equity ||
        type == AssetType.etf ||
        type == AssetType.mutualFund) {
      return isLt ? TaxCategory.ltcg112a : TaxCategory.stcg111a;
    }

    // Debt MF LTCG abolished — always stcgOther
    if (type == AssetType.bond) {
      return TaxCategory.stcgOther;
    }

    // NCD, other debt instruments
    return isLt ? TaxCategory.ltcgOther : TaxCategory.stcgOther;
  }

  /// Computes CII-indexed cost in paise.
  ///
  /// Formula: `originalCost × CII(saleYear) / CII(acquisitionYear)`
  ///
  /// If either year is not in the official CII table, the nearest available
  /// year is used as a fallback to prevent exceptions.
  ///
  /// [originalCost] — acquisition cost in paise.
  /// [acquisitionYear] — financial year start of purchase (e.g. 2001 for FY 2001-02).
  /// [saleYear] — financial year start of sale (e.g. 2024 for FY 2024-25).
  int computeIndexedCost(int originalCost, int acquisitionYear, int saleYear) {
    final ciiAcq = _lookupCii(acquisitionYear);
    final ciiSale = _lookupCii(saleYear);
    return originalCost * ciiSale ~/ ciiAcq;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Looks up CII for the given year. Falls back to the nearest known year
  /// if [year] is not in the table (handles future/past years gracefully).
  int _lookupCii(int year) {
    if (_cii.containsKey(year)) return _cii[year]!;

    // Find nearest key
    final keys = _cii.keys.toList()..sort();
    if (year < keys.first) return _cii[keys.first]!;
    if (year > keys.last) return _cii[keys.last]!;

    // Interpolate: return value of the highest key <= year
    int nearest = keys.first;
    for (final k in keys) {
      if (k <= year) nearest = k;
    }
    return _cii[nearest]!;
  }

  /// Returns true if the holding qualifies as long-term for the given [assetType].
  bool _isLongTerm(AssetType assetType, int holdingDays) {
    switch (assetType) {
      case AssetType.equity:
      case AssetType.etf:
      case AssetType.mutualFund:
        return holdingDays > 365;
      case AssetType.ncd:
      case AssetType.derivative:
      case AssetType.commodity:
        return holdingDays > 1095; // 36 months
      case AssetType.bond:
        // Debt MF / bonds — LTCG abolished April 2023, treat all as short-term
        return false;
    }
  }

  /// Default category assignment without exemption checks.
  TaxCategory _defaultCategory(AssetType assetType, bool isLongTerm) {
    if (assetType == AssetType.equity ||
        assetType == AssetType.etf ||
        assetType == AssetType.mutualFund) {
      return isLongTerm ? TaxCategory.ltcg112a : TaxCategory.stcg111a;
    }
    if (assetType == AssetType.bond) return TaxCategory.stcgOther;
    return isLongTerm ? TaxCategory.ltcgOther : TaxCategory.stcgOther;
  }
}

// ---------------------------------------------------------------------------
// Internal value type — not exposed outside this file
// ---------------------------------------------------------------------------

/// Tracks remaining quantity in a buy lot during FIFO matching.
class _Lot {
  const _Lot(this.buy, this.remaining);

  final BrokerTransaction buy;
  final double remaining;
}

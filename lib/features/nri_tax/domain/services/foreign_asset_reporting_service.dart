import 'package:ca_app/features/nri_tax/domain/models/foreign_asset_declaration.dart';
import 'package:ca_app/features/nri_tax/domain/models/foreign_asset_item.dart';

/// Service for building Schedule FA (Foreign Assets) disclosures and computing
/// penalties under the Black Money (Undisclosed Foreign Income and Assets) and
/// Imposition of Tax Act, 2015.
///
/// All monetary values are in **paise** (1/100 of Indian Rupee).
///
/// Key thresholds:
/// - Schedule FA mandatory when total foreign assets > ₹5 lakh (50,000,000 paise).
/// - Non-disclosure penalty: ₹10 lakh flat OR 300% of tax (@ 30%), whichever higher.
class ForeignAssetReportingService {
  ForeignAssetReportingService._();

  static final ForeignAssetReportingService instance =
      ForeignAssetReportingService._();

  /// ₹5 lakh in paise — threshold above which Schedule FA is mandatory.
  static const int _scheduleFaThresholdPaise = 50000000;

  /// ₹10 lakh in paise — minimum penalty for non-disclosure.
  static const int _minPenaltyPaise = 100000000;

  /// Standard Indian income tax rate used for penalty computation (30%).
  static const double _taxRate = 0.30;

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Returns true when [asset.peakValue] meets or exceeds the ₹5 lakh
  /// reporting threshold.
  ///
  /// Individual asset threshold is checked against peak value since the
  /// Black Money Act requires disclosure of the highest value during the year.
  bool computeReportingThreshold(ForeignAssetItem asset) {
    return asset.peakValue >= _scheduleFaThresholdPaise;
  }

  /// Builds a [ForeignAssetDeclaration] (Schedule FA) from [assets] for the
  /// specified [financialYear].
  ///
  /// The [pan] field is left empty (caller should update via [copyWith] if
  /// needed). [requiresScheduleFA] is set to true when total closing value
  /// exceeds ₹5 lakh.
  ForeignAssetDeclaration buildScheduleFA(
    List<ForeignAssetItem> assets,
    int financialYear,
  ) {
    final totalClosing = assets.fold<int>(0, (sum, a) => sum + a.closingValue);
    final requiresScheduleFA = totalClosing >= _scheduleFaThresholdPaise;

    return ForeignAssetDeclaration(
      pan: '',
      financialYear: financialYear,
      assets: List.unmodifiable(assets),
      totalForeignAssetValue: totalClosing,
      requiresScheduleFA: requiresScheduleFA,
      requiresFbar: false,
    );
  }

  /// Computes the penalty for non-disclosure of foreign assets under the
  /// Black Money Act, 2015.
  ///
  /// Penalty = max(₹10 lakh, 300% × tax on [assetValue]).
  /// Tax = [assetValue] × 30%.
  /// 300% of tax = 3 × 30% × [assetValue] = 90% × [assetValue].
  int computePenaltyForNonDisclosure(int assetValue) {
    final taxOnAsset = (assetValue * _taxRate).round();
    final penaltyAt300Percent = taxOnAsset * 3;
    return penaltyAt300Percent > _minPenaltyPaise
        ? penaltyAt300Percent
        : _minPenaltyPaise;
  }
}

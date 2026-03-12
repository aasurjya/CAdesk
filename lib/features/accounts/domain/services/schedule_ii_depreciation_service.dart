import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_ii_depreciation.dart';

/// Stateless service for computing Schedule II depreciation per the
/// Companies Act 2013.
///
/// Supports both SLM (Straight Line Method) and WDV (Written Down Value)
/// methods with pro-rata adjustments for mid-year additions and disposals.
///
/// All amounts are in paise (int).
class ScheduleIIDepreciationService {
  ScheduleIIDepreciationService._();

  /// Computes depreciation for a single [AssetBlock] for the given
  /// [financialYear] (e.g. 2025 = FY 2024-25, Apr 2024 – Mar 2025).
  static ScheduleIIDepreciation computeDepreciation({
    required AssetBlock block,
    required int financialYear,
  }) {
    final usefulLifeYears = scheduleIIUsefulLifeYears[block.category] ?? 10;
    final slmRatePercent = 100.0 / usefulLifeYears;

    // Financial year runs Apr 1 to Mar 31.
    final fyStart = DateTime(financialYear - 1, 4, 1);
    final fyEnd = DateTime(financialYear, 3, 31);
    final totalDaysInYear = fyEnd.difference(fyStart).inDays + 1;

    int depreciation;

    switch (block.depreciationMethod) {
      case DepreciationMethod.slm:
        depreciation = _slmDepreciation(
          block: block,
          fyStart: fyStart,
          fyEnd: fyEnd,
          usefulLifeYears: usefulLifeYears,
          totalDaysInYear: totalDaysInYear,
        );

      case DepreciationMethod.wdv:
        depreciation = _wdvDepreciation(
          block: block,
          fyStart: fyStart,
          fyEnd: fyEnd,
          totalDaysInYear: totalDaysInYear,
        );
    }

    // Closing WDV = opening + additions - disposals - depreciation, >= 0
    final grossClosing =
        block.openingWdvPaise +
        block.additionsPaise -
        block.disposalsPaise -
        depreciation;
    final closingWdv = grossClosing < 0 ? 0 : grossClosing;

    return ScheduleIIDepreciation(
      assetBlock: block,
      depreciationForYearPaise: depreciation,
      closingWdvPaise: closingWdv,
      financialYear: financialYear,
      usefulLifeYears: usefulLifeYears,
      slmRatePercent: slmRatePercent,
    );
  }

  // ── SLM ────────────────────────────────────────────────────────────────────

  static int _slmDepreciation({
    required AssetBlock block,
    required DateTime fyStart,
    required DateTime fyEnd,
    required int usefulLifeYears,
    required int totalDaysInYear,
  }) {
    // Annual SLM depreciation = cost / useful life
    // For opening WDV: charge for the full year (no pro-rata on existing block)
    int depr = 0;

    final annualOnOpening = block.openingWdvPaise ~/ usefulLifeYears;

    // Determine how many days the opening balance was held this year.
    // If there is a mid-year disposal, charge only up to disposal date;
    // otherwise charge for the full year.
    if (block.disposalsPaise > 0 && block.disposalDate != null) {
      final dispDate = block.disposalDate!;
      final effectiveDisp = dispDate.isBefore(fyStart) ? fyStart : dispDate;
      final daysHeld = effectiveDisp.difference(fyStart).inDays;
      depr += (annualOnOpening * daysHeld) ~/ totalDaysInYear;
    } else if (block.openingWdvPaise > 0) {
      // Full year depreciation on opening balance.
      depr += annualOnOpening;
    }

    // Depreciation on additions: pro-rata from addition date to year end.
    if (block.additionsPaise > 0 && block.additionDate != null) {
      final addDate = block.additionDate!;
      // Clamp addition date to FY window.
      final effectiveStart = addDate.isBefore(fyStart) ? fyStart : addDate;
      // Days = difference (not inclusive of start day, consistent with test).
      final daysUsed = fyEnd.difference(effectiveStart).inDays;
      final annualOnAddition = block.additionsPaise ~/ usefulLifeYears;
      final proRata = (annualOnAddition * daysUsed) ~/ totalDaysInYear;
      depr += proRata;
    }

    return depr < 0 ? 0 : depr;
  }

  // ── WDV ───────────────────────────────────────────────────────────────────

  static int _wdvDepreciation({
    required AssetBlock block,
    required DateTime fyStart,
    required DateTime fyEnd,
    required int totalDaysInYear,
  }) {
    final rate = wdvRates[block.category] ?? 15.0;

    // WDV on opening balance — full year.
    int depr = 0;
    if (block.openingWdvPaise > 0) {
      depr += (block.openingWdvPaise * rate ~/ 100);
    }

    // WDV on additions — pro-rata from addition date.
    if (block.additionsPaise > 0 && block.additionDate != null) {
      final addDate = block.additionDate!;
      final effectiveStart = addDate.isBefore(fyStart) ? fyStart : addDate;
      final daysUsed = fyEnd.difference(effectiveStart).inDays;
      final annualOnAddition = (block.additionsPaise * rate ~/ 100);
      depr += (annualOnAddition * daysUsed) ~/ totalDaysInYear;
    }

    // Reduce for disposals — only charged until disposal date.
    if (block.disposalsPaise > 0 && block.disposalDate != null) {
      final dispDate = block.disposalDate!;
      final effectiveDisp = dispDate.isBefore(fyStart) ? fyStart : dispDate;
      final daysHeld = effectiveDisp.difference(fyStart).inDays;
      final annualOnDisposal = (block.disposalsPaise * rate ~/ 100);
      final proRataRemoved = (annualOnDisposal * daysHeld) ~/ totalDaysInYear;
      depr = depr - annualOnDisposal + proRataRemoved;
    }

    return depr < 0 ? 0 : depr;
  }
}

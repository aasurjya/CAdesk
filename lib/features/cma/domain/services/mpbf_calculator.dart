import 'package:ca_app/features/cma/domain/models/cma_balance_sheet.dart';

/// Stateless singleton service that computes Maximum Permissible Bank
/// Finance (MPBF) using the three Tandon / Nayak Committee methods.
///
/// All inputs and outputs are in **paise** (1/100 rupee) to eliminate
/// floating-point rounding errors in financial calculations.
///
/// References:
/// - Tandon Committee Report (RBI, 1974) — Methods 1 and 2
/// - Nayak Committee Report (RBI, 1992) — Turnover Method
class MpbfCalculator {
  MpbfCalculator._();

  /// Singleton access point.
  static final MpbfCalculator instance = MpbfCalculator._();

  // ── Method 1 ─────────────────────────────────────────────────────────────

  /// Computes MPBF using Tandon Method 1.
  ///
  /// Formula:
  /// ```
  /// Working Capital Gap (WCG) = Total CA - CL (excl. bank borrowings)
  /// MPBF = 75% × WCG
  /// ```
  ///
  /// Returns 0 when WCG ≤ 0 (no gap to finance).
  int computeMethod1(CmaBalanceSheet bs) {
    final wcg = bs.totalCurrentAssets - bs.currentLiabilitiesExclBank;
    if (wcg <= 0) return 0;
    return (wcg * 75) ~/ 100;
  }

  // ── Method 2 ─────────────────────────────────────────────────────────────

  /// Computes MPBF using Tandon Method 2.
  ///
  /// Formula:
  /// ```
  /// MPBF = (75% × Total CA) - CL (excl. bank borrowings)
  /// ```
  ///
  /// The borrower is required to contribute at least 25% of current assets
  /// from long-term (net working capital) sources.
  /// Returns 0 when the result would be negative.
  int computeMethod2(CmaBalanceSheet bs) {
    final seventyFivePctCA = (bs.totalCurrentAssets * 75) ~/ 100;
    final result = seventyFivePctCA - bs.currentLiabilitiesExclBank;
    return result < 0 ? 0 : result;
  }

  // ── Turnover Method (Nayak Committee) ────────────────────────────────────

  /// Computes MPBF using the Turnover Method (applicable for borrowers with
  /// fund-based working capital limits up to ₹5 crore).
  ///
  /// Formula:
  /// ```
  /// MPBF = 20% of projected annual gross sales
  /// ```
  ///
  /// [annualSalesPaise] — projected gross annual sales in paise.
  int computeTurnoverMethod(int annualSalesPaise) {
    return (annualSalesPaise * 20) ~/ 100;
  }

  // ── Drawing Power ─────────────────────────────────────────────────────────

  /// Computes drawing power against a working capital limit.
  ///
  /// Drawing power is the maximum amount the borrower can draw from the
  /// cash credit account at any point in time, based on the current stock
  /// and debtor position minus creditors.
  ///
  /// Formula (using standard 75% DP% for both stock and debtors):
  /// ```
  /// DP = (stockPaise × 75%) + (debtorsPaise × 75%) - creditorsPaise
  /// ```
  ///
  /// All parameters are in paise.
  /// Returns 0 when the result would be negative.
  int computeDrawingPower(
    int stockPaise,
    int debtorsPaise,
    int creditorsPaise,
  ) {
    const dpPercent = 75;
    final stockFunding = (stockPaise * dpPercent) ~/ 100;
    final debtorFunding = (debtorsPaise * dpPercent) ~/ 100;
    final dp = stockFunding + debtorFunding - creditorsPaise;
    return dp < 0 ? 0 : dp;
  }
}

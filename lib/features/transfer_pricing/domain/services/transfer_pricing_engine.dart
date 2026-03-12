import 'package:ca_app/features/transfer_pricing/domain/models/alp_benchmark.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/international_transaction.dart';

/// Comparable transaction data used in ALP benchmarking analysis.
class ComparableData {
  const ComparableData({required this.name, required this.valuePaise});

  final String name;
  final int valuePaise;
}

/// Transfer Pricing Engine implementing Sections 92–92F of the Income Tax Act.
///
/// Key rules:
/// - Tolerance range: ±3% for most transactions (Rule 10CA)
/// - Tolerance range: ±1% for wholesale trading transactions
/// - Mandatory TP documentation if international transactions > ₹1 crore
/// - Mandatory audit report (Form 3CEB) if international transactions > ₹1 crore
class TransferPricingEngine {
  TransferPricingEngine._();

  static final TransferPricingEngine instance = TransferPricingEngine._();

  /// General tolerance percentage (3% for non-wholesale transactions).
  static const double _generalTolerancePercent = 3.0;

  /// Determines the most appropriate ALP method for [t].
  ///
  /// Preference order per Rule 10C (Most Appropriate Method):
  /// - Commodity/goods transactions: CUP (direct comparables available)
  /// - Service transactions: TNMM (margin-based comparison)
  /// - Loans: CUP (comparable interest rate)
  /// - Other: TNMM as default fallback
  AlpMethod determineMethod(InternationalTransaction t) {
    switch (t.nature) {
      case TransactionNature.sale:
      case TransactionNature.purchase:
        // CUP preferred for traded goods; TNMM for complex manufacturing
        return AlpMethod.cup;
      case TransactionNature.loan:
        // CUP using comparable bank interest rates
        return AlpMethod.cup;
      case TransactionNature.royalty:
      case TransactionNature.service:
        // TNMM widely used for service and royalty transactions
        return AlpMethod.tnmm;
    }
  }

  /// Computes the ALP benchmark from [comparables] using [t]'s method.
  ///
  /// Uses the interquartile range of comparable values.
  /// Returns a benchmark with the median as the selected ALP.
  AlpBenchmark computeArmLengthPrice(
    InternationalTransaction t,
    List<ComparableData> comparables,
  ) {
    if (comparables.isEmpty) {
      return AlpBenchmark(
        method: t.method,
        searchCriteria: 'No comparables',
        comparableCount: 0,
        interquartileLowerPaise: t.amountPaise,
        interquartileMedianPaise: t.amountPaise,
        interquartileUpperPaise: t.amountPaise,
        selectedAlpPaise: t.amountPaise,
      );
    }

    final sorted = comparables.map((c) => c.valuePaise).toList()..sort();
    final lower = _percentile(sorted, 25);
    final median = _percentile(sorted, 50);
    final upper = _percentile(sorted, 75);

    return AlpBenchmark(
      method: t.method,
      searchCriteria: 'Comparable database search',
      comparableCount: comparables.length,
      interquartileLowerPaise: lower,
      interquartileMedianPaise: median,
      interquartileUpperPaise: upper,
      selectedAlpPaise: median,
    );
  }

  /// Computes the transfer pricing adjustment for [t] against [benchmark].
  ///
  /// Returns the upward adjustment in paise (positive) or 0 if within range.
  ///
  /// If the actual transaction price falls outside the tolerance range:
  /// - For sale: if actual < lower bound → adjustment = median - actual
  /// - For purchase: if actual > upper bound → adjustment = actual - median
  int computeTransferPricingAdjustment(
    InternationalTransaction t,
    AlpBenchmark benchmark,
  ) {
    final actual = t.amountPaise;
    final lower = benchmark.interquartileLowerPaise;
    final median = benchmark.interquartileMedianPaise;
    final upper = benchmark.interquartileUpperPaise;

    // Apply tolerance: if actual is within ±3% of median, no adjustment
    final tolerance = (median * _generalTolerancePercent / 100).round();
    final adjustedLower = lower - tolerance;
    final adjustedUpper = upper + tolerance;

    if (actual >= adjustedLower && actual <= adjustedUpper) {
      return 0;
    }

    // Sale transaction: if actual price received is below ALP → upward adjustment
    // Purchase transaction: if actual price paid is above ALP → upward adjustment
    switch (t.nature) {
      case TransactionNature.sale:
        if (actual < lower) {
          return median - actual;
        }
      case TransactionNature.purchase:
        if (actual > upper) {
          return actual - median;
        }
      case TransactionNature.loan:
      case TransactionNature.royalty:
      case TransactionNature.service:
        if (actual < lower) return median - actual;
        if (actual > upper) return actual - median;
    }

    return 0;
  }

  int _percentile(List<int> sorted, int p) {
    if (sorted.isEmpty) return 0;
    final index = (p / 100 * (sorted.length - 1)).round();
    return sorted[index];
  }
}

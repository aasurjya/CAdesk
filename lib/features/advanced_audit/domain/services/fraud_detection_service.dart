import 'dart:math' as math;

import 'package:ca_app/features/advanced_audit/domain/models/audit_transaction.dart';
import 'package:ca_app/features/advanced_audit/domain/models/fraud_indicator.dart';

/// Stateless service that detects common fraud indicators in a transaction set.
///
/// Detection methods follow ACFE (Association of Certified Fraud Examiners)
/// best practices and the Fraud Triangle (Pressure, Opportunity, Rationalisation).
class FraudDetectionService {
  FraudDetectionService._();

  // ─── Threshold constants ───────────────────────────────────────────────────

  /// Default minimum amount (in paise) for round-number detection (₹1,000).
  static const int _defaultRoundThreshold = 100000; // ₹1,000

  /// Percentage window below a threshold that counts as "just below".
  static const double _justBelowPercent = 0.01; // within 1%

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Detects transactions with suspiciously round amounts.
  ///
  /// A transaction is flagged when its amount is evenly divisible by 100,000
  /// paise (₹1,000) and meets the [threshold].  All qualifying transactions
  /// are collected into a single [FraudIndicator].
  ///
  /// Severity escalates with divisibility:
  ///   - divisible by 1,000,000 (₹10,000) → medium
  ///   - divisible by 10,000,000 (₹1,00,000) → high
  ///   - otherwise → low
  static List<FraudIndicator> detectRoundNumbers(
    List<AuditTransaction> transactions, {
    int threshold = _defaultRoundThreshold,
  }) {
    if (transactions.isEmpty) return const [];

    final flagged = transactions
        .where((t) => t.amountPaise >= threshold && _isRound(t.amountPaise))
        .toList();

    if (flagged.isEmpty) return const [];

    final severity = _roundSeverity(flagged);

    return [
      FraudIndicator(
        indicatorType: FraudIndicatorType.roundNumberBias,
        description:
            '${flagged.length} transaction(s) have suspiciously round '
            'amounts, which may indicate estimated or fictitious entries.',
        transactions: List.unmodifiable(flagged.map((t) => t.transactionId)),
        severity: severity,
      ),
    ];
  }

  /// Detects transactions with amounts just below a regulatory threshold.
  ///
  /// Common thresholds in India:
  ///   - ₹50,000 (5,000,000 paise) — PAN required for cash transactions
  ///   - ₹2,00,000 (20,000,000 paise) — TDS under Sec 194C
  ///
  /// A transaction is "just below" when its amount falls within
  /// [_justBelowPercent] of a threshold from below.
  ///
  /// Transactions near the same threshold are grouped into one indicator.
  static List<FraudIndicator> detectJustBelowThreshold(
    List<AuditTransaction> transactions,
    List<int> thresholds,
  ) {
    if (transactions.isEmpty || thresholds.isEmpty) return const [];

    final indicators = <FraudIndicator>[];

    for (final threshold in thresholds) {
      final lowerBound = (threshold * (1 - _justBelowPercent)).round();
      final flagged = transactions
          .where(
            (t) => t.amountPaise >= lowerBound && t.amountPaise < threshold,
          )
          .toList();

      if (flagged.isEmpty) continue;

      indicators.add(
        FraudIndicator(
          indicatorType: FraudIndicatorType.justBelowThreshold,
          description:
              '${flagged.length} transaction(s) are just below the '
              '₹${_paiseToRupees(threshold)} threshold, suggesting '
              'deliberate structuring to avoid regulatory reporting.',
          transactions: List.unmodifiable(flagged.map((t) => t.transactionId)),
          severity: FraudIndicatorSeverity.high,
        ),
      );
    }

    return List.unmodifiable(indicators);
  }

  /// Detects duplicate payments: same amount + same party within 30 days.
  ///
  /// All transactions in a duplicate group are collected into a single
  /// [FraudIndicator].
  static List<FraudIndicator> detectDuplicates(
    List<AuditTransaction> transactions,
  ) {
    if (transactions.length < 2) return const [];

    // Group by (partyName, amountPaise)
    final groups = <String, List<AuditTransaction>>{};
    for (final txn in transactions) {
      final key = '${txn.partyName}__${txn.amountPaise}';
      groups.putIfAbsent(key, () => []).add(txn);
    }

    final indicators = <FraudIndicator>[];

    for (final group in groups.values) {
      if (group.length < 2) continue;

      // Sort by date
      final sorted = [...group]
        ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      // Find pairs within 30 days
      final duplicateIds = <String>{};
      for (int i = 0; i < sorted.length; i++) {
        for (int j = i + 1; j < sorted.length; j++) {
          final diff = sorted[j].transactionDate.difference(
            sorted[i].transactionDate,
          );
          if (diff.inDays <= 30) {
            duplicateIds.add(sorted[i].transactionId);
            duplicateIds.add(sorted[j].transactionId);
          }
        }
      }

      if (duplicateIds.isEmpty) continue;

      indicators.add(
        FraudIndicator(
          indicatorType: FraudIndicatorType.duplicateAmount,
          description:
              '${duplicateIds.length} transaction(s) to the same party '
              '"${sorted.first.partyName}" for the same amount within 30 days.',
          transactions: List.unmodifiable(duplicateIds.toList()),
          severity: FraudIndicatorSeverity.high,
        ),
      );
    }

    return List.unmodifiable(indicators);
  }

  /// Detects velocity anomalies: a month whose total is > 3 standard
  /// deviations above the 6-month rolling mean of prior months.
  ///
  /// Requires at least 7 months of data (6 baseline + 1 test month).
  static List<FraudIndicator> detectVelocityAnomalies(
    List<AuditTransaction> transactions,
  ) {
    if (transactions.isEmpty) return const [];

    // Aggregate totals by (year, month)
    final monthlyTotals = _aggregateByMonth(transactions);
    final months = monthlyTotals.keys.toList()..sort();

    if (months.length < 7) return const [];

    final indicators = <FraudIndicator>[];

    for (int i = 6; i < months.length; i++) {
      final window = months.sublist(i - 6, i);
      final windowValues = window.map((m) => monthlyTotals[m]!.toDouble());

      final mean = _mean(windowValues);
      final stdDev = _stdDev(windowValues, mean);

      final currentMonth = months[i];
      final currentTotal = monthlyTotals[currentMonth]!.toDouble();

      // When stdDev == 0 (perfectly uniform baseline), flag any value that
      // exceeds the mean by more than 100% (i.e., more than double the average).
      final isAnomaly = stdDev > 0
          ? currentTotal > mean + 3 * stdDev
          : currentTotal > mean * 2;

      if (isAnomaly) {
        final affectedTxns = transactions
            .where(
              (t) =>
                  t.transactionDate.year == currentMonth.year &&
                  t.transactionDate.month == currentMonth.month,
            )
            .map((t) => t.transactionId)
            .toList();

        indicators.add(
          FraudIndicator(
            indicatorType: FraudIndicatorType.velocityAnomaly,
            description:
                'Month ${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')} '
                'total (₹${_paiseToRupees(currentTotal.round())}) is '
                '${((currentTotal - mean) / stdDev).toStringAsFixed(1)} std '
                'deviations above the 6-month rolling average '
                '(₹${_paiseToRupees(mean.round())}).',
            transactions: List.unmodifiable(affectedTxns),
            severity: FraudIndicatorSeverity.high,
          ),
        );
      }
    }

    return List.unmodifiable(indicators);
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static bool _isRound(int amountPaise) {
    return amountPaise % 100000 == 0;
  }

  static FraudIndicatorSeverity _roundSeverity(List<AuditTransaction> flagged) {
    final maxAmount = flagged.fold<int>(
      0,
      (max, t) => t.amountPaise > max ? t.amountPaise : max,
    );
    if (maxAmount % 10000000 == 0) return FraudIndicatorSeverity.high;
    if (maxAmount % 1000000 == 0) return FraudIndicatorSeverity.medium;
    return FraudIndicatorSeverity.low;
  }

  /// Aggregates transaction amounts by calendar month.
  static Map<DateTime, int> _aggregateByMonth(
    List<AuditTransaction> transactions,
  ) {
    final result = <DateTime, int>{};
    for (final txn in transactions) {
      final key = DateTime(txn.transactionDate.year, txn.transactionDate.month);
      result[key] = (result[key] ?? 0) + txn.amountPaise;
    }
    return result;
  }

  static double _mean(Iterable<double> values) {
    final list = values.toList();
    return list.fold<double>(0, (sum, v) => sum + v) / list.length;
  }

  static double _stdDev(Iterable<double> values, double mean) {
    final list = values.toList();
    final variance =
        list.fold<double>(0, (sum, v) => sum + math.pow(v - mean, 2)) /
        list.length;
    return math.sqrt(variance);
  }

  /// Converts paise to rupees string for human-readable descriptions.
  static String _paiseToRupees(int paise) {
    return (paise / 100).toStringAsFixed(0);
  }
}

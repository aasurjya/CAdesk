import 'package:ca_app/features/vda/domain/models/vda_transaction.dart';

/// Immutable model representing the ITR Schedule VDA (Virtual Digital Assets).
///
/// Schedule VDA was introduced in ITR forms from AY 2023-24 onwards to capture
/// income from transfer of virtual digital assets under Section 115BBH.
///
/// Key rules:
/// - 30% flat tax on gains (no deductions except cost of acquisition)
/// - Losses cannot be set off against gains or other income
/// - Losses can only be carried forward within VDA income (future VDA gains)
/// - No indexation benefit
/// - 1% TDS under Section 194S
class ScheduleVDA {
  const ScheduleVDA({
    required this.transactions,
    required this.totalGainPaise,
    required this.totalLossPaise,
    required this.taxAtFlatRatePaise,
    required this.tdsDeducted1PercentPaise,
  });

  final List<VdaTransaction> transactions;

  /// Sum of gains from all profitable VDA transactions in paise.
  final int totalGainPaise;

  /// Sum of losses from all loss-making VDA transactions in paise (absolute value).
  final int totalLossPaise;

  /// Tax at flat 30% rate on total gains (not offset by losses) in paise.
  final int taxAtFlatRatePaise;

  /// Total 1% TDS deducted by buyer under Section 194S in paise.
  final int tdsDeducted1PercentPaise;

  ScheduleVDA copyWith({
    List<VdaTransaction>? transactions,
    int? totalGainPaise,
    int? totalLossPaise,
    int? taxAtFlatRatePaise,
    int? tdsDeducted1PercentPaise,
  }) {
    return ScheduleVDA(
      transactions: transactions ?? this.transactions,
      totalGainPaise: totalGainPaise ?? this.totalGainPaise,
      totalLossPaise: totalLossPaise ?? this.totalLossPaise,
      taxAtFlatRatePaise: taxAtFlatRatePaise ?? this.taxAtFlatRatePaise,
      tdsDeducted1PercentPaise:
          tdsDeducted1PercentPaise ?? this.tdsDeducted1PercentPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleVDA) return false;
    if (other.totalGainPaise != totalGainPaise) return false;
    if (other.totalLossPaise != totalLossPaise) return false;
    if (other.taxAtFlatRatePaise != taxAtFlatRatePaise) return false;
    if (other.tdsDeducted1PercentPaise != tdsDeducted1PercentPaise) {
      return false;
    }
    if (other.transactions.length != transactions.length) return false;
    for (var i = 0; i < transactions.length; i++) {
      if (other.transactions[i] != transactions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(transactions),
    totalGainPaise,
    totalLossPaise,
    taxAtFlatRatePaise,
    tdsDeducted1PercentPaise,
  );
}

import 'package:ca_app/features/vda/domain/models/schedule_vda.dart';
import 'package:ca_app/features/vda/domain/models/vda_transaction.dart';

/// Engine for computing tax liability on Virtual Digital Asset (VDA) transactions.
///
/// Implements Section 115BBH of the Income Tax Act (effective FY 2022-23):
/// - 30% flat tax on gains (no deductions allowed except cost of acquisition)
/// - VDA losses CANNOT be set off against VDA gains or any other income
/// - No indexation benefit
/// - Losses may only be carried forward to be set off against future VDA gains
///
/// Also covers Section 194S TDS:
/// - 1% TDS deducted by buyer on seller if consideration > ₹10,000
///   (₹50,000 for specified persons — individuals/HUFs below audit threshold)
class VdaTaxComputationEngine {
  VdaTaxComputationEngine._();

  static final VdaTaxComputationEngine instance = VdaTaxComputationEngine._();

  /// Tax rate under Section 115BBH: 30% (as an integer numerator for 30/100).
  static const int _taxRateNumerator = 30;
  static const int _taxRateDenominator = 100;

  /// Computes VDA tax liability for a list of [transactions].
  ///
  /// Returns a [ScheduleVDA] with:
  /// - [ScheduleVDA.totalGainPaise]: sum of gains across profit-making transactions
  /// - [ScheduleVDA.totalLossPaise]: sum of losses (absolute value) from loss transactions
  /// - [ScheduleVDA.taxAtFlatRatePaise]: 30% of total gains (losses do NOT reduce this)
  /// - [ScheduleVDA.tdsDeducted1PercentPaise]: 1% TDS on sale considerations
  ScheduleVDA computeVdaTax(List<VdaTransaction> transactions) {
    var totalGain = 0;
    var totalLoss = 0;
    var totalSaleConsideration = 0;

    for (final tx in transactions) {
      final gain = tx.gainPaise;
      if (gain > 0) {
        totalGain += gain;
      } else if (gain < 0) {
        totalLoss += gain.abs();
      }
      totalSaleConsideration += tx.saleConsiderationPaise;
    }

    // Tax = 30% of total gains only (losses cannot reduce tax liability)
    final tax = (totalGain * _taxRateNumerator) ~/ _taxRateDenominator;

    // 1% TDS on total sale consideration
    final tds = totalSaleConsideration ~/ 100;

    return ScheduleVDA(
      transactions: transactions,
      totalGainPaise: totalGain,
      totalLossPaise: totalLoss,
      taxAtFlatRatePaise: tax,
      tdsDeducted1PercentPaise: tds,
    );
  }
}

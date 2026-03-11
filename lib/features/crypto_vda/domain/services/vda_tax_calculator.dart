import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';

// ---------------------------------------------------------------------------
// VdaScheduleSummary
// ---------------------------------------------------------------------------

/// Immutable Schedule VDA summary computed by [VdaTaxCalculator].
class VdaScheduleSummary {
  const VdaScheduleSummary({
    required this.totalSaleValue,
    required this.totalCost,
    required this.totalNetGains,
    required this.totalLosses,
    required this.totalTaxPayable,
    required this.totalTdsDeducted,
    required this.netTaxAfterTds,
    this.lossDisallowedNote,
  });

  final double totalSaleValue;
  final double totalCost;
  final double totalNetGains;

  /// Aggregate of all per-transaction losses (always positive magnitude).
  /// Under Section 115BBH these are disallowed for set-off.
  final double totalLosses;
  final double totalTaxPayable;
  final double totalTdsDeducted;
  final double netTaxAfterTds;

  /// Non-null when there are disallowed losses; contains a human-readable note.
  final String? lossDisallowedNote;
}

// ---------------------------------------------------------------------------
// VdaTaxCalculator
// ---------------------------------------------------------------------------

/// Pure static computation helpers for VDA tax under Section 115BBH / 194S.
class VdaTaxCalculator {
  VdaTaxCalculator._();

  /// Section 115BBH: 30% flat tax on net VDA gains + 4% cess.
  /// No deduction allowed except cost of acquisition.
  /// Losses from VDA cannot be set off against any other income.
  static double taxOnVdaGains(double netGains) {
    if (netGains <= 0) {
      return 0;
    }
    return netGains * 0.30 * 1.04; // 30% + 4% cess
  }

  /// TDS under Section 194S: 1% on consideration paid for VDA transfer.
  /// Threshold: ₹50,000 p.a. (specified persons ₹10,000).
  static double tds194S({
    required double transactionValue,
    required bool isSpecifiedPerson,
  }) {
    final double threshold = isSpecifiedPerson ? 10000.0 : 50000.0;
    if (transactionValue < threshold) {
      return 0;
    }
    return transactionValue * 0.01;
  }

  /// Net gain per transaction: sale price − cost of acquisition (no indexation).
  static double netGain({
    required double salePrice,
    required double costOfAcquisition,
  }) {
    return salePrice - costOfAcquisition;
  }

  /// Schedule VDA summary: aggregate all VDA transactions for a PAN / client.
  static VdaScheduleSummary computeScheduleVda(
    List<VdaTransaction> transactions,
  ) {
    double totalSaleValue = 0;
    double totalCost = 0;
    double totalGains = 0;
    double totalLosses = 0;
    double totalTax = 0;
    double totalTdsDeducted = 0;

    for (final VdaTransaction t in transactions) {
      totalSaleValue += t.sellPrice;
      totalCost += t.buyPrice;
      final double gain = netGain(
        salePrice: t.sellPrice,
        costOfAcquisition: t.buyPrice,
      );
      if (gain > 0) {
        totalGains += gain;
        totalTax += taxOnVdaGains(gain);
      } else {
        totalLosses += gain.abs(); // losses disallowed for set-off
      }
      totalTdsDeducted += t.tdsUnder194S;
    }

    final double netTax =
        (totalTax - totalTdsDeducted).clamp(0, double.infinity);

    final String? lossNote = totalLosses > 0
        ? '₹${(totalLosses / 100000).toStringAsFixed(2)}L loss disallowed'
            ' — cannot be set off u/s 115BBH'
        : null;

    return VdaScheduleSummary(
      totalSaleValue: totalSaleValue,
      totalCost: totalCost,
      totalNetGains: totalGains,
      totalLosses: totalLosses,
      totalTaxPayable: totalTax,
      totalTdsDeducted: totalTdsDeducted,
      netTaxAfterTds: netTax,
      lossDisallowedNote: lossNote,
    );
  }
}

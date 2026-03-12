import 'package:ca_app/features/filing/domain/models/itr2/schedule_112a.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';

/// Result of the full capital gains tax computation.
///
/// All amounts are in INR. Tax figures are base tax only (before surcharge
/// and cess — those are applied by the main tax engine).
class CapitalGainsTaxResult {
  const CapitalGainsTaxResult({
    required this.stcg111ATax,
    required this.stcgOtherTax,
    required this.ltcg112ATax,
    required this.ltcgOnPropertyTax,
    required this.ltcgOtherTax,
  });

  /// Tax on STCG under Section 111A at 20% (Finance Act 2024).
  final double stcg111ATax;

  /// Tax on other STCG at slab rate.
  ///
  /// Note: Slab-rate STCG is integrated into the regular income computation
  /// by the main tax engine. This field is for reporting/breakdown only.
  final double stcgOtherTax;

  /// Tax on LTCG under Section 112A at 12.5% (above ₹1.25L exemption).
  final double ltcg112ATax;

  /// Tax on LTCG on property at 20% (Section 112 with indexation).
  final double ltcgOnPropertyTax;

  /// Tax on other LTCG at 20% with indexation (Section 112).
  final double ltcgOtherTax;

  /// Total capital gains tax (all special-rate components combined).
  double get totalCgTax =>
      stcg111ATax +
      stcg111ATax * 0 + // self-cancels; slab-rate STCG excluded here
      ltcg112ATax +
      ltcgOnPropertyTax +
      ltcgOtherTax;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapitalGainsTaxResult &&
        other.stcg111ATax == stcg111ATax &&
        other.stcgOtherTax == stcgOtherTax &&
        other.ltcg112ATax == ltcg112ATax &&
        other.ltcgOnPropertyTax == ltcgOnPropertyTax &&
        other.ltcgOtherTax == ltcgOtherTax;
  }

  @override
  int get hashCode => Object.hash(
    stcg111ATax,
    stcgOtherTax,
    ltcg112ATax,
    ltcgOnPropertyTax,
    ltcgOtherTax,
  );
}

/// Stateless service that computes capital gains tax for ITR-2 / ITR-3.
///
/// Tax rates per Finance Act 2024 (effective FY 2024-25 / AY 2025-26):
/// - STCG s.111A (listed equity/MF with STT): **20%** (raised from 15%)
/// - LTCG s.112A (listed equity/MF above ₹1.25L): **12.5%** (raised from 10%)
/// - LTCG on property s.112 with indexation: **20%**
/// - LTCG other assets s.112 with indexation: **20%** or 10% without (lower)
/// - Slab-rate STCG/LTCG: added to regular income for slab computation
class CapitalGainsComputationService {
  CapitalGainsComputationService._();

  // Tax rate constants (Finance Act 2024)
  static const double _kStcg111ARate = 0.20; // 20% from FY 2024-25
  static const double _kLtcg112ARate = 0.125; // 12.5% from FY 2024-25
  static const double _kLtcgPropertyRate = 0.20; // 20% (Section 112)
  static const double _kLtcgOther20Rate = 0.20; // 20% with indexation
  static const double _kLtcgOther10Rate = 0.10; // 10% without indexation

  /// Compute tax on STCG under Section 111A at 20%.
  ///
  /// Applies to short-term gains on listed equity shares and equity-oriented
  /// MFs where STT has been paid. Negative net STCG (loss) yields zero tax.
  static double computeStcg111ATax(ScheduleCg schedule) {
    final netStcg = schedule.netStcgAfterSetOff;
    if (netStcg <= 0) return 0;
    // Only the 111A portion is taxed at 20% — other STCG at slab
    final stcg111ANet = schedule.totalStcg111A;
    if (stcg111ANet <= 0) return 0;
    return stcg111ANet * _kStcg111ARate;
  }

  /// Compute tax on LTCG under Section 112A at 12.5% above ₹1.25L.
  ///
  /// The [Schedule112a] model already applies the exemption via [taxableGain].
  static double computeLtcg112ATax(Schedule112a schedule) {
    final taxable = schedule.taxableGain;
    if (taxable <= 0) return 0;
    return taxable * _kLtcg112ARate;
  }

  /// Compute tax on LTCG on immovable property at 20% (Section 112).
  static double computeLtcgOnPropertyTax(ScheduleCg schedule) {
    final ltcgProperty = schedule.totalLtcgOnProperty;
    if (ltcgProperty <= 0) return 0;
    return ltcgProperty * _kLtcgPropertyRate;
  }

  /// Compute tax on other LTCG (Section 112): lower of 20% with indexation
  /// or 10% without indexation.
  static double computeLtcgOtherTax(ScheduleCg schedule) {
    final taxWith =
        schedule.otherLtcgEntries.fold(0.0, (sum, e) {
          final g = e.gainWithIndexation;
          return sum + (g > 0 ? g : 0);
        }) *
        _kLtcgOther20Rate;
    final taxWithout =
        schedule.otherLtcgEntries.fold(0.0, (sum, e) {
          final g = e.gainWithoutIndexation;
          return sum + (g > 0 ? g : 0);
        }) *
        _kLtcgOther10Rate;
    return taxWith < taxWithout ? taxWith : taxWithout;
  }

  /// Aggregate capital gains tax from all components.
  ///
  /// Slab-rate STCG (other assets, debt MF) is NOT included here —
  /// it is added to ordinary income by the main tax computation engine.
  static CapitalGainsTaxResult computeTotalCapitalGainsTax({
    required ScheduleCg scheduleCg,
    required Schedule112a schedule112a,
  }) {
    return CapitalGainsTaxResult(
      stcg111ATax: computeStcg111ATax(scheduleCg),
      stcgOtherTax: 0, // slab rate — handled by main engine
      ltcg112ATax: computeLtcg112ATax(schedule112a),
      ltcgOnPropertyTax: computeLtcgOnPropertyTax(scheduleCg),
      ltcgOtherTax: computeLtcgOtherTax(scheduleCg),
    );
  }
}

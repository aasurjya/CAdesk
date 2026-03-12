import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:flutter/foundation.dart';

/// Immutable model for Schedule CG — Capital Gains computation in ITR-2.
///
/// Covers all capital gain heads:
/// - STCG on listed equity/MF (Section 111A) — 20% flat rate
/// - LTCG on listed equity/MF (Section 112A) — 12.5% above ₹1.25L
/// - STCG/LTCG on debt instruments (slab rate post Finance Act 2023)
/// - LTCG on property (20% with indexation)
/// - STCG/LTCG on other assets (slab rate / 20%)
///
/// Set-off rules per Income Tax Act:
/// - STCL can set off against STCG and LTCG.
/// - LTCL can ONLY set off against LTCG.
/// - Unabsorbed losses carry forward for 8 years.
class ScheduleCg {
  const ScheduleCg({
    required this.equityStcgEntries,
    required this.equityLtcgEntries,
    required this.debtStcgEntries,
    required this.debtLtcgEntries,
    required this.propertyLtcgEntries,
    required this.otherStcgEntries,
    required this.otherLtcgEntries,
    required this.broughtForwardStcl,
    required this.broughtForwardLtcl,
  });

  factory ScheduleCg.empty() => const ScheduleCg(
    equityStcgEntries: [],
    equityLtcgEntries: [],
    debtStcgEntries: [],
    debtLtcgEntries: [],
    propertyLtcgEntries: [],
    otherStcgEntries: [],
    otherLtcgEntries: [],
    broughtForwardStcl: 0,
    broughtForwardLtcl: 0,
  );

  /// Short-term capital gain entries on listed equity/MF (Section 111A).
  final List<EquityStcgEntry> equityStcgEntries;

  /// Long-term capital gain entries on listed equity/MF (Section 112A).
  final List<EquityLtcgEntry> equityLtcgEntries;

  /// Short-term capital gain entries on debt instruments.
  final List<DebtStcgEntry> debtStcgEntries;

  /// Long-term capital gain entries on debt instruments.
  final List<DebtLtcgEntry> debtLtcgEntries;

  /// Long-term capital gain entries on immovable property (Section 112).
  final List<PropertyLtcgEntry> propertyLtcgEntries;

  /// Short-term capital gain entries on other assets (slab rate).
  final List<OtherStcgEntry> otherStcgEntries;

  /// Long-term capital gain entries on other assets (Section 112).
  final List<OtherLtcgEntry> otherLtcgEntries;

  /// Brought-forward short-term capital loss from previous years (positive).
  final double broughtForwardStcl;

  /// Brought-forward long-term capital loss from previous years (positive).
  final double broughtForwardLtcl;

  // ---------------------------------------------------------------------------
  // Short-term gains aggregates
  // ---------------------------------------------------------------------------

  /// Net STCG on listed equity/MF under Section 111A.
  double get totalStcg111A =>
      equityStcgEntries.fold(0.0, (sum, e) => sum + e.gain);

  /// Net STCG on debt instruments (slab rate).
  double get totalStcgDebt =>
      debtStcgEntries.fold(0.0, (sum, e) => sum + e.gain);

  /// Net STCG on other assets (slab rate).
  double get totalStcgOther =>
      otherStcgEntries.fold(0.0, (sum, e) => sum + e.gain);

  /// Aggregate short-term capital gains/losses across all STCG heads.
  double get netStcg => totalStcg111A + totalStcgDebt + totalStcgOther;

  // ---------------------------------------------------------------------------
  // Long-term gains aggregates
  // ---------------------------------------------------------------------------

  /// Net LTCG on listed equity/MF under Section 112A (pre-exemption).
  double get totalLtcg112A =>
      equityLtcgEntries.fold(0.0, (sum, e) => sum + e.gain);

  /// Net LTCG on debt instruments (slab rate post Finance Act 2023).
  double get totalLtcgDebt =>
      debtLtcgEntries.fold(0.0, (sum, e) => sum + e.gain);

  /// Net LTCG on immovable property (Section 112 — 20%).
  double get totalLtcgOnProperty =>
      propertyLtcgEntries.fold(0.0, (sum, e) => sum + e.gain);

  /// Net LTCG on other assets under Section 112.
  double get totalLtcgOther =>
      otherLtcgEntries.fold(0.0, (sum, e) => sum + e.gainWithIndexation);

  /// Aggregate long-term capital gains across all LTCG heads.
  double get netLtcg =>
      totalLtcg112A + totalLtcgDebt + totalLtcgOnProperty + totalLtcgOther;

  // ---------------------------------------------------------------------------
  // Set-off and carry-forward
  // ---------------------------------------------------------------------------

  /// STCG after set-off of brought-forward STCL, floored at zero.
  ///
  /// STCL can also be set off against LTCG. Excess STCL beyond current-year
  /// STCG is applied to LTCG in [netLtcgAfterSetOff].
  double get netStcgAfterSetOff {
    final afterSetOff = netStcg - broughtForwardStcl;
    return afterSetOff < 0 ? 0 : afterSetOff;
  }

  /// Excess STCL remaining after setting off current-year STCG.
  ///
  /// This excess is eligible to be set off against current-year LTCG.
  double get _excessStclForLtcg {
    final excessStcl = broughtForwardStcl - netStcg;
    return excessStcl > 0 ? excessStcl : 0;
  }

  /// LTCG after set-off of (remaining STCL + brought-forward LTCL),
  /// floored at zero.
  double get netLtcgAfterSetOff {
    final afterLosses = netLtcg - _excessStclForLtcg - broughtForwardLtcl;
    return afterLosses < 0 ? 0 : afterLosses;
  }

  ScheduleCg copyWith({
    List<EquityStcgEntry>? equityStcgEntries,
    List<EquityLtcgEntry>? equityLtcgEntries,
    List<DebtStcgEntry>? debtStcgEntries,
    List<DebtLtcgEntry>? debtLtcgEntries,
    List<PropertyLtcgEntry>? propertyLtcgEntries,
    List<OtherStcgEntry>? otherStcgEntries,
    List<OtherLtcgEntry>? otherLtcgEntries,
    double? broughtForwardStcl,
    double? broughtForwardLtcl,
  }) {
    return ScheduleCg(
      equityStcgEntries: equityStcgEntries ?? this.equityStcgEntries,
      equityLtcgEntries: equityLtcgEntries ?? this.equityLtcgEntries,
      debtStcgEntries: debtStcgEntries ?? this.debtStcgEntries,
      debtLtcgEntries: debtLtcgEntries ?? this.debtLtcgEntries,
      propertyLtcgEntries: propertyLtcgEntries ?? this.propertyLtcgEntries,
      otherStcgEntries: otherStcgEntries ?? this.otherStcgEntries,
      otherLtcgEntries: otherLtcgEntries ?? this.otherLtcgEntries,
      broughtForwardStcl: broughtForwardStcl ?? this.broughtForwardStcl,
      broughtForwardLtcl: broughtForwardLtcl ?? this.broughtForwardLtcl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleCg &&
        listEquals(other.equityStcgEntries, equityStcgEntries) &&
        listEquals(other.equityLtcgEntries, equityLtcgEntries) &&
        listEquals(other.debtStcgEntries, debtStcgEntries) &&
        listEquals(other.debtLtcgEntries, debtLtcgEntries) &&
        listEquals(other.propertyLtcgEntries, propertyLtcgEntries) &&
        listEquals(other.otherStcgEntries, otherStcgEntries) &&
        listEquals(other.otherLtcgEntries, otherLtcgEntries) &&
        other.broughtForwardStcl == broughtForwardStcl &&
        other.broughtForwardLtcl == broughtForwardLtcl;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(equityStcgEntries),
    Object.hashAll(equityLtcgEntries),
    Object.hashAll(debtStcgEntries),
    Object.hashAll(debtLtcgEntries),
    Object.hashAll(propertyLtcgEntries),
    Object.hashAll(otherStcgEntries),
    Object.hashAll(otherLtcgEntries),
    broughtForwardStcl,
    broughtForwardLtcl,
  );
}

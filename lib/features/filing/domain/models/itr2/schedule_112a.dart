import 'dart:math' show max;
import 'package:flutter/foundation.dart';

/// Section 112A exemption threshold for FY 2025-26 (Finance Act 2024).
///
/// LTCG on listed equity/MF above ₹1,25,000 is taxable at 12.5%.
const double _kExemptionLimit112A = 125000.0;

/// Immutable model for a single entry in Schedule 112A.
///
/// Schedule 112A captures LTCG on listed equity shares and equity-oriented MFs
/// where STT has been paid on both purchase and sale (or redemption).
///
/// Grandfathering rule (Section 112A proviso):
/// For assets acquired BEFORE 31-Jan-2018, cost of acquisition is deemed to be
/// the HIGHER of (a) the actual cost, or (b) the FMV on 31-Jan-2018.
/// This protects gains accrued until 31 Jan 2018 from taxation.
class Schedule112aEntry {
  const Schedule112aEntry({
    required this.isin,
    required this.assetName,
    required this.unitsOrShares,
    required this.salePrice,
    required this.costOfAcquisition,
    required this.fmvOn31Jan2018,
    required this.saleDate,
    required this.acquisitionDate,
  });

  /// ISIN of the security or MF scheme.
  final String isin;

  /// Name of the company or MF scheme.
  final String assetName;

  /// Number of units/shares sold.
  final double unitsOrShares;

  /// Total sale consideration (full value).
  final double salePrice;

  /// Actual cost of acquisition.
  final double costOfAcquisition;

  /// Fair market value as on 31 January 2018 (per SEBI/BSE/NSE closing price).
  ///
  /// Set to 0 for assets acquired after 31-Jan-2018 (grandfathering not applicable).
  final double fmvOn31Jan2018;

  /// Date of sale/transfer (ISO-8601 date string, e.g. '2025-01-15').
  final String saleDate;

  /// Date of acquisition (ISO-8601 date string, e.g. '2016-06-01').
  final String acquisitionDate;

  /// Effective cost of acquisition after applying grandfathering.
  ///
  /// = max(actual cost, FMV on 31-Jan-2018).
  double get effectiveCostOfAcquisition =>
      max(costOfAcquisition, fmvOn31Jan2018);

  /// Net LTCG on this entry (after grandfathering, no transfer expense field
  /// at entry level — net of brokerage already in salePrice in ITD schema).
  double get gain => salePrice - effectiveCostOfAcquisition;

  Schedule112aEntry copyWith({
    String? isin,
    String? assetName,
    double? unitsOrShares,
    double? salePrice,
    double? costOfAcquisition,
    double? fmvOn31Jan2018,
    String? saleDate,
    String? acquisitionDate,
  }) {
    return Schedule112aEntry(
      isin: isin ?? this.isin,
      assetName: assetName ?? this.assetName,
      unitsOrShares: unitsOrShares ?? this.unitsOrShares,
      salePrice: salePrice ?? this.salePrice,
      costOfAcquisition: costOfAcquisition ?? this.costOfAcquisition,
      fmvOn31Jan2018: fmvOn31Jan2018 ?? this.fmvOn31Jan2018,
      saleDate: saleDate ?? this.saleDate,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule112aEntry &&
        other.isin == isin &&
        other.assetName == assetName &&
        other.unitsOrShares == unitsOrShares &&
        other.salePrice == salePrice &&
        other.costOfAcquisition == costOfAcquisition &&
        other.fmvOn31Jan2018 == fmvOn31Jan2018 &&
        other.saleDate == saleDate &&
        other.acquisitionDate == acquisitionDate;
  }

  @override
  int get hashCode => Object.hash(
    isin,
    assetName,
    unitsOrShares,
    salePrice,
    costOfAcquisition,
    fmvOn31Jan2018,
    saleDate,
    acquisitionDate,
  );
}

/// Immutable aggregate model for Schedule 112A.
///
/// Aggregates all listed equity/MF LTCG entries and applies the ₹1.25L
/// exemption to derive the taxable gain (Finance Act 2024 rate: 12.5%).
class Schedule112a {
  const Schedule112a({required this.entries});

  /// All Schedule 112A entries for the assessment year.
  final List<Schedule112aEntry> entries;

  /// Total aggregate LTCG across all entries (before exemption).
  double get totalGain => entries.fold(0.0, (sum, e) => sum + e.gain);

  /// Taxable LTCG after applying the ₹1,25,000 exemption, floored at zero.
  double get taxableGain {
    final afterExemption = totalGain - _kExemptionLimit112A;
    return afterExemption < 0 ? 0 : afterExemption;
  }

  Schedule112a copyWith({List<Schedule112aEntry>? entries}) {
    return Schedule112a(entries: entries ?? this.entries);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule112a && listEquals(other.entries, entries);
  }

  @override
  int get hashCode => Object.hashAll(entries);
}

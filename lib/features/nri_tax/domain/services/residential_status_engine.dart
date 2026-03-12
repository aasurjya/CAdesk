import 'package:flutter/foundation.dart';
import 'package:ca_app/features/nri_tax/domain/models/residential_status.dart';

/// Immutable record of an individual's physical presence in a country
/// during a specific period.
@immutable
class StayRecord {
  const StayRecord({
    required this.dateFrom,
    required this.dateTo,
    required this.country,
  });

  /// Start date of the stay (inclusive).
  final DateTime dateFrom;

  /// End date of the stay (inclusive).
  final DateTime dateTo;

  /// ISO alpha-2 country code (use "IN" for India).
  final String country;

  StayRecord copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? country,
  }) {
    return StayRecord(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StayRecord &&
          runtimeType == other.runtimeType &&
          dateFrom == other.dateFrom &&
          dateTo == other.dateTo &&
          country == other.country;

  @override
  int get hashCode => Object.hash(dateFrom, dateTo, country);

  @override
  String toString() =>
      'StayRecord(country: $country, from: $dateFrom, to: $dateTo)';
}

/// Engine that determines residential status under Section 6 of the
/// Income Tax Act, 1961.
///
/// Rules implemented:
/// - **Resident**: days in India ≥ 182 in FY, OR (days ≥ 60 in FY AND
///   days ≥ 365 in preceding 4 FYs).
/// - **NRI**: neither condition above is met.
/// - **RNOR** (Resident but Not Ordinarily Resident): meets Resident test but
///   (was NRI in ≥ 9 of 10 preceding FYs) OR (days in India ≤ 729 in
///   preceding 7 FYs).
///
/// Financial year convention: FY [year] spans 1 April [year−1] to
/// 31 March [year].
class ResidentialStatusEngine {
  ResidentialStatusEngine._();

  static final ResidentialStatusEngine instance = ResidentialStatusEngine._();

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Determines the residential status of a taxpayer for [financialYear]
  /// based on the supplied [stayRecords].
  ///
  /// [financialYear] = 2024 → FY 2023-24 (1 Apr 2023 – 31 Mar 2024).
  ResidentialStatus determine(
    List<StayRecord> stayRecords,
    int financialYear,
  ) {
    final currentDays = computeDaysInIndia(stayRecords, financialYear);
    final prev1 = computeDaysInIndia(stayRecords, financialYear - 1);
    final prev2 = computeDaysInIndia(stayRecords, financialYear - 2);
    final prev3 = computeDaysInIndia(stayRecords, financialYear - 3);
    final prev4 = computeDaysInIndia(stayRecords, financialYear - 4);

    final preceding4Total = prev1 + prev2 + prev3 + prev4;

    // ── Resident tests ────────────────────────────────────────────────────
    final rule182 = currentDays >= 182;
    final rule60 = currentDays >= 60 && preceding4Total >= 365;
    final isResident = rule182 || rule60;

    if (!isResident) {
      return ResidentialStatus(
        pan: '',
        financialYear: financialYear,
        daysInIndia: currentDays,
        daysInIndiaPrev1: prev1,
        daysInIndiaPrev2: prev2,
        daysInIndiaPrev3: prev3,
        daysInIndiaPrev4: prev4,
        status: NriStatus.nri,
        determination: _buildNriDetermination(currentDays, preceding4Total),
      );
    }

    // ── RNOR tests (only applies when Resident) ───────────────────────────
    final isRnor = _checkRnor(stayRecords, financialYear);

    final finalStatus = isRnor ? NriStatus.rnor : NriStatus.resident;
    final determination = isRnor
        ? _buildRnorDetermination(stayRecords, financialYear, currentDays)
        : _buildResidentDetermination(currentDays, preceding4Total, rule182);

    return ResidentialStatus(
      pan: '',
      financialYear: financialYear,
      daysInIndia: currentDays,
      daysInIndiaPrev1: prev1,
      daysInIndiaPrev2: prev2,
      daysInIndiaPrev3: prev3,
      daysInIndiaPrev4: prev4,
      status: finalStatus,
      determination: determination,
    );
  }

  /// Computes the number of days an individual was present in India (country
  /// code "IN") during the financial year [financialYear].
  ///
  /// A financial year [fy] spans from 1 April [fy−1] to 31 March [fy].
  /// Records that partially overlap the year boundary are clipped.
  int computeDaysInIndia(List<StayRecord> records, int financialYear) {
    final fyStart = DateTime(financialYear - 1, 4, 1);
    final fyEnd = DateTime(financialYear, 3, 31);

    int total = 0;
    for (final record in records) {
      if (record.country != 'IN') continue;
      // Clip to FY boundaries
      final from = record.dateFrom.isBefore(fyStart) ? fyStart : record.dateFrom;
      final to = record.dateTo.isAfter(fyEnd) ? fyEnd : record.dateTo;
      if (to.isBefore(from)) continue;
      final days = to.difference(from).inDays + 1;
      total += days;
    }
    return total;
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  /// Checks whether the RNOR conditions are met for [financialYear].
  ///
  /// RNOR if:
  /// (a) Was NRI in ≥ 9 of the 10 immediately preceding FYs, OR
  /// (b) Was in India ≤ 729 days in the preceding 7 FYs.
  bool _checkRnor(List<StayRecord> stayRecords, int financialYear) {
    // Condition (b): days in preceding 7 FYs
    int days7 = 0;
    for (int i = 1; i <= 7; i++) {
      days7 += computeDaysInIndia(stayRecords, financialYear - i);
    }
    if (days7 <= 729) return true;

    // Condition (a): NRI count in preceding 10 FYs
    int nriYears = 0;
    for (int i = 1; i <= 10; i++) {
      final fy = financialYear - i;
      final days = computeDaysInIndia(stayRecords, fy);
      // Simplified resident test for prior years: ≥182 days
      if (days < 182) nriYears++;
    }
    return nriYears >= 9;
  }

  String _buildNriDetermination(int currentDays, int preceding4Days) {
    return 'NRI: $currentDays days in India this FY (< 182). '
        'Second rule not met: $currentDays < 60 days OR '
        '$preceding4Days days in preceding 4 years (< 365).';
  }

  String _buildResidentDetermination(
    int currentDays,
    int preceding4Days,
    bool via182,
  ) {
    if (via182) {
      return 'Resident via Section 6(1)(a): $currentDays days in India '
          '(≥ 182 days).';
    }
    return 'Resident via Section 6(1)(c): $currentDays days in India this FY '
        '(≥ 60) and $preceding4Days days in preceding 4 years (≥ 365).';
  }

  String _buildRnorDetermination(
    List<StayRecord> stayRecords,
    int financialYear,
    int currentDays,
  ) {
    int days7 = 0;
    for (int i = 1; i <= 7; i++) {
      days7 += computeDaysInIndia(stayRecords, financialYear - i);
    }

    int nriYears = 0;
    for (int i = 1; i <= 10; i++) {
      final days = computeDaysInIndia(stayRecords, financialYear - i);
      if (days < 182) nriYears++;
    }

    final reasons = <String>[];
    if (days7 <= 729) {
      reasons.add(
        'India days in preceding 7 years: $days7 (≤ 729)',
      );
    }
    if (nriYears >= 9) {
      reasons.add('NRI in $nriYears of preceding 10 years (≥ 9)');
    }

    return 'RNOR: Resident ($currentDays days this FY) but: '
        '${reasons.join('; ')}.';
  }
}

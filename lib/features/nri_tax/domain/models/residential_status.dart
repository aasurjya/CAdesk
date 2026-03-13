import 'package:flutter/foundation.dart';

/// Residential status under Section 6 of the Income Tax Act, 1961.
enum NriStatus {
  /// Ordinarily resident in India — taxed on worldwide income.
  resident('Resident'),

  /// Non-Resident Indian — taxed only on Indian-source income.
  nri('NRI'),

  /// Resident but Not Ordinarily Resident — partial exemption on foreign income.
  rnor('RNOR');

  const NriStatus(this.label);
  final String label;
}

/// Immutable model representing the determined residential status of a taxpayer
/// for a given financial year under Section 6 of the Income Tax Act, 1961.
///
/// Financial year convention: [financialYear] = 2024 means FY 2023-24
/// (1 April 2023 to 31 March 2024).
@immutable
class ResidentialStatus {
  const ResidentialStatus({
    required this.pan,
    required this.financialYear,
    required this.daysInIndia,
    required this.daysInIndiaPrev1,
    required this.daysInIndiaPrev2,
    required this.daysInIndiaPrev3,
    required this.daysInIndiaPrev4,
    required this.status,
    required this.determination,
  });

  /// PAN of the taxpayer.
  final String pan;

  /// Financial year — e.g. 2024 means FY 2023-24.
  final int financialYear;

  /// Days present in India during the current financial year.
  final int daysInIndia;

  /// Days in India during FY (financialYear − 1).
  final int daysInIndiaPrev1;

  /// Days in India during FY (financialYear − 2).
  final int daysInIndiaPrev2;

  /// Days in India during FY (financialYear − 3).
  final int daysInIndiaPrev3;

  /// Days in India during FY (financialYear − 4).
  final int daysInIndiaPrev4;

  /// Determined residential status.
  final NriStatus status;

  /// Human-readable explanation of the determination.
  final String determination;

  /// Total India days across the preceding 4 financial years.
  int get lookBackPeriodDays =>
      daysInIndiaPrev1 + daysInIndiaPrev2 + daysInIndiaPrev3 + daysInIndiaPrev4;

  /// True only when [status] is [NriStatus.rnor].
  bool get isRnor => status == NriStatus.rnor;

  ResidentialStatus copyWith({
    String? pan,
    int? financialYear,
    int? daysInIndia,
    int? daysInIndiaPrev1,
    int? daysInIndiaPrev2,
    int? daysInIndiaPrev3,
    int? daysInIndiaPrev4,
    NriStatus? status,
    String? determination,
  }) {
    return ResidentialStatus(
      pan: pan ?? this.pan,
      financialYear: financialYear ?? this.financialYear,
      daysInIndia: daysInIndia ?? this.daysInIndia,
      daysInIndiaPrev1: daysInIndiaPrev1 ?? this.daysInIndiaPrev1,
      daysInIndiaPrev2: daysInIndiaPrev2 ?? this.daysInIndiaPrev2,
      daysInIndiaPrev3: daysInIndiaPrev3 ?? this.daysInIndiaPrev3,
      daysInIndiaPrev4: daysInIndiaPrev4 ?? this.daysInIndiaPrev4,
      status: status ?? this.status,
      determination: determination ?? this.determination,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResidentialStatus &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          financialYear == other.financialYear &&
          daysInIndia == other.daysInIndia &&
          daysInIndiaPrev1 == other.daysInIndiaPrev1 &&
          daysInIndiaPrev2 == other.daysInIndiaPrev2 &&
          daysInIndiaPrev3 == other.daysInIndiaPrev3 &&
          daysInIndiaPrev4 == other.daysInIndiaPrev4 &&
          status == other.status &&
          determination == other.determination;

  @override
  int get hashCode => Object.hash(
    pan,
    financialYear,
    daysInIndia,
    daysInIndiaPrev1,
    daysInIndiaPrev2,
    daysInIndiaPrev3,
    daysInIndiaPrev4,
    status,
    determination,
  );

  @override
  String toString() =>
      'ResidentialStatus(pan: $pan, fy: $financialYear, '
      'days: $daysInIndia, status: ${status.label})';
}

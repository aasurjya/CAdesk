import 'package:flutter/material.dart';

/// Residency status for Income Tax purposes (India).
enum ResidencyStatus {
  resident(label: 'Resident'),
  nonResident(label: 'Non-Resident'),
  rnor(label: 'Resident but Not Ordinarily Resident');

  const ResidencyStatus({required this.label});

  final String label;
}

/// Filing status of an NRI Tax Record.
enum NriTaxStatus {
  draft(label: 'Draft', color: Color(0xFF757575)),
  inProgress(label: 'In Progress', color: Color(0xFFD4890E)),
  filed(label: 'Filed', color: Color(0xFF1A7A3A)),
  closed(label: 'Closed', color: Color(0xFF1565C0));

  const NriTaxStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Immutable model representing an NRI Tax record covering DTAA,
/// foreign assets (FBAR / Schedule FA) and related cross-border filings.
@immutable
class NriTaxRecord {
  const NriTaxRecord({
    required this.id,
    required this.clientId,
    required this.assessmentYear,
    required this.residencyStatus,
    required this.scheduleFA,
    required this.scheduleFSL,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.foreignIncomeSources,
    this.dtaaCountry,
    this.dtaaRelief,
  });

  final String id;
  final String clientId;

  /// Assessment year in "YYYY-YY" format, e.g. "2024-25".
  final String assessmentYear;

  final ResidencyStatus residencyStatus;

  /// Free-text description of foreign income sources (employment, dividends, etc.).
  final String? foreignIncomeSources;

  /// Country with which DTAA benefit is being claimed.
  final String? dtaaCountry;

  /// Amount of DTAA relief claimed (INR).
  final double? dtaaRelief;

  /// Whether Schedule FA (foreign assets) needs to be filed.
  final bool scheduleFA;

  /// Whether Schedule FSL (foreign source loss) needs to be filed.
  final bool scheduleFSL;

  final NriTaxStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  NriTaxRecord copyWith({
    String? id,
    String? clientId,
    String? assessmentYear,
    ResidencyStatus? residencyStatus,
    String? foreignIncomeSources,
    String? dtaaCountry,
    double? dtaaRelief,
    bool? scheduleFA,
    bool? scheduleFSL,
    NriTaxStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NriTaxRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      residencyStatus: residencyStatus ?? this.residencyStatus,
      foreignIncomeSources: foreignIncomeSources ?? this.foreignIncomeSources,
      dtaaCountry: dtaaCountry ?? this.dtaaCountry,
      dtaaRelief: dtaaRelief ?? this.dtaaRelief,
      scheduleFA: scheduleFA ?? this.scheduleFA,
      scheduleFSL: scheduleFSL ?? this.scheduleFSL,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NriTaxRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          assessmentYear == other.assessmentYear &&
          residencyStatus == other.residencyStatus &&
          foreignIncomeSources == other.foreignIncomeSources &&
          dtaaCountry == other.dtaaCountry &&
          dtaaRelief == other.dtaaRelief &&
          scheduleFA == other.scheduleFA &&
          scheduleFSL == other.scheduleFSL &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    assessmentYear,
    residencyStatus,
    foreignIncomeSources,
    dtaaCountry,
    dtaaRelief,
    scheduleFA,
    scheduleFSL,
    status,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'NriTaxRecord(id: $id, clientId: $clientId, '
      'ay: $assessmentYear, status: ${status.label})';
}

import 'package:flutter/material.dart';

/// Section 80-IAC tax holiday status for eligible startups.
enum Section80IACStatus {
  eligible(
    label: 'Eligible',
    color: Color(0xFF1565C0),
    icon: Icons.verified_outlined,
  ),
  applied(
    label: 'Applied',
    color: Color(0xFFD4890E),
    icon: Icons.pending_rounded,
  ),
  approved(
    label: 'Approved',
    color: Color(0xFF1A7A3A),
    icon: Icons.verified_rounded,
  ),
  expired(
    label: 'Expired',
    color: Color(0xFFC62828),
    icon: Icons.timer_off_rounded,
  );

  const Section80IACStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// DPIIT recognition status of the startup.
enum RecognitionStatus {
  recognized(
    label: 'Recognized',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  pending(
    label: 'Pending',
    color: Color(0xFFD4890E),
    icon: Icons.hourglass_empty_rounded,
  ),
  expired(
    label: 'Expired',
    color: Color(0xFFC62828),
    icon: Icons.cancel_rounded,
  );

  const RecognitionStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model for a single investment round in a startup.
@immutable
class InvestmentRound {
  const InvestmentRound({
    required this.roundName,
    required this.amount,
    required this.date,
    required this.investor,
  });

  final String roundName;
  final double amount;
  final DateTime date;
  final String investor;
}

/// Immutable model representing a DPIIT-recognized startup entity
/// eligible for benefits under Startup India.
@immutable
class StartupEntity {
  const StartupEntity({
    required this.id,
    required this.entityName,
    required this.dpiitNumber,
    required this.incorporationDate,
    required this.sector,
    required this.turnover,
    required this.isBelow100Cr,
    required this.section80IACStatus,
    this.taxHolidayStartYear,
    this.taxHolidayEndYear,
    required this.recognitionStatus,
    required this.investmentRounds,
  });

  final String id;
  final String entityName;
  final String dpiitNumber;
  final DateTime incorporationDate;
  final String sector;
  final double turnover;
  final bool isBelow100Cr;
  final Section80IACStatus section80IACStatus;
  final int? taxHolidayStartYear;
  final int? taxHolidayEndYear;
  final RecognitionStatus recognitionStatus;
  final List<InvestmentRound> investmentRounds;

  /// Returns a new [StartupEntity] with the given fields replaced.
  StartupEntity copyWith({
    String? id,
    String? entityName,
    String? dpiitNumber,
    DateTime? incorporationDate,
    String? sector,
    double? turnover,
    bool? isBelow100Cr,
    Section80IACStatus? section80IACStatus,
    int? taxHolidayStartYear,
    int? taxHolidayEndYear,
    RecognitionStatus? recognitionStatus,
    List<InvestmentRound>? investmentRounds,
  }) {
    return StartupEntity(
      id: id ?? this.id,
      entityName: entityName ?? this.entityName,
      dpiitNumber: dpiitNumber ?? this.dpiitNumber,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      sector: sector ?? this.sector,
      turnover: turnover ?? this.turnover,
      isBelow100Cr: isBelow100Cr ?? this.isBelow100Cr,
      section80IACStatus: section80IACStatus ?? this.section80IACStatus,
      taxHolidayStartYear: taxHolidayStartYear ?? this.taxHolidayStartYear,
      taxHolidayEndYear: taxHolidayEndYear ?? this.taxHolidayEndYear,
      recognitionStatus: recognitionStatus ?? this.recognitionStatus,
      investmentRounds: investmentRounds ?? this.investmentRounds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entityName == other.entityName &&
          dpiitNumber == other.dpiitNumber &&
          incorporationDate == other.incorporationDate &&
          sector == other.sector &&
          turnover == other.turnover &&
          isBelow100Cr == other.isBelow100Cr &&
          section80IACStatus == other.section80IACStatus &&
          recognitionStatus == other.recognitionStatus;

  @override
  int get hashCode => Object.hash(
    id,
    entityName,
    dpiitNumber,
    incorporationDate,
    sector,
    turnover,
    isBelow100Cr,
    section80IACStatus,
    recognitionStatus,
  );

  @override
  String toString() =>
      'StartupEntity(name: $entityName, dpiit: $dpiitNumber, '
      'recognition: ${recognitionStatus.label})';
}

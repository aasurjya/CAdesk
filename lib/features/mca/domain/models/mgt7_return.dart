import 'package:ca_app/features/mca/domain/models/director_detail.dart';

// ---------------------------------------------------------------------------
// Supporting value types
// ---------------------------------------------------------------------------

/// Category of shareholder per Schedule V of Companies Act 2013.
enum ShareholderCategory {
  promoterIndian,
  promoterForeign,
  publicInstitution,
  publicNonInstitution,
  nri,
  employees,
  other,
}

/// A single row in the shareholding pattern table.
class ShareholdingEntry {
  const ShareholdingEntry({
    required this.category,
    required this.numberOfShares,
    required this.percentage,
  });

  final ShareholderCategory category;
  final int numberOfShares;

  /// 0–100; all entries in a Mgt7Return must sum to 100.
  final double percentage;

  ShareholdingEntry copyWith({
    ShareholderCategory? category,
    int? numberOfShares,
    double? percentage,
  }) {
    return ShareholdingEntry(
      category: category ?? this.category,
      numberOfShares: numberOfShares ?? this.numberOfShares,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareholdingEntry &&
        other.category == category &&
        other.numberOfShares == numberOfShares &&
        other.percentage == percentage;
  }

  @override
  int get hashCode => Object.hash(category, numberOfShares, percentage);
}

/// Key Managerial Personnel entry (CEO, CFO, CS).
class KmpDetail {
  const KmpDetail({
    required this.din,
    required this.name,
    required this.designation,
    required this.dateOfAppointment,
    this.dateOfCessation,
  });

  final String din;
  final String name;
  final String designation;
  final DateTime dateOfAppointment;
  final DateTime? dateOfCessation;

  KmpDetail copyWith({
    String? din,
    String? name,
    String? designation,
    DateTime? dateOfAppointment,
    DateTime? dateOfCessation,
  }) {
    return KmpDetail(
      din: din ?? this.din,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      dateOfAppointment: dateOfAppointment ?? this.dateOfAppointment,
      dateOfCessation: dateOfCessation ?? this.dateOfCessation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KmpDetail &&
        other.din == din &&
        other.name == name &&
        other.designation == designation &&
        other.dateOfAppointment == dateOfAppointment &&
        other.dateOfCessation == dateOfCessation;
  }

  @override
  int get hashCode => Object.hash(
    din,
    name,
    designation,
    dateOfAppointment,
    dateOfCessation,
  );
}

/// Type of board / general meeting.
enum MeetingType {
  boardMeeting,
  agm,
  egm,
  auditCommittee,
  nominationCommittee,
}

/// A single meeting record for the year.
class MeetingRecord {
  const MeetingRecord({
    required this.meetingType,
    required this.date,
    required this.attendees,
  });

  final MeetingType meetingType;
  final DateTime date;

  /// List of DINs of directors who attended.
  final List<String> attendees;

  MeetingRecord copyWith({
    MeetingType? meetingType,
    DateTime? date,
    List<String>? attendees,
  }) {
    return MeetingRecord(
      meetingType: meetingType ?? this.meetingType,
      date: date ?? this.date,
      attendees: attendees ?? this.attendees,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MeetingRecord) return false;
    if (other.meetingType != meetingType) return false;
    if (other.date != date) return false;
    if (other.attendees.length != attendees.length) return false;
    for (int i = 0; i < attendees.length; i++) {
      if (other.attendees[i] != attendees[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(meetingType, date, Object.hashAll(attendees));
}

/// A penalty or compounding record disclosed in the annual return.
class PenaltyRecord {
  const PenaltyRecord({
    required this.section,
    required this.description,
    required this.amountInRupees,
    required this.date,
  });

  final String section;
  final String description;
  final double amountInRupees;
  final DateTime date;

  PenaltyRecord copyWith({
    String? section,
    String? description,
    double? amountInRupees,
    DateTime? date,
  }) {
    return PenaltyRecord(
      section: section ?? this.section,
      description: description ?? this.description,
      amountInRupees: amountInRupees ?? this.amountInRupees,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PenaltyRecord &&
        other.section == section &&
        other.description == description &&
        other.amountInRupees == amountInRupees &&
        other.date == date;
  }

  @override
  int get hashCode =>
      Object.hash(section, description, amountInRupees, date);
}

// ---------------------------------------------------------------------------
// MGT-7 Annual Return
// ---------------------------------------------------------------------------

/// Immutable model representing an MGT-7 Annual Return under Section 92
/// of the Companies Act 2013.
///
/// For March financial-year-end companies:
/// - AGM must be held on or before September 30
/// - MGT-7 must be filed within 60 days of AGM → deadline November 29
class Mgt7Return {
  const Mgt7Return({
    required this.cin,
    required this.companyName,
    required this.registeredOffice,
    required this.financialYear,
    required this.shareholdingPattern,
    required this.directors,
    required this.keyManagerialPersonnel,
    required this.meetings,
    required this.penalties,
    this.agmDate,
  });

  /// Corporate Identification Number.
  final String cin;
  final String companyName;
  final String registeredOffice;

  /// Calendar year in which the financial year ends (e.g. 2024 for FY 2023-24).
  final int financialYear;

  /// Date of Annual General Meeting. Null if AGM not yet held.
  final DateTime? agmDate;

  final List<ShareholdingEntry> shareholdingPattern;
  final List<DirectorDetail> directors;
  final List<KmpDetail> keyManagerialPersonnel;
  final List<MeetingRecord> meetings;
  final List<PenaltyRecord> penalties;

  /// Filing deadline = 60 days from AGM (or sentinel date when AGM unknown).
  DateTime get filingDeadline {
    if (agmDate == null) {
      return DateTime(financialYear, 11, 29);
    }
    return agmDate!.add(const Duration(days: 60));
  }

  Mgt7Return copyWith({
    String? cin,
    String? companyName,
    String? registeredOffice,
    int? financialYear,
    DateTime? agmDate,
    List<ShareholdingEntry>? shareholdingPattern,
    List<DirectorDetail>? directors,
    List<KmpDetail>? keyManagerialPersonnel,
    List<MeetingRecord>? meetings,
    List<PenaltyRecord>? penalties,
  }) {
    return Mgt7Return(
      cin: cin ?? this.cin,
      companyName: companyName ?? this.companyName,
      registeredOffice: registeredOffice ?? this.registeredOffice,
      financialYear: financialYear ?? this.financialYear,
      agmDate: agmDate ?? this.agmDate,
      shareholdingPattern: shareholdingPattern ?? this.shareholdingPattern,
      directors: directors ?? this.directors,
      keyManagerialPersonnel:
          keyManagerialPersonnel ?? this.keyManagerialPersonnel,
      meetings: meetings ?? this.meetings,
      penalties: penalties ?? this.penalties,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mgt7Return &&
        other.cin == cin &&
        other.companyName == companyName &&
        other.registeredOffice == registeredOffice &&
        other.financialYear == financialYear &&
        other.agmDate == agmDate;
  }

  @override
  int get hashCode => Object.hash(
    cin,
    companyName,
    registeredOffice,
    financialYear,
    agmDate,
  );
}

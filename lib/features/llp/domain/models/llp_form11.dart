// LLP Form-11: Annual Return of Limited Liability Partnership.
// Filed annually by every LLP with MCA within 60 days of close of financial year.
// Deadline: May 30 of the year following the financial year end.

/// Details of a partner in the LLP.
class LlpPartnerDetail {
  const LlpPartnerDetail({
    required this.dpin,
    required this.name,
    required this.contributionPaise,
    required this.isDesignatedPartner,
  });

  /// Designated Partner Identification Number.
  final String dpin;
  final String name;

  /// Capital contribution in paise.
  final int contributionPaise;

  /// Whether this partner is a designated partner (responsible for compliance).
  final bool isDesignatedPartner;

  LlpPartnerDetail copyWith({
    String? dpin,
    String? name,
    int? contributionPaise,
    bool? isDesignatedPartner,
  }) {
    return LlpPartnerDetail(
      dpin: dpin ?? this.dpin,
      name: name ?? this.name,
      contributionPaise: contributionPaise ?? this.contributionPaise,
      isDesignatedPartner: isDesignatedPartner ?? this.isDesignatedPartner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LlpPartnerDetail &&
        other.dpin == dpin &&
        other.name == name &&
        other.contributionPaise == contributionPaise &&
        other.isDesignatedPartner == isDesignatedPartner;
  }

  @override
  int get hashCode =>
      Object.hash(dpin, name, contributionPaise, isDesignatedPartner);
}

/// Record of a meeting held by the LLP partners.
class MeetingRecord {
  const MeetingRecord({
    required this.date,
    required this.purpose,
    required this.venue,
  });

  final DateTime date;
  final String purpose;
  final String venue;

  MeetingRecord copyWith({DateTime? date, String? purpose, String? venue}) {
    return MeetingRecord(
      date: date ?? this.date,
      purpose: purpose ?? this.purpose,
      venue: venue ?? this.venue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeetingRecord &&
        other.date == date &&
        other.purpose == purpose &&
        other.venue == venue;
  }

  @override
  int get hashCode => Object.hash(date, purpose, venue);
}

/// Data Transfer Object representing the LLP entity.
class LlpData {
  const LlpData({
    required this.llpin,
    required this.name,
    required this.registeredOffice,
    required this.numberOfPartners,
    required this.totalContributionPaise,
  });

  /// LLP Identification Number assigned by MCA.
  final String llpin;
  final String name;
  final String registeredOffice;
  final int numberOfPartners;

  /// Total capital contribution of all partners in paise.
  final int totalContributionPaise;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LlpData &&
        other.llpin == llpin &&
        other.name == name &&
        other.registeredOffice == registeredOffice &&
        other.numberOfPartners == numberOfPartners &&
        other.totalContributionPaise == totalContributionPaise;
  }

  @override
  int get hashCode => Object.hash(
    llpin,
    name,
    registeredOffice,
    numberOfPartners,
    totalContributionPaise,
  );
}

/// Immutable model for LLP Form-11 (Annual Return).
class LlpForm11 {
  const LlpForm11({
    required this.llpin,
    required this.name,
    required this.registeredOffice,
    required this.numberOfPartners,
    required this.totalContributionPaise,
    required this.financialYear,
    required this.partners,
    required this.meetings,
  });

  /// LLP Identification Number.
  final String llpin;
  final String name;
  final String registeredOffice;
  final int numberOfPartners;

  /// Total capital contribution in paise.
  final int totalContributionPaise;

  /// Financial year for which this return is being filed (e.g. 2024 for FY 2023-24).
  final int financialYear;

  final List<LlpPartnerDetail> partners;
  final List<MeetingRecord> meetings;

  LlpForm11 copyWith({
    String? llpin,
    String? name,
    String? registeredOffice,
    int? numberOfPartners,
    int? totalContributionPaise,
    int? financialYear,
    List<LlpPartnerDetail>? partners,
    List<MeetingRecord>? meetings,
  }) {
    return LlpForm11(
      llpin: llpin ?? this.llpin,
      name: name ?? this.name,
      registeredOffice: registeredOffice ?? this.registeredOffice,
      numberOfPartners: numberOfPartners ?? this.numberOfPartners,
      totalContributionPaise:
          totalContributionPaise ?? this.totalContributionPaise,
      financialYear: financialYear ?? this.financialYear,
      partners: partners ?? this.partners,
      meetings: meetings ?? this.meetings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LlpForm11) return false;
    if (other.llpin != llpin) return false;
    if (other.name != name) return false;
    if (other.registeredOffice != registeredOffice) return false;
    if (other.numberOfPartners != numberOfPartners) return false;
    if (other.totalContributionPaise != totalContributionPaise) return false;
    if (other.financialYear != financialYear) return false;
    if (other.partners.length != partners.length) return false;
    if (other.meetings.length != meetings.length) return false;
    for (var i = 0; i < partners.length; i++) {
      if (other.partners[i] != partners[i]) return false;
    }
    for (var i = 0; i < meetings.length; i++) {
      if (other.meetings[i] != meetings[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    llpin,
    name,
    registeredOffice,
    numberOfPartners,
    totalContributionPaise,
    financialYear,
    Object.hashAll(partners),
    Object.hashAll(meetings),
  );
}

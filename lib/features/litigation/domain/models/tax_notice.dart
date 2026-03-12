/// Notice types issued by the Income Tax Department.
enum NoticeType {
  /// Section 143(1) — CPC intimation (adjustments, TDS mismatch, etc.)
  intimation143_1,

  /// Section 143(2) — Scrutiny notice selecting the return for scrutiny.
  scrutiny143_2,

  /// Section 143(3) — Assessment order (faceless assessment via NFAC).
  assessment143_3,

  /// Section 148 — Notice for reopening/reassessment of a completed assessment.
  reopening148,

  /// Section 156 — Demand notice (penalty or tax demand).
  penalty156,

  /// Show-cause notice before penalty imposition or disallowance.
  show_cause,

  /// High-pitched assessment (demand > 3× returned income).
  highPitchAssessment,

  /// Search and seizure under Section 132 / 132A.
  search_seizure,
}

/// Lifecycle status of a tax notice.
enum NoticeStatus {
  received,
  underReview,
  responseDrafted,
  responseFiled,
  resolved,
  appealed,
}

/// Urgency level based on time remaining before the response deadline.
enum UrgencyLevel {
  /// < 7 days remaining.
  critical,

  /// 7–15 days remaining.
  high,

  /// 15–30 days remaining.
  medium,

  /// > 30 days remaining.
  low,
}

/// Immutable model representing a tax notice received by a client.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
class TaxNotice {
  const TaxNotice({
    required this.noticeId,
    required this.pan,
    required this.assessmentYear,
    required this.noticeType,
    required this.issuedBy,
    required this.issuedDate,
    required this.responseDeadline,
    required this.section,
    required this.status,
    this.demandAmount,
  });

  final String noticeId;
  final String pan;
  final String assessmentYear;
  final NoticeType noticeType;
  final String issuedBy;
  final DateTime issuedDate;
  final DateTime responseDeadline;

  /// Demand amount in paise. Null if no monetary demand is raised.
  final int? demandAmount;

  final String section;
  final NoticeStatus status;

  TaxNotice copyWith({
    String? noticeId,
    String? pan,
    String? assessmentYear,
    NoticeType? noticeType,
    String? issuedBy,
    DateTime? issuedDate,
    DateTime? responseDeadline,
    int? demandAmount,
    String? section,
    NoticeStatus? status,
  }) {
    return TaxNotice(
      noticeId: noticeId ?? this.noticeId,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      noticeType: noticeType ?? this.noticeType,
      issuedBy: issuedBy ?? this.issuedBy,
      issuedDate: issuedDate ?? this.issuedDate,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      demandAmount: demandAmount ?? this.demandAmount,
      section: section ?? this.section,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxNotice && other.noticeId == noticeId;
  }

  @override
  int get hashCode => noticeId.hashCode;
}

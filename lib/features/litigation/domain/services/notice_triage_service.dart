import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/notice_triage_result.dart';

/// Stateless service that performs AI-assisted triage of Income Tax notices.
///
/// Triage encompasses:
/// - Risk assessment (demand quantum + notice type)
/// - Urgency computation (days to deadline)
/// - Suggested legal grounds for response
/// - Recommended action (respond / appeal / pay / seekStay / ignore)
///
/// All monetary thresholds are expressed in **paise**:
/// - ₹10,00,000 = 100,000,000 paise (critical threshold)
/// - ₹1,00,000  =  10,000,000 paise (high threshold)
class NoticeTriageService {
  NoticeTriageService._();

  static final NoticeTriageService instance = NoticeTriageService._();

  // Demand thresholds in paise
  static const int _criticalDemandThreshold = 100_000_000; // ₹10L
  static const int _highDemandThreshold = 10_000_000; // ₹1L

  // Urgency thresholds in days
  static const int _criticalDays = 7;
  static const int _highDays = 15;
  static const int _mediumDays = 30;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fully triages a notice and returns a [NoticeTriageResult].
  static NoticeTriageResult triage(TaxNotice notice) {
    final today = DateTime.now();
    final risk = assessRisk(notice);
    final urgency = computeUrgency(notice, today);
    final grounds = suggestGrounds(notice);
    final action = _recommendAction(notice, risk);
    final issues = _identifyKeyIssues(notice);
    final timeline = _buildTimelineAdvice(notice, urgency, today);

    return NoticeTriageResult(
      noticeId: notice.noticeId,
      recommendedAction: action,
      riskLevel: risk,
      keyIssues: issues,
      suggestedGrounds: grounds,
      timelineAdvice: timeline,
      estimatedDemand: notice.demandAmount ?? 0,
    );
  }

  /// Classifies the risk level of a notice.
  ///
  /// Rules:
  /// - Critical: demand ≥ ₹10L OR search & seizure notice.
  /// - High: demand ≥ ₹1L OR 148 reopening notice.
  /// - Medium: 143(1) adjustments, penalty notices with any demand.
  /// - Low: routine queries, no demand, show-cause.
  static RiskLevel assessRisk(TaxNotice notice) {
    // Search & seizure is always critical.
    if (notice.noticeType == NoticeType.search_seizure) {
      return RiskLevel.critical;
    }

    final demand = notice.demandAmount ?? 0;

    if (demand >= _criticalDemandThreshold) return RiskLevel.critical;

    if (demand >= _highDemandThreshold || notice.noticeType == NoticeType.reopening148) {
      return RiskLevel.high;
    }

    if (_isMediumRiskType(notice.noticeType) && demand > 0) {
      return RiskLevel.medium;
    }

    return RiskLevel.low;
  }

  /// Computes the urgency level based on days remaining before [notice.responseDeadline].
  ///
  /// - Critical: ≤ 7 days (or past deadline).
  /// - High: 8–15 days.
  /// - Medium: 16–30 days.
  /// - Low: > 30 days.
  static UrgencyLevel computeUrgency(TaxNotice notice, DateTime today) {
    final daysRemaining =
        notice.responseDeadline.difference(today).inDays;

    if (daysRemaining <= _criticalDays) return UrgencyLevel.critical;
    if (daysRemaining <= _highDays) return UrgencyLevel.high;
    if (daysRemaining <= _mediumDays) return UrgencyLevel.medium;
    return UrgencyLevel.low;
  }

  /// Returns a list of suggested legal grounds for responding to the notice.
  static List<String> suggestGrounds(TaxNotice notice) {
    switch (notice.noticeType) {
      case NoticeType.intimation143_1:
        return [
          'TDS credit mismatch',
          'Advance tax credit not given',
          'Arithmetical error',
          'Income already offered in correct head',
        ];

      case NoticeType.scrutiny143_2:
        return [
          'Return selected for scrutiny — full compliance to be demonstrated',
          'All deductions claimed with documentary evidence',
          'Source of income fully explained',
          'No unexplained cash or credits',
        ];

      case NoticeType.assessment143_3:
        return [
          'Addition without jurisdiction',
          'No opportunity of hearing',
          'Addition based on estimate',
          'Principles of natural justice violated',
          'Faceless assessment procedure not followed (NFAC)',
        ];

      case NoticeType.reopening148:
        return [
          'Reassessment beyond limitation period',
          'No tangible material',
          'Change of opinion',
          'Income already assessed in original assessment',
          'Condition precedent u/s 147 not satisfied',
        ];

      case NoticeType.penalty156:
        return [
          'Bona fide belief',
          'Reasonable cause',
          'No concealment intent',
          'Tax underpayment due to inadvertent error, not fraud',
          'Penalty not leviable when quantum appeal is pending',
        ];

      case NoticeType.show_cause:
        return [
          'Bona fide belief',
          'Reasonable cause',
          'All facts fully and truthfully disclosed',
          'No deliberate non-compliance',
        ];

      case NoticeType.highPitchAssessment:
        return [
          'Demand exceeds 3× returned income — mandatory PCIT review',
          'Addition based on presumption without corroborative evidence',
          'Comparable cases / precedents ignored',
          'High-pitched assessment guidelines violated (CBDT Circular)',
        ];

      case NoticeType.search_seizure:
        return [
          'Seized documents belong to third party',
          'No undisclosed income found during search',
          'Satisfaction note u/s 132 not properly recorded',
          'Block assessment period exceeded',
          'All assets/income already declared',
        ];
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static bool _isMediumRiskType(NoticeType type) {
    return type == NoticeType.intimation143_1 ||
        type == NoticeType.penalty156 ||
        type == NoticeType.show_cause ||
        type == NoticeType.scrutiny143_2;
  }

  static RecommendedAction _recommendAction(
    TaxNotice notice,
    RiskLevel risk,
  ) {
    switch (risk) {
      case RiskLevel.critical:
        return RecommendedAction.seekStay;
      case RiskLevel.high:
        return RecommendedAction.appeal;
      case RiskLevel.medium:
        // Small 143(1) demands are often best paid if uncontestable.
        if (notice.noticeType == NoticeType.intimation143_1 &&
            (notice.demandAmount ?? 0) < 5_000_000) {
          // < ₹50k: consider pay or respond
          return notice.demandAmount != null &&
                  notice.demandAmount! < 1_000_000
              ? RecommendedAction.pay
              : RecommendedAction.respond;
        }
        return RecommendedAction.respond;
      case RiskLevel.low:
        return notice.noticeType == NoticeType.show_cause
            ? RecommendedAction.respond
            : RecommendedAction.ignore;
    }
  }

  static List<String> _identifyKeyIssues(TaxNotice notice) {
    final issues = <String>[];

    switch (notice.noticeType) {
      case NoticeType.intimation143_1:
        issues.addAll([
          'CPC adjustment — verify against Form 26AS and AIS',
          'Check TDS/advance tax credit matching',
        ]);
      case NoticeType.scrutiny143_2:
        issues.addAll([
          'Return selected for scrutiny — gather all source documents',
          'Prepare reconciliation of income heads',
        ]);
      case NoticeType.assessment143_3:
        issues.addAll([
          'Faceless assessment (NFAC) — respond only via e-Proceedings portal',
          'Review addition grounds and prepare rebuttal',
        ]);
      case NoticeType.reopening148:
        issues.addAll([
          'Verify whether reassessment is within limitation period',
          'Challenge tangibility of material on which reopening is based',
        ]);
      case NoticeType.penalty156:
        issues.addAll([
          'Demand u/s 156 — verify computation of penalty',
          'Check if penalty proceedings separate from quantum appeal',
        ]);
      case NoticeType.show_cause:
        issues.addAll([
          'Respond with full factual explanation',
          'Provide documentary evidence of compliance',
        ]);
      case NoticeType.highPitchAssessment:
        issues.addAll([
          'Demand > 3× returned income — invoke PCIT review mechanism',
          'File representation before Local Committee on Disputes',
        ]);
      case NoticeType.search_seizure:
        issues.addAll([
          'Post-search assessment under s.153A — ensure compliance',
          'Account for all seized material and cash',
          'Engage senior counsel immediately',
        ]);
    }

    return issues;
  }

  static String _buildTimelineAdvice(
    TaxNotice notice,
    UrgencyLevel urgency,
    DateTime today,
  ) {
    final daysRemaining =
        notice.responseDeadline.difference(today).inDays;

    final prefix = switch (urgency) {
      UrgencyLevel.critical =>
        'URGENT: Only $daysRemaining day(s) remaining to respond.',
      UrgencyLevel.high =>
        'HIGH PRIORITY: $daysRemaining days to deadline.',
      UrgencyLevel.medium =>
        '$daysRemaining days remaining — begin preparation.',
      UrgencyLevel.low =>
        '$daysRemaining days to deadline — plan response.',
    };

    return '$prefix '
        'Response must be filed via the e-Proceedings portal '
        'by ${_formatDate(notice.responseDeadline)}.';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

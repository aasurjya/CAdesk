import 'package:flutter/foundation.dart';

import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';

// ---------------------------------------------------------------------------
// LlpPenaltyCalculator
// ---------------------------------------------------------------------------

/// Pure calculator class for LLP compliance penalty rules (MCA).
class LlpPenaltyCalculator {
  LlpPenaltyCalculator._();

  /// Form 11 (Annual Return) late filing fee: ₹100 per day (no cap).
  static double form11LateFee(int daysLate) {
    if (daysLate <= 0) return 0;
    return daysLate * 100.0;
  }

  /// Form 8 (Statement of Accounts) late filing fee: ₹100 per day.
  static double form8LateFee(int daysLate) {
    if (daysLate <= 0) return 0;
    return daysLate * 100.0;
  }

  /// Audit threshold: turnover > ₹40L or contribution > ₹25L requires audit.
  static bool requiresAudit({
    required double turnoverLakhs,
    required double contributionLakhs,
  }) {
    return turnoverLakhs > 40 || contributionLakhs > 25;
  }

  /// ITR-5 due date for LLP (non-audit: Jul 31, audit: Oct 31, TP: Nov 30).
  static String itr5DueDate({
    required bool requiresAudit,
    required bool hasTransferPricing,
  }) {
    if (hasTransferPricing) return '30 Nov';
    if (requiresAudit) return '31 Oct';
    return '31 Jul';
  }

  /// Strike-off risk: LLP with no filing for 3+ years.
  static bool hasStrikeOffRisk({required int yearsSinceLastFiling}) {
    return yearsSinceLastFiling >= 3;
  }

  static const double designatedPartnerMinPenalty = 10000;
  static const double designatedPartnerMaxPenalty = 100000;
}

// ---------------------------------------------------------------------------
// LlpFilingRecord model
// ---------------------------------------------------------------------------

/// Immutable model aggregating Form 11 / Form 8 compliance status for an LLP.
@immutable
class LlpFilingRecord {
  const LlpFilingRecord({
    required this.id,
    required this.llpName,
    required this.llpin,
    required this.form11DaysLate,
    required this.form8DaysLate,
    required this.turnoverLakhs,
    required this.contributionLakhs,
    required this.form11Status,
    required this.form8Status,
    required this.yearsSinceLastFiling,
    required this.assessmentYear,
  });

  final String id;
  final String llpName;
  final String llpin;
  final int form11DaysLate;
  final int form8DaysLate;
  final double turnoverLakhs;
  final double contributionLakhs;
  final LLPFilingStatus form11Status;
  final LLPFilingStatus form8Status;
  final int yearsSinceLastFiling;
  final String assessmentYear;

  double get form11Penalty =>
      LlpPenaltyCalculator.form11LateFee(form11DaysLate);
  double get form8Penalty => LlpPenaltyCalculator.form8LateFee(form8DaysLate);
  double get totalPenalty => form11Penalty + form8Penalty;
  bool get requiresAudit => LlpPenaltyCalculator.requiresAudit(
    turnoverLakhs: turnoverLakhs,
    contributionLakhs: contributionLakhs,
  );
  bool get hasStrikeOffRisk => LlpPenaltyCalculator.hasStrikeOffRisk(
    yearsSinceLastFiling: yearsSinceLastFiling,
  );

  LlpFilingRecord copyWith({
    String? id,
    String? llpName,
    String? llpin,
    int? form11DaysLate,
    int? form8DaysLate,
    double? turnoverLakhs,
    double? contributionLakhs,
    LLPFilingStatus? form11Status,
    LLPFilingStatus? form8Status,
    int? yearsSinceLastFiling,
    String? assessmentYear,
  }) {
    return LlpFilingRecord(
      id: id ?? this.id,
      llpName: llpName ?? this.llpName,
      llpin: llpin ?? this.llpin,
      form11DaysLate: form11DaysLate ?? this.form11DaysLate,
      form8DaysLate: form8DaysLate ?? this.form8DaysLate,
      turnoverLakhs: turnoverLakhs ?? this.turnoverLakhs,
      contributionLakhs: contributionLakhs ?? this.contributionLakhs,
      form11Status: form11Status ?? this.form11Status,
      form8Status: form8Status ?? this.form8Status,
      yearsSinceLastFiling: yearsSinceLastFiling ?? this.yearsSinceLastFiling,
      assessmentYear: assessmentYear ?? this.assessmentYear,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlpFilingRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          assessmentYear == other.assessmentYear &&
          form11Status == other.form11Status &&
          form8Status == other.form8Status;

  @override
  int get hashCode =>
      Object.hash(id, assessmentYear, form11Status, form8Status);

  @override
  String toString() =>
      'LlpFilingRecord(llpName: $llpName, penalty: $totalPenalty)';
}

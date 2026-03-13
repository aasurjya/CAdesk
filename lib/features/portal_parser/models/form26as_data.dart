import 'package:ca_app/features/portal_parser/models/tds_entry_26as.dart';
import 'package:flutter/foundation.dart';

/// Immutable aggregate model for all data parsed from Form 26AS.
///
/// All monetary amounts are stored in **paise** (1 rupee = 100 paise).
@immutable
class Form26AsData {
  const Form26AsData({
    required this.pan,
    required this.assessmentYear,
    required this.tdsEntries,
    required this.tcsTcsEntries,
    required this.advanceTaxEntries,
    required this.selfAssessmentEntries,
    required this.refundEntries,
    required this.totalTdsCredited,
    required this.totalTcsCredited,
  });

  /// PAN of the taxpayer.
  final String pan;

  /// Assessment year in "YYYY-YY" format (e.g. "2024-25").
  final String assessmentYear;

  /// TDS entries (Part A of Form 26AS).
  final List<TdsEntry26As> tdsEntries;

  /// TCS entries (Part B of Form 26AS).
  final List<TcsEntry26As> tcsTcsEntries;

  /// Advance tax payment entries (Part C of Form 26AS).
  final List<TaxPaymentEntry26As> advanceTaxEntries;

  /// Self-assessment tax payment entries (Part C of Form 26AS).
  final List<TaxPaymentEntry26As> selfAssessmentEntries;

  /// Refund entries (Part D of Form 26AS).
  final List<RefundEntry26As> refundEntries;

  /// Total TDS credited across all [tdsEntries], in paise.
  final int totalTdsCredited;

  /// Total TCS credited across all [tcsTcsEntries], in paise.
  final int totalTcsCredited;

  Form26AsData copyWith({
    String? pan,
    String? assessmentYear,
    List<TdsEntry26As>? tdsEntries,
    List<TcsEntry26As>? tcsTcsEntries,
    List<TaxPaymentEntry26As>? advanceTaxEntries,
    List<TaxPaymentEntry26As>? selfAssessmentEntries,
    List<RefundEntry26As>? refundEntries,
    int? totalTdsCredited,
    int? totalTcsCredited,
  }) {
    return Form26AsData(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      tdsEntries: tdsEntries ?? this.tdsEntries,
      tcsTcsEntries: tcsTcsEntries ?? this.tcsTcsEntries,
      advanceTaxEntries: advanceTaxEntries ?? this.advanceTaxEntries,
      selfAssessmentEntries:
          selfAssessmentEntries ?? this.selfAssessmentEntries,
      refundEntries: refundEntries ?? this.refundEntries,
      totalTdsCredited: totalTdsCredited ?? this.totalTdsCredited,
      totalTcsCredited: totalTcsCredited ?? this.totalTcsCredited,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          assessmentYear == other.assessmentYear &&
          totalTdsCredited == other.totalTdsCredited &&
          totalTcsCredited == other.totalTcsCredited;

  @override
  int get hashCode =>
      Object.hash(pan, assessmentYear, totalTdsCredited, totalTcsCredited);

  @override
  String toString() =>
      'Form26AsData(pan: $pan, ay: $assessmentYear, '
      'tdsEntries: ${tdsEntries.length}, totalTds: $totalTdsCredited)';
}

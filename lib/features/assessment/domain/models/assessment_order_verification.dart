import 'package:ca_app/features/assessment/domain/models/order_discrepancy.dart';

/// Type of assessment/intimation order.
enum OrderType {
  /// Section 143(1) — CPC-processed intimation (most common).
  intimation143_1(label: '143(1) Intimation'),

  /// Section 143(3) — Scrutiny assessment.
  assessment143_3(label: '143(3) Scrutiny'),

  /// Section 147 — Reassessment / reopening.
  reopening147(label: '147 Reopening');

  const OrderType({required this.label});

  final String label;
}

/// Overall result of the verification exercise.
enum VerificationResult {
  /// All figures match; no action required.
  correct(label: 'Correct'),

  /// Minor differences found; may or may not warrant filing.
  discrepancy(label: 'Discrepancy'),

  /// Errors that require filing a rectification u/s 154.
  needsRectification(label: 'Needs Rectification');

  const VerificationResult({required this.label});

  final String label;
}

/// Immutable result of verifying a 143(1)/143(3)/147 order against the
/// taxpayer's filed return.
///
/// All monetary amounts are in **paise** (integer).
class AssessmentOrderVerification {
  const AssessmentOrderVerification({
    required this.panNumber,
    required this.assessmentYear,
    required this.orderType,
    required this.filedIncome,
    required this.assessedIncome,
    required this.taxDemand,
    required this.interestCharged,
    required this.penaltyLeviable,
    required this.verificationResult,
    required this.discrepancies,
    this.orderDate,
  });

  /// 10-character PAN of the taxpayer.
  final String panNumber;

  /// Assessment year, e.g. "2023-24".
  final String assessmentYear;

  final OrderType orderType;

  /// Income as declared in the filed ITR (paise).
  final int filedIncome;

  /// Income as assessed by the department (paise).
  final int assessedIncome;

  /// Net tax demand raised by the department (paise).
  final int taxDemand;

  /// Interest charged in the order (paise).
  final int interestCharged;

  /// Penalty leviable, if any (paise).
  final int penaltyLeviable;

  final VerificationResult verificationResult;

  /// List of individual discrepancies found.
  final List<OrderDiscrepancy> discrepancies;

  /// Date the order was issued (optional — not present on intimations).
  final DateTime? orderDate;

  AssessmentOrderVerification copyWith({
    String? panNumber,
    String? assessmentYear,
    OrderType? orderType,
    int? filedIncome,
    int? assessedIncome,
    int? taxDemand,
    int? interestCharged,
    int? penaltyLeviable,
    VerificationResult? verificationResult,
    List<OrderDiscrepancy>? discrepancies,
    DateTime? orderDate,
  }) {
    return AssessmentOrderVerification(
      panNumber: panNumber ?? this.panNumber,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      orderType: orderType ?? this.orderType,
      filedIncome: filedIncome ?? this.filedIncome,
      assessedIncome: assessedIncome ?? this.assessedIncome,
      taxDemand: taxDemand ?? this.taxDemand,
      interestCharged: interestCharged ?? this.interestCharged,
      penaltyLeviable: penaltyLeviable ?? this.penaltyLeviable,
      verificationResult: verificationResult ?? this.verificationResult,
      discrepancies: discrepancies ?? this.discrepancies,
      orderDate: orderDate ?? this.orderDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssessmentOrderVerification) return false;
    if (other.panNumber != panNumber) return false;
    if (other.assessmentYear != assessmentYear) return false;
    if (other.orderType != orderType) return false;
    if (other.filedIncome != filedIncome) return false;
    if (other.assessedIncome != assessedIncome) return false;
    if (other.taxDemand != taxDemand) return false;
    if (other.interestCharged != interestCharged) return false;
    if (other.penaltyLeviable != penaltyLeviable) return false;
    if (other.verificationResult != verificationResult) return false;
    if (other.orderDate != orderDate) return false;
    if (other.discrepancies.length != discrepancies.length) return false;
    for (var i = 0; i < discrepancies.length; i++) {
      if (other.discrepancies[i] != discrepancies[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    panNumber,
    assessmentYear,
    orderType,
    filedIncome,
    assessedIncome,
    taxDemand,
    interestCharged,
    penaltyLeviable,
    verificationResult,
    orderDate,
    Object.hashAll(discrepancies),
  );
}

import 'package:ca_app/features/assessment/domain/models/assessment_order_verification.dart';
import 'package:ca_app/features/assessment/domain/models/order_discrepancy.dart';

// ---------------------------------------------------------------------------
// Input data types
// ---------------------------------------------------------------------------

/// Type of CPC adjustment found in a 143(1) intimation.
enum AdjustmentType {
  /// Disallowance under Section 14A (expenditure relating to exempt income).
  disallowanceSec14A,

  /// Depreciation reduced / disallowed by CPC.
  incorrectDepreciation,

  /// Arithmetical error in the filed return.
  arithmeticalError,

  /// Incorrect claim not covered by other types.
  incorrectClaim,
}

/// A single CPC adjustment item in a 143(1) intimation.
class AdjustmentItem {
  const AdjustmentItem({
    required this.type,
    required this.amount,
    required this.description,
  });

  final AdjustmentType type;

  /// Amount of the adjustment in paise.
  final int amount;

  final String description;
}

/// Flattened representation of a 143(1) intimation for verification input.
///
/// All monetary amounts are in **paise** (integer).
class IntimationData {
  const IntimationData({
    required this.panNumber,
    required this.assessmentYear,
    required this.assessedIncome,
    required this.taxAssessed,
    required this.taxDemand,
    required this.interestCharged,
    required this.tdsCredited,
    required this.advanceTaxCredited,
    required this.selfAssessmentTax,
    required this.adjustments,
  });

  final String panNumber;
  final String assessmentYear;
  final int assessedIncome;
  final int taxAssessed;
  final int taxDemand;
  final int interestCharged;
  final int tdsCredited;
  final int advanceTaxCredited;
  final int selfAssessmentTax;
  final List<AdjustmentItem> adjustments;
}

/// Flattened representation of filed ITR data for comparison.
///
/// All monetary amounts are in **paise** (integer).
class ItrData {
  const ItrData({
    required this.panNumber,
    required this.assessmentYear,
    required this.filedIncome,
    required this.taxOnIncome,
    required this.tdsClaimed,
    required this.advanceTaxClaimed,
    required this.selfAssessmentTax,
  });

  final String panNumber;
  final String assessmentYear;
  final int filedIncome;
  final int taxOnIncome;
  final int tdsClaimed;
  final int advanceTaxClaimed;
  final int selfAssessmentTax;
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

/// Stateless engine for verifying Income Tax assessment orders and intimations.
///
/// Supports:
/// - Section 143(1) intimation verification against filed ITR
/// - Interest u/s 143(1A) on demand
/// - CPC adjustment checks
class AssessmentOrderCheckerEngine {
  AssessmentOrderCheckerEngine._();

  static final AssessmentOrderCheckerEngine instance =
      AssessmentOrderCheckerEngine._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Verifies a 143(1) intimation against the taxpayer's filed return.
  ///
  /// Checks:
  /// 1. Income mismatch
  /// 2. TDS credit mismatch (Form 26AS vs ITR claim)
  /// 3. Advance tax credit mismatch
  /// 4. CPC adjustments
  ///
  /// Returns an [AssessmentOrderVerification] with all discrepancies and the
  /// overall [VerificationResult].
  AssessmentOrderVerification verifyIntimation143_1(
    IntimationData intimation,
    ItrData filedReturn,
  ) {
    final discrepancies = <OrderDiscrepancy>[
      ..._checkIncomeMismatch(intimation, filedReturn),
      ..._checkTdsMismatch(intimation, filedReturn),
      ..._checkAdvanceTaxMismatch(intimation, filedReturn),
      ...checkSection143_1Adjustments(intimation),
    ];

    final result = _resolveResult(discrepancies, intimation, filedReturn);

    return AssessmentOrderVerification(
      panNumber: intimation.panNumber,
      assessmentYear: intimation.assessmentYear,
      orderType: OrderType.intimation143_1,
      filedIncome: filedReturn.filedIncome,
      assessedIncome: intimation.assessedIncome,
      taxDemand: intimation.taxDemand,
      interestCharged: intimation.interestCharged,
      penaltyLeviable: 0,
      verificationResult: result,
      discrepancies: List.unmodifiable(discrepancies),
    );
  }

  /// Computes Section 143(1A) interest on demand.
  ///
  /// Rate: 1% per month (or part thereof) on [taxDemand].
  /// Period: [dueDate] to [paymentDate].
  /// Returns interest in paise. Returns 0 if paid on or before due date.
  int computeInterest143_1A(
    int taxDemand,
    DateTime dueDate,
    DateTime paymentDate,
  ) {
    if (taxDemand <= 0) return 0;
    final months = _monthsDelayed(dueDate, paymentDate);
    if (months <= 0) return 0;
    return (taxDemand * months) ~/ 100;
  }

  /// Returns [OrderDiscrepancy] objects for each CPC adjustment in the
  /// intimation that represents a change from the filed figures.
  List<OrderDiscrepancy> checkSection143_1Adjustments(IntimationData data) {
    final result = <OrderDiscrepancy>[];
    for (final item in data.adjustments) {
      final discrepancy = _adjustmentToDiscrepancy(item);
      if (discrepancy != null) {
        result.add(discrepancy);
      }
    }
    return List.unmodifiable(result);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  List<OrderDiscrepancy> _checkIncomeMismatch(
    IntimationData intimation,
    ItrData filedReturn,
  ) {
    if (intimation.assessedIncome == filedReturn.filedIncome) return [];
    return [
      OrderDiscrepancy(
        section: 'Total Income',
        filedAmount: filedReturn.filedIncome,
        assessedAmount: intimation.assessedIncome,
        difference: intimation.assessedIncome - filedReturn.filedIncome,
        reason: 'Income as assessed by CPC differs from filed return.',
      ),
    ];
  }

  List<OrderDiscrepancy> _checkTdsMismatch(
    IntimationData intimation,
    ItrData filedReturn,
  ) {
    if (intimation.tdsCredited == filedReturn.tdsClaimed) return [];
    return [
      OrderDiscrepancy(
        section: 'TDS Credit (Form 26AS)',
        filedAmount: filedReturn.tdsClaimed,
        assessedAmount: intimation.tdsCredited,
        difference: intimation.tdsCredited - filedReturn.tdsClaimed,
        reason: 'TDS credited by CPC (from Form 26AS) differs from ITR claim.',
      ),
    ];
  }

  List<OrderDiscrepancy> _checkAdvanceTaxMismatch(
    IntimationData intimation,
    ItrData filedReturn,
  ) {
    if (intimation.advanceTaxCredited == filedReturn.advanceTaxClaimed) {
      return [];
    }
    return [
      OrderDiscrepancy(
        section: 'Advance Tax Credit',
        filedAmount: filedReturn.advanceTaxClaimed,
        assessedAmount: intimation.advanceTaxCredited,
        difference:
            intimation.advanceTaxCredited - filedReturn.advanceTaxClaimed,
        reason:
            'Advance tax credited by CPC differs from advance tax claimed in ITR.',
      ),
    ];
  }

  OrderDiscrepancy? _adjustmentToDiscrepancy(AdjustmentItem item) {
    switch (item.type) {
      case AdjustmentType.disallowanceSec14A:
        return OrderDiscrepancy(
          section: 'Section 14A Disallowance',
          filedAmount: 0,
          assessedAmount: item.amount,
          difference: item.amount,
          reason: item.description,
        );
      case AdjustmentType.incorrectDepreciation:
        return OrderDiscrepancy(
          section: 'Depreciation Adjustment',
          filedAmount: item.amount,
          assessedAmount: 0,
          difference: -item.amount,
          reason: item.description,
        );
      case AdjustmentType.arithmeticalError:
        return OrderDiscrepancy(
          section: 'Arithmetical Error',
          filedAmount: 0,
          assessedAmount: item.amount,
          difference: item.amount,
          reason: item.description,
        );
      case AdjustmentType.incorrectClaim:
        return OrderDiscrepancy(
          section: 'Incorrect Claim',
          filedAmount: 0,
          assessedAmount: item.amount,
          difference: item.amount,
          reason: item.description,
        );
    }
  }

  VerificationResult _resolveResult(
    List<OrderDiscrepancy> discrepancies,
    IntimationData intimation,
    ItrData filedReturn,
  ) {
    if (discrepancies.isEmpty) return VerificationResult.correct;

    // TDS mismatch always requires rectification u/s 154.
    final hasTdsMismatch = discrepancies.any(
      (d) => d.section.contains('TDS'),
    );
    if (hasTdsMismatch) return VerificationResult.needsRectification;

    return VerificationResult.discrepancy;
  }

  /// Returns the number of months (rounded up) between [from] and [to].
  /// Returns 0 if [to] is on or before [from].
  int _monthsDelayed(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;
    final wholeMonths =
        (to.year - from.year) * 12 + (to.month - from.month);
    final hasPartialMonth =
        to.day > from.day ||
        (to.day == from.day && to.isAfter(from));
    // If [to] lands exactly on from+wholeMonths, no extra month needed.
    final exactBoundary = DateTime(
      from.year + (from.month + wholeMonths - 1) ~/ 12,
      (from.month + wholeMonths - 1) % 12 + 1,
      from.day,
    );
    if (to.isAfter(exactBoundary)) return wholeMonths + 1;
    if (hasPartialMonth && wholeMonths == 0) return 1;
    return wholeMonths;
  }
}

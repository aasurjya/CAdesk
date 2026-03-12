import 'dart:math' as math;

import 'package:ca_app/features/gst/domain/models/gst_return.dart';

/// Immutable result of a GST late fee calculation.
class GstLateFeeResult {
  const GstLateFeeResult({
    required this.cgstLateFee,
    required this.sgstLateFee,
    required this.totalLateFee,
    required this.maxCapApplied,
    required this.daysLate,
  });

  /// Late fee under CGST Act.
  final double cgstLateFee;

  /// Late fee under SGST Act (mirrors CGST).
  final double sgstLateFee;

  /// Total late fee (CGST + SGST).
  final double totalLateFee;

  /// Whether the maximum cap was applied.
  final bool maxCapApplied;

  /// Number of days the return was filed late.
  final int daysLate;

  GstLateFeeResult copyWith({
    double? cgstLateFee,
    double? sgstLateFee,
    double? totalLateFee,
    bool? maxCapApplied,
    int? daysLate,
  }) {
    return GstLateFeeResult(
      cgstLateFee: cgstLateFee ?? this.cgstLateFee,
      sgstLateFee: sgstLateFee ?? this.sgstLateFee,
      totalLateFee: totalLateFee ?? this.totalLateFee,
      maxCapApplied: maxCapApplied ?? this.maxCapApplied,
      daysLate: daysLate ?? this.daysLate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstLateFeeResult &&
          runtimeType == other.runtimeType &&
          cgstLateFee == other.cgstLateFee &&
          sgstLateFee == other.sgstLateFee &&
          totalLateFee == other.totalLateFee &&
          maxCapApplied == other.maxCapApplied &&
          daysLate == other.daysLate;

  @override
  int get hashCode => Object.hash(
        cgstLateFee,
        sgstLateFee,
        totalLateFee,
        maxCapApplied,
        daysLate,
      );
}

/// Immutable result combining late fee and interest.
class GstPenaltyResult {
  const GstPenaltyResult({
    required this.lateFee,
    required this.interest,
    required this.totalPenalty,
  });

  /// Late fee breakdown.
  final GstLateFeeResult lateFee;

  /// Interest amount.
  final double interest;

  /// Total penalty (late fee + interest).
  final double totalPenalty;

  GstPenaltyResult copyWith({
    GstLateFeeResult? lateFee,
    double? interest,
    double? totalPenalty,
  }) {
    return GstPenaltyResult(
      lateFee: lateFee ?? this.lateFee,
      interest: interest ?? this.interest,
      totalPenalty: totalPenalty ?? this.totalPenalty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstPenaltyResult &&
          runtimeType == other.runtimeType &&
          lateFee == other.lateFee &&
          interest == other.interest &&
          totalPenalty == other.totalPenalty;

  @override
  int get hashCode => Object.hash(lateFee, interest, totalPenalty);
}

/// Static service for calculating GST late fees, interest, and total penalties.
///
/// Implements late fee rules per CGST Act Section 47 and interest under
/// Section 50.
class GstLateFeeService {
  GstLateFeeService._();

  /// Calculates late fee for a GST return filing.
  ///
  /// Late fee rules:
  /// - GSTR-1/3B: Rs 50/day (Rs 25 CGST + Rs 25 SGST), max Rs 10,000;
  ///   nil return: Rs 20/day (Rs 10 + Rs 10), max Rs 500
  /// - GSTR-9/9C: Rs 200/day (Rs 100 + Rs 100), max 0.25% of turnover
  /// - GSTR-2A/2B: No late fee (auto-drafted, not filed by taxpayer)
  static GstLateFeeResult calculateLateFee({
    required GstReturnType returnType,
    required int daysLate,
    required bool isNilReturn,
    double turnoverInState = 0,
  }) {
    if (daysLate <= 0) {
      return const GstLateFeeResult(
        cgstLateFee: 0,
        sgstLateFee: 0,
        totalLateFee: 0,
        maxCapApplied: false,
        daysLate: 0,
      );
    }

    switch (returnType) {
      case GstReturnType.gstr1:
      case GstReturnType.gstr3b:
        return _calculateGstr1And3bLateFee(daysLate, isNilReturn);
      case GstReturnType.gstr9:
      case GstReturnType.gstr9c:
        return _calculateGstr9LateFee(daysLate, turnoverInState);
      case GstReturnType.gstr2a:
      case GstReturnType.gstr2b:
        // Auto-drafted returns — no late fee applicable.
        return GstLateFeeResult(
          cgstLateFee: 0,
          sgstLateFee: 0,
          totalLateFee: 0,
          maxCapApplied: false,
          daysLate: daysLate,
        );
    }
  }

  /// GSTR-1 / GSTR-3B late fee calculation.
  static GstLateFeeResult _calculateGstr1And3bLateFee(
    int daysLate,
    bool isNilReturn,
  ) {
    final double perDayCgst;
    final double maxCap;

    if (isNilReturn) {
      // Nil return: Rs 10 CGST + Rs 10 SGST = Rs 20/day, max Rs 500
      perDayCgst = 10.0;
      maxCap = 500.0;
    } else {
      // Regular: Rs 25 CGST + Rs 25 SGST = Rs 50/day, max Rs 10,000
      perDayCgst = 25.0;
      maxCap = 10000.0;
    }

    final rawTotal = perDayCgst * 2 * daysLate;
    final capped = math.min(rawTotal, maxCap);
    final half = capped / 2;

    return GstLateFeeResult(
      cgstLateFee: half,
      sgstLateFee: half,
      totalLateFee: capped,
      maxCapApplied: rawTotal > maxCap,
      daysLate: daysLate,
    );
  }

  /// GSTR-9 / GSTR-9C late fee calculation.
  static GstLateFeeResult _calculateGstr9LateFee(
    int daysLate,
    double turnoverInState,
  ) {
    // Rs 100 CGST + Rs 100 SGST = Rs 200/day, max 0.25% of turnover
    const perDayCgst = 100.0;
    final rawTotal = perDayCgst * 2 * daysLate;
    final maxCap = turnoverInState * 0.0025; // 0.25%
    final capped = math.min(rawTotal, maxCap);
    final half = capped / 2;

    return GstLateFeeResult(
      cgstLateFee: half,
      sgstLateFee: half,
      totalLateFee: capped,
      maxCapApplied: rawTotal > maxCap,
      daysLate: daysLate,
    );
  }

  /// Calculates interest on delayed GST payment.
  ///
  /// Normal supplies: 18% p.a.
  /// RCM supplies: 24% p.a.
  /// Formula: taxDue * rate * daysLate / 365
  static double calculateInterest({
    required double taxDue,
    required int daysLate,
    bool isRcm = false,
  }) {
    if (daysLate <= 0 || taxDue <= 0) {
      return 0.0;
    }

    final rate = isRcm ? 0.24 : 0.18;
    return taxDue * rate * daysLate / 365;
  }

  /// Calculates total penalty combining late fee and interest.
  static GstPenaltyResult calculateTotalPenalty({
    required GstReturnType returnType,
    required int daysLate,
    required bool isNilReturn,
    required double taxDue,
    double turnoverInState = 0,
    bool isRcm = false,
  }) {
    final lateFee = calculateLateFee(
      returnType: returnType,
      daysLate: daysLate,
      isNilReturn: isNilReturn,
      turnoverInState: turnoverInState,
    );

    final interest = calculateInterest(
      taxDue: taxDue,
      daysLate: daysLate,
      isRcm: isRcm,
    );

    return GstPenaltyResult(
      lateFee: lateFee,
      interest: interest,
      totalPenalty: lateFee.totalLateFee + interest,
    );
  }
}

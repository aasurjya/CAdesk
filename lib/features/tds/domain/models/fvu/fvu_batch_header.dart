import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:flutter/foundation.dart';

/// Immutable model representing the Batch Header (BH) record in an FVU file.
///
/// Contains deductor identification, financial year, quarter, and totals.
@immutable
class FvuBatchHeader {
  const FvuBatchHeader({
    required this.tan,
    required this.pan,
    required this.deductorName,
    required this.financialYear,
    required this.quarter,
    required this.formType,
    required this.preparationDate,
    required this.totalChallans,
    required this.totalDeductees,
    required this.totalTaxDeducted,
  });

  /// TAN of the deductor (10 chars).
  final String tan;

  /// PAN of the deductor (10 chars).
  final String pan;

  /// Deductor name (up to 40 chars).
  final String deductorName;

  /// Financial year, e.g. "2025-26".
  final String financialYear;

  /// Quarter of the financial year.
  final TdsQuarter quarter;

  /// Form type (24Q, 26Q, 27Q, 27EQ).
  final TdsFormType formType;

  /// Return preparation date in DDMMYYYY format.
  final String preparationDate;

  /// Total number of challans in the batch.
  final int totalChallans;

  /// Total number of deductee records across all challans.
  final int totalDeductees;

  /// Grand total of TDS deducted across all deductees.
  final double totalTaxDeducted;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Returns the FVU form type code (2-char).
  String get formTypeCode {
    switch (formType) {
      case TdsFormType.form24Q:
        return '24';
      case TdsFormType.form26Q:
        return '26';
      case TdsFormType.form27Q:
        return '27';
      case TdsFormType.form27EQ:
        return '2E';
    }
  }

  /// Returns quarter as an integer (1–4).
  int get quarterNumber {
    switch (quarter) {
      case TdsQuarter.q1:
        return 1;
      case TdsQuarter.q2:
        return 2;
      case TdsQuarter.q3:
        return 3;
      case TdsQuarter.q4:
        return 4;
    }
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  FvuBatchHeader copyWith({
    String? tan,
    String? pan,
    String? deductorName,
    String? financialYear,
    TdsQuarter? quarter,
    TdsFormType? formType,
    String? preparationDate,
    int? totalChallans,
    int? totalDeductees,
    double? totalTaxDeducted,
  }) {
    return FvuBatchHeader(
      tan: tan ?? this.tan,
      pan: pan ?? this.pan,
      deductorName: deductorName ?? this.deductorName,
      financialYear: financialYear ?? this.financialYear,
      quarter: quarter ?? this.quarter,
      formType: formType ?? this.formType,
      preparationDate: preparationDate ?? this.preparationDate,
      totalChallans: totalChallans ?? this.totalChallans,
      totalDeductees: totalDeductees ?? this.totalDeductees,
      totalTaxDeducted: totalTaxDeducted ?? this.totalTaxDeducted,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FvuBatchHeader &&
          runtimeType == other.runtimeType &&
          tan == other.tan &&
          pan == other.pan &&
          deductorName == other.deductorName &&
          financialYear == other.financialYear &&
          quarter == other.quarter &&
          formType == other.formType &&
          preparationDate == other.preparationDate &&
          totalChallans == other.totalChallans &&
          totalDeductees == other.totalDeductees &&
          totalTaxDeducted == other.totalTaxDeducted;

  @override
  int get hashCode => Object.hash(
    tan,
    pan,
    deductorName,
    financialYear,
    quarter,
    formType,
    preparationDate,
    totalChallans,
    totalDeductees,
    totalTaxDeducted,
  );

  @override
  String toString() =>
      'FvuBatchHeader(tan: $tan, fy: $financialYear, '
      'quarter: Q$quarterNumber, form: $formTypeCode, '
      'challans: $totalChallans, deductees: $totalDeductees)';
}

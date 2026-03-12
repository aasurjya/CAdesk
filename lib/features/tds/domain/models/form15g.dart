import 'package:flutter/foundation.dart';

/// Immutable model representing a Form 15G declaration.
///
/// Form 15G is submitted by resident individuals (age < 60) whose income is
/// below the basic exemption limit, requesting nil TDS deduction under
/// Section 197A.
@immutable
class Form15G {
  const Form15G({
    required this.formNumber,
    required this.pan,
    required this.declarantName,
    required this.assessmentYear,
    required this.financialYear,
    required this.dateSubmitted,
    required this.estimatedTotalIncome,
    required this.estimatedIncomeFromSection,
    required this.aggregateDeclaredAmount,
    required this.deductorTan,
    required this.deductorName,
    required this.sectionCode,
  });

  /// Unique form number assigned by the deductor, e.g. "F15G/2025-26/001".
  final String formNumber;

  /// PAN of the declarant.
  final String pan;

  /// Name of the declarant.
  final String declarantName;

  /// Assessment year, e.g. "2026-27".
  final String assessmentYear;

  /// Financial year this declaration is valid for, e.g. "2025-26".
  final String financialYear;

  /// Date the form was submitted to the deductor.
  final DateTime dateSubmitted;

  /// Estimated total income for the financial year (from all sources).
  final double estimatedTotalIncome;

  /// Estimated income from the section for which the form is submitted.
  final double estimatedIncomeFromSection;

  /// Total aggregate amount declared across all Form 15G submissions for
  /// the financial year with the same deductor.
  final double aggregateDeclaredAmount;

  /// TAN of the deductor receiving the declaration.
  final String deductorTan;

  /// Name of the deductor.
  final String deductorName;

  /// TDS section code for which TDS deduction is being waived, e.g. "194A".
  final String sectionCode;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Basic exemption limit for non-senior-citizen individuals (FY 2025-26).
  static const double _basicExemptionLimit = 300000.0;

  /// Returns true when the declarant's conditions are valid for Form 15G:
  /// estimated total income must be at or below the basic exemption limit.
  bool get isValid => estimatedTotalIncome <= _basicExemptionLimit;

  /// Returns true if the declaration has expired at the given date.
  ///
  /// Form 15G is valid only for the financial year in which it was submitted.
  /// The FY ends on 31 March of the second year (e.g. FY 2025-26 ends
  /// on 31 March 2026).
  bool isExpiredAt(DateTime asOf) {
    final expiryDate = _financialYearEndDate();
    return asOf.isAfter(expiryDate);
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Form15G copyWith({
    String? formNumber,
    String? pan,
    String? declarantName,
    String? assessmentYear,
    String? financialYear,
    DateTime? dateSubmitted,
    double? estimatedTotalIncome,
    double? estimatedIncomeFromSection,
    double? aggregateDeclaredAmount,
    String? deductorTan,
    String? deductorName,
    String? sectionCode,
  }) {
    return Form15G(
      formNumber: formNumber ?? this.formNumber,
      pan: pan ?? this.pan,
      declarantName: declarantName ?? this.declarantName,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      financialYear: financialYear ?? this.financialYear,
      dateSubmitted: dateSubmitted ?? this.dateSubmitted,
      estimatedTotalIncome: estimatedTotalIncome ?? this.estimatedTotalIncome,
      estimatedIncomeFromSection:
          estimatedIncomeFromSection ?? this.estimatedIncomeFromSection,
      aggregateDeclaredAmount:
          aggregateDeclaredAmount ?? this.aggregateDeclaredAmount,
      deductorTan: deductorTan ?? this.deductorTan,
      deductorName: deductorName ?? this.deductorName,
      sectionCode: sectionCode ?? this.sectionCode,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form15G &&
          runtimeType == other.runtimeType &&
          formNumber == other.formNumber &&
          pan == other.pan &&
          declarantName == other.declarantName &&
          assessmentYear == other.assessmentYear &&
          financialYear == other.financialYear &&
          dateSubmitted == other.dateSubmitted &&
          estimatedTotalIncome == other.estimatedTotalIncome &&
          estimatedIncomeFromSection == other.estimatedIncomeFromSection &&
          aggregateDeclaredAmount == other.aggregateDeclaredAmount &&
          deductorTan == other.deductorTan &&
          deductorName == other.deductorName &&
          sectionCode == other.sectionCode;

  @override
  int get hashCode => Object.hash(
    formNumber,
    pan,
    declarantName,
    assessmentYear,
    financialYear,
    dateSubmitted,
    estimatedTotalIncome,
    estimatedIncomeFromSection,
    aggregateDeclaredAmount,
    deductorTan,
    deductorName,
    sectionCode,
  );

  @override
  String toString() =>
      'Form15G(formNumber: $formNumber, pan: $pan, fy: $financialYear, '
      'income: $estimatedTotalIncome)';

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  DateTime _financialYearEndDate() {
    final startYear = int.parse(financialYear.split('-').first);
    return DateTime(startYear + 1, 3, 31);
  }
}

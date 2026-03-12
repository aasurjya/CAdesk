import 'package:flutter/foundation.dart';

/// Immutable model representing a Form 15H declaration.
///
/// Form 15H is submitted by senior citizens (age ≥ 60) whose income is below
/// the basic exemption limit, requesting nil TDS deduction under Section 197A.
@immutable
class Form15H {
  const Form15H({
    required this.formNumber,
    required this.pan,
    required this.declarantName,
    required this.dateOfBirth,
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

  /// Unique form number assigned by the deductor, e.g. "F15H/2025-26/001".
  final String formNumber;

  /// PAN of the declarant.
  final String pan;

  /// Name of the declarant.
  final String declarantName;

  /// Date of birth of the declarant.
  final DateTime dateOfBirth;

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

  /// Total aggregate amount declared across all Form 15H submissions for
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

  /// Age of the declarant at the time of submission, in years.
  int get ageAtSubmission {
    final age = dateSubmitted.year - dateOfBirth.year;
    final birthdayPassedThisYear =
        dateSubmitted.month > dateOfBirth.month ||
        (dateSubmitted.month == dateOfBirth.month &&
            dateSubmitted.day >= dateOfBirth.day);
    return birthdayPassedThisYear ? age : age - 1;
  }

  /// Returns true when the declarant is a senior citizen (age ≥ 60).
  bool get isSeniorCitizen => ageAtSubmission >= 60;

  /// Returns true when conditions are valid for Form 15H:
  /// declarant must be a senior citizen.
  bool get isValid => isSeniorCitizen;

  /// Returns true if the declaration has expired at the given date.
  ///
  /// Form 15H is valid only for the financial year in which it was submitted.
  bool isExpiredAt(DateTime asOf) {
    final expiryDate = _financialYearEndDate();
    return asOf.isAfter(expiryDate);
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Form15H copyWith({
    String? formNumber,
    String? pan,
    String? declarantName,
    DateTime? dateOfBirth,
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
    return Form15H(
      formNumber: formNumber ?? this.formNumber,
      pan: pan ?? this.pan,
      declarantName: declarantName ?? this.declarantName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
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
      other is Form15H &&
          runtimeType == other.runtimeType &&
          formNumber == other.formNumber &&
          pan == other.pan &&
          declarantName == other.declarantName &&
          dateOfBirth == other.dateOfBirth &&
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
    dateOfBirth,
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
      'Form15H(formNumber: $formNumber, pan: $pan, fy: $financialYear, '
      'income: $estimatedTotalIncome, age: $ageAtSubmission)';

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  DateTime _financialYearEndDate() {
    final startYear = int.parse(financialYear.split('-').first);
    return DateTime(startYear + 1, 3, 31);
  }
}

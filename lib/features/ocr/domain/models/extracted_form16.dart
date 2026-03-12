import 'package:flutter/foundation.dart';

/// Immutable structured data extracted from a Form 16 document.
///
/// All monetary amounts are stored in **paise** (1 INR = 100 paise) to avoid
/// floating-point precision issues.
@immutable
class ExtractedForm16 {
  const ExtractedForm16({
    required this.employeePan,
    required this.employerTan,
    required this.employerName,
    required this.financialYear,
    required this.assessmentYear,
    required this.grossSalary,
    required this.taxableIncome,
    required this.tdsDeducted,
    required this.professionalTax,
    required this.standardDeduction,
    required this.confidence,
  });

  /// PAN of the employee (e.g. "ABCDE1234F").
  final String employeePan;

  /// TAN of the employer/deductor (e.g. "AAATA1234X").
  final String employerTan;

  /// Name of the employer organisation.
  final String employerName;

  /// Financial year, e.g. 2024 represents FY 2023-24.
  final int financialYear;

  /// Assessment year string, e.g. "2024-25".
  final String assessmentYear;

  /// Gross salary in paise.
  final int grossSalary;

  /// Net taxable income in paise after all deductions.
  final int taxableIncome;

  /// Total TDS deducted in paise.
  final int tdsDeducted;

  /// Professional tax paid in paise.
  final int professionalTax;

  /// Standard deduction (u/s 16(ia)) in paise.
  final int standardDeduction;

  /// Extraction confidence score in [0.0, 1.0].
  final double confidence;

  ExtractedForm16 copyWith({
    String? employeePan,
    String? employerTan,
    String? employerName,
    int? financialYear,
    String? assessmentYear,
    int? grossSalary,
    int? taxableIncome,
    int? tdsDeducted,
    int? professionalTax,
    int? standardDeduction,
    double? confidence,
  }) {
    return ExtractedForm16(
      employeePan: employeePan ?? this.employeePan,
      employerTan: employerTan ?? this.employerTan,
      employerName: employerName ?? this.employerName,
      financialYear: financialYear ?? this.financialYear,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      grossSalary: grossSalary ?? this.grossSalary,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      professionalTax: professionalTax ?? this.professionalTax,
      standardDeduction: standardDeduction ?? this.standardDeduction,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedForm16 &&
          runtimeType == other.runtimeType &&
          employeePan == other.employeePan &&
          employerTan == other.employerTan &&
          employerName == other.employerName &&
          financialYear == other.financialYear &&
          assessmentYear == other.assessmentYear &&
          grossSalary == other.grossSalary &&
          taxableIncome == other.taxableIncome &&
          tdsDeducted == other.tdsDeducted &&
          professionalTax == other.professionalTax &&
          standardDeduction == other.standardDeduction &&
          confidence == other.confidence;

  @override
  int get hashCode => Object.hash(
        employeePan,
        employerTan,
        employerName,
        financialYear,
        assessmentYear,
        grossSalary,
        taxableIncome,
        tdsDeducted,
        professionalTax,
        standardDeduction,
        confidence,
      );

  @override
  String toString() =>
      'ExtractedForm16(pan: $employeePan, tan: $employerTan, '
      'ay: $assessmentYear, gross: $grossSalary, tds: $tdsDeducted)';
}

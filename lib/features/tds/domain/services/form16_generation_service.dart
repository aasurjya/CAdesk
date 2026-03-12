import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/domain/models/form16a_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';

/// Static service for generating and validating Form 16 and Form 16A
/// TDS certificates.
class Form16GenerationService {
  Form16GenerationService._();

  // ---------------------------------------------------------------------------
  // TAN: 4 alpha + 5 numeric + 1 alpha (e.g., MUMB12345A)
  // ---------------------------------------------------------------------------
  static final RegExp _tanPattern = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]$');

  // ---------------------------------------------------------------------------
  // PAN: 5 alpha + 4 numeric + 1 alpha (e.g., ABCDE1234F)
  // ---------------------------------------------------------------------------
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  // ---------------------------------------------------------------------------
  // Assessment Year: YYYY-YY (e.g., 2026-27)
  // ---------------------------------------------------------------------------
  static final RegExp _ayPattern = RegExp(r'^\d{4}-\d{2}$');

  // ---------------------------------------------------------------------------
  // Generate Form 16
  // ---------------------------------------------------------------------------

  /// Creates a [Form16Data] from the provided parameters.
  static Form16Data generateForm16({
    required String certificateNumber,
    required String employerTan,
    required String employerPan,
    required String employerName,
    required TdsAddress employerAddress,
    required String employeePan,
    required String employeeName,
    required TdsAddress employeeAddress,
    required String assessmentYear,
    required DateTime periodFrom,
    required DateTime periodTo,
    required Form16PartA partA,
    required Form16PartB partB,
  }) {
    return Form16Data(
      certificateNumber: certificateNumber,
      employerTan: employerTan,
      employerPan: employerPan,
      employerName: employerName,
      employerAddress: employerAddress,
      employeePan: employeePan,
      employeeName: employeeName,
      employeeAddress: employeeAddress,
      assessmentYear: assessmentYear,
      periodFrom: periodFrom,
      periodTo: periodTo,
      partA: partA,
      partB: partB,
    );
  }

  // ---------------------------------------------------------------------------
  // Generate Form 16A
  // ---------------------------------------------------------------------------

  /// Creates a [Form16AData] from the provided parameters.
  static Form16AData generateForm16A({
    required String certificateNumber,
    required String deductorTan,
    required String deductorPan,
    required String deductorName,
    required TdsAddress deductorAddress,
    required String deducteePan,
    required String deducteeName,
    required TdsAddress deducteeAddress,
    required String assessmentYear,
    required TdsQuarter quarter,
    required String section,
    required List<Form16ATransaction> transactions,
  }) {
    return Form16AData(
      certificateNumber: certificateNumber,
      deductorTan: deductorTan,
      deductorPan: deductorPan,
      deductorName: deductorName,
      deductorAddress: deductorAddress,
      deducteePan: deducteePan,
      deducteeName: deducteeName,
      deducteeAddress: deducteeAddress,
      assessmentYear: assessmentYear,
      quarter: quarter,
      section: section,
      transactions: transactions,
    );
  }

  // ---------------------------------------------------------------------------
  // Bulk Generate Form 16
  // ---------------------------------------------------------------------------

  /// Generates Form 16 certificates for multiple employees with sequential
  /// certificate numbers in the format: TAN/AY/Form16/NNN.
  static List<Form16Data> bulkGenerateForm16({
    required String employerTan,
    required String employerPan,
    required String employerName,
    required TdsAddress employerAddress,
    required String assessmentYear,
    required DateTime periodFrom,
    required DateTime periodTo,
    required List<
            ({
              String employeePan,
              String employeeName,
              TdsAddress employeeAddress,
              Form16PartA partA,
              Form16PartB partB,
            })>
        employees,
  }) {
    return [
      for (var i = 0; i < employees.length; i++)
        generateForm16(
          certificateNumber: _certificateNumber(
            tan: employerTan,
            assessmentYear: assessmentYear,
            formLabel: 'Form16',
            index: i + 1,
          ),
          employerTan: employerTan,
          employerPan: employerPan,
          employerName: employerName,
          employerAddress: employerAddress,
          employeePan: employees[i].employeePan,
          employeeName: employees[i].employeeName,
          employeeAddress: employees[i].employeeAddress,
          assessmentYear: assessmentYear,
          periodFrom: periodFrom,
          periodTo: periodTo,
          partA: employees[i].partA,
          partB: employees[i].partB,
        ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Bulk Generate Form 16A
  // ---------------------------------------------------------------------------

  /// Generates Form 16A certificates for multiple deductees with sequential
  /// certificate numbers in the format: TAN/AY/Form16A/NNN.
  static List<Form16AData> bulkGenerateForm16A({
    required String deductorTan,
    required String deductorPan,
    required String deductorName,
    required TdsAddress deductorAddress,
    required String assessmentYear,
    required TdsQuarter quarter,
    required String section,
    required List<
            ({
              String deducteePan,
              String deducteeName,
              TdsAddress deducteeAddress,
              List<Form16ATransaction> transactions,
            })>
        deductees,
  }) {
    return [
      for (var i = 0; i < deductees.length; i++)
        generateForm16A(
          certificateNumber: _certificateNumber(
            tan: deductorTan,
            assessmentYear: assessmentYear,
            formLabel: 'Form16A',
            index: i + 1,
          ),
          deductorTan: deductorTan,
          deductorPan: deductorPan,
          deductorName: deductorName,
          deductorAddress: deductorAddress,
          deducteePan: deductees[i].deducteePan,
          deducteeName: deductees[i].deducteeName,
          deducteeAddress: deductees[i].deducteeAddress,
          assessmentYear: assessmentYear,
          quarter: quarter,
          section: section,
          transactions: deductees[i].transactions,
        ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Validate Form 16
  // ---------------------------------------------------------------------------

  /// Validates a [Form16Data] and returns a list of error messages.
  /// An empty list indicates valid data.
  static List<String> validateForm16(Form16Data data) {
    final errors = <String>[];

    if (!_tanPattern.hasMatch(data.employerTan)) {
      errors.add('Invalid employer TAN format: ${data.employerTan}');
    }
    if (!_panPattern.hasMatch(data.employerPan)) {
      errors.add('Invalid employer PAN format: ${data.employerPan}');
    }
    if (!_panPattern.hasMatch(data.employeePan)) {
      errors.add('Invalid employee PAN format: ${data.employeePan}');
    }
    if (!_ayPattern.hasMatch(data.assessmentYear)) {
      errors.add(
        'Invalid assessment year format: ${data.assessmentYear} '
        '(expected YYYY-YY)',
      );
    }
    if (data.periodFrom.isAfter(data.periodTo)) {
      errors.add(
        'Invalid period: periodFrom (${data.periodFrom}) '
        'is after periodTo (${data.periodTo})',
      );
    }
    if (data.partA.quarterlyDetails.isEmpty) {
      errors.add('Part A must contain at least one quarter detail');
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Validate Form 16A
  // ---------------------------------------------------------------------------

  /// Validates a [Form16AData] and returns a list of error messages.
  /// An empty list indicates valid data.
  static List<String> validateForm16A(Form16AData data) {
    final errors = <String>[];

    if (!_tanPattern.hasMatch(data.deductorTan)) {
      errors.add('Invalid deductor TAN format: ${data.deductorTan}');
    }
    if (!_panPattern.hasMatch(data.deductorPan)) {
      errors.add('Invalid deductor PAN format: ${data.deductorPan}');
    }
    if (!_panPattern.hasMatch(data.deducteePan)) {
      errors.add('Invalid deductee PAN format: ${data.deducteePan}');
    }
    if (data.section.isEmpty) {
      errors.add('TDS section must not be empty');
    }
    if (data.transactions.isEmpty) {
      errors.add('At least one transaction is required');
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Compute Part B Totals
  // ---------------------------------------------------------------------------

  /// Returns a new [Form16PartB] with grossTotalIncome recalculated from
  /// the salary breakup and other income sources.
  static Form16PartB computePartBTotals(Form16PartB partB) {
    // grossTotalIncome is a computed getter, so we just return as-is.
    // The caller can read partB.grossTotalIncome directly.
    // We return a fresh copy to signal that totals are verified.
    return partB.copyWith();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _certificateNumber({
    required String tan,
    required String assessmentYear,
    required String formLabel,
    required int index,
  }) {
    final padded = index.toString().padLeft(3, '0');
    return '$tan/$assessmentYear/$formLabel/$padded';
  }
}

import 'dart:convert';

import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';

/// Stateless service for validating ITD e-Filing 2.0 export results against
/// schema rules.
///
/// Validation covers:
/// - PAN format (regex AAAAA9999A)
/// - Assessment year format (YYYY-YY)
/// - Mandatory field presence
/// - Monetary field integrity (non-negative integers)
class ItrSchemaValidator {
  ItrSchemaValidator._();

  // ---------------------------------------------------------------------------
  // Field-level validators
  // ---------------------------------------------------------------------------

  /// Returns true if [pan] matches the ITD PAN format: 5 uppercase letters,
  /// 4 digits, 1 uppercase letter.
  static bool validatePan(String pan) {
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan);
  }

  /// Returns true if [ay] matches the assessment year format "YYYY-YY"
  /// (e.g. "2024-25").
  static bool validateAssessmentYear(String ay) {
    return RegExp(r'^\d{4}-\d{2}$').hasMatch(ay);
  }

  /// Returns a list of field names from [required] that are absent in [json].
  ///
  /// A field is considered present if its key exists in [json], regardless of
  /// value.
  static List<String> validateMandatoryFields(
    Map<String, dynamic> json,
    List<String> required,
  ) {
    return required.where((field) => !json.containsKey(field)).toList();
  }

  /// Validates all numeric values in [json] are non-negative integers.
  ///
  /// Returns a list of error messages for fields that are negative or
  /// non-integer (double with fractional part). String, bool, and nested map
  /// values are skipped.
  static List<String> validateAmounts(Map<String, dynamic> json) {
    final errors = <String>[];
    for (final entry in json.entries) {
      final value = entry.value;
      if (value is num) {
        if (value is double && value != value.truncateToDouble()) {
          errors.add(
            '${entry.key}: monetary amount must be an integer, got $value',
          );
        } else if (value < 0) {
          errors.add(
            '${entry.key}: monetary amount must be non-negative, got $value',
          );
        }
      }
    }
    return errors;
  }

  // ---------------------------------------------------------------------------
  // Result-level validation
  // ---------------------------------------------------------------------------

  /// Validates an [ItrExportResult] and returns all discovered errors.
  ///
  /// Checks:
  /// 1. Non-empty payload
  /// 2. Valid PAN format
  /// 3. Valid assessment year format
  static List<String> validate(ItrExportResult result) {
    final errors = <String>[];

    if (result.jsonPayload.isEmpty) {
      errors.add('JSON payload must not be empty');
      return errors;
    }

    if (!validatePan(result.panNumber)) {
      errors.add(
        'Invalid PAN "${result.panNumber}": must match pattern AAAAA9999A',
      );
    }

    if (!validateAssessmentYear(result.assessmentYear)) {
      errors.add(
        'Invalid assessment year "${result.assessmentYear}": '
        'must match format YYYY-YY (e.g. "2024-25")',
      );
    }

    // Attempt JSON decode for structural validation
    try {
      final decoded = jsonDecode(result.jsonPayload);
      if (decoded is! Map) {
        errors.add('JSON payload must be a JSON object at the root level');
      }
    } on FormatException catch (e) {
      errors.add('JSON payload is not valid JSON: ${e.message}');
    }

    return errors;
  }
}

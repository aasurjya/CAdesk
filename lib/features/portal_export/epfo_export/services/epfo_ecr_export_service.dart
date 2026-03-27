import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';
import 'package:ca_app/features/portal_export/epfo_export/models/ecr_export_result.dart';
import 'package:ca_app/features/portal_export/epfo_export/services/ecr_file_generator.dart';
import 'package:ca_app/features/portal_export/epfo_export/services/ecr_validator.dart';

/// Stateless service that generates EPFO ECR v2.0 (Electronic Challan cum
/// Return) pipe-delimited files from [PayrollRun] records.
///
/// Delegates file generation to [EcrFileGenerator] and validation to
/// [EcrValidator]. The service is the single entry point for ECR export in
/// the portal export layer.
///
/// Usage:
/// ```dart
/// final result = EpfoEcrExportService.generateEcr(
///   runs, '1234567', 3, 2024,
/// );
/// if (result.isValid) {
///   // Save result.fileContent as a .txt file for EPFO portal upload.
/// }
/// ```
class EpfoEcrExportService {
  EpfoEcrExportService._();

  // ---------------------------------------------------------------------------
  // Feature flag
  // ---------------------------------------------------------------------------

  /// Feature flag name for real ECR generation.
  /// When disabled, callers should use mock/stub responses.
  static const String featureFlag = 'epfo_ecr_export_enabled';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a complete ECR v2.0 file from [runs] for the given
  /// [establishmentId], [month] (1–12), and [year].
  ///
  /// Pre-validates inputs via [validate] and merges any pre-export errors
  /// with validation errors produced by [EcrFileGenerator].
  ///
  /// Returns an [EcrExportResult] whose [EcrExportResult.isValid] reflects
  /// whether the generated ECR file is structurally and logically valid.
  static EcrExportResult generateEcr(
    List<PayrollRun> runs,
    String establishmentId,
    int month,
    int year,
  ) {
    final preErrors = validate(runs, establishmentId, month, year);

    final result = EcrFileGenerator.instance.generate(
      runs,
      establishmentId,
      month,
      year,
    );

    if (preErrors.isNotEmpty) {
      final combined = [...preErrors, ...result.validationErrors];
      return result.copyWith(validationErrors: List.unmodifiable(combined));
    }

    return result;
  }

  /// Validates inputs before ECR generation.
  ///
  /// Returns a list of human-readable error strings. An empty list means all
  /// pre-generation checks passed.
  static List<String> validate(
    List<PayrollRun> runs,
    String establishmentId,
    int month,
    int year,
  ) {
    final errors = <String>[];

    if (!EcrValidator.instance.validateEstablishmentId(establishmentId)) {
      errors.add(
        'Establishment ID "$establishmentId" is invalid — '
        'must be exactly 7 numeric digits.',
      );
    }

    if (month < 1 || month > 12) {
      errors.add('Invalid wage month: $month. Must be between 1 and 12.');
    }

    if (year < 2012) {
      errors.add('Invalid wage year: $year. EPFO ECR was introduced in 2012.');
    }

    for (final run in runs) {
      if (!EcrValidator.instance.validateUan(run.uan)) {
        errors.add(
          'Employee "${run.employeeName}": UAN "${run.uan}" is invalid — '
          'must be exactly 12 digits.',
        );
      }
    }

    return List.unmodifiable(errors);
  }
}

import 'package:ca_app/features/portal_export/tds_export/models/fvu_export_result.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_file_generator.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_validator.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';

/// Stateless service for generating and validating FVU export packages for
/// NSDL TIN 2.0 / TRACES submission.
///
/// Delegates file generation to [FvuFileGenerator] and field-level checks to
/// [FvuValidator]. The service is the single entry point for FVU export in
/// the portal export layer.
///
/// Usage:
/// ```dart
/// final result = FvuExportService.generateFvu(structure, 'AAATA1234X');
/// if (result.isValid) {
///   // Save result.fvuFileContent as a .fvu file for TRACES upload.
/// }
/// ```
class FvuExportService {
  FvuExportService._();

  // ---------------------------------------------------------------------------
  // Feature flag
  // ---------------------------------------------------------------------------

  /// Feature flag name for real FVU generation.
  /// When disabled, callers should use mock/stub responses.
  static const String featureFlag = 'fvu_export_enabled';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a complete [FvuExportResult] from [structure] for [tanNumber].
  ///
  /// The TAN is validated and normalised to uppercase before use.
  /// Any validation errors in [FvuValidator] are surfaced in the result's
  /// [FvuExportResult.validationErrors] list.
  ///
  /// Returns an [FvuExportResult] whose [FvuExportResult.isValid] reflects
  /// whether the generated FVU content is structurally sound.
  static FvuExportResult generateFvu(
    FvuFileStructure structure,
    String tanNumber,
  ) {
    final preErrors = validate(structure, tanNumber);

    final result = FvuFileGenerator.generate(structure, tanNumber);

    if (preErrors.isNotEmpty) {
      // Merge pre-validation errors with any content-level errors from the
      // generator, preserving the original order.
      final combined = [...preErrors, ...result.validationErrors];
      return result.copyWith(validationErrors: List.unmodifiable(combined));
    }

    return result;
  }

  /// Validates [structure] and [tanNumber] before FVU generation.
  ///
  /// Returns a list of human-readable error strings. An empty list means all
  /// pre-generation checks passed.
  static List<String> validate(FvuFileStructure structure, String tanNumber) {
    final errors = <String>[];

    if (!FvuValidator.validateTan(tanNumber.trim().toUpperCase())) {
      errors.add(
        'Invalid TAN "$tanNumber": must be 4 uppercase letters + '
        '5 alphanumeric chars + 1 uppercase letter (10 chars total).',
      );
    }

    if (structure.challans.isEmpty) {
      errors.add('FVU structure must contain at least one challan record.');
    }

    for (var i = 0; i < structure.challans.length; i++) {
      final group = structure.challans[i];
      if (group.deductees.isEmpty) {
        errors.add(
          'Challan ${i + 1}: must contain at least one deductee record.',
        );
      }
      for (final dd in group.deductees) {
        if (!FvuValidator.validatePan(dd.pan)) {
          errors.add('Challan ${i + 1}: deductee PAN "${dd.pan}" is invalid.');
        }
      }
      if (!FvuValidator.validateChallanBsrCode(group.challan.bsrCode)) {
        errors.add(
          'Challan ${i + 1}: BSR code "${group.challan.bsrCode}" must be '
          'exactly 7 digits.',
        );
      }
    }

    return List.unmodifiable(errors);
  }
}

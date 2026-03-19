import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstn_schema_validator.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr3b_json_serializer.dart';

/// Stateless service that exports [Gstr3bFormData] to the GSTN API v3.0 JSON
/// format and wraps the result in a validated [GstrExportResult].
///
/// Delegates serialization to [Gstr3bJsonSerializer] and applies schema
/// validation via [GstnSchemaValidator]. The service acts as the single
/// entry point for GSTR-3B export in the portal export layer.
///
/// Usage:
/// ```dart
/// final result = Gstr3bExportService.export(formData);
/// if (result.isValid) {
///   // Submit result.jsonPayload to the GSTN portal.
/// }
/// ```
class Gstr3bExportService {
  Gstr3bExportService._();

  // ---------------------------------------------------------------------------
  // Feature flag
  // ---------------------------------------------------------------------------

  /// Feature flag name for real GSTR-3B export.
  /// When disabled, callers should use mock/stub responses.
  static const String featureFlag = 'gstr3b_export_enabled';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Exports [data] to GSTN API v3.0 JSON for the period derived from
  /// [data.periodMonth] and [data.periodYear].
  ///
  /// Returns a [GstrExportResult] with the JSON payload, section count, and
  /// any validation errors discovered during export.
  static GstrExportResult export(Gstr3bFormData data) {
    final period = _buildPeriod(data.periodMonth, data.periodYear);
    final errors = validate(data);
    final result = Gstr3bJsonSerializer.instance.serialize(
      data,
      data.gstin,
      period,
    );

    if (errors.isNotEmpty) {
      return result.copyWith(validationErrors: List.unmodifiable(errors));
    }

    // Run schema-level validation on the serialised output.
    final schemaErrors = GstnSchemaValidator.instance.validateGstr3b(result);
    if (schemaErrors.isNotEmpty) {
      return result.copyWith(validationErrors: List.unmodifiable(schemaErrors));
    }

    return result;
  }

  /// Validates inputs before serialization.
  ///
  /// Returns a list of human-readable error strings. Empty means valid.
  static List<String> validate(Gstr3bFormData data) {
    final errors = <String>[];

    if (!GstnSchemaValidator.instance.validateGstin(data.gstin)) {
      errors.add('Invalid GSTIN format: ${data.gstin}');
    }

    if (data.periodMonth < 1 || data.periodMonth > 12) {
      errors.add(
        'Invalid period month: ${data.periodMonth}. Must be between 1 and 12.',
      );
    }

    if (data.periodYear < 2017) {
      errors.add(
        'Invalid period year: ${data.periodYear}. '
        'GST was introduced in July 2017.',
      );
    }

    return List.unmodifiable(errors);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts month (1–12) and year to MMYYYY format, e.g. "032024".
  static String _buildPeriod(int month, int year) {
    final mm = month.toString().padLeft(2, '0');
    return '$mm$year';
  }
}

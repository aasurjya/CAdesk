import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstn_schema_validator.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr1_json_serializer.dart';

/// Stateless service that exports [Gstr1FormData] to the GSTN API v3.0 JSON
/// format and wraps the result in a validated [GstrExportResult].
///
/// Delegates serialization to [Gstr1JsonSerializer] and applies schema
/// validation via [GstnSchemaValidator]. The service acts as the single
/// entry point for GSTR-1 export in the portal export layer.
///
/// Usage:
/// ```dart
/// final result = Gstr1ExportService.export(formData, gstin, '032024');
/// if (result.isValid) {
///   // Submit result.jsonPayload to the GSTN portal.
/// }
/// ```
class Gstr1ExportService {
  Gstr1ExportService._();

  // ---------------------------------------------------------------------------
  // Feature flag
  // ---------------------------------------------------------------------------

  /// Feature flag name for real GSTR-1 export.
  /// When disabled, callers should use mock/stub responses.
  static const String featureFlag = 'gstr1_export_enabled';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Exports [data] for [gstin] and [period] (MMYYYY format).
  ///
  /// Returns a [GstrExportResult] with the JSON payload, section count,
  /// and any validation errors discovered during export.
  static GstrExportResult export(
    Gstr1FormData data,
    String gstin,
    String period,
  ) {
    final errors = validate(data, gstin, period);
    final result = Gstr1JsonSerializer.instance.serialize(data, gstin, period);

    if (errors.isNotEmpty) {
      return result.copyWith(validationErrors: List.unmodifiable(errors));
    }

    // Run schema-level validation on the serialized output.
    final schemaErrors = GstnSchemaValidator.instance.validateGstr1(result);

    if (schemaErrors.isNotEmpty) {
      return result.copyWith(validationErrors: List.unmodifiable(schemaErrors));
    }

    return result;
  }

  /// Validates inputs before serialization.
  ///
  /// Returns a list of human-readable error strings. Empty means valid.
  static List<String> validate(
    Gstr1FormData data,
    String gstin,
    String period,
  ) {
    final errors = <String>[];

    if (!GstnSchemaValidator.instance.validateGstin(gstin)) {
      errors.add('Invalid GSTIN format: $gstin');
    }

    if (!GstnSchemaValidator.instance.validatePeriod(period)) {
      errors.add('Invalid period format: $period. Expected MMYYYY.');
    }

    if (data.b2bInvoices.isEmpty &&
        data.b2cInvoices.isEmpty &&
        data.creditDebitNotes.isEmpty &&
        data.exports.isEmpty) {
      errors.add('GSTR-1 has no invoice data to export.');
    }

    return List.unmodifiable(errors);
  }

  /// Validates a GSTIN string using the GSTN schema rules.
  ///
  /// Convenience wrapper for [GstnSchemaValidator.validateGstin].
  static bool isValidGstin(String gstin) {
    return GstnSchemaValidator.instance.validateGstin(gstin);
  }

  /// Computes the HSN summary from B2B and B2C invoices.
  ///
  /// Returns a list of maps with HSN code, description, quantity,
  /// taxable value, and tax amounts. This is used for the HSN summary
  /// table in GSTR-1.
  static List<Map<String, Object?>> computeHsnSummary(Gstr1FormData data) {
    final hsnMap = <String, _HsnAccumulator>{};

    // Accumulate from B2B invoices (group by GST rate as proxy for HSN)
    for (final inv in data.b2bInvoices) {
      final key = 'RATE_${inv.gstRate.toStringAsFixed(0)}';
      final acc = hsnMap[key] ?? _HsnAccumulator(hsnCode: key);
      hsnMap[key] = acc.add(
        taxableValue: inv.taxableValue,
        igst: inv.igst,
        cgst: inv.cgst,
        sgst: inv.sgst,
        cess: inv.cess,
        quantity: 1,
      );
    }

    // Accumulate from B2C invoices (B2C has no HSN, group by rate)
    for (final inv in data.b2cInvoices) {
      final key = 'RATE_${inv.gstRate.toStringAsFixed(0)}';
      final acc = hsnMap[key] ?? _HsnAccumulator(hsnCode: key);
      hsnMap[key] = acc.add(
        taxableValue: inv.taxableValue,
        igst: inv.igst,
        cgst: inv.cgst,
        sgst: inv.sgst,
        cess: inv.cess,
        quantity: 1,
      );
    }

    return hsnMap.values.map((acc) => acc.toMap()).toList(growable: false);
  }
}

// ---------------------------------------------------------------------------
// Private helper: HSN accumulator (immutable)
// ---------------------------------------------------------------------------

/// Immutable accumulator for HSN-wise invoice totals.
class _HsnAccumulator {
  const _HsnAccumulator({
    required this.hsnCode,
    this.totalQuantity = 0,
    this.totalTaxableValue = 0.0,
    this.totalIgst = 0.0,
    this.totalCgst = 0.0,
    this.totalSgst = 0.0,
    this.totalCess = 0.0,
  });

  final String hsnCode;
  final int totalQuantity;
  final double totalTaxableValue;
  final double totalIgst;
  final double totalCgst;
  final double totalSgst;
  final double totalCess;

  _HsnAccumulator add({
    required double taxableValue,
    required double igst,
    required double cgst,
    required double sgst,
    required double cess,
    required int quantity,
  }) {
    return _HsnAccumulator(
      hsnCode: hsnCode,
      totalQuantity: totalQuantity + quantity,
      totalTaxableValue: totalTaxableValue + taxableValue,
      totalIgst: totalIgst + igst,
      totalCgst: totalCgst + cgst,
      totalSgst: totalSgst + sgst,
      totalCess: totalCess + cess,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'hsn_sc': hsnCode,
      'qty': totalQuantity,
      'txval': totalTaxableValue.toStringAsFixed(2),
      'iamt': totalIgst.toStringAsFixed(2),
      'camt': totalCgst.toStringAsFixed(2),
      'samt': totalSgst.toStringAsFixed(2),
      'csamt': totalCess.toStringAsFixed(2),
    };
  }
}

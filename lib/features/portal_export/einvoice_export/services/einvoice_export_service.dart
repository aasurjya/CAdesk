import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_export_result.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/einvoice_json_serializer.dart';
import 'package:ca_app/features/portal_export/einvoice_export/services/einvoice_validator.dart';

/// Stateless service that produces an NIC/IRP API v1.03 JSON payload from a
/// [GstInvoice] and wraps the result in an [EInvoiceExportResult].
///
/// Delegates serialization to [EInvoiceJsonSerializer] and validation to
/// [EInvoiceValidator]. The service is the single entry point for e-invoice
/// export in the portal export layer.
///
/// Usage:
/// ```dart
/// final result = EinvoiceExportService.export(
///   invoice, sellerGstin, buyerGstin,
/// );
/// if (result.isValid) {
///   // Submit result.requestPayload to the NIC IRP portal.
/// }
/// ```
class EinvoiceExportService {
  EinvoiceExportService._();

  // ---------------------------------------------------------------------------
  // Feature flag
  // ---------------------------------------------------------------------------

  /// Feature flag name for real e-invoice export.
  /// When disabled, callers should use mock/stub responses.
  static const String featureFlag = 'einvoice_export_enabled';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Exports [invoice] for [sellerGstin] and [buyerGstin] to the NIC IRP
  /// API v1.03 JSON format.
  ///
  /// Returns an [EInvoiceExportResult] containing the JSON payload and any
  /// pre-submission validation errors.
  static EInvoiceExportResult export(
    GstInvoice invoice,
    String sellerGstin,
    String buyerGstin,
  ) {
    final preErrors = validate(invoice, sellerGstin, buyerGstin);

    // Serializer runs its own validation; merge with pre-export errors.
    final result = EInvoiceJsonSerializer.serialize(
      invoice,
      sellerGstin,
      buyerGstin,
    );

    if (preErrors.isNotEmpty) {
      final combined = [...preErrors, ...result.validationErrors];
      return result.copyWith(validationErrors: List.unmodifiable(combined));
    }

    return result;
  }

  /// Validates inputs before serialization.
  ///
  /// Returns a list of human-readable error strings. An empty list means all
  /// pre-serialization checks passed.
  static List<String> validate(
    GstInvoice invoice,
    String sellerGstin,
    String buyerGstin,
  ) {
    final errors = <String>[];

    if (!EInvoiceValidator.validateGstin(sellerGstin)) {
      errors.add(
        'Seller GSTIN "$sellerGstin" is invalid — must be 15 characters.',
      );
    }

    if (!EInvoiceValidator.validateGstin(buyerGstin)) {
      errors.add(
        'Buyer GSTIN "$buyerGstin" is invalid — must be 15 characters.',
      );
    }

    if (!EInvoiceValidator.validateInvoiceNumber(invoice.invoiceNumber)) {
      errors.add(
        'Invalid invoice number "${invoice.invoiceNumber}": '
        'max 16 alphanumeric chars plus / and -.',
      );
    }

    if (invoice.items.isEmpty) {
      errors.add('Invoice must contain at least one line item.');
    }

    for (final item in invoice.items) {
      if (!EInvoiceValidator.validateHsn(item.hsnSacCode)) {
        errors.add(
          'Item "${item.description}": HSN/SAC code "${item.hsnSacCode}" '
          'must be 4, 6, or 8 digits.',
        );
      }
    }

    return List.unmodifiable(errors);
  }
}

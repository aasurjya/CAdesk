import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_response.dart';

/// Immutable result of an e-invoice JSON export operation.
///
/// Contains the serialised JSON payload, optional IRP portal response,
/// any validation errors found before submission, and the timestamp of export.
/// [response] is null until the payload has been submitted to the IRP portal.
class EInvoiceExportResult {
  const EInvoiceExportResult({
    required this.requestPayload,
    required this.validationErrors,
    required this.exportedAt,
    this.response,
  });

  /// JSON string ready for submission to the NIC/IRP API.
  final String requestPayload;

  /// IRP portal response — null if not yet submitted.
  final EInvoiceResponse? response;

  /// Validation errors found during serialisation.
  /// An empty list means the payload is valid and ready to submit.
  final List<String> validationErrors;

  /// UTC timestamp at which the export was generated.
  final DateTime exportedAt;

  /// Whether the payload passed all local validation checks.
  bool get isValid => validationErrors.isEmpty;

  /// Whether this result has been submitted and acknowledged by the IRP.
  bool get isSubmitted => response != null;

  EInvoiceExportResult copyWith({
    String? requestPayload,
    EInvoiceResponse? response,
    List<String>? validationErrors,
    DateTime? exportedAt,
  }) {
    return EInvoiceExportResult(
      requestPayload: requestPayload ?? this.requestPayload,
      response: response ?? this.response,
      validationErrors: validationErrors ?? this.validationErrors,
      exportedAt: exportedAt ?? this.exportedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceExportResult &&
          runtimeType == other.runtimeType &&
          requestPayload == other.requestPayload &&
          exportedAt == other.exportedAt;

  @override
  int get hashCode => Object.hash(requestPayload, exportedAt);
}

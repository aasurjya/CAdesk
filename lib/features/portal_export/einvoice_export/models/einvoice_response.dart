/// Immutable response from the NIC/IRP e-invoice portal after IRN registration.
///
/// The [status] field is "1" on success. [ewbNo] is null when no e-Way Bill
/// was generated alongside the invoice registration.
class EInvoiceResponse {
  const EInvoiceResponse({
    required this.irn,
    required this.ackNo,
    required this.ackDt,
    required this.signedInvoice,
    required this.signedQrCode,
    required this.status,
    this.ewbNo,
  });

  /// Invoice Reference Number — 64-character SHA-256 hex hash.
  final String irn;

  /// Acknowledgment number from the IRP portal.
  final String ackNo;

  /// Acknowledgment datetime string (as returned by IRP).
  final String ackDt;

  /// Signed invoice payload (JWT format).
  final String signedInvoice;

  /// Base64-encoded QR code data string.
  final String signedQrCode;

  /// Status code: "1" = success.
  final String status;

  /// e-Way Bill number, populated only when an e-Way Bill was generated.
  final String? ewbNo;

  /// Whether this response represents a successful registration.
  bool get isSuccess => status == '1';

  EInvoiceResponse copyWith({
    String? irn,
    String? ackNo,
    String? ackDt,
    String? signedInvoice,
    String? signedQrCode,
    String? status,
    String? ewbNo,
  }) {
    return EInvoiceResponse(
      irn: irn ?? this.irn,
      ackNo: ackNo ?? this.ackNo,
      ackDt: ackDt ?? this.ackDt,
      signedInvoice: signedInvoice ?? this.signedInvoice,
      signedQrCode: signedQrCode ?? this.signedQrCode,
      status: status ?? this.status,
      ewbNo: ewbNo ?? this.ewbNo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EInvoiceResponse &&
          runtimeType == other.runtimeType &&
          irn == other.irn &&
          ackNo == other.ackNo;

  @override
  int get hashCode => Object.hash(irn, ackNo);
}

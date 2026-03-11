/// Immutable model representing a single e-invoice record.
///
/// Tracks IRN generation status, compliance window, and days remaining
/// to submit on the IRP (Invoice Registration Portal).
class EinvoiceRecord {
  const EinvoiceRecord({
    required this.id,
    required this.clientName,
    required this.invoiceNumber,
    required this.buyerName,
    required this.invoiceValue,
    required this.gstAmount,
    required this.irn,
    required this.status,
    required this.windowType,
    required this.daysRemaining,
    required this.invoiceDate,
    required this.qrGenerated,
  });

  /// Unique record identifier.
  final String id;

  /// CA client (seller) name.
  final String clientName;

  /// Invoice number as printed on the document, e.g. INV-2025-0234.
  final String invoiceNumber;

  /// Buyer / recipient business name.
  final String buyerName;

  /// Invoice value in Indian Rupees (₹).
  final double invoiceValue;

  /// GST amount charged (₹).
  final double gstAmount;

  /// Invoice Registration Number — 64-char hash; placeholder shown truncated.
  final String irn;

  /// Lifecycle status: Generated | Cancelled | Pending | Overdue
  final String status;

  /// Compliance reporting window:
  ///   "30-day" for turnover ≥ ₹5 Cr, "3-day" for turnover ≥ ₹100 Cr.
  final String windowType;

  /// Days left to report on IRP.  Negative values indicate overdue.
  final int daysRemaining;

  /// Invoice date in human-readable form, e.g. "15 Feb 2025".
  final String invoiceDate;

  /// Whether QR code has been generated and embedded.
  final bool qrGenerated;

  /// Returns a copy with the given fields replaced.
  EinvoiceRecord copyWith({
    String? id,
    String? clientName,
    String? invoiceNumber,
    String? buyerName,
    double? invoiceValue,
    double? gstAmount,
    String? irn,
    String? status,
    String? windowType,
    int? daysRemaining,
    String? invoiceDate,
    bool? qrGenerated,
  }) {
    return EinvoiceRecord(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      buyerName: buyerName ?? this.buyerName,
      invoiceValue: invoiceValue ?? this.invoiceValue,
      gstAmount: gstAmount ?? this.gstAmount,
      irn: irn ?? this.irn,
      status: status ?? this.status,
      windowType: windowType ?? this.windowType,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      qrGenerated: qrGenerated ?? this.qrGenerated,
    );
  }
}

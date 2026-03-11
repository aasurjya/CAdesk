/// A payment record tracks an individual payment made against an invoice.
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.invoiceId,
    required this.clientName,
    required this.amount,
    required this.paymentDate,
    required this.mode,
    required this.reference,
    required this.notes,
  });

  final String id;
  final String invoiceId;
  final String clientName;
  final double amount;

  /// Human-readable date string, e.g. "15 Mar 2026".
  final String paymentDate;

  /// Payment mode: NEFT, RTGS, UPI, Cheque, Cash, etc.
  final String mode;

  /// UTR number, cheque number, or UPI transaction ID.
  final String reference;

  final String notes;

  PaymentRecord copyWith({
    String? id,
    String? invoiceId,
    String? clientName,
    double? amount,
    String? paymentDate,
    String? mode,
    String? reference,
    String? notes,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      mode: mode ?? this.mode,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

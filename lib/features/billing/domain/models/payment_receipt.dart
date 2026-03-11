/// Payment method used to settle an invoice.
enum PaymentMethod {
  cash('Cash'),
  bankTransfer('Bank Transfer'),
  upi('UPI'),
  cheque('Cheque'),
  card('Card');

  const PaymentMethod(this.label);
  final String label;
}

/// Immutable model for a payment receipt against an invoice.
class PaymentReceipt {
  const PaymentReceipt({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.remarks,
  });

  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;

  /// UTR / cheque number / UPI txn ID.
  final String? referenceNumber;
  final String? remarks;

  PaymentReceipt copyWith({
    String? id,
    String? invoiceId,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNumber,
    String? remarks,
  }) {
    return PaymentReceipt(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentReceipt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

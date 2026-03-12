/// Status of a payment link.
enum PaymentLinkStatus {
  active,
  paid,
  expired,
  cancelled,
}

/// Domain model representing a payment link sent to a client.
///
/// All monetary values are in **paise** (int), never double.
/// Immutable — use [copyWith] to derive updated copies.
/// Equality and [hashCode] are based solely on [linkId].
class PaymentLink {
  const PaymentLink({
    required this.linkId,
    required this.clientId,
    required this.invoiceId,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.paidAt,
    this.paymentReference,
    this.upiId,
    this.razorpayLinkId,
  });

  final String linkId;
  final String clientId;
  final String invoiceId;

  /// Amount in paise (1 INR = 100 paise).
  final int amount;
  final String description;
  final PaymentLinkStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? paidAt;
  final String? paymentReference;
  final String? upiId;
  final String? razorpayLinkId;

  PaymentLink copyWith({
    String? linkId,
    String? clientId,
    String? invoiceId,
    int? amount,
    String? description,
    PaymentLinkStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? paidAt,
    String? paymentReference,
    String? upiId,
    String? razorpayLinkId,
  }) {
    return PaymentLink(
      linkId: linkId ?? this.linkId,
      clientId: clientId ?? this.clientId,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      paidAt: paidAt ?? this.paidAt,
      paymentReference: paymentReference ?? this.paymentReference,
      upiId: upiId ?? this.upiId,
      razorpayLinkId: razorpayLinkId ?? this.razorpayLinkId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentLink && other.linkId == linkId;
  }

  @override
  int get hashCode => linkId.hashCode;
}

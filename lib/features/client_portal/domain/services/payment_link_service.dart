import 'dart:math';

import 'package:ca_app/features/client_portal/domain/models/payment_link.dart';

/// Domain service for payment link lifecycle: creation, UPI deep-link
/// generation, and payment recording.
///
/// All methods are pure and return new immutable values — no in-place mutation.
class PaymentLinkService {
  PaymentLinkService._();

  static final PaymentLinkService instance = PaymentLinkService._();

  /// Default validity window for a payment link.
  static const Duration _defaultValidity = Duration(days: 7);

  final Random _random = Random();

  // ---------------------------------------------------------------------------
  // Creation
  // ---------------------------------------------------------------------------

  /// Creates a new [PaymentLink] with [PaymentLinkStatus.active] status.
  ///
  /// [amountPaise] is the fee amount in paise (100 paise = ₹1).
  /// Expiry is set to [computeExpiryDate] from the creation timestamp.
  PaymentLink createPaymentLink(
    String clientId,
    String invoiceId,
    int amountPaise,
    String description,
  ) {
    final createdAt = DateTime.now();
    final expiresAt = computeExpiryDate(createdAt);
    return PaymentLink(
      linkId: _generateId('pay'),
      clientId: clientId,
      invoiceId: invoiceId,
      amount: amountPaise,
      description: description,
      status: PaymentLinkStatus.active,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  // ---------------------------------------------------------------------------
  // UPI deep link
  // ---------------------------------------------------------------------------

  /// Generates a UPI payment deep link for [link] using [upiId] as the
  /// payee VPA.
  ///
  /// Format: `upi://pay?pa={upiId}&pn={payeeName}&am={amount}&cu=INR&tn={desc}`
  ///
  /// Amount is converted from paise to rupees (e.g. 150000 paise → 1500.00).
  String generateUpiLink(PaymentLink link, String upiId) {
    final amountRupees = (link.amount / 100).toStringAsFixed(2);
    final encodedUpi = Uri.encodeQueryComponent(upiId);
    final encodedDesc = Uri.encodeQueryComponent(link.description);
    return 'upi://pay?pa=$encodedUpi&pn=CA+Firm&am=$amountRupees&cu=INR&tn=$encodedDesc';
  }

  // ---------------------------------------------------------------------------
  // Payment recording
  // ---------------------------------------------------------------------------

  /// Returns a copy of [link] with [PaymentLinkStatus.paid] status,
  /// [paidAt] set to [paidAt], and [paymentReference] set to [reference].
  PaymentLink markPaid(
    PaymentLink link,
    String reference,
    DateTime paidAt,
  ) {
    return link.copyWith(
      status: PaymentLinkStatus.paid,
      paymentReference: reference,
      paidAt: paidAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Expiry helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` if [now] is strictly after [link.expiresAt].
  bool isExpired(PaymentLink link, DateTime now) {
    return now.isAfter(link.expiresAt);
  }

  /// Computes the expiry date as [created] + [_defaultValidity] (7 days).
  DateTime computeExpiryDate(DateTime created) {
    return created.add(_defaultValidity);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _generateId(String prefix) {
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buffer.write(_random.nextInt(10));
    }
    return '$prefix-$buffer';
  }
}

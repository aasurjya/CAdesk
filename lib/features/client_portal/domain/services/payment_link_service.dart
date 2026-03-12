import 'dart:math';

import 'package:ca_app/features/client_portal/domain/models/payment_link.dart';

/// Stateless singleton service for payment link domain operations.
///
/// All money values are in **paise** (int). Methods are pure functions that
/// return new immutable objects.
class PaymentLinkService {
  PaymentLinkService._();

  static final PaymentLinkService instance = PaymentLinkService._();

  static final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Link creation
  // ---------------------------------------------------------------------------

  /// Creates a new [PaymentLink] with [PaymentLinkStatus.active] status.
  ///
  /// [amount] must be in paise. Expiry is set 7 days from creation.
  PaymentLink createPaymentLink(
    String clientId,
    String invoiceId,
    int amount,
    String description,
  ) {
    final createdAt = DateTime.now();
    final expiresAt = computeExpiryDate(createdAt);
    return PaymentLink(
      linkId: _generateId(),
      clientId: clientId,
      invoiceId: invoiceId,
      amount: amount,
      description: description,
      status: PaymentLinkStatus.active,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  /// Returns the expiry date for a link created at [createdAt] (7 days later).
  DateTime computeExpiryDate(DateTime createdAt) {
    return createdAt.add(const Duration(days: 7));
  }

  // ---------------------------------------------------------------------------
  // UPI deep link
  // ---------------------------------------------------------------------------

  /// Generates a `upi://pay?...` deep-link string for [link] payable to [upiId].
  ///
  /// Amount is converted from paise to rupees with 2 decimal places.
  /// All query parameters are URI-encoded.
  String generateUpiLink(PaymentLink link, String upiId) {
    final amountRupees = (link.amount / 100).toStringAsFixed(2);
    final params = {
      'pa': upiId,
      'pn': 'CA Portal',
      'am': amountRupees,
      'cu': 'INR',
      'tn': link.description,
    };
    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'upi://pay?$query';
  }

  // ---------------------------------------------------------------------------
  // Status transitions
  // ---------------------------------------------------------------------------

  /// Returns a copy of [link] marked as paid.
  PaymentLink markPaid(
    PaymentLink link,
    String paymentReference,
    DateTime paidAt,
  ) {
    return link.copyWith(
      status: PaymentLinkStatus.paid,
      paidAt: paidAt,
      paymentReference: paymentReference,
    );
  }

  /// Returns true if [link] has expired relative to [now].
  ///
  /// A link is expired when [now] is strictly after [link.expiresAt].
  bool isExpired(PaymentLink link, DateTime now) {
    return now.isAfter(link.expiresAt);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _generateId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

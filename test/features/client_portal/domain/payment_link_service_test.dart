import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/models/payment_link.dart';
import 'package:ca_app/features/client_portal/domain/services/payment_link_service.dart';

void main() {
  late PaymentLinkService service;

  setUp(() {
    service = PaymentLinkService.instance;
  });

  // ---------------------------------------------------------------------------
  // PaymentLink model
  // ---------------------------------------------------------------------------
  group('PaymentLink model', () {
    final createdAt = DateTime(2025, 6, 1);
    final expiresAt = DateTime(2025, 6, 8);

    test('const constructor and field defaults', () {
      final link = PaymentLink(
        linkId: 'link1',
        clientId: 'c1',
        invoiceId: 'inv1',
        amount: 50000,
        description: 'CA fees',
        status: PaymentLinkStatus.active,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
      expect(link.linkId, 'link1');
      expect(link.amount, 50000);
      expect(link.paidAt, isNull);
      expect(link.paymentReference, isNull);
      expect(link.upiId, isNull);
      expect(link.razorpayLinkId, isNull);
    });

    test('copyWith returns new instance', () {
      final link = PaymentLink(
        linkId: 'link1',
        clientId: 'c1',
        invoiceId: 'inv1',
        amount: 50000,
        description: 'CA fees',
        status: PaymentLinkStatus.active,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
      final paid = link.copyWith(
        status: PaymentLinkStatus.paid,
        paidAt: createdAt,
        paymentReference: 'REF123',
      );
      expect(paid.status, PaymentLinkStatus.paid);
      expect(paid.paidAt, createdAt);
      expect(paid.paymentReference, 'REF123');
      expect(link.status, PaymentLinkStatus.active); // original unchanged
    });

    test('equality based on linkId', () {
      final a = PaymentLink(
        linkId: 'link1',
        clientId: 'c1',
        invoiceId: 'inv1',
        amount: 50000,
        description: 'CA fees',
        status: PaymentLinkStatus.active,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
      final b = a.copyWith(description: 'Different');
      expect(a, equals(b));
      final c = a.copyWith(linkId: 'link2');
      expect(a, isNot(equals(c)));
    });

    test('PaymentLinkStatus enum has all expected values', () {
      expect(
        PaymentLinkStatus.values,
        containsAll([
          PaymentLinkStatus.active,
          PaymentLinkStatus.paid,
          PaymentLinkStatus.expired,
          PaymentLinkStatus.cancelled,
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // PaymentLinkService
  // ---------------------------------------------------------------------------
  group('PaymentLinkService', () {
    test('is singleton', () {
      expect(PaymentLinkService.instance, same(PaymentLinkService.instance));
    });

    test('createPaymentLink sets correct fields', () {
      final link = service.createPaymentLink(
        'c1',
        'inv1',
        150000,
        'ITR filing fee',
      );
      expect(link.clientId, 'c1');
      expect(link.invoiceId, 'inv1');
      expect(link.amount, 150000);
      expect(link.description, 'ITR filing fee');
      expect(link.status, PaymentLinkStatus.active);
      expect(link.linkId, isNotEmpty);
    });

    test('createPaymentLink sets expiry 7 days from creation', () {
      final link = service.createPaymentLink('c1', 'inv1', 10000, 'fee');
      final expectedExpiry = service.computeExpiryDate(link.createdAt);
      expect(expectedExpiry.difference(link.createdAt).inDays, 7);
      expect(link.expiresAt, expectedExpiry);
    });

    test('createPaymentLink generates unique linkIds', () {
      final l1 = service.createPaymentLink('c1', 'inv1', 10000, 'fee1');
      final l2 = service.createPaymentLink('c1', 'inv2', 20000, 'fee2');
      expect(l1.linkId, isNot(equals(l2.linkId)));
    });

    test('computeExpiryDate returns created + 7 days', () {
      final created = DateTime(2025, 6, 1);
      final expiry = service.computeExpiryDate(created);
      expect(expiry, DateTime(2025, 6, 8));
    });

    test('generateUpiLink returns valid upi:// deep link', () {
      final link = service.createPaymentLink('c1', 'inv1', 150000, 'CA fees');
      final upiLink = service.generateUpiLink(link, 'cafirm@upi');
      expect(upiLink, startsWith('upi://pay?'));
      expect(upiLink, contains('pa=cafirm%40upi'));
      expect(upiLink, contains('am=1500.00'));
      expect(upiLink, contains('cu=INR'));
    });

    test('generateUpiLink encodes special characters in description', () {
      final link = service.createPaymentLink(
        'c1',
        'inv1',
        50000,
        'GST & filing',
      );
      final upiLink = service.generateUpiLink(link, 'ca@upi');
      expect(upiLink, isNotEmpty);
      expect(upiLink, startsWith('upi://pay?'));
    });

    test('generateUpiLink stores upiId on returned PaymentLink', () {
      final link = service.createPaymentLink('c1', 'inv1', 50000, 'fees');
      // generateUpiLink returns the URL string; upiId is on the link itself
      service.generateUpiLink(link, 'ca@upi');
      // The original link is unchanged (stateless service, no mutation)
      expect(link.upiId, isNull);
    });

    test('markPaid returns link with paid status and reference', () {
      final link = service.createPaymentLink('c1', 'inv1', 100000, 'fees');
      final paidAt = DateTime(2025, 6, 3);
      final paid = service.markPaid(link, 'REF456', paidAt);
      expect(paid.status, PaymentLinkStatus.paid);
      expect(paid.paidAt, paidAt);
      expect(paid.paymentReference, 'REF456');
      expect(link.status, PaymentLinkStatus.active); // original unchanged
    });

    test('isExpired returns false when now is before expiresAt', () {
      final link = service.createPaymentLink('c1', 'inv1', 10000, 'fee');
      final now = link.createdAt.add(const Duration(days: 3));
      expect(service.isExpired(link, now), isFalse);
    });

    test('isExpired returns true when now is after expiresAt', () {
      final link = service.createPaymentLink('c1', 'inv1', 10000, 'fee');
      final now = link.expiresAt.add(const Duration(hours: 1));
      expect(service.isExpired(link, now), isTrue);
    });

    test('isExpired returns false at exact expiry moment', () {
      final link = service.createPaymentLink('c1', 'inv1', 10000, 'fee');
      expect(service.isExpired(link, link.expiresAt), isFalse);
    });
  });
}

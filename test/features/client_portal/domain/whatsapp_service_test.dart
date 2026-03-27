import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_client.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';
import 'package:ca_app/features/client_portal/domain/models/payment_link.dart';
import 'package:ca_app/features/client_portal/domain/models/whatsapp_message.dart';
import 'package:ca_app/features/client_portal/domain/services/whatsapp_service.dart';

void main() {
  late WhatsAppService service;

  const testClient = PortalClient(
    clientId: 'c1',
    pan: 'ABCDE1234F',
    name: 'Ravi Kumar',
    email: 'ravi@example.com',
    mobile: '919876543210',
    portalStatus: PortalStatus.active,
    caFirmId: 'firm1',
    totalDocuments: 3,
  );

  final testDoc = SharedDocument(
    documentId: 'd1',
    clientId: 'c1',
    caFirmId: 'firm1',
    title: 'ITR-V 2024',
    documentType: DocumentType.itrV,
    fileSize: 102400,
    mimeType: 'application/pdf',
    sharedAt: DateTime(2025, 6, 1),
    requiresESign: false,
    eSigned: false,
    status: DocumentStatus.shared,
  );

  final testLink = PaymentLink(
    linkId: 'link1',
    clientId: 'c1',
    invoiceId: 'inv1',
    amount: 150000,
    description: 'CA fees',
    status: PaymentLinkStatus.active,
    createdAt: DateTime(2025, 6, 1),
    expiresAt: DateTime(2025, 6, 8),
  );

  setUp(() {
    service = WhatsAppService.instance;
  });

  // ---------------------------------------------------------------------------
  // WhatsAppMessage model
  // ---------------------------------------------------------------------------
  group('WhatsAppMessage model', () {
    test('const constructor and field defaults', () {
      const msg = WhatsAppMessage(
        messageId: 'm1',
        to: '919876543210',
        messageType: MessageType.text,
        content: 'Hello',
        status: MessageStatus.queued,
        caFirmId: 'firm1',
      );
      expect(msg.messageId, 'm1');
      expect(msg.templateName, isNull);
      expect(msg.sentAt, isNull);
      expect(msg.deliveredAt, isNull);
      expect(msg.readAt, isNull);
    });

    test('copyWith returns new instance with updated fields', () {
      const msg = WhatsAppMessage(
        messageId: 'm1',
        to: '919876543210',
        messageType: MessageType.text,
        content: 'Hello',
        status: MessageStatus.queued,
        caFirmId: 'firm1',
      );
      final sent = msg.copyWith(
        status: MessageStatus.sent,
        sentAt: DateTime(2025, 6, 1, 10, 0),
      );
      expect(sent.status, MessageStatus.sent);
      expect(sent.sentAt, isNotNull);
      expect(msg.status, MessageStatus.queued); // original unchanged
    });

    test('equality based on messageId', () {
      const a = WhatsAppMessage(
        messageId: 'm1',
        to: '919876543210',
        messageType: MessageType.text,
        content: 'Hello',
        status: MessageStatus.queued,
        caFirmId: 'firm1',
      );
      final b = a.copyWith(content: 'World');
      expect(a, equals(b)); // same messageId
      final c = a.copyWith(messageId: 'm2');
      expect(a, isNot(equals(c)));
    });

    test('MessageType enum has all expected values', () {
      expect(
        MessageType.values,
        containsAll([
          MessageType.text,
          MessageType.template,
          MessageType.document,
          MessageType.image,
        ]),
      );
    });

    test('MessageStatus enum has all expected values', () {
      expect(
        MessageStatus.values,
        containsAll([
          MessageStatus.queued,
          MessageStatus.sent,
          MessageStatus.delivered,
          MessageStatus.read,
          MessageStatus.failed,
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // WhatsAppService
  // ---------------------------------------------------------------------------
  group('WhatsAppService', () {
    test('is singleton', () {
      expect(WhatsAppService.instance, same(WhatsAppService.instance));
    });

    test('sendTextMessage returns message with sent status', () {
      final msg = service.sendTextMessage(
        '919876543210',
        'Hello from CA',
        'firm1',
      );
      expect(msg.to, '919876543210');
      expect(msg.content, 'Hello from CA');
      expect(msg.caFirmId, 'firm1');
      expect(msg.status, MessageStatus.sent);
      expect(msg.messageType, MessageType.text);
      expect(msg.messageId, isNotEmpty);
      expect(msg.sentAt, isNotNull);
    });

    test('sendTextMessage generates unique messageIds', () {
      final m1 = service.sendTextMessage('91111', 'Hi', 'firm1');
      final m2 = service.sendTextMessage('91222', 'Hey', 'firm1');
      expect(m1.messageId, isNot(equals(m2.messageId)));
    });

    test('sendTemplateMessage returns template message with sent status', () {
      final msg = service
          .sendTemplateMessage('919876543210', 'document_shared', {
            'clientName': 'Ravi',
            'caName': 'Sharma & Co',
            'documentTitle': 'ITR-V',
            'portalLink': 'https://portal.example.com',
          }, 'firm1');
      expect(msg.templateName, 'document_shared');
      expect(msg.messageType, MessageType.template);
      expect(msg.status, MessageStatus.sent);
      expect(msg.to, '919876543210');
    });

    test('sendDocumentNotification sends to client mobile', () {
      final msg = service.sendDocumentNotification(testClient, testDoc);
      expect(msg.to, testClient.mobile);
      expect(msg.caFirmId, testClient.caFirmId);
      expect(msg.status, MessageStatus.sent);
      expect(msg.messageType, MessageType.template);
      expect(msg.content, contains('ITR-V 2024'));
    });

    test('sendDeadlineReminder mentions filing type and deadline', () {
      final msg = service.sendDeadlineReminder(
        testClient,
        '2025-07-31',
        'ITR Filing',
      );
      expect(msg.to, testClient.mobile);
      expect(msg.status, MessageStatus.sent);
      expect(msg.content, contains('ITR Filing'));
      expect(msg.content, contains('2025-07-31'));
    });

    test('sendPaymentReminder mentions amount', () {
      final msg = service.sendPaymentReminder(testClient, testLink);
      expect(msg.to, testClient.mobile);
      expect(msg.status, MessageStatus.sent);
      // amount 150000 paise = ₹1500
      expect(msg.content, contains('1500'));
    });
  });
}

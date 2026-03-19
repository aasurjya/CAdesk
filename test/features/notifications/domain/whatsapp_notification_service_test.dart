import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/notifications/domain/services/whatsapp_notification_service.dart';

void main() {
  group('MockWhatsAppNotificationService', () {
    // Opted-in numbers used in most tests.
    const optedInPhone = '919876543210';
    const nonOptedInPhone = '910000000000';

    // -------------------------------------------------------------------------
    // Default opted-in numbers
    // -------------------------------------------------------------------------

    group('with default opted-in numbers', () {
      late MockWhatsAppNotificationService service;

      setUp(() {
        service = MockWhatsAppNotificationService();
      });

      test(
        'isOptedIn returns true for a pre-configured opted-in number',
        () async {
          final result = await service.isOptedIn(optedInPhone);
          expect(result, isTrue);
        },
      );

      test(
        'isOptedIn returns false for a number not in the default set',
        () async {
          final result = await service.isOptedIn(nonOptedInPhone);
          expect(result, isFalse);
        },
      );
    });

    // -------------------------------------------------------------------------
    // sendTemplate — opted-in recipient
    // -------------------------------------------------------------------------

    group('sendTemplate to opted-in recipient', () {
      late MockWhatsAppNotificationService service;

      setUp(() {
        service = MockWhatsAppNotificationService(
          optedInNumbers: {optedInPhone},
        );
      });

      test('returns success result', () async {
        final result = await service.sendTemplate(
          optedInPhone,
          WhatsAppTemplate.deadlineReminder,
          {'clientName': 'Rahul', 'deadlineDate': '31 Jul 2025'},
        );

        expect(result.success, isTrue);
      });

      test('success result has a non-null messageId', () async {
        final result = await service.sendTemplate(
          optedInPhone,
          WhatsAppTemplate.deadlineReminder,
          {},
        );

        expect(result.messageId, isNotNull);
        expect(result.messageId, isNotEmpty);
      });

      test('success result has null errorCode and errorMessage', () async {
        final result = await service.sendTemplate(
          optedInPhone,
          WhatsAppTemplate.paymentDue,
          {'amount': '11800'},
        );

        expect(result.errorCode, isNull);
        expect(result.errorMessage, isNull);
      });

      test('messageId contains the template name', () async {
        final result = await service.sendTemplate(
          optedInPhone,
          WhatsAppTemplate.documentShared,
          {'docName': 'ITR Ack'},
        );

        expect(result.messageId, contains('documentShared'));
      });

      test('successive sends produce different messageIds', () async {
        final r1 = await service.sendTemplate(
          optedInPhone,
          WhatsAppTemplate.filingComplete,
          {},
        );
        final r2 = await service.sendTemplate(
          optedInPhone,
          WhatsAppTemplate.filingComplete,
          {},
        );

        expect(r1.messageId, isNot(equals(r2.messageId)));
      });

      test('WhatsAppSendResult.sent factory creates a success result', () {
        final result = WhatsAppSendResult.sent('msg-001');

        expect(result.success, isTrue);
        expect(result.messageId, equals('msg-001'));
        expect(result.errorCode, isNull);
        expect(result.errorMessage, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // sendTemplate — non opted-in recipient
    // -------------------------------------------------------------------------

    group('sendTemplate to non opted-in recipient', () {
      late MockWhatsAppNotificationService service;

      setUp(() {
        service = MockWhatsAppNotificationService(
          optedInNumbers: {optedInPhone},
        );
      });

      test('returns failure result', () async {
        final result = await service.sendTemplate(
          nonOptedInPhone,
          WhatsAppTemplate.deadlineReminder,
          {},
        );

        expect(result.success, isFalse);
      });

      test('failure result has errorCode "131047"', () async {
        final result = await service.sendTemplate(
          nonOptedInPhone,
          WhatsAppTemplate.paymentDue,
          {},
        );

        expect(result.errorCode, equals('131047'));
      });

      test('failure result has a non-null errorMessage', () async {
        final result = await service.sendTemplate(
          nonOptedInPhone,
          WhatsAppTemplate.documentShared,
          {},
        );

        expect(result.errorMessage, isNotNull);
        expect(result.errorMessage, isNotEmpty);
      });

      test('failure result has null messageId', () async {
        final result = await service.sendTemplate(
          nonOptedInPhone,
          WhatsAppTemplate.deadlineReminder,
          {},
        );

        expect(result.messageId, isNull);
      });

      test('WhatsAppSendResult.failed factory creates a failure result', () {
        final result = WhatsAppSendResult.failed(
          errorCode: '131047',
          errorMessage: 'Recipient not opted in',
        );

        expect(result.success, isFalse);
        expect(result.errorCode, equals('131047'));
        expect(result.errorMessage, equals('Recipient not opted in'));
        expect(result.messageId, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Custom opted-in numbers
    // -------------------------------------------------------------------------

    group('custom optedInNumbers', () {
      test('only custom numbers are opted in', () async {
        const customPhone = '911234567890';
        final service = MockWhatsAppNotificationService(
          optedInNumbers: {customPhone},
        );

        // Default numbers should NOT be opted in when custom set provided.
        final defaultOptedIn = await service.isOptedIn(optedInPhone);
        final customOptedIn = await service.isOptedIn(customPhone);

        expect(defaultOptedIn, isFalse);
        expect(customOptedIn, isTrue);
      });

      test('send succeeds for custom opted-in number', () async {
        const customPhone = '911111111111';
        final service = MockWhatsAppNotificationService(
          optedInNumbers: {customPhone},
        );

        final result = await service.sendTemplate(
          customPhone,
          WhatsAppTemplate.queryResponse,
          {'response': 'Your query has been resolved.'},
        );

        expect(result.success, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // All template types
    // -------------------------------------------------------------------------

    group('all WhatsAppTemplate values are sendable', () {
      late MockWhatsAppNotificationService service;

      setUp(() {
        service = MockWhatsAppNotificationService(
          optedInNumbers: {optedInPhone},
        );
      });

      for (final template in WhatsAppTemplate.values) {
        test('can send ${template.name} template', () async {
          final result = await service.sendTemplate(optedInPhone, template, {});
          expect(result.success, isTrue);
        });
      }
    });

    // -------------------------------------------------------------------------
    // WhatsAppTemplate enum
    // -------------------------------------------------------------------------

    group('WhatsAppTemplate enum', () {
      test('has deadlineReminder', () {
        expect(
          WhatsAppTemplate.values,
          contains(WhatsAppTemplate.deadlineReminder),
        );
      });

      test('has documentShared', () {
        expect(
          WhatsAppTemplate.values,
          contains(WhatsAppTemplate.documentShared),
        );
      });

      test('has paymentDue', () {
        expect(WhatsAppTemplate.values, contains(WhatsAppTemplate.paymentDue));
      });

      test('has filingComplete', () {
        expect(
          WhatsAppTemplate.values,
          contains(WhatsAppTemplate.filingComplete),
        );
      });

      test('has queryResponse', () {
        expect(
          WhatsAppTemplate.values,
          contains(WhatsAppTemplate.queryResponse),
        );
      });
    });

    // -------------------------------------------------------------------------
    // WhatsAppSendResult model
    // -------------------------------------------------------------------------

    group('WhatsAppSendResult', () {
      test('equality based on success, messageId, and errorCode', () {
        const a = WhatsAppSendResult(success: true, messageId: 'msg-001');
        const b = WhatsAppSendResult(
          success: true,
          messageId: 'msg-001',
          errorMessage: 'ignored',
        );
        expect(a, equals(b));
      });

      test('two results with different messageIds are not equal', () {
        const a = WhatsAppSendResult(success: true, messageId: 'msg-001');
        const b = WhatsAppSendResult(success: true, messageId: 'msg-002');
        expect(a, isNot(equals(b)));
      });

      test('toString for success mentions messageId', () {
        const r = WhatsAppSendResult(success: true, messageId: 'msg-abc');
        expect(r.toString(), contains('msg-abc'));
      });

      test('toString for failure mentions errorCode and errorMessage', () {
        const r = WhatsAppSendResult(
          success: false,
          errorCode: '131047',
          errorMessage: 'Not opted in',
        );
        expect(r.toString(), contains('131047'));
        expect(r.toString(), contains('Not opted in'));
      });
    });
  });
}

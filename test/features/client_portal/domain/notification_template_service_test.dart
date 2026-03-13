import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/client_portal/domain/models/notification_template.dart';
import 'package:ca_app/features/client_portal/domain/services/notification_template_service.dart';

void main() {
  late NotificationTemplateService service;

  setUp(() {
    service = NotificationTemplateService.instance;
  });

  // ---------------------------------------------------------------------------
  // NotificationTemplate model
  // ---------------------------------------------------------------------------
  group('NotificationTemplate model', () {
    test('const constructor and field access', () {
      const template = NotificationTemplate(
        templateId: 't1',
        name: 'document_shared',
        channel: NotificationChannel.whatsapp,
        templateText: 'Dear {clientName}, {caName} has shared {documentTitle}.',
        placeholders: ['clientName', 'caName', 'documentTitle'],
        useCase: NotificationUseCase.documentShared,
      );
      expect(template.templateId, 't1');
      expect(template.channel, NotificationChannel.whatsapp);
      expect(template.useCase, NotificationUseCase.documentShared);
      expect(template.placeholders, hasLength(3));
    });

    test('copyWith returns new instance', () {
      const template = NotificationTemplate(
        templateId: 't1',
        name: 'doc_shared',
        channel: NotificationChannel.whatsapp,
        templateText: 'Hello {clientName}',
        placeholders: ['clientName'],
        useCase: NotificationUseCase.documentShared,
      );
      final updated = template.copyWith(name: 'doc_shared_v2');
      expect(updated.name, 'doc_shared_v2');
      expect(template.name, 'doc_shared'); // original unchanged
    });

    test('equality based on all fields', () {
      const a = NotificationTemplate(
        templateId: 't1',
        name: 'doc_shared',
        channel: NotificationChannel.whatsapp,
        templateText: 'Hello {clientName}',
        placeholders: ['clientName'],
        useCase: NotificationUseCase.documentShared,
      );
      const b = NotificationTemplate(
        templateId: 't1',
        name: 'doc_shared',
        channel: NotificationChannel.whatsapp,
        templateText: 'Hello {clientName}',
        placeholders: ['clientName'],
        useCase: NotificationUseCase.documentShared,
      );
      expect(a, equals(b));
    });

    test('NotificationChannel enum has all expected values', () {
      expect(
        NotificationChannel.values,
        containsAll([
          NotificationChannel.whatsapp,
          NotificationChannel.email,
          NotificationChannel.sms,
          NotificationChannel.push,
        ]),
      );
    });

    test('NotificationUseCase enum has all expected values', () {
      expect(
        NotificationUseCase.values,
        containsAll([
          NotificationUseCase.documentShared,
          NotificationUseCase.deadlineReminder,
          NotificationUseCase.paymentDue,
          NotificationUseCase.filingComplete,
          NotificationUseCase.otp,
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // NotificationTemplateService
  // ---------------------------------------------------------------------------
  group('NotificationTemplateService', () {
    test('is singleton', () {
      expect(
        NotificationTemplateService.instance,
        same(NotificationTemplateService.instance),
      );
    });

    test('getTemplate returns documentShared WhatsApp template', () {
      final template = service.getTemplate(
        NotificationUseCase.documentShared,
        NotificationChannel.whatsapp,
      );
      expect(template.useCase, NotificationUseCase.documentShared);
      expect(template.channel, NotificationChannel.whatsapp);
      expect(template.templateText, contains('{clientName}'));
      expect(template.templateText, contains('{documentTitle}'));
      expect(template.templateText, contains('{portalLink}'));
      expect(template.placeholders, contains('clientName'));
    });

    test('getTemplate returns deadlineReminder WhatsApp template', () {
      final template = service.getTemplate(
        NotificationUseCase.deadlineReminder,
        NotificationChannel.whatsapp,
      );
      expect(template.useCase, NotificationUseCase.deadlineReminder);
      expect(template.templateText, contains('{filingType}'));
      expect(template.templateText, contains('{deadline}'));
    });

    test('getTemplate returns paymentDue WhatsApp template', () {
      final template = service.getTemplate(
        NotificationUseCase.paymentDue,
        NotificationChannel.whatsapp,
      );
      expect(template.useCase, NotificationUseCase.paymentDue);
      expect(template.templateText, contains('{amount}'));
      expect(template.templateText, contains('{paymentLink}'));
    });

    test('getTemplate returns filingComplete WhatsApp template', () {
      final template = service.getTemplate(
        NotificationUseCase.filingComplete,
        NotificationChannel.whatsapp,
      );
      expect(template.useCase, NotificationUseCase.filingComplete);
      expect(template.templateText, contains('{filingType}'));
      expect(template.templateText, contains('{arn}'));
    });

    test('getTemplate throws when template not found', () {
      expect(
        () => service.getTemplate(
          NotificationUseCase.otp,
          NotificationChannel.email,
        ),
        throwsArgumentError,
      );
    });

    test('fillTemplate replaces all placeholders', () {
      final template = service.getTemplate(
        NotificationUseCase.documentShared,
        NotificationChannel.whatsapp,
      );
      final filled = service.fillTemplate(template, {
        'clientName': 'Ravi Kumar',
        'caName': 'Sharma & Co',
        'documentTitle': 'ITR-V 2024',
        'portalLink': 'https://portal.caapp.in',
      });
      expect(filled, contains('Ravi Kumar'));
      expect(filled, contains('Sharma & Co'));
      expect(filled, contains('ITR-V 2024'));
      expect(filled, contains('https://portal.caapp.in'));
      expect(filled, isNot(contains('{')));
      expect(filled, isNot(contains('}')));
    });

    test(
      'fillTemplate with partial variables leaves unreplaced placeholders',
      () {
        const template = NotificationTemplate(
          templateId: 'x',
          name: 'test',
          channel: NotificationChannel.whatsapp,
          templateText: 'Hello {clientName}, your {thing} is ready.',
          placeholders: ['clientName', 'thing'],
          useCase: NotificationUseCase.documentShared,
        );
        final filled = service.fillTemplate(template, {'clientName': 'Ravi'});
        expect(filled, contains('Ravi'));
        expect(filled, contains('{thing}')); // unreplaced stays
      },
    );

    test('fillTemplate with deadlineReminder replaces variables correctly', () {
      final template = service.getTemplate(
        NotificationUseCase.deadlineReminder,
        NotificationChannel.whatsapp,
      );
      final filled = service.fillTemplate(template, {
        'filingType': 'ITR Filing',
        'deadline': '2025-07-31',
        'requiredDocuments': 'Form 16, Bank Statement',
      });
      expect(filled, contains('ITR Filing'));
      expect(filled, contains('2025-07-31'));
    });

    test('fillTemplate with paymentDue replaces variables correctly', () {
      final template = service.getTemplate(
        NotificationUseCase.paymentDue,
        NotificationChannel.whatsapp,
      );
      final filled = service.fillTemplate(template, {
        'amount': '5000',
        'dueDate': '2025-06-30',
        'paymentLink': 'upi://pay?pa=ca@upi',
      });
      expect(filled, contains('5000'));
      expect(filled, contains('2025-06-30'));
    });
  });
}

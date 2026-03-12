import 'package:ca_app/features/client_portal/domain/models/notification_template.dart';

/// Stateless singleton service for notification template operations.
///
/// Provides a registry of built-in templates and a utility to fill
/// placeholder tokens.
class NotificationTemplateService {
  NotificationTemplateService._();

  static final NotificationTemplateService instance =
      NotificationTemplateService._();

  // ---------------------------------------------------------------------------
  // Built-in template registry
  // ---------------------------------------------------------------------------

  static const List<NotificationTemplate> _templates = [
    // documentShared — whatsapp
    NotificationTemplate(
      templateId: 'tpl_doc_shared_wa',
      name: 'document_shared',
      channel: NotificationChannel.whatsapp,
      templateText:
          'Dear {clientName}, {caName} has shared a document: {documentTitle}. '
          'Please log in to your portal to view it: {portalLink}',
      placeholders: ['clientName', 'caName', 'documentTitle', 'portalLink'],
      useCase: NotificationUseCase.documentShared,
    ),

    // deadlineReminder — whatsapp
    NotificationTemplate(
      templateId: 'tpl_deadline_wa',
      name: 'deadline_reminder',
      channel: NotificationChannel.whatsapp,
      templateText:
          'Reminder: Your {filingType} is due on {deadline}. '
          'Please provide the following documents: {requiredDocuments}.',
      placeholders: ['filingType', 'deadline', 'requiredDocuments'],
      useCase: NotificationUseCase.deadlineReminder,
    ),

    // paymentDue — whatsapp
    NotificationTemplate(
      templateId: 'tpl_payment_due_wa',
      name: 'payment_due',
      channel: NotificationChannel.whatsapp,
      templateText:
          'Your payment of ₹{amount} is due on {dueDate}. '
          'Pay now: {paymentLink}',
      placeholders: ['amount', 'dueDate', 'paymentLink'],
      useCase: NotificationUseCase.paymentDue,
    ),

    // filingComplete — whatsapp
    NotificationTemplate(
      templateId: 'tpl_filing_complete_wa',
      name: 'filing_complete',
      channel: NotificationChannel.whatsapp,
      templateText:
          'Your {filingType} has been successfully filed. '
          'Acknowledgement number (ARN): {arn}.',
      placeholders: ['filingType', 'arn'],
      useCase: NotificationUseCase.filingComplete,
    ),

    // otp — whatsapp
    NotificationTemplate(
      templateId: 'tpl_otp_wa',
      name: 'otp',
      channel: NotificationChannel.whatsapp,
      templateText: 'Your OTP is {otp}. Valid for 5 minutes. Do not share it.',
      placeholders: ['otp'],
      useCase: NotificationUseCase.otp,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the template matching [useCase] and [channel].
  ///
  /// Throws [ArgumentError] if no template is registered for the combination.
  NotificationTemplate getTemplate(
    NotificationUseCase useCase,
    NotificationChannel channel,
  ) {
    for (final t in _templates) {
      if (t.useCase == useCase && t.channel == channel) return t;
    }
    throw ArgumentError(
      'No template found for useCase=$useCase, channel=$channel.',
    );
  }

  /// Returns [template.templateText] with all `{key}` tokens replaced by the
  /// corresponding values in [variables].
  ///
  /// Tokens whose key is absent in [variables] are left unchanged.
  String fillTemplate(
    NotificationTemplate template,
    Map<String, String> variables,
  ) {
    var text = template.templateText;
    for (final entry in variables.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }
}

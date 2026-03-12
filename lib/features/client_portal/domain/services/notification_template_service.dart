import 'package:ca_app/features/client_portal/domain/models/notification_template.dart';

/// Domain service for resolving and filling notification templates.
///
/// Built-in WhatsApp templates are registered at construction time.
/// Additional channels (email, SMS, push) can be registered at runtime.
class NotificationTemplateService {
  NotificationTemplateService._() {
    _registerBuiltIns();
  }

  static final NotificationTemplateService instance =
      NotificationTemplateService._();

  /// Keyed by (useCase, channel) pair.
  final Map<_TemplateKey, NotificationTemplate> _templates = {};

  // ---------------------------------------------------------------------------
  // Lookup
  // ---------------------------------------------------------------------------

  /// Returns the [NotificationTemplate] for the given [useCase] and [channel].
  ///
  /// Throws [ArgumentError] if no template is registered for that combination.
  NotificationTemplate getTemplate(
    NotificationUseCase useCase,
    NotificationChannel channel,
  ) {
    final key = _TemplateKey(useCase, channel);
    final template = _templates[key];
    if (template == null) {
      throw ArgumentError(
        'No template registered for useCase=$useCase channel=$channel.',
        'useCase',
      );
    }
    return template;
  }

  // ---------------------------------------------------------------------------
  // Filling
  // ---------------------------------------------------------------------------

  /// Returns [template.templateText] with all `{key}` placeholders replaced
  /// by their corresponding value in [variables].
  ///
  /// Placeholders with no matching key are left as-is.
  String fillTemplate(
    NotificationTemplate template,
    Map<String, String> variables,
  ) {
    var result = template.templateText;
    for (final entry in variables.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Built-in registration
  // ---------------------------------------------------------------------------

  void _registerBuiltIns() {
    _register(
      const NotificationTemplate(
        templateId: 'wa-doc-shared',
        name: 'document_shared',
        channel: NotificationChannel.whatsapp,
        templateText:
            'Dear {clientName}, {caName} has shared {documentTitle} for your review. Login: {portalLink}',
        placeholders: ['clientName', 'caName', 'documentTitle', 'portalLink'],
        useCase: NotificationUseCase.documentShared,
      ),
    );

    _register(
      const NotificationTemplate(
        templateId: 'wa-deadline-reminder',
        name: 'deadline_reminder',
        channel: NotificationChannel.whatsapp,
        templateText:
            'Reminder: {filingType} deadline is {deadline}. Please share {requiredDocuments}.',
        placeholders: ['filingType', 'deadline', 'requiredDocuments'],
        useCase: NotificationUseCase.deadlineReminder,
      ),
    );

    _register(
      const NotificationTemplate(
        templateId: 'wa-payment-due',
        name: 'payment_due',
        channel: NotificationChannel.whatsapp,
        templateText:
            'Invoice ₹{amount} is due by {dueDate}. Pay here: {paymentLink}',
        placeholders: ['amount', 'dueDate', 'paymentLink'],
        useCase: NotificationUseCase.paymentDue,
      ),
    );

    _register(
      const NotificationTemplate(
        templateId: 'wa-filing-complete',
        name: 'filing_complete',
        channel: NotificationChannel.whatsapp,
        templateText:
            'Your {filingType} for {period} has been filed successfully. ARN: {arn}',
        placeholders: ['filingType', 'period', 'arn'],
        useCase: NotificationUseCase.filingComplete,
      ),
    );
  }

  void _register(NotificationTemplate template) {
    final key = _TemplateKey(template.useCase, template.channel);
    _templates[key] = template;
  }
}

/// Composite key for the template registry.
class _TemplateKey {
  const _TemplateKey(this.useCase, this.channel);

  final NotificationUseCase useCase;
  final NotificationChannel channel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TemplateKey &&
        other.useCase == useCase &&
        other.channel == channel;
  }

  @override
  int get hashCode => Object.hash(useCase, channel);
}

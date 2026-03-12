/// Delivery channel for a notification template.
///
/// Note: this is distinct from [portal_notification.dart]'s `NotificationChannel`
/// which is used for client portal UI notifications. This enum covers
/// outbound communication channels including push notifications.
enum NotificationChannel {
  whatsapp('WhatsApp'),
  email('Email'),
  sms('SMS'),
  push('Push');

  const NotificationChannel(this.label);

  final String label;
}

/// Business use-case that a notification template covers.
enum NotificationUseCase {
  documentShared('Document Shared'),
  deadlineReminder('Deadline Reminder'),
  paymentDue('Payment Due'),
  filingComplete('Filing Complete'),
  otp('OTP');

  const NotificationUseCase(this.label);

  final String label;
}

/// Immutable model representing a reusable notification template.
///
/// [templateText] uses `{placeholder}` syntax, e.g. `{clientName}`.
/// [placeholders] lists the expected keys for substitution.
class NotificationTemplate {
  const NotificationTemplate({
    required this.templateId,
    required this.name,
    required this.channel,
    required this.templateText,
    required this.placeholders,
    required this.useCase,
  });

  final String templateId;
  final String name;
  final NotificationChannel channel;

  /// Template body with `{key}` placeholders.
  final String templateText;

  /// Ordered list of placeholder keys expected by this template.
  final List<String> placeholders;

  final NotificationUseCase useCase;

  NotificationTemplate copyWith({
    String? templateId,
    String? name,
    NotificationChannel? channel,
    String? templateText,
    List<String>? placeholders,
    NotificationUseCase? useCase,
  }) {
    return NotificationTemplate(
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      channel: channel ?? this.channel,
      templateText: templateText ?? this.templateText,
      placeholders: placeholders ?? this.placeholders,
      useCase: useCase ?? this.useCase,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationTemplate) return false;
    if (other.templateId != templateId) return false;
    if (other.name != name) return false;
    if (other.channel != channel) return false;
    if (other.templateText != templateText) return false;
    if (other.useCase != useCase) return false;
    if (other.placeholders.length != placeholders.length) return false;
    for (var i = 0; i < placeholders.length; i++) {
      if (other.placeholders[i] != placeholders[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        templateId,
        name,
        channel,
        templateText,
        useCase,
        Object.hashAll(placeholders),
      );
}

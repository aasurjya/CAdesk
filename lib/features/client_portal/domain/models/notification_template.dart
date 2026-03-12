/// Delivery channels for notifications sent to clients.
enum NotificationChannel {
  whatsapp,
  email,
  sms,
  push,
}

/// Use-case categories for notification templates.
enum NotificationUseCase {
  documentShared,
  deadlineReminder,
  paymentDue,
  filingComplete,
  otp,
}

/// Immutable domain model for a notification message template.
///
/// [placeholders] lists the variable names that appear as `{name}` tokens
/// inside [templateText].
///
/// Equality is based on all fields (value-equality semantics).
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
  final String templateText;
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
    if (templateId != other.templateId) return false;
    if (name != other.name) return false;
    if (channel != other.channel) return false;
    if (templateText != other.templateText) return false;
    if (useCase != other.useCase) return false;
    if (placeholders.length != other.placeholders.length) return false;
    for (var i = 0; i < placeholders.length; i++) {
      if (placeholders[i] != other.placeholders[i]) return false;
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

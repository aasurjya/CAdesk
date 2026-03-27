/// Events that can trigger a notification to be dispatched.
enum NotificationTrigger {
  deadlineApproaching,
  paymentDue,
  documentShared,
  filingComplete,
  queryReceived,
}

/// Delivery channels through which a notification can be sent.
enum NotificationChannel { push, email, whatsApp, sms }

/// Immutable rule that maps a [NotificationTrigger] to one or more
/// [NotificationChannel]s along with optional parameters.
///
/// [parameters] carries rule-specific configuration such as:
/// - `daysBeforeDeadline`: number of days before a deadline to fire the rule.
/// - `templateName`: override the default notification template.
///
/// Example:
/// ```dart
/// const rule = NotificationRule(
///   id: 'rule-001',
///   trigger: NotificationTrigger.deadlineApproaching,
///   channels: [NotificationChannel.whatsApp, NotificationChannel.email],
///   isActive: true,
///   parameters: {'daysBeforeDeadline': '3'},
/// );
/// ```
class NotificationRule {
  const NotificationRule({
    required this.id,
    required this.trigger,
    required this.channels,
    required this.isActive,
    this.parameters = const {},
  });

  /// Unique identifier for this rule.
  final String id;

  /// Event that activates this rule.
  final NotificationTrigger trigger;

  /// Ordered list of channels through which the notification is sent.
  final List<NotificationChannel> channels;

  /// `false` disables dispatching without deleting the rule.
  final bool isActive;

  /// Key-value configuration pairs specific to this rule's trigger type.
  ///
  /// Common keys:
  /// - `daysBeforeDeadline` — used with [NotificationTrigger.deadlineApproaching].
  /// - `templateName` — optional channel-specific template override.
  /// - `minAmountPaise` — minimum invoice amount to trigger payment reminders.
  final Map<String, String> parameters;

  /// Returns the value of [key] from [parameters], or [defaultValue] if absent.
  String parameter(String key, {String defaultValue = ''}) =>
      parameters[key] ?? defaultValue;

  NotificationRule copyWith({
    String? id,
    NotificationTrigger? trigger,
    List<NotificationChannel>? channels,
    bool? isActive,
    Map<String, String>? parameters,
  }) {
    return NotificationRule(
      id: id ?? this.id,
      trigger: trigger ?? this.trigger,
      channels: channels ?? this.channels,
      isActive: isActive ?? this.isActive,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationRule &&
        other.id == id &&
        other.trigger == trigger &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, trigger, isActive);

  @override
  String toString() =>
      'NotificationRule(id: $id, trigger: ${trigger.name}, '
      'channels: ${channels.map((c) => c.name).join(', ')}, '
      'isActive: $isActive)';
}

/// Type of portal notification.
enum NotificationType {
  reminder('Reminder'),
  document('Document'),
  message('Message'),
  payment('Payment'),
  deadline('Deadline');

  const NotificationType(this.label);

  final String label;
}

/// Channel through which the notification is delivered.
enum NotificationChannel {
  email('Email'),
  sms('SMS'),
  whatsapp('WhatsApp'),
  inApp('In-App');

  const NotificationChannel(this.label);

  final String label;
}

/// Represents a notification sent to a client through the portal.
class PortalNotification {
  const PortalNotification({
    required this.id,
    required this.clientId,
    required this.type,
    required this.title,
    required this.body,
    required this.channel,
    required this.sentAt,
    this.isRead = false,
  });

  final String id;
  final String clientId;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationChannel channel;
  final DateTime sentAt;
  final bool isRead;

  PortalNotification copyWith({
    String? id,
    String? clientId,
    NotificationType? type,
    String? title,
    String? body,
    NotificationChannel? channel,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return PortalNotification(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      channel: channel ?? this.channel,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortalNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

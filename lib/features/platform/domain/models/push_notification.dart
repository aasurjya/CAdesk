/// Category of a push notification.
enum NotificationType {
  /// Upcoming statutory deadline alert.
  deadlineAlert,

  /// Filing has been successfully submitted.
  filingComplete,

  /// A document has been shared with the user.
  documentShared,

  /// Income tax demand raised by the department.
  demandRaised,

  /// New message from a colleague or client.
  newMessage,

  /// Platform-level system notice.
  systemAlert,
}

/// Immutable push notification record.
class PushNotification {
  const PushNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.sentAt,
    this.readAt,
  });

  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;

  /// Deep-link and contextual data (e.g. `{"clientId": "c-1", "route": "/itr"}`).
  final Map<String, String> data;
  final DateTime sentAt;
  final DateTime? readAt;

  /// Derived: true when the notification has been read.
  bool get isRead => readAt != null;

  PushNotification copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, String>? data,
    DateTime? sentAt,
    DateTime? readAt,
  }) {
    return PushNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushNotification && other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;

  @override
  String toString() =>
      'PushNotification(notificationId: $notificationId, type: $type, '
      'isRead: $isRead)';
}

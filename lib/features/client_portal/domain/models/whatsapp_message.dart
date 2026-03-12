/// Type of a WhatsApp message.
enum MessageType {
  text,
  template,
  document,
  image,
}

/// Delivery status of a WhatsApp message.
enum MessageStatus {
  queued,
  sent,
  delivered,
  read,
  failed,
}

/// Domain model representing a WhatsApp message sent to a client.
///
/// Immutable — use [copyWith] to derive updated copies.
/// Equality and [hashCode] are based solely on [messageId].
class WhatsAppMessage {
  const WhatsAppMessage({
    required this.messageId,
    required this.to,
    required this.messageType,
    required this.content,
    required this.status,
    required this.caFirmId,
    this.templateName,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
  });

  final String messageId;

  /// Recipient phone in E.164 format without the '+' prefix.
  final String to;
  final MessageType messageType;
  final String content;
  final MessageStatus status;
  final String caFirmId;
  final String? templateName;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  WhatsAppMessage copyWith({
    String? messageId,
    String? to,
    MessageType? messageType,
    String? content,
    MessageStatus? status,
    String? caFirmId,
    String? templateName,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return WhatsAppMessage(
      messageId: messageId ?? this.messageId,
      to: to ?? this.to,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      status: status ?? this.status,
      caFirmId: caFirmId ?? this.caFirmId,
      templateName: templateName ?? this.templateName,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WhatsAppMessage && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;
}

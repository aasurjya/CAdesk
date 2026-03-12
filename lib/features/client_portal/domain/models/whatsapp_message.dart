/// Type of WhatsApp message payload.
enum MessageType {
  text('Text'),
  template('Template'),
  document('Document'),
  image('Image');

  const MessageType(this.label);

  final String label;
}

/// Delivery status of a WhatsApp message.
enum MessageStatus {
  queued('Queued'),
  sent('Sent'),
  delivered('Delivered'),
  read('Read'),
  failed('Failed');

  const MessageStatus(this.label);

  final String label;
}

/// Immutable model representing a WhatsApp Business API message.
///
/// Phone numbers must include country code without '+', e.g. "919876543210"
/// for an Indian number.
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

  /// Recipient phone number with country code, e.g. "919876543210".
  final String to;

  /// Template name for [MessageType.template] messages (Meta pre-approved).
  final String? templateName;

  final MessageType messageType;
  final String content;
  final MessageStatus status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String caFirmId;

  WhatsAppMessage copyWith({
    String? messageId,
    String? to,
    String? templateName,
    MessageType? messageType,
    String? content,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    String? caFirmId,
  }) {
    return WhatsAppMessage(
      messageId: messageId ?? this.messageId,
      to: to ?? this.to,
      templateName: templateName ?? this.templateName,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      caFirmId: caFirmId ?? this.caFirmId,
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

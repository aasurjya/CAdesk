/// Sender type for portal messages.
enum SenderType {
  client('Client'),
  staff('Staff'),
  system('System');

  const SenderType(this.label);

  final String label;
}

/// Represents a message within the client portal communication system.
class PortalMessage {
  const PortalMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.threadId,
    required this.createdAt,
    this.attachments = const [],
    this.isRead = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final SenderType senderType;
  final String content;
  final List<String> attachments;
  final String threadId;
  final DateTime createdAt;
  final bool isRead;

  PortalMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    SenderType? senderType,
    String? content,
    List<String>? attachments,
    String? threadId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return PortalMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      threadId: threadId ?? this.threadId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortalMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

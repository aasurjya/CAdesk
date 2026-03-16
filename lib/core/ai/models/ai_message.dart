/// Role of a participant in an AI conversation.
enum AiRole { system, user, assistant, tool }

/// An immutable message in an AI conversation.
class AiMessage {
  const AiMessage({
    required this.role,
    required this.content,
    this.toolCallId,
    this.name,
  });

  final AiRole role;
  final String content;
  final String? toolCallId;
  final String? name;

  AiMessage copyWith({
    AiRole? role,
    String? content,
    String? toolCallId,
    String? name,
  }) {
    return AiMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      toolCallId: toolCallId ?? this.toolCallId,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiMessage &&
        other.role == role &&
        other.content == content &&
        other.toolCallId == toolCallId &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(role, content, toolCallId, name);
}

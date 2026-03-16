import 'package:ca_app/core/ai/models/ai_message.dart';

/// Sliding window memory for conversation context.
///
/// Keeps the last [maxMessages] messages to stay within token limits.
class ConversationMemory {
  ConversationMemory({
    List<AiMessage> messages = const [],
    this.maxMessages = 20,
  }) : _messages = List.unmodifiable(messages);

  final List<AiMessage> _messages;
  final int maxMessages;

  List<AiMessage> get messages => _messages;
  bool get isEmpty => _messages.isEmpty;
  int get length => _messages.length;

  /// Returns a new [ConversationMemory] with [message] appended.
  ///
  /// If the window exceeds [maxMessages], the oldest non-system message is dropped.
  ConversationMemory addMessage(AiMessage message) {
    final updated = [..._messages, message];

    if (updated.length > maxMessages) {
      // Keep system messages, drop oldest non-system
      final systemMessages = updated
          .where((m) => m.role == AiRole.system)
          .toList();
      final nonSystem = updated.where((m) => m.role != AiRole.system).toList();

      final trimmed = nonSystem.length > maxMessages - systemMessages.length
          ? nonSystem.sublist(
              nonSystem.length - (maxMessages - systemMessages.length),
            )
          : nonSystem;

      return ConversationMemory(
        messages: [...systemMessages, ...trimmed],
        maxMessages: maxMessages,
      );
    }

    return ConversationMemory(messages: updated, maxMessages: maxMessages);
  }

  /// Returns a new empty [ConversationMemory].
  ConversationMemory clear() => ConversationMemory(maxMessages: maxMessages);
}

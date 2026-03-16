import 'ai_message.dart';
import 'ai_tool_definition.dart';

/// An immutable request to the AI gateway.
class AiRequest {
  AiRequest({
    required List<AiMessage> messages,
    this.systemPrompt,
    this.temperature = 0.3,
    this.maxTokens = 4096,
    List<AiToolDefinition> tools = const [],
    this.stream = false,
  }) : messages = List.unmodifiable(messages),
       tools = List.unmodifiable(tools);

  final List<AiMessage> messages;
  final String? systemPrompt;
  final double temperature;
  final int maxTokens;
  final List<AiToolDefinition> tools;
  final bool stream;

  AiRequest copyWith({
    List<AiMessage>? messages,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
    List<AiToolDefinition>? tools,
    bool? stream,
  }) {
    return AiRequest(
      messages: messages ?? this.messages,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      tools: tools ?? this.tools,
      stream: stream ?? this.stream,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiRequest &&
        other.systemPrompt == systemPrompt &&
        other.temperature == temperature &&
        other.maxTokens == maxTokens &&
        other.stream == stream;
  }

  @override
  int get hashCode => Object.hash(systemPrompt, temperature, maxTokens, stream);
}

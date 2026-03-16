import 'ai_tool_call.dart';
import 'ai_usage.dart';

/// Reason the model stopped generating.
enum FinishReason { stop, toolUse, maxTokens, contentFilter, error }

/// An immutable response from the AI gateway.
class AiResponse {
  AiResponse({
    required this.content,
    this.finishReason = FinishReason.stop,
    this.usage = AiUsage.zero,
    List<AiToolCall> toolCalls = const [],
    List<String> citations = const [],
  }) : toolCalls = List.unmodifiable(toolCalls),
       citations = List.unmodifiable(citations);

  final String content;
  final FinishReason finishReason;
  final AiUsage usage;
  final List<AiToolCall> toolCalls;
  final List<String> citations;

  bool get hasToolCalls => toolCalls.isNotEmpty;

  AiResponse copyWith({
    String? content,
    FinishReason? finishReason,
    AiUsage? usage,
    List<AiToolCall>? toolCalls,
    List<String>? citations,
  }) {
    return AiResponse(
      content: content ?? this.content,
      finishReason: finishReason ?? this.finishReason,
      usage: usage ?? this.usage,
      toolCalls: toolCalls ?? this.toolCalls,
      citations: citations ?? this.citations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiResponse &&
        other.content == content &&
        other.finishReason == finishReason &&
        other.usage == usage;
  }

  @override
  int get hashCode => Object.hash(content, finishReason, usage);
}

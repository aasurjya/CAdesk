import 'package:ca_app/core/ai/models/ai_message.dart';
import 'package:ca_app/core/ai/models/ai_tool_call.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_citation.dart';

/// The current phase of the agent's ReAct loop.
enum AgentPhase { idle, thinking, acting, observing, responding, error }

/// Immutable snapshot of the agent's state during a ReAct loop.
class AgentState {
  AgentState({
    this.phase = AgentPhase.idle,
    this.currentIteration = 0,
    List<AiMessage> messages = const [],
    List<AiToolCall> toolCalls = const [],
    List<TaxCitation> citations = const [],
    this.finalAnswer,
    this.error,
  }) : messages = List.unmodifiable(messages),
       toolCalls = List.unmodifiable(toolCalls),
       citations = List.unmodifiable(citations);

  final AgentPhase phase;
  final int currentIteration;
  final List<AiMessage> messages;
  final List<AiToolCall> toolCalls;
  final List<TaxCitation> citations;
  final String? finalAnswer;
  final String? error;

  bool get isComplete =>
      phase == AgentPhase.responding || phase == AgentPhase.error;

  AgentState copyWith({
    AgentPhase? phase,
    int? currentIteration,
    List<AiMessage>? messages,
    List<AiToolCall>? toolCalls,
    List<TaxCitation>? citations,
    String? finalAnswer,
    String? error,
  }) {
    return AgentState(
      phase: phase ?? this.phase,
      currentIteration: currentIteration ?? this.currentIteration,
      messages: messages ?? this.messages,
      toolCalls: toolCalls ?? this.toolCalls,
      citations: citations ?? this.citations,
      finalAnswer: finalAnswer ?? this.finalAnswer,
      error: error ?? this.error,
    );
  }
}

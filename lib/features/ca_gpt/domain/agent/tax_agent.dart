import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/models/ai_message.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/rag/models/rag_context.dart';
import 'package:ca_app/core/ai/rag/pipeline/rag_pipeline.dart';
import 'package:ca_app/features/ca_gpt/domain/agent/agent_config.dart';
import 'package:ca_app/features/ca_gpt/domain/agent/agent_state.dart';
import 'package:ca_app/features/ca_gpt/domain/agent/tool_registry.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_citation.dart';

/// Core ReAct (Reason + Act) agent for tax advisory.
///
/// Loop: plan -> tool -> observe -> respond. Uses RAG for knowledge retrieval
/// and registered tools for domain-specific actions.
class TaxAgent {
  const TaxAgent({
    required this.gateway,
    required this.ragPipeline,
    required this.toolRegistry,
    this.config,
  });

  final AiGateway gateway;
  final RagPipeline ragPipeline;
  final ToolRegistry toolRegistry;
  final AgentConfig? config;

  AgentConfig get _config => config ?? AgentConfig.defaultConfig;

  static const _systemPrompt =
      '''You are CA GPT, an expert Indian tax assistant for Chartered Accountants.
You help with Income Tax, GST, TDS, and compliance queries.

INSTRUCTIONS:
- Use the provided tools to look up accurate information before answering.
- Always cite your sources using [1], [2] notation.
- If you need to look up a section, use section_lookup.
- If you need to check deadlines, use deadline_check.
- If you need to draft a notice reply, use notice_drafting.
- Be precise and cite specific sections, rules, and circulars.
- When uncertain, say so and suggest consulting the original text.
- Format responses clearly with headings and bullet points.''';

  /// Runs the agent for a single user query and emits state updates.
  Stream<AgentState> run(String userQuery) async* {
    var state = AgentState(phase: AgentPhase.thinking);
    yield state;

    // Step 1: Retrieve RAG context
    RagContext ragContext;
    try {
      ragContext = await ragPipeline.retrieve(userQuery);
    } catch (_) {
      ragContext = RagContext(
        chunks: const [],
        formattedPrompt: '',
        citations: const [],
      );
    }

    // Build system prompt with RAG context
    final systemPrompt = ragContext.isEmpty
        ? _systemPrompt
        : '$_systemPrompt\n\n${ragContext.formattedPrompt}';

    final messages = <AiMessage>[
      AiMessage(role: AiRole.user, content: userQuery),
    ];

    state = state.copyWith(messages: messages, phase: AgentPhase.thinking);
    yield state;

    // ReAct loop
    for (var i = 0; i < _config.maxIterations; i++) {
      state = state.copyWith(
        currentIteration: i + 1,
        phase: AgentPhase.thinking,
      );
      yield state;

      // Call the LLM
      final request = AiRequest(
        messages: messages,
        systemPrompt: systemPrompt,
        tools: toolRegistry.toToolDefinitions(),
      );

      final response = await gateway.complete(request);

      // If no tool calls, we have the final answer
      if (!response.hasToolCalls) {
        final citations = _extractCitations(ragContext);
        state = state.copyWith(
          phase: AgentPhase.responding,
          finalAnswer: response.content,
          citations: citations,
          messages: [
            ...messages,
            AiMessage(role: AiRole.assistant, content: response.content),
          ],
        );
        yield state;
        return;
      }

      // Execute tool calls
      state = state.copyWith(phase: AgentPhase.acting);
      yield state;

      messages.add(
        AiMessage(role: AiRole.assistant, content: response.content),
      );

      final completedToolCalls = <dynamic>[];
      for (final toolCall in response.toolCalls) {
        final result = await toolRegistry.execute(
          toolCall.toolName,
          toolCall.arguments,
        );

        final completedCall = toolCall.copyWith(result: result);
        completedToolCalls.add(completedCall);

        // Add tool result as a message
        messages.add(
          AiMessage(
            role: AiRole.tool,
            content: result,
            toolCallId: toolCall.id,
            name: toolCall.toolName,
          ),
        );
      }

      state = state.copyWith(
        phase: AgentPhase.observing,
        toolCalls: [...state.toolCalls, ...completedToolCalls],
        messages: List.of(messages),
      );
      yield state;
    }

    // Max iterations reached — ask the LLM for a final summary
    final finalRequest = AiRequest(
      messages: messages,
      systemPrompt:
          '$systemPrompt\n\nYou have reached the maximum number of '
          'tool calls. Please provide your best answer with the information gathered.',
    );

    final finalResponse = await gateway.complete(finalRequest);
    final citations = _extractCitations(ragContext);

    state = state.copyWith(
      phase: AgentPhase.responding,
      finalAnswer: finalResponse.content,
      citations: citations,
    );
    yield state;
  }

  List<TaxCitation> _extractCitations(RagContext context) {
    return context.chunks.map((chunk) {
      return TaxCitation(
        type: CitationType.section,
        reference: chunk.source ?? chunk.chunk.documentId,
        summary: chunk.chunk.text.length > 100
            ? '${chunk.chunk.text.substring(0, 100)}...'
            : chunk.chunk.text,
        relevanceScore: chunk.score,
      );
    }).toList();
  }
}

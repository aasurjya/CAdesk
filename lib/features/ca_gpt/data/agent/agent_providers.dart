import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/ai/providers/ai_gateway_provider.dart';
import 'package:ca_app/core/ai/rag/providers/rag_providers.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/ca_gpt/domain/agent/agent_state.dart';
import 'package:ca_app/features/ca_gpt/domain/agent/tax_agent.dart';
import 'package:ca_app/features/ca_gpt/domain/agent/tool_registry.dart';
import 'package:ca_app/features/ca_gpt/domain/memory/client_context_memory.dart';
import 'package:ca_app/features/ca_gpt/domain/memory/conversation_memory.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/circular_search_tool.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/client_lookup_tool.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/deadline_check_tool.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/notice_drafting_tool.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/precedent_search_tool.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/section_lookup_tool.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/tax_computation_tool.dart';

/// Provides the [ToolRegistry] with all available agent tools.
final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  final ragPipeline = ref.watch(ragPipelineProvider);

  return ToolRegistry([
    const SectionLookupTool(),
    const DeadlineCheckTool(),
    const NoticeDraftingTool(),
    const TaxComputationTool(),
    CircularSearchTool(ragPipeline: ragPipeline),
    PrecedentSearchTool(ragPipeline: ragPipeline),
    const ClientLookupTool(),
  ]);
});

/// Provides the [TaxAgent] instance.
final taxAgentProvider = Provider<TaxAgent>((ref) {
  final gateway = ref.watch(aiGatewayProvider);
  final ragPipeline = ref.watch(ragPipelineProvider);
  final toolRegistry = ref.watch(toolRegistryProvider);

  return TaxAgent(
    gateway: gateway,
    ragPipeline: ragPipeline,
    toolRegistry: toolRegistry,
  );
});

/// Provides the current [AgentState] during a query execution.
final agentStateProvider =
    NotifierProvider<AgentStateNotifier, AgentState>(AgentStateNotifier.new);

/// Notifier managing the agent execution state.
class AgentStateNotifier extends Notifier<AgentState> {
  @override
  AgentState build() => AgentState();

  void update(AgentState newState) {
    state = newState;
  }

  void reset() {
    state = AgentState();
  }
}

/// Provides [ConversationMemory] for the current chat session.
final conversationMemoryProvider =
    NotifierProvider<ConversationMemoryNotifier, ConversationMemory>(
  ConversationMemoryNotifier.new,
);

class ConversationMemoryNotifier extends Notifier<ConversationMemory> {
  @override
  ConversationMemory build() => ConversationMemory();

  void addMessage(dynamic message) {
    state = state.addMessage(message);
  }

  void clear() {
    state = state.clear();
  }
}

/// Provides [ClientContextMemory] for the current session.
final clientContextProvider =
    NotifierProvider<ClientContextNotifier, ClientContextMemory>(
  ClientContextNotifier.new,
);

class ClientContextNotifier extends Notifier<ClientContextMemory> {
  @override
  ClientContextMemory build() => ClientContextMemory.empty;

  void update(ClientContextMemory context) {
    state = context;
  }

  void clear() {
    state = ClientContextMemory.empty;
  }
}

/// Whether the AI agent is enabled via feature flags.
final isAgentEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(featureFlagProvider).asData?.value;
  return flags?.isEnabled('ai_agent_enabled') ?? false;
});

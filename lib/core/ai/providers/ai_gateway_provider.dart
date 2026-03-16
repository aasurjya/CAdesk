import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/ai/adapters/claude_adapter.dart';
import 'package:ca_app/core/ai/adapters/mock_ai_adapter.dart';
import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/gateway/routing_ai_gateway.dart';
import 'package:ca_app/core/ai/interceptors/cost_tracker.dart';
import 'package:ca_app/core/ai/interceptors/pii_redactor.dart';
import 'package:ca_app/core/ai/models/ai_model_config.dart';
import 'package:ca_app/core/ai/models/ai_request.dart';
import 'package:ca_app/core/ai/models/ai_response.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';

/// Provides the configured [AiGateway] based on feature flags.
///
/// When `ai_gateway_enabled` is off, returns [MockAiAdapter].
/// When `ai_model_claude` is on, includes [ClaudeAdapter] as first choice.
final aiGatewayProvider = Provider<AiGateway>((ref) {
  final flags = ref.watch(featureFlagProvider).asData?.value;
  final gatewayEnabled = flags?.isEnabled('ai_gateway_enabled') ?? false;

  if (!gatewayEnabled) {
    return const MockAiAdapter();
  }

  final adapters = <AiGateway>[];

  final claudeEnabled = flags?.isEnabled('ai_model_claude') ?? false;
  if (claudeEnabled) {
    adapters.add(ClaudeAdapter(
      dio: Dio(), // Separate Dio instance for Claude API
      config: AiModelConfig(
        modelId: 'claude-sonnet-4-6-20250514',
        endpoint: 'https://api.anthropic.com/v1/messages',
        apiKeyEnvVar: 'CLAUDE_API_KEY',
        maxTokens: 4096,
        capabilities: [
          AiCapability.chat,
          AiCapability.streaming,
          AiCapability.toolUse,
        ],
      ),
    ));
  }

  // Always include mock as ultimate fallback
  adapters.add(const MockAiAdapter());

  return RoutingAiGateway(adapters);
});

/// Provides the [PiiRedactor] singleton.
final piiRedactorProvider = Provider<PiiRedactor>((_) => const PiiRedactor());

/// Provides the [CostTracker] with configurable budgets.
final costTrackerProvider = NotifierProvider<CostTrackerNotifier, CostTracker>(
  CostTrackerNotifier.new,
);

/// Notifier managing the [CostTracker] state.
class CostTrackerNotifier extends Notifier<CostTracker> {
  @override
  CostTracker build() => CostTracker();

  /// Records a usage entry and returns the updated tracker.
  void trackUsage(AiUsage usage) {
    state = state.trackUsage(usage);
  }
}

/// A convenience provider that wraps [AiGateway] with PII redaction and cost tracking.
final safeAiGatewayProvider = Provider<SafeAiGateway>((ref) {
  return SafeAiGateway(
    gateway: ref.watch(aiGatewayProvider),
    redactor: ref.watch(piiRedactorProvider),
    costTrackerNotifier: ref.watch(costTrackerProvider.notifier),
  );
});

/// Wraps an [AiGateway] with automatic PII redaction and cost tracking.
class SafeAiGateway {
  const SafeAiGateway({
    required this.gateway,
    required this.redactor,
    required this.costTrackerNotifier,
  });

  final AiGateway gateway;
  final PiiRedactor redactor;
  final CostTrackerNotifier costTrackerNotifier;

  Future<AiResponse> complete(AiRequest request) async {
    final sanitized = redactor.redact(request);
    final response = await gateway.complete(sanitized);
    costTrackerNotifier.trackUsage(response.usage);
    return response;
  }

  Stream<AiResponse> streamComplete(AiRequest request) async* {
    final sanitized = redactor.redact(request);
    await for (final response in gateway.streamComplete(sanitized)) {
      yield response;
    }
  }

  Future<List<double>> embed(String text) async {
    final sanitized = redactor.redactText(text);
    return gateway.embed(sanitized);
  }
}

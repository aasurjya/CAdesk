/// Capabilities a model may support.
enum AiCapability { chat, streaming, toolUse, embedding, vision }

/// Configuration for a specific AI model endpoint.
class AiModelConfig {
  AiModelConfig({
    required this.modelId,
    required this.endpoint,
    this.apiKeyEnvVar = '',
    this.maxTokens = 4096,
    this.defaultTemperature = 0.3,
    List<AiCapability> capabilities = const [],
  }) : capabilities = List.unmodifiable(capabilities);

  final String modelId;
  final String endpoint;
  final String apiKeyEnvVar;
  final int maxTokens;
  final double defaultTemperature;
  final List<AiCapability> capabilities;

  bool supports(AiCapability capability) => capabilities.contains(capability);

  AiModelConfig copyWith({
    String? modelId,
    String? endpoint,
    String? apiKeyEnvVar,
    int? maxTokens,
    double? defaultTemperature,
    List<AiCapability>? capabilities,
  }) {
    return AiModelConfig(
      modelId: modelId ?? this.modelId,
      endpoint: endpoint ?? this.endpoint,
      apiKeyEnvVar: apiKeyEnvVar ?? this.apiKeyEnvVar,
      maxTokens: maxTokens ?? this.maxTokens,
      defaultTemperature: defaultTemperature ?? this.defaultTemperature,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiModelConfig &&
        other.modelId == modelId &&
        other.endpoint == endpoint;
  }

  @override
  int get hashCode => Object.hash(modelId, endpoint);
}

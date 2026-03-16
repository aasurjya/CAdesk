/// Token usage statistics for an AI API call.
class AiUsage {
  const AiUsage({
    required this.promptTokens,
    required this.completionTokens,
    this.estimatedCostUsd = 0.0,
  });

  static const AiUsage zero = AiUsage(promptTokens: 0, completionTokens: 0);

  final int promptTokens;
  final int completionTokens;
  final double estimatedCostUsd;

  int get totalTokens => promptTokens + completionTokens;

  AiUsage copyWith({
    int? promptTokens,
    int? completionTokens,
    double? estimatedCostUsd,
  }) {
    return AiUsage(
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      estimatedCostUsd: estimatedCostUsd ?? this.estimatedCostUsd,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiUsage &&
        other.promptTokens == promptTokens &&
        other.completionTokens == completionTokens &&
        other.estimatedCostUsd == estimatedCostUsd;
  }

  @override
  int get hashCode =>
      Object.hash(promptTokens, completionTokens, estimatedCostUsd);
}

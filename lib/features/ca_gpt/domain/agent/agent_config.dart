/// Configuration for the ReAct tax agent.
class AgentConfig {
  AgentConfig({
    this.maxIterations = 5,
    this.timeoutMs = 30000,
    List<String> allowedTools = const [],
  }) : allowedTools = List.unmodifiable(allowedTools);

  final int maxIterations;
  final int timeoutMs;
  final List<String> allowedTools;

  static final defaultConfig = AgentConfig(
    allowedTools: [
      'section_lookup',
      'deadline_check',
      'notice_drafting',
      'tax_computation',
      'circular_search',
      'precedent_search',
      'client_lookup',
    ],
  );

  AgentConfig copyWith({
    int? maxIterations,
    int? timeoutMs,
    List<String>? allowedTools,
  }) {
    return AgentConfig(
      maxIterations: maxIterations ?? this.maxIterations,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      allowedTools: allowedTools ?? this.allowedTools,
    );
  }
}

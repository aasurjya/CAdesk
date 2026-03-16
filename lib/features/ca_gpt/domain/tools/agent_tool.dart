/// Abstract interface for tools the agent can invoke.
abstract class AgentTool {
  /// Unique name used in tool calling (e.g., 'section_lookup').
  String get name;

  /// Human-readable description for the model's tool schema.
  String get description;

  /// JSON Schema for the tool's parameters.
  Map<String, dynamic> get parameters;

  /// Executes the tool with the given [arguments] and returns a text result.
  Future<String> execute(Map<String, dynamic> arguments);
}

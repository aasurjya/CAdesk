import 'package:ca_app/core/ai/models/ai_tool_definition.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// Maps tool names to their implementations.
class ToolRegistry {
  ToolRegistry(List<AgentTool> tools)
    : _tools = Map.unmodifiable({for (final tool in tools) tool.name: tool});

  final Map<String, AgentTool> _tools;

  /// Returns the tool with the given [name], or null if not found.
  AgentTool? get(String name) => _tools[name];

  /// All registered tool names.
  Iterable<String> get names => _tools.keys;

  /// Converts all tools to [AiToolDefinition] for the AI request.
  List<AiToolDefinition> toToolDefinitions() {
    return _tools.values.map((tool) {
      return AiToolDefinition(
        name: tool.name,
        description: tool.description,
        parameters: tool.parameters,
      );
    }).toList();
  }

  /// Executes a tool by [name] with the given [arguments].
  ///
  /// Returns the tool's text output, or an error message if not found.
  Future<String> execute(String name, Map<String, dynamic> arguments) async {
    final tool = _tools[name];
    if (tool == null) {
      return 'Error: Unknown tool "$name". Available tools: ${names.join(", ")}';
    }
    return tool.execute(arguments);
  }
}

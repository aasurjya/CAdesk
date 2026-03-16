/// A tool invocation requested by the AI model.
class AiToolCall {
  AiToolCall({
    required this.id,
    required this.toolName,
    required Map<String, dynamic> arguments,
    this.result,
  }) : arguments = Map.unmodifiable(arguments);

  final String id;
  final String toolName;
  final Map<String, dynamic> arguments;
  final String? result;

  AiToolCall copyWith({
    String? id,
    String? toolName,
    Map<String, dynamic>? arguments,
    String? result,
  }) {
    return AiToolCall(
      id: id ?? this.id,
      toolName: toolName ?? this.toolName,
      arguments: arguments ?? this.arguments,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiToolCall &&
        other.id == id &&
        other.toolName == toolName &&
        other.result == result;
  }

  @override
  int get hashCode => Object.hash(id, toolName, result);
}

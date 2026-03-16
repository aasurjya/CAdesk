/// Schema definition for a tool that the AI model can call.
class AiToolDefinition {
  AiToolDefinition({
    required this.name,
    required this.description,
    required Map<String, dynamic> parameters,
  }) : parameters = Map.unmodifiable(parameters);

  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() {
    return Map.unmodifiable(<String, dynamic>{
      'name': name,
      'description': description,
      'parameters': parameters,
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiToolDefinition &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(name, description);
}

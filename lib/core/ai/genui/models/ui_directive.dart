/// Types of UI directives the AI can generate.
enum DirectiveType {
  insightCard,
  deadlineAlert,
  complianceStatus,
  actionSuggestion,
  taxComparison,
  noticeWarning,
  clientAlert,
}

/// An immutable UI directive from the AI — instructs the frontend to render
/// a specific widget with contextual data.
class UiDirective {
  UiDirective({
    required this.type,
    required this.title,
    required this.body,
    this.priority = 0,
    this.actionRoute,
    Map<String, dynamic> payload = const {},
  }) : payload = Map.unmodifiable(payload);

  final DirectiveType type;
  final String title;
  final String body;
  final int priority;
  final String? actionRoute;
  final Map<String, dynamic> payload;

  UiDirective copyWith({
    DirectiveType? type,
    String? title,
    String? body,
    int? priority,
    String? actionRoute,
    Map<String, dynamic>? payload,
  }) {
    return UiDirective(
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      actionRoute: actionRoute ?? this.actionRoute,
      payload: payload ?? this.payload,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UiDirective &&
        other.type == type &&
        other.title == title &&
        other.body == body &&
        other.priority == priority;
  }

  @override
  int get hashCode => Object.hash(type, title, body, priority);
}

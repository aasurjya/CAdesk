/// Type of follow-up action.
enum ActionType { whatsapp, email, createTask, scheduleCall, navigateTo }

/// An immutable follow-up action attached to a smart notification.
class FollowUpAction {
  FollowUpAction({
    required this.type,
    required this.label,
    required this.route,
    Map<String, String> parameters = const {},
  }) : parameters = Map.unmodifiable(parameters);

  final ActionType type;
  final String label;
  final String route;
  final Map<String, String> parameters;

  FollowUpAction copyWith({
    ActionType? type,
    String? label,
    String? route,
    Map<String, String>? parameters,
  }) {
    return FollowUpAction(
      type: type ?? this.type,
      label: label ?? this.label,
      route: route ?? this.route,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FollowUpAction &&
        other.type == type &&
        other.label == label &&
        other.route == route;
  }

  @override
  int get hashCode => Object.hash(type, label, route);
}

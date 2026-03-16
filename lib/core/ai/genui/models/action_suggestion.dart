import 'package:flutter/material.dart';

/// An immutable one-tap action the AI suggests to the user.
class ActionSuggestion {
  ActionSuggestion({
    required this.label,
    required this.icon,
    required this.route,
    Map<String, String> parameters = const {},
  }) : parameters = Map.unmodifiable(parameters);

  final String label;
  final IconData icon;
  final String route;
  final Map<String, String> parameters;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActionSuggestion &&
        other.label == label &&
        other.route == route;
  }

  @override
  int get hashCode => Object.hash(label, route);
}

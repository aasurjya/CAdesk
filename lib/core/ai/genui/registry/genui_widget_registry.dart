import 'package:flutter/material.dart';
import 'package:ca_app/core/ai/genui/models/ui_directive.dart';
import 'package:ca_app/core/ai/genui/widgets/genui_card.dart';

/// Maps [DirectiveType] values to Flutter widget builders.
class GenUiWidgetRegistry {
  GenUiWidgetRegistry({
    Map<DirectiveType, Widget Function(UiDirective)>? builders,
  }) : _builders = builders ?? _defaultBuilders;

  final Map<DirectiveType, Widget Function(UiDirective)> _builders;

  static final Map<DirectiveType, Widget Function(UiDirective)>
  _defaultBuilders = {
    for (final type in DirectiveType.values)
      type: (d) => GenUiCard(directive: d),
  };

  /// Returns a widget for the given [directive], using the registered builder.
  Widget build(UiDirective directive) {
    final builder = _builders[directive.type];
    if (builder != null) return builder(directive);
    return GenUiCard(directive: directive);
  }
}

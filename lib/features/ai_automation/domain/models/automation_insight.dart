import 'package:flutter/material.dart';

enum AutomationInsightStatus {
  onTrack(
    label: 'On Track',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  attentionNeeded(
    label: 'Attention Needed',
    color: Color(0xFFEF6C00),
    icon: Icons.warning_amber_rounded,
  ),
  blocked(
    label: 'Blocked',
    color: Color(0xFFC62828),
    icon: Icons.block_rounded,
  );

  const AutomationInsightStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class AutomationInsight {
  const AutomationInsight({
    required this.id,
    required this.title,
    required this.clientName,
    required this.description,
    required this.metricLabel,
    required this.metricValue,
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.status,
  });

  final String id;
  final String title;
  final String clientName;
  final String description;
  final String metricLabel;
  final String metricValue;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final AutomationInsightStatus status;

  AutomationInsight copyWith({
    String? id,
    String? title,
    String? clientName,
    String? description,
    String? metricLabel,
    String? metricValue,
    String? actionLabel,
    IconData? icon,
    Color? color,
    AutomationInsightStatus? status,
  }) {
    return AutomationInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      clientName: clientName ?? this.clientName,
      description: description ?? this.description,
      metricLabel: metricLabel ?? this.metricLabel,
      metricValue: metricValue ?? this.metricValue,
      actionLabel: actionLabel ?? this.actionLabel,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationInsight && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

import 'package:flutter/material.dart';

/// Priority level for a task, ordered from lowest to highest urgency.
enum TaskPriority {
  low(
    label: 'Low',
    color: Color(0xFF1565C0),
    icon: Icons.arrow_downward_rounded,
  ),
  medium(label: 'Medium', color: Color(0xFFFFA000), icon: Icons.remove_rounded),
  high(
    label: 'High',
    color: Color(0xFFEF6C00),
    icon: Icons.arrow_upward_rounded,
  ),
  urgent(
    label: 'Urgent',
    color: Color(0xFFC62828),
    icon: Icons.priority_high_rounded,
  );

  const TaskPriority({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

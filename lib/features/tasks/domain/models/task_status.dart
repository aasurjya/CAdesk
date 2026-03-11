import 'package:flutter/material.dart';

/// Workflow status of a task.
enum TaskStatus {
  todo(
    label: 'To Do',
    color: Color(0xFF718096),
    icon: Icons.radio_button_unchecked_rounded,
  ),
  inProgress(
    label: 'In Progress',
    color: Color(0xFF1565C0),
    icon: Icons.sync_rounded,
  ),
  review(
    label: 'Review',
    color: Color(0xFF7B1FA2),
    icon: Icons.rate_review_rounded,
  ),
  completed(
    label: 'Completed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  overdue(
    label: 'Overdue',
    color: Color(0xFFC62828),
    icon: Icons.warning_rounded,
  );

  const TaskStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

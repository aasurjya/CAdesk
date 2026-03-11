import 'package:flutter/material.dart';

/// Lifecycle status of an ITR filing.
enum FilingStatus {
  pending(
    label: 'Pending',
    color: Color(0xFFD4890E),
    icon: Icons.hourglass_empty_rounded,
  ),
  inProgress(
    label: 'In Progress',
    color: Color(0xFF1565C0),
    icon: Icons.sync_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF0D7C7C),
    icon: Icons.upload_file_rounded,
  ),
  verified(
    label: 'Verified',
    color: Color(0xFF1A7A3A),
    icon: Icons.verified_rounded,
  ),
  processed(
    label: 'Processed',
    color: Color(0xFF2E7D32),
    icon: Icons.check_circle_rounded,
  ),
  defective(
    label: 'Defective',
    color: Color(0xFFC62828),
    icon: Icons.error_rounded,
  );

  const FilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

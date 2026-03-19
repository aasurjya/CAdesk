import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Standard empty state widget with icon, message, and optional subtitle.
///
/// Used across 12+ screens to show a consistent "nothing here" placeholder.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.iconSize = 56,
  });

  final String message;
  final String? subtitle;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: AppColors.neutral300),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

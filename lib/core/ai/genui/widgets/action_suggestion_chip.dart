import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/ai/genui/models/action_suggestion.dart';
import 'package:ca_app/core/theme/app_colors.dart';

/// A one-tap actionable suggestion chip.
class ActionSuggestionChip extends StatelessWidget {
  const ActionSuggestionChip({super.key, required this.suggestion});

  final ActionSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(suggestion.icon, size: 16, color: AppColors.primary),
      label: Text(
        suggestion.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.primary.withAlpha(12),
      side: BorderSide(color: AppColors.primary.withAlpha(40)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => context.go(suggestion.route),
    );
  }
}

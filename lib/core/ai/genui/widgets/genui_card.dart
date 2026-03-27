import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/ai/genui/models/ui_directive.dart';
import 'package:ca_app/core/theme/app_colors.dart';

/// Renders any [UiDirective] as a Material 3 card.
class GenUiCard extends StatelessWidget {
  const GenUiCard({super.key, required this.directive});

  final UiDirective directive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(directive.type);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(40)),
      ),
      child: InkWell(
        onTap: directive.actionRoute != null
            ? () => context.go(directive.actionRoute!)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconForType(directive.type),
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      directive.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  if (directive.actionRoute != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.neutral400,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                directive.body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForType(DirectiveType type) {
    return switch (type) {
      DirectiveType.insightCard => AppColors.primary,
      DirectiveType.deadlineAlert => AppColors.error,
      DirectiveType.complianceStatus => AppColors.success,
      DirectiveType.actionSuggestion => AppColors.accent,
      DirectiveType.taxComparison => AppColors.secondary,
      DirectiveType.noticeWarning => AppColors.error,
      DirectiveType.clientAlert => AppColors.accent,
    };
  }

  IconData _iconForType(DirectiveType type) {
    return switch (type) {
      DirectiveType.insightCard => Icons.auto_awesome,
      DirectiveType.deadlineAlert => Icons.schedule_rounded,
      DirectiveType.complianceStatus => Icons.verified_rounded,
      DirectiveType.actionSuggestion => Icons.lightbulb_outline_rounded,
      DirectiveType.taxComparison => Icons.compare_arrows_rounded,
      DirectiveType.noticeWarning => Icons.warning_amber_rounded,
      DirectiveType.clientAlert => Icons.person_outline_rounded,
    };
  }
}

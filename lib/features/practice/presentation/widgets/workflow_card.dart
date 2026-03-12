import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';

/// Card displaying a workflow template summary.
class WorkflowCard extends StatelessWidget {
  const WorkflowCard({
    super.key,
    required this.workflow,
    required this.onStart,
    required this.onTap,
  });

  final WorkflowTemplate workflow;
  final VoidCallback onStart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workflow.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  _CategoryBadge(category: workflow.category),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.checklist_rounded,
                    label: '${workflow.tasks.length} steps',
                  ),
                  const SizedBox(width: 12),
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    label: '${workflow.estimatedHours}h est.',
                  ),
                  const SizedBox(width: 12),
                  _MetaChip(
                    icon: Icons.calendar_today_rounded,
                    label: '${workflow.deadline.offsetDays}d deadline',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withAlpha(18),
                    foregroundColor: AppColors.primary,
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final WorkflowCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color _categoryColor(WorkflowCategory category) {
    switch (category) {
      case WorkflowCategory.itrFiling:
        return AppColors.primary;
      case WorkflowCategory.gstFiling:
        return AppColors.secondary;
      case WorkflowCategory.tdsFiling:
        return AppColors.accent;
      case WorkflowCategory.audit:
        return const Color(0xFF7C3AED);
      case WorkflowCategory.accounting:
        return const Color(0xFF2196F3);
      case WorkflowCategory.advisory:
        return const Color(0xFF00897B);
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}

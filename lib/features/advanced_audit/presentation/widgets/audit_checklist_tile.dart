import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_checklist.dart';

/// A tile displaying an audit checklist with completion progress bar.
class AuditChecklistTile extends StatelessWidget {
  const AuditChecklistTile({super.key, required this.checklist, this.onTap});

  final AuditChecklist checklist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = checklist.completionPercent;
    final isComplete = percent >= 1.0;
    final progressColor = isComplete
        ? AppColors.success
        : AppColors.primaryVariant;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    checklist.auditType.icon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checklist.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isComplete)
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.success,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${checklist.auditType.label} Audit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${checklist.completedItems} of ${checklist.totalItems} '
                    'completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(percent * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              _RecentItems(checklist: checklist),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the last few incomplete items as a preview.
class _RecentItems extends StatelessWidget {
  const _RecentItems({required this.checklist});

  final AuditChecklist checklist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incompleteItems = checklist.items
        .where((item) => !item.isCompleted)
        .take(3)
        .toList();

    if (incompleteItems.isEmpty) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: 6),
          Text(
            'All items completed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...incompleteItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.radio_button_unchecked,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

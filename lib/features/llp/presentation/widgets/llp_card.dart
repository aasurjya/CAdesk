import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp/data/providers/llp_providers.dart';

/// Card widget displaying an LLP summary: name, LLPIN, compliance status, penalty.
class LlpCard extends StatelessWidget {
  const LlpCard({super.key, required this.llp, required this.onTap});

  final LlpEntity llp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOverdue =
        llp.form8Status == LlpFilingStatus.overdue ||
        llp.form11Status == LlpFilingStatus.overdue ||
        llp.itr5Status == LlpFilingStatus.overdue;

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
                      llp.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Overdue',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Compliant',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'LLPIN: ${llp.llpin}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${llp.numberOfPartners} partners  |  '
                '${llp.designatedPartners.length} designated',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _FilingChip(label: 'F-8', status: llp.form8Status),
                  const SizedBox(width: 6),
                  _FilingChip(label: 'F-11', status: llp.form11Status),
                  const SizedBox(width: 6),
                  _FilingChip(label: 'ITR-5', status: llp.itr5Status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filing status chip
// ---------------------------------------------------------------------------

class _FilingChip extends StatelessWidget {
  const _FilingChip({required this.label, required this.status});

  final String label;
  final LlpFilingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, color) = switch (status) {
      LlpFilingStatus.filed => ('Filed', AppColors.success),
      LlpFilingStatus.overdue => ('Overdue', AppColors.error),
      LlpFilingStatus.pending => ('Pending', AppColors.warning),
      LlpFilingStatus.notDue => ('Not Due', AppColors.neutral400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $statusLabel',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

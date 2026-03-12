import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/bulk_operations/domain/models/filing_batch.dart';

/// Card displaying a batch summary with progress bar and status chip.
class BatchCard extends StatelessWidget {
  const BatchCard({super.key, required this.batch, required this.onTap});

  final FilingBatch batch;
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
                      batch.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  _BatchTypeBadge(type: batch.type),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${batch.completedCount}/${batch.jobs.length} jobs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(status: batch.status),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: batch.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.neutral100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progressColor(batch.status),
                  ),
                ),
              ),
              if (batch.failedCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${batch.failedCount} failed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _progressColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.completed:
        return AppColors.success;
      case BatchStatus.failed:
        return AppColors.error;
      case BatchStatus.running:
        return AppColors.primary;
      case BatchStatus.queued:
        return AppColors.neutral400;
      case BatchStatus.cancelled:
        return AppColors.neutral300;
    }
  }
}

class _BatchTypeBadge extends StatelessWidget {
  const _BatchTypeBadge({required this.type});

  final BatchType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BatchStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _chipColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color _chipColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.completed:
        return AppColors.success;
      case BatchStatus.failed:
        return AppColors.error;
      case BatchStatus.running:
        return AppColors.secondary;
      case BatchStatus.queued:
        return AppColors.accent;
      case BatchStatus.cancelled:
        return AppColors.neutral400;
    }
  }
}

import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

/// Tile showing a single job's status, name, and optional error from items.
class JobStatusTile extends StatelessWidget {
  const JobStatusTile({super.key, required this.job, required this.onRetry});

  final BatchJob job;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Surface the first failed item's error, if any.
    final firstError = job.items
        .where((item) => item.error != null)
        .map((item) => item.error)
        .firstOrNull;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _jobTypeLabel(job.jobType),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                _JobStatusChip(status: job.status),
              ],
            ),
            if (firstError != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  firstError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _jobTypeLabel(JobType type) {
    switch (type) {
      case JobType.itrFiling:
        return 'ITR Filing';
      case JobType.gstFiling:
        return 'GST Filing';
      case JobType.tdsFiling:
        return 'TDS Filing';
      case JobType.bulkExport:
        return 'Bulk Export';
      case JobType.bulkSigning:
        return 'Bulk Signing';
    }
  }
}

class _JobStatusChip extends StatelessWidget {
  const _JobStatusChip({required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _chipColor(status);
    final icon = _chipIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(JobStatus status) {
    switch (status) {
      case JobStatus.queued:
        return 'Queued';
      case JobStatus.running:
        return 'Running';
      case JobStatus.paused:
        return 'Paused';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  static Color _chipColor(JobStatus status) {
    switch (status) {
      case JobStatus.completed:
        return AppColors.success;
      case JobStatus.failed:
        return AppColors.error;
      case JobStatus.running:
        return AppColors.secondary;
      case JobStatus.queued:
        return AppColors.neutral400;
      case JobStatus.paused:
        return AppColors.accent;
      case JobStatus.cancelled:
        return AppColors.neutral400;
    }
  }

  static IconData _chipIcon(JobStatus status) {
    switch (status) {
      case JobStatus.completed:
        return Icons.check_circle_outline_rounded;
      case JobStatus.failed:
        return Icons.error_outline_rounded;
      case JobStatus.running:
        return Icons.sync_rounded;
      case JobStatus.queued:
        return Icons.schedule_rounded;
      case JobStatus.paused:
        return Icons.pause_circle_outline_rounded;
      case JobStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

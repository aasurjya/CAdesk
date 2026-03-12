import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/bulk_operations/data/providers/bulk_operations_providers.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/presentation/widgets/job_status_tile.dart';

/// Detail screen for a single filing batch.
class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batch = ref.watch(activeBatchProvider);
    final theme = Theme.of(context);

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Batch Detail')),
        body: const Center(child: Text('No batch selected')),
      );
    }

    final failedJobs = batch.jobs
        .where((j) => j.status == JobStatus.failed)
        .toList();
    final hasFailures = failedJobs.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              batch.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '${batch.type.label} \u2022 ${batch.financialYear}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProgressCard(
              completed: batch.completedCount,
              total: batch.jobs.length,
              progress: batch.progress,
              failed: batch.failedCount,
            ),
            const SizedBox(height: 16),
            if (hasFailures) ...[
              _ActionButtons(
                batchId: batch.batchId,
                onRetryAll: () {
                  ref
                      .read(batchListProvider.notifier)
                      .retryFailedJobs(batch.batchId);
                },
                onCancel: () {
                  ref
                      .read(batchListProvider.notifier)
                      .cancelBatch(batch.batchId);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
            _SectionHeader(title: 'Jobs', icon: Icons.list_alt_rounded),
            const SizedBox(height: 10),
            ...batch.jobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JobStatusTile(
                  job: job,
                  onRetry: () {
                    // Individual retry — update the single job
                    final updatedJobs = batch.jobs.map((j) {
                      if (j.jobId == job.jobId &&
                          j.status == JobStatus.failed) {
                        return j.copyWith(
                          status: JobStatus.retrying,
                          errorMessage: null,
                        );
                      }
                      return j;
                    }).toList();
                    ref
                        .read(batchListProvider.notifier)
                        .updateBatch(
                          batch.copyWith(jobs: List.unmodifiable(updatedJobs)),
                        );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress card
// ---------------------------------------------------------------------------

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
    required this.failed,
  });

  final int completed;
  final int total;
  final double progress;
  final int failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.neutral100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  failed > 0 ? AppColors.accent : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completed / $total completed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (failed > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$failed failed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.batchId,
    required this.onRetryAll,
    required this.onCancel,
  });

  final String batchId;
  final VoidCallback onRetryAll;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onRetryAll,
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Retry All Failed'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel Batch'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

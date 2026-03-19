import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';

// ---------------------------------------------------------------------------
// Step → UI mapping
// ---------------------------------------------------------------------------

extension _SubmissionStepUi on SubmissionStep {
  Color get color => switch (this) {
    SubmissionStep.pending => AppColors.neutral400,
    SubmissionStep.loggingIn ||
    SubmissionStep.filling ||
    SubmissionStep.otp ||
    SubmissionStep.reviewing ||
    SubmissionStep.submitting ||
    SubmissionStep.downloading => AppColors.secondary,
    SubmissionStep.done => AppColors.success,
    SubmissionStep.failed => AppColors.error,
  };

  IconData get icon => switch (this) {
    SubmissionStep.pending => Icons.schedule_rounded,
    SubmissionStep.loggingIn ||
    SubmissionStep.filling ||
    SubmissionStep.otp ||
    SubmissionStep.reviewing ||
    SubmissionStep.submitting ||
    SubmissionStep.downloading => Icons.sync_rounded,
    SubmissionStep.done => Icons.check_circle_rounded,
    SubmissionStep.failed => Icons.error_rounded,
  };
}

// ---------------------------------------------------------------------------
// Filter categories
// ---------------------------------------------------------------------------

enum _QueueFilter {
  pending('Pending', AppColors.neutral400),
  inProgress('In Progress', AppColors.secondary),
  done('Done', AppColors.success),
  failed('Failed', AppColors.error);

  const _QueueFilter(this.label, this.color);

  final String label;
  final Color color;

  bool matches(SubmissionJob job) => switch (this) {
    _QueueFilter.pending => job.currentStep == SubmissionStep.pending,
    _QueueFilter.inProgress => job.isInProgress,
    _QueueFilter.done => job.isCompleted,
    _QueueFilter.failed => job.isFailed,
  };
}

// ---------------------------------------------------------------------------
// Filter notifier
// ---------------------------------------------------------------------------

final _queueFilterProvider =
    NotifierProvider<_QueueFilterNotifier, _QueueFilter?>(
      _QueueFilterNotifier.new,
    );

class _QueueFilterNotifier extends Notifier<_QueueFilter?> {
  @override
  _QueueFilter? build() => null;

  void set(_QueueFilter? value) => state = value;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Displays the live queue of portal auto-submission jobs.
///
/// Watches [submissionJobsStreamProvider] for real-time data from the
/// [SubmissionRepository].  Supports filtering by status category and
/// retrying failed jobs via [SubmissionOrchestrator].
class AutosubmitQueueScreen extends ConsumerWidget {
  const AutosubmitQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(submissionJobsStreamProvider);
    final filter = ref.watch(_queueFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-Submit Queue',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Pending portal submissions',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(message: error.toString()),
        data: (allJobs) => _QueueBody(
          allJobs: allJobs,
          filter: filter,
          onFilterChanged: (f) {
            final current = ref.read(_queueFilterProvider);
            ref
                .read(_queueFilterProvider.notifier)
                .set(f == current ? null : f);
          },
          onRetry: (job) => _retryJob(ref, job),
          onTap: (job) => _handleTap(context, job),
        ),
      ),
    );
  }

  void _retryJob(WidgetRef ref, SubmissionJob job) {
    if (!job.canRetry) return;
    final orchestrator = ref.read(submissionOrchestratorProvider);
    orchestrator.updateStep(
      job.id,
      SubmissionStep.pending,
      message: 'Re-queued by user',
    );
  }

  void _handleTap(BuildContext context, SubmissionJob job) {
    if (job.currentStep != SubmissionStep.pending) return;
    context.push('/portal-autosubmit/review/${job.id}', extra: job);
  }
}

// ---------------------------------------------------------------------------
// Queue body (stats + filter + list)
// ---------------------------------------------------------------------------

class _QueueBody extends StatelessWidget {
  const _QueueBody({
    required this.allJobs,
    required this.filter,
    required this.onFilterChanged,
    required this.onRetry,
    required this.onTap,
  });

  final List<SubmissionJob> allJobs;
  final _QueueFilter? filter;
  final ValueChanged<_QueueFilter> onFilterChanged;
  final ValueChanged<SubmissionJob> onRetry;
  final ValueChanged<SubmissionJob> onTap;

  List<SubmissionJob> get _filteredJobs {
    if (filter == null) return allJobs;
    return allJobs.where(filter!.matches).toList();
  }

  int _countMatching(_QueueFilter f) => allJobs.where(f.matches).length;

  @override
  Widget build(BuildContext context) {
    final items = _filteredJobs;

    return Column(
      children: [
        // Stats row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _StatCard(
                label: 'Pending',
                value: '${_countMatching(_QueueFilter.pending)}',
                icon: Icons.schedule_rounded,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'In Progress',
                value: '${_countMatching(_QueueFilter.inProgress)}',
                icon: Icons.sync_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Done',
                value: '${_countMatching(_QueueFilter.done)}',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Failed',
                value: '${_countMatching(_QueueFilter.failed)}',
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
              ),
            ],
          ),
        ),

        // Filter chips
        _FilterBar(selected: filter, onSelected: onFilterChanged),

        // Queue list
        Expanded(
          child: items.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 80,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _QueueItemCard(
                    job: items[index],
                    onRetry: () => onRetry(items[index]),
                    onTap: () => onTap(items[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Queue item card
// ---------------------------------------------------------------------------

class _QueueItemCard extends StatelessWidget {
  const _QueueItemCard({
    required this.job,
    required this.onRetry,
    required this.onTap,
  });

  final SubmissionJob job;
  final VoidCallback onRetry;
  final VoidCallback onTap;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = job.currentStep;

    return GestureDetector(
      onTap: job.currentStep == SubmissionStep.pending ? onTap : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(step.icon, size: 20, color: step.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${job.portalType.label} / ${job.returnType}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: step.color,
                      ),
                    ),
                  ),
                ],
              ),
              if (job.errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          job.errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(job.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.replay_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Attempts: ${job.retryCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                  const Spacer(),
                  if (job.canRetry)
                    SizedBox(
                      height: 28,
                      child: OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Retry'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(fontSize: 11),
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
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
// Shared widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final _QueueFilter? selected;
  final ValueChanged<_QueueFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _QueueFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _QueueFilter.values[index];
          final isActive = filter == selected;

          return FilterChip(
            label: Text(filter.label),
            selected: isActive,
            onSelected: (_) => onSelected(filter),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : filter.color,
            ),
            selectedColor: filter.color,
            backgroundColor: filter.color.withValues(alpha: 0.08),
            side: BorderSide(color: filter.color.withValues(alpha: 0.3)),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
          const SizedBox(height: 12),
          Text(
            'No submissions match the filter',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load queue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.neutral900),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

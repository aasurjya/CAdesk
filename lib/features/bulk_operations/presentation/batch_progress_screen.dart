import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum ItemStatus { pending, inProgress, success, failed }

extension ItemStatusX on ItemStatus {
  String get label => switch (this) {
    ItemStatus.pending => 'Pending',
    ItemStatus.inProgress => 'In Progress',
    ItemStatus.success => 'Success',
    ItemStatus.failed => 'Failed',
  };

  Color get color => switch (this) {
    ItemStatus.pending => AppColors.neutral400,
    ItemStatus.inProgress => AppColors.secondary,
    ItemStatus.success => AppColors.success,
    ItemStatus.failed => AppColors.error,
  };

  IconData get icon => switch (this) {
    ItemStatus.pending => Icons.schedule_rounded,
    ItemStatus.inProgress => Icons.sync_rounded,
    ItemStatus.success => Icons.check_circle_rounded,
    ItemStatus.failed => Icons.cancel_rounded,
  };
}

class BatchItem {
  const BatchItem({
    required this.clientName,
    required this.pan,
    required this.returnType,
    required this.status,
    required this.progress,
    required this.errorMessage,
  });

  final String clientName;
  final String pan;
  final String returnType;
  final ItemStatus status;
  final double progress;
  final String? errorMessage;
}

class BatchProgress {
  const BatchProgress({
    required this.batchId,
    required this.batchName,
    required this.createdAt,
    required this.items,
    required this.estimatedCompletion,
  });

  final String batchId;
  final String batchName;
  final DateTime createdAt;
  final List<BatchItem> items;
  final Duration estimatedCompletion;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _batchProgressProvider = Provider.family<BatchProgress, String>((
  ref,
  batchId,
) {
  return BatchProgress(
    batchId: batchId,
    batchName: 'ITR Batch - March 2026',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    estimatedCompletion: const Duration(minutes: 28),
    items: const [
      BatchItem(
        clientName: 'Rajesh Kumar',
        pan: 'ABCPK1234D',
        returnType: 'ITR-1',
        status: ItemStatus.success,
        progress: 1.0,
        errorMessage: null,
      ),
      BatchItem(
        clientName: 'Priya Sharma',
        pan: 'BPXPS5678G',
        returnType: 'ITR-1',
        status: ItemStatus.success,
        progress: 1.0,
        errorMessage: null,
      ),
      BatchItem(
        clientName: 'Mohan Gupta',
        pan: 'CLQMG9012H',
        returnType: 'ITR-2',
        status: ItemStatus.inProgress,
        progress: 0.65,
        errorMessage: null,
      ),
      BatchItem(
        clientName: 'Sunita Devi',
        pan: 'DRVSD3456A',
        returnType: 'ITR-1',
        status: ItemStatus.failed,
        progress: 0.40,
        errorMessage: 'PAN mismatch with Form 26AS',
      ),
      BatchItem(
        clientName: 'Anil Joshi',
        pan: 'EWFAJ7890B',
        returnType: 'ITR-4',
        status: ItemStatus.pending,
        progress: 0.0,
        errorMessage: null,
      ),
      BatchItem(
        clientName: 'Kavita Rao',
        pan: 'FXHKR1234C',
        returnType: 'ITR-1',
        status: ItemStatus.pending,
        progress: 0.0,
        errorMessage: null,
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BatchProgressScreen extends ConsumerWidget {
  const BatchProgressScreen({super.key, required this.batchId});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batch = ref.watch(_batchProgressProvider(batchId));
    final theme = Theme.of(context);

    final successCount = batch.items
        .where((i) => i.status == ItemStatus.success)
        .length;
    final failedCount = batch.items
        .where((i) => i.status == ItemStatus.failed)
        .length;
    final pendingCount = batch.items
        .where((i) => i.status == ItemStatus.pending)
        .length;
    final inProgressCount = batch.items
        .where((i) => i.status == ItemStatus.inProgress)
        .length;

    final overallProgress = batch.items.isEmpty
        ? 0.0
        : batch.items.map((i) => i.progress).reduce((a, b) => a + b) /
              batch.items.length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              batch.batchName,
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
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.pause_rounded, size: 18),
            label: const Text('Pause'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats
          Row(
            children: [
              _StatCard(
                label: 'Success',
                value: '$successCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'In Progress',
                value: '$inProgressCount',
                icon: Icons.sync_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Failed',
                value: '$failedCount',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Pending',
                value: '$pendingCount',
                icon: Icons.schedule_rounded,
                color: AppColors.neutral400,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall progress
          _OverallProgressCard(
            progress: overallProgress,
            estimatedMinutes: batch.estimatedCompletion.inMinutes,
            totalItems: batch.items.length,
            completedItems: successCount + failedCount,
          ),
          const SizedBox(height: 16),

          // Item list
          _SectionHeader(
            title: 'Items (${batch.items.length})',
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(height: 10),
          ...batch.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BatchItemCard(item: item),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overall progress card
// ---------------------------------------------------------------------------

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({
    required this.progress,
    required this.estimatedMinutes,
    required this.totalItems,
    required this.completedItems,
  });

  final double progress;
  final int estimatedMinutes;
  final int totalItems;
  final int completedItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.neutral200,
                color: AppColors.primary,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedItems of $totalItems completed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral400,
                  ),
                ),
                Text(
                  'ETA: ${estimatedMinutes}m',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Batch item card
// ---------------------------------------------------------------------------

class _BatchItemCard extends StatelessWidget {
  const _BatchItemCard({required this.item});

  final BatchItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: item.status.color, width: 3)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.status.icon, size: 20, color: item.status.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.clientName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${item.pan} - ${item.returnType}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(item.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: item.status.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                backgroundColor: AppColors.neutral200,
                color: item.status.color,
                minHeight: 4,
              ),
            ),
            if (item.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.errorMessage!,
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
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
// Shared
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

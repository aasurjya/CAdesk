import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _StageStatus { completed, running, pending, error }

extension _StageStatusExt on _StageStatus {
  String get label => switch (this) {
    _StageStatus.completed => 'Completed',
    _StageStatus.running => 'Running',
    _StageStatus.pending => 'Pending',
    _StageStatus.error => 'Error',
  };
  Color get color => switch (this) {
    _StageStatus.completed => AppColors.success,
    _StageStatus.running => AppColors.primary,
    _StageStatus.pending => AppColors.neutral400,
    _StageStatus.error => AppColors.error,
  };
  IconData get icon => switch (this) {
    _StageStatus.completed => Icons.check_circle_rounded,
    _StageStatus.running => Icons.sync_rounded,
    _StageStatus.pending => Icons.radio_button_unchecked,
    _StageStatus.error => Icons.error_rounded,
  };
}

class _PipelineStage {
  const _PipelineStage({
    required this.name,
    required this.type,
    required this.status,
    required this.recordsIn,
    required this.recordsOut,
    required this.errorMessage,
  });

  final String name;
  final String type; // Source, Transform, Load
  final _StageStatus status;
  final int recordsIn;
  final int recordsOut;
  final String? errorMessage;
}

class _ErrorLog {
  const _ErrorLog({
    required this.stage,
    required this.message,
    required this.timestamp,
  });

  final String stage;
  final String message;
  final String timestamp;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockStages = <_PipelineStage>[
  const _PipelineStage(
    name: 'ITD 26AS Fetch',
    type: 'Source',
    status: _StageStatus.completed,
    recordsIn: 0,
    recordsOut: 245,
    errorMessage: null,
  ),
  const _PipelineStage(
    name: 'PAN Dedup & Normalize',
    type: 'Transform',
    status: _StageStatus.completed,
    recordsIn: 245,
    recordsOut: 238,
    errorMessage: null,
  ),
  const _PipelineStage(
    name: 'TDS Reconciliation',
    type: 'Transform',
    status: _StageStatus.running,
    recordsIn: 238,
    recordsOut: 0,
    errorMessage: null,
  ),
  const _PipelineStage(
    name: 'Client DB Upsert',
    type: 'Load',
    status: _StageStatus.pending,
    recordsIn: 0,
    recordsOut: 0,
    errorMessage: null,
  ),
];

final _mockErrors = <_ErrorLog>[
  const _ErrorLog(
    stage: 'ITD 26AS Fetch',
    message: 'Timeout on PAN GHIJK5678L - retried successfully',
    timestamp: '08:22',
  ),
  const _ErrorLog(
    stage: 'PAN Dedup & Normalize',
    message: '7 records had invalid PAN format, skipped',
    timestamp: '08:25',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Data pipeline detail screen showing stages, status, and error logs.
class PipelineDetailScreen extends ConsumerWidget {
  const PipelineDetailScreen({super.key, required this.pipelineId});

  final String pipelineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final completedCount = _mockStages
        .where((s) => s.status == _StageStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pipeline #$pipelineId',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '26AS TDS Reconciliation Pipeline',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Re-run pipeline',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Re-running pipeline...')),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(
            children: [
              SummaryCard(
                label: 'Stages',
                value: '${_mockStages.length}',
                icon: Icons.account_tree_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Completed',
                value: '$completedCount',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Errors',
                value: '${_mockErrors.length}',
                icon: Icons.warning_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Schedule info
          const _ScheduleCard(),
          const SizedBox(height: 20),

          // Pipeline visualization
          const SectionHeader(
            title: 'Pipeline Stages',
            icon: Icons.account_tree_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockStages.asMap().entries.map(
            (entry) => _StageTile(
              stage: entry.value,
              isLast: entry.key == _mockStages.length - 1,
            ),
          ),
          const SizedBox(height: 24),

          // Error logs
          const SectionHeader(
            title: 'Error Logs',
            icon: Icons.bug_report_rounded,
          ),
          const SizedBox(height: 10),
          if (_mockErrors.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: EmptyState(
                message: 'No errors',
                icon: Icons.check_circle_outline_rounded,
              ),
            )
          else
            ..._mockErrors.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ErrorLogTile(error: e),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule card
// ---------------------------------------------------------------------------

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily at 08:00 AM',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Next run: 18 Mar 2026, 08:00',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Edit Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stage tile with flow visualization
// ---------------------------------------------------------------------------

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage, required this.isLast});

  final _PipelineStage stage;
  final bool isLast;

  Color get _typeColor => switch (stage.type) {
    'Source' => AppColors.secondary,
    'Transform' => AppColors.primary,
    'Load' => AppColors.accent,
    _ => AppColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flow indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(stage.status.icon, color: stage.status.color, size: 22),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: stage.status.color.withAlpha(60),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(label: stage.type, color: _typeColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stage.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: stage.status.label,
                          color: stage.status.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _FlowMetric(label: 'In', value: '${stage.recordsIn}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.neutral400,
                          ),
                        ),
                        _FlowMetric(label: 'Out', value: '${stage.recordsOut}'),
                        if (stage.errorMessage != null) ...[
                          const Spacer(),
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              stage.errorMessage!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.error,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowMetric extends StatelessWidget {
  const _FlowMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error log tile
// ---------------------------------------------------------------------------

class _ErrorLogTile extends StatelessWidget {
  const _ErrorLogTile({required this.error});

  final _ErrorLog error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: AppColors.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error.stage,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    error.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              error.timestamp,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum _StepStatus { completed, running, pending, failed }

class _WorkflowStep {
  const _WorkflowStep({
    required this.title,
    required this.description,
    required this.status,
    required this.confidence,
    required this.duration,
    this.canOverride = false,
  });

  final String title;
  final String description;
  final _StepStatus status;
  final double confidence;
  final String duration;
  final bool canOverride;
}

class _ExecutionRecord {
  const _ExecutionRecord({
    required this.id,
    required this.date,
    required this.duration,
    required this.status,
    required this.itemsProcessed,
  });

  final String id;
  final String date;
  final String duration;
  final String status;
  final int itemsProcessed;
}

final _mockSteps = <_WorkflowStep>[
  const _WorkflowStep(
    title: 'Auto-Categorize Documents',
    description:
        'Classify uploaded PDFs into ITR, GST, TDS, and misc categories',
    status: _StepStatus.completed,
    confidence: 0.96,
    duration: '12s',
  ),
  const _WorkflowStep(
    title: 'Extract Key Data',
    description:
        'Pull PAN, amounts, dates, and assessment year from each document',
    status: _StepStatus.completed,
    confidence: 0.91,
    duration: '34s',
    canOverride: true,
  ),
  const _WorkflowStep(
    title: 'Cross-Reconcile',
    description: 'Match extracted values against 26AS / AIS data',
    status: _StepStatus.running,
    confidence: 0.0,
    duration: '~45s',
  ),
  const _WorkflowStep(
    title: 'Flag Anomalies',
    description: 'Detect mismatches, missing deductions, and duplicate entries',
    status: _StepStatus.pending,
    confidence: 0.0,
    duration: '~20s',
    canOverride: true,
  ),
];

final _mockHistory = <_ExecutionRecord>[
  const _ExecutionRecord(
    id: 'WF-1041',
    date: '16 Mar 2026, 14:32',
    duration: '1m 48s',
    status: 'Completed',
    itemsProcessed: 24,
  ),
  const _ExecutionRecord(
    id: 'WF-1040',
    date: '15 Mar 2026, 09:15',
    duration: '2m 03s',
    status: 'Completed',
    itemsProcessed: 31,
  ),
  const _ExecutionRecord(
    id: 'WF-1039',
    date: '14 Mar 2026, 11:50',
    duration: '0m 52s',
    status: 'Failed',
    itemsProcessed: 8,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// AI-powered workflow automation detail screen.
class AiWorkflowScreen extends ConsumerWidget {
  const AiWorkflowScreen({super.key, required this.workflowId});

  final String workflowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workflow #$workflowId',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Auto-Categorize & Reconcile',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Run'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Summary row --
          Row(
            children: [
              SummaryCard(
                label: 'Steps',
                value: '${_mockSteps.length}',
                icon: Icons.checklist_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Completed',
                value:
                    '${_mockSteps.where((s) => s.status == _StepStatus.completed).length}',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Avg Confidence',
                value: _avgConfidenceLabel(),
                icon: Icons.insights_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // -- Steps --
          const SectionHeader(
            title: 'Execution Steps',
            icon: Icons.account_tree_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockSteps.asMap().entries.map(
            (entry) => _StepTile(
              index: entry.key,
              step: entry.value,
              isLast: entry.key == _mockSteps.length - 1,
            ),
          ),
          const SizedBox(height: 24),

          // -- History --
          const SectionHeader(
            title: 'Execution History',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockHistory.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryTile(record: record),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _avgConfidenceLabel() {
    final scored = _mockSteps.where((s) => s.confidence > 0).toList();
    if (scored.isEmpty) return '--';
    final avg =
        scored.fold<double>(0, (sum, s) => sum + s.confidence) / scored.length;
    return '${(avg * 100).round()}%';
  }
}

// ---------------------------------------------------------------------------
// Step tile with timeline connector
// ---------------------------------------------------------------------------

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.step,
    required this.isLast,
  });

  final int index;
  final _WorkflowStep step;
  final bool isLast;

  Color get _statusColor => switch (step.status) {
    _StepStatus.completed => AppColors.success,
    _StepStatus.running => AppColors.primary,
    _StepStatus.pending => AppColors.neutral300,
    _StepStatus.failed => AppColors.error,
  };

  IconData get _statusIcon => switch (step.status) {
    _StepStatus.completed => Icons.check_circle_rounded,
    _StepStatus.running => Icons.sync_rounded,
    _StepStatus.pending => Icons.radio_button_unchecked,
    _StepStatus.failed => Icons.error_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(_statusIcon, color: _statusColor, size: 22),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _statusColor.withAlpha(60),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Content
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
                        Expanded(
                          child: Text(
                            'Step ${index + 1}: ${step.title}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: step.status.name,
                          color: _statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaPill(
                          icon: Icons.timer_outlined,
                          label: step.duration,
                        ),
                        const SizedBox(width: 8),
                        if (step.confidence > 0)
                          _MetaPill(
                            icon: Icons.psychology_rounded,
                            label:
                                'Confidence ${(step.confidence * 100).round()}%',
                          ),
                        const Spacer(),
                        if (step.canOverride)
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_rounded, size: 14),
                            label: const Text('Override'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              textStyle: const TextStyle(fontSize: 12),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
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

// ---------------------------------------------------------------------------
// History tile
// ---------------------------------------------------------------------------

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final _ExecutionRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuccess = record.status == 'Completed';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? AppColors.success : AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.id,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.date}  •  ${record.duration}  •  ${record.itemsProcessed} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: record.status,
              color: isSuccess ? AppColors.success : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared meta pill
// ---------------------------------------------------------------------------

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.neutral600),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

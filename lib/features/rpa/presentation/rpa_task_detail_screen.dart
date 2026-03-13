import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/presentation/widgets/portal_badge.dart';

/// Detailed view for a single [AutomationTask].
///
/// Receives the task via GoRouter [extra].
class RpaTaskDetailScreen extends ConsumerWidget {
  const RpaTaskDetailScreen({required this.task, super.key});

  final AutomationTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (statusLabel, statusColor) = _statusInfo(task.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(
            task: task,
            statusLabel: statusLabel,
            statusColor: statusColor,
          ),
          const SizedBox(height: 16),
          _StepperSection(task: task),
          if (_hasExtractedData(task)) ...[
            const SizedBox(height: 16),
            _ExtractedDataSection(task: task),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static bool _hasExtractedData(AutomationTask task) {
    if (task.status != AutomationTaskStatus.completed) return false;
    final raw = task.resultData;
    if (raw == null || raw.isEmpty) return false;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final extracted = decoded['extractedData'];
      if (extracted is Map) return extracted.isNotEmpty;
    } catch (_) {}
    return false;
  }

  static (String, Color) _statusInfo(AutomationTaskStatus status) {
    switch (status) {
      case AutomationTaskStatus.completed:
        return ('Completed', const Color(0xFF2E7D32));
      case AutomationTaskStatus.running:
        return ('Running', const Color(0xFF1565C0));
      case AutomationTaskStatus.queued:
        return ('Queued', const Color(0xFF795548));
      case AutomationTaskStatus.failed:
        return ('Failed', const Color(0xFFC62828));
      case AutomationTaskStatus.retrying:
        return ('Retrying', const Color(0xFFE65100));
      case AutomationTaskStatus.cancelled:
        return ('Cancelled', const Color(0xFF546E7A));
    }
  }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.task,
    required this.statusLabel,
    required this.statusColor,
  });

  final AutomationTask task;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                PortalBadge(portal: task.portal),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (task.parameters.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              ...task.parameters.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '${e.key}: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(e.value, style: theme.textTheme.bodySmall),
                    ],
                  ),
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
// Stepper section (uses mock steps based on task type)
// ---------------------------------------------------------------------------

class _StepperSection extends StatelessWidget {
  const _StepperSection({required this.task});

  final AutomationTask task;

  static List<_MockStep> _stepsForTask(AutomationTask task) {
    final isCompleted = task.status == AutomationTaskStatus.completed;
    final isRunning = task.status == AutomationTaskStatus.running;

    final baseSteps = _baseStepNames(task.taskType);
    return baseSteps.asMap().entries.map((entry) {
      final idx = entry.key;
      final name = entry.value;
      late _MockStepState state;
      if (isCompleted) {
        state = _MockStepState.done;
      } else if (isRunning) {
        if (idx < 3) {
          state = _MockStepState.done;
        } else if (idx == 3) {
          state = _MockStepState.active;
        } else {
          state = _MockStepState.pending;
        }
      } else {
        state = _MockStepState.pending;
      }
      return _MockStep(name: name, state: state);
    }).toList();
  }

  static List<String> _baseStepNames(AutomationTaskType type) {
    switch (type) {
      case AutomationTaskType.tracesDownload:
        return [
          'Navigate to TRACES',
          'Login with credentials',
          'Open Form 16 request',
          'Select FY & PANs',
          'Submit request',
          'Extract request ID',
        ];
      case AutomationTaskType.challanFetch:
        return [
          'Navigate to TRACES',
          'Login',
          'Open Challan Status',
          'Enter BSR & date',
          'Search',
          'Extract status',
        ];
      case AutomationTaskType.gstFilingStatus:
        return [
          'Navigate to GST portal',
          'Login',
          'Open Returns dashboard',
          'Select period',
          'Extract GSTR-1 status',
          'Extract GSTR-3B status',
        ];
      case AutomationTaskType.mcaPrefill:
        return [
          'Navigate to MCA',
          'Login',
          'Open form',
          'Enter CIN',
          'Fill fields',
          'Save draft',
        ];
      case AutomationTaskType.itrStatus:
        return [
          'Navigate to ITD',
          'Login',
          'Open returns',
          'Select AY',
          'Extract status',
        ];
      case AutomationTaskType.bulkPanVerify:
        return [
          'Navigate to ITD',
          'Login',
          'Upload PAN list',
          'Run verification',
          'Download report',
        ];
      case AutomationTaskType.aisDownload:
        return [
          'Navigate to ITD',
          'Login',
          'Open AIS',
          'Download PDF',
          'Confirm download',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _stepsForTask(task);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Execution Steps',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map(
              (entry) => _StepRow(
                step: entry.value,
                isLast: entry.key == steps.length - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MockStepState { done, active, pending }

class _MockStep {
  const _MockStep({required this.name, required this.state});

  final String name;
  final _MockStepState state;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final _MockStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _StepIcon(state: step.state),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Text(
                step.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: step.state == _MockStepState.pending
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                  fontWeight: step.state == _MockStepState.active
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.state});

  final _MockStepState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (state) {
      case _MockStepState.done:
        return CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF2E7D32),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
        );
      case _MockStepState.active:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.colorScheme.primary,
          ),
        );
      case _MockStepState.pending:
        return CircleAvatar(
          radius: 12,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.circle_outlined,
            color: theme.colorScheme.onSurfaceVariant,
            size: 14,
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Extracted data section
// ---------------------------------------------------------------------------

class _ExtractedDataSection extends StatelessWidget {
  const _ExtractedDataSection({required this.task});

  final AutomationTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _extractedEntries(task.resultData);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extracted Data',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map(
              (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  e.key,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  e.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<MapEntry<String, String>> _extractedEntries(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final extracted = decoded['extractedData'];
      if (extracted is Map) {
        return extracted.entries
            .map((e) => MapEntry(e.key.toString(), e.value.toString()))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}

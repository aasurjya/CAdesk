import 'package:flutter/material.dart';

import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/presentation/widgets/portal_badge.dart';

/// Card displaying a single [AutomationTask] with status chip, progress bar,
/// and last-run time.
class AutomationTaskCard extends StatelessWidget {
  const AutomationTaskCard({required this.task, this.onTap, super.key});

  final AutomationTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = _statusInfo(task.status);
    final isRunning = task.status == AutomationTaskStatus.running;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PortalBadge(portal: task.portal),
                  const Spacer(),
                  if (task.completedAt != null)
                    Text(
                      _relativeTime(task.completedAt!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else if (task.startedAt != null)
                    Text(
                      'Started ${_relativeTime(task.startedAt!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              if (isRunning) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

/// Draggable kanban card displaying task summary.
///
/// Long-press to drag between columns, tap to open the detail sheet.
class KanbanCard extends StatelessWidget {
  const KanbanCard({super.key, required this.card, required this.onTap});

  final KanbanCardData card;
  final VoidCallback onTap;

  // ---------------------------------------------------------------------------
  // Due-date urgency
  // ---------------------------------------------------------------------------

  Color _dueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    if (diff.isNegative) return AppColors.error;
    if (diff.inDays <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String _dueDateLabel(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    if (diff.isNegative) {
      return 'Overdue ${diff.inDays.abs()}d';
    }
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    return '${diff.inDays}d left';
  }

  // ---------------------------------------------------------------------------
  // Initials avatar
  // ---------------------------------------------------------------------------

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ---------------------------------------------------------------------------
  // Subtask progress
  // ---------------------------------------------------------------------------

  int get _completedSubtasks =>
      card.subtasks.where((s) => s.isCompleted).length;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<KanbanCardData>(
      data: card,
      feedback: _DragFeedback(card: card),
      childWhenDragging: _DragPlaceholder(),
      child: GestureDetector(
        onTap: onTap,
        child: _CardBody(
          card: card,
          dueDateColor: _dueDateColor(card.dueDate),
          dueDateLabel: _dueDateLabel(card.dueDate),
          initials: _initials(card.assignee),
          completedSubtasks: _completedSubtasks,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card body — the resting visual
// ---------------------------------------------------------------------------

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.card,
    required this.dueDateColor,
    required this.dueDateLabel,
    required this.initials,
    required this.completedSubtasks,
  });

  final KanbanCardData card;
  final Color dueDateColor;
  final String dueDateLabel;
  final String initials;
  final int completedSubtasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: card.priority.color.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority indicator + title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: card.priority.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Client name
            Row(
              children: [
                const Icon(
                  Icons.business_rounded,
                  size: 14,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    card.clientName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tags
            if (card.tags.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: card.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Subtask progress
            if (card.subtasks.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.checklist_rounded,
                    size: 14,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$completedSubtasks/${card.subtasks.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: card.subtasks.isNotEmpty
                            ? completedSubtasks / card.subtasks.length
                            : 0,
                        minHeight: 3,
                        backgroundColor: AppColors.neutral100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Footer: due date + assignee avatar
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: dueDateColor),
                const SizedBox(width: 4),
                Text(
                  dueDateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dueDateColor,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withAlpha(25),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
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
// Drag feedback — slightly scaled card
// ---------------------------------------------------------------------------

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.card});

  final KanbanCardData card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: card.priority.color.withAlpha(80)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: card.priority.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              card.clientName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder shown when card is being dragged
// ---------------------------------------------------------------------------

class _DragPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.neutral300,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}

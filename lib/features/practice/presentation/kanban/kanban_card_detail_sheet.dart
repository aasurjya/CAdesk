import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

/// Bottom sheet for viewing and editing kanban card details.
///
/// Shows all card fields with inline editing, subtask checklist,
/// and save/delete actions.
void showKanbanCardDetailSheet(
  BuildContext context,
  WidgetRef ref,
  KanbanCardData card,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _KanbanCardDetailSheet(card: card),
  );
}

class _KanbanCardDetailSheet extends ConsumerStatefulWidget {
  const _KanbanCardDetailSheet({required this.card});

  final KanbanCardData card;

  @override
  ConsumerState<_KanbanCardDetailSheet> createState() =>
      _KanbanCardDetailSheetState();
}

class _KanbanCardDetailSheetState
    extends ConsumerState<_KanbanCardDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedAssignee;
  late KanbanPriority _selectedPriority;
  late DateTime _selectedDueDate;
  late String _selectedColumnId;
  late List<KanbanSubtask> _subtasks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descriptionController = TextEditingController(
      text: widget.card.description,
    );
    _selectedAssignee = widget.card.assignee;
    _selectedPriority = widget.card.priority;
    _selectedDueDate = widget.card.dueDate;
    _selectedColumnId = widget.card.columnId;
    _subtasks = List.of(widget.card.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.card.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      assignee: _selectedAssignee,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      columnId: _selectedColumnId,
      subtasks: List.unmodifiable(_subtasks),
    );
    ref.read(kanbanCardsProvider.notifier).updateCard(updated);
    Navigator.of(context).pop();
  }

  void _delete() {
    ref.read(kanbanCardsProvider.notifier).deleteCard(widget.card.id);
    Navigator.of(context).pop();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks = [
        for (int i = 0; i < _subtasks.length; i++)
          if (i == index)
            _subtasks[i].copyWith(isCompleted: !_subtasks[i].isCompleted)
          else
            _subtasks[i],
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = ref.watch(kanbanColumnsProvider);
    final assignees = ref.watch(kanbanAssigneesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              TextField(
                controller: _titleController,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
                decoration: const InputDecoration(
                  hintText: 'Card title',
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),

              // Description
              TextField(
                controller: _descriptionController,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add description...',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Assignee selector
              _DetailRow(
                icon: Icons.person_rounded,
                label: 'Assignee',
                child: DropdownButton<String>(
                  value: _selectedAssignee,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral900,
                  ),
                  items: assignees.map((name) {
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAssignee = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Priority selector
              _DetailRow(
                icon: Icons.flag_rounded,
                label: 'Priority',
                child: DropdownButton<KanbanPriority>(
                  value: _selectedPriority,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: KanbanPriority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: p.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(p.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Due date picker
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Due Date',
                child: InkWell(
                  onTap: _pickDueDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _formatDate(_selectedDueDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status / column selector
              _DetailRow(
                icon: Icons.view_column_rounded,
                label: 'Status',
                child: DropdownButton<String>(
                  value: _selectedColumnId,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: columns.map((col) {
                    return DropdownMenuItem(
                      value: col.id,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: col.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(col.title),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedColumnId = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Time logged
              _DetailRow(
                icon: Icons.timer_rounded,
                label: 'Time Logged',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${widget.card.hoursLogged.toStringAsFixed(1)} hrs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Client
              _DetailRow(
                icon: Icons.business_rounded,
                label: 'Client',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.card.clientName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Subtasks checklist
              if (_subtasks.isNotEmpty) ...[
                Text(
                  'Subtasks',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 8),
                ..._subtasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subtask = entry.value;
                  return CheckboxListTile(
                    value: subtask.isCompleted,
                    onChanged: (_) => _toggleSubtask(index),
                    title: Text(
                      subtask.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: subtask.isCompleted
                            ? AppColors.neutral400
                            : AppColors.neutral900,
                        decoration: subtask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Detail row — icon + label + value widget
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.neutral400),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

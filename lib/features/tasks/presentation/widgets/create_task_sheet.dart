import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tasks/data/providers/task_providers.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

/// Bottom sheet form for creating a new task.
///
/// Shows a draggable scrollable sheet with fields for title, description,
/// client name, task type, priority, assigned to, due date, and tags.
/// Validates that title and due date are provided before submission.
class CreateTaskSheet extends ConsumerStatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskType _selectedTaskType = TaskType.other;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    _assignedToController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  List<String> _parseTags(String input) {
    if (input.trim().isEmpty) return const [];
    return input
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a due date')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clientId: '',
        clientName: _clientNameController.text.trim().isEmpty
            ? 'Unassigned'
            : _clientNameController.text.trim(),
        taskType: _selectedTaskType,
        priority: _selectedPriority,
        status: TaskStatus.todo,
        assignedTo: _assignedToController.text.trim().isEmpty
            ? 'Unassigned'
            : _assignedToController.text.trim(),
        assignedBy: 'Current User',
        dueDate: _selectedDueDate!,
        createdAt: DateTime.now(),
        tags: _parseTags(_tagsController.text),
      );

      await ref.read(allTasksProvider.notifier).addTask(newTask);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${newTask.title}" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Text(
                  'Create New Task',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter task title',
                    prefixIcon: Icon(Icons.title_rounded),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task description',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Client Name field
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    hintText: 'Enter client name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                // Task Type dropdown
                DropdownButtonFormField<TaskType>(
                  initialValue: _selectedTaskType,
                  decoration: const InputDecoration(
                    labelText: 'Task Type',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: TaskType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTaskType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Priority dropdown
                DropdownButtonFormField<TaskPriority>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              Icon(
                                priority.icon,
                                size: 16,
                                color: priority.color,
                              ),
                              const SizedBox(width: 8),
                              Text(priority.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Assigned To field
                TextFormField(
                  controller: _assignedToController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned To',
                    hintText: 'Enter assignee name',
                    prefixIcon: Icon(Icons.assignment_ind_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                // Due Date picker
                InkWell(
                  onTap: _pickDueDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date *',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: _selectedDueDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                setState(() {
                                  _selectedDueDate = null;
                                });
                              },
                            )
                          : null,
                      errorText: null,
                    ),
                    child: Text(
                      _selectedDueDate != null
                          ? dateFormat.format(_selectedDueDate!)
                          : 'Select due date',
                      style: TextStyle(
                        color: _selectedDueDate != null
                            ? theme.textTheme.bodyLarge?.color
                            : AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tags field
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Comma-separated (e.g. urgent, Q4)',
                    prefixIcon: Icon(Icons.label_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_task_rounded),
                    label: Text(_isSubmitting ? 'Creating...' : 'Create Task'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

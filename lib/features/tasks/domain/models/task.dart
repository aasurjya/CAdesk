import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

/// The type of work a task represents.
enum TaskType {
  itrFiling('ITR Filing'),
  gstReturn('GST Return'),
  tdsReturn('TDS Return'),
  audit('Audit'),
  rocFiling('ROC Filing'),
  other('Other');

  const TaskType(this.label);

  final String label;
}

/// Immutable model representing a task in the CA practice workflow.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    required this.clientName,
    required this.taskType,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.assignedBy,
    required this.dueDate,
    required this.createdAt,
    this.completedDate,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String description;
  final String clientId;
  final String clientName;
  final TaskType taskType;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedTo;
  final String assignedBy;
  final DateTime dueDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final List<String> tags;

  /// Returns the initials of the assigned person (first letter of up to two words).
  String get assigneeInitials {
    final parts = assignedTo.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  /// True when the task is past due and not yet completed.
  bool get isOverdue {
    if (status == TaskStatus.completed) return false;
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.isBefore(todayMidnight);
  }

  /// Number of days remaining until the due date (negative if overdue).
  int get daysRemaining {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? clientId,
    String? clientName,
    TaskType? taskType,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    String? assignedBy,
    DateTime? dueDate,
    DateTime? completedDate,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

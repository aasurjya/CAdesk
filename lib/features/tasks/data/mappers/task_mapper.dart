import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

class TaskMapper {
  const TaskMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → Task domain model
  // ---------------------------------------------------------------------------
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      taskType: _safeTaskType(json['task_type'] as String? ?? 'other'),
      priority: _safeTaskPriority(json['priority'] as String? ?? 'medium'),
      status: _safeTaskStatus(json['status'] as String? ?? 'todo'),
      assignedTo: json['assigned_to'] as String? ?? '',
      assignedBy: json['assigned_by'] as String? ?? '',
      dueDate: DateTime.parse(json['due_date'] as String),
      completedDate: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      tags: _parseTags(json['tags']),
    );
  }

  // ---------------------------------------------------------------------------
  // Task domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'client_id': task.clientId,
      'client_name': task.clientName,
      'task_type': task.taskType.name,
      'priority': task.priority.name,
      'status': task.status.name,
      'assigned_to': task.assignedTo,
      'assigned_by': task.assignedBy,
      'due_date': task.dueDate.toIso8601String(),
      'completed_at': task.completedDate?.toIso8601String(),
      'created_at': task.createdAt.toIso8601String(),
      'tags': task.tags,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift TaskRow → Task domain model
  // ---------------------------------------------------------------------------
  static Task fromRow(TaskRow row) {
    return Task(
      id: row.id,
      title: row.title,
      description: row.description,
      clientId: row.clientId,
      clientName: row.clientName,
      taskType: _safeTaskType(row.taskType),
      priority: _safeTaskPriority(row.priority),
      status: _safeTaskStatus(row.status),
      assignedTo: row.assignedTo,
      assignedBy: row.assignedBy,
      dueDate: DateTime.parse(row.dueDate),
      completedDate: row.completedDate != null
          ? DateTime.tryParse(row.completedDate!)
          : null,
      createdAt: row.createdAt,
      tags: _parseTagsFromJson(row.tags),
    );
  }

  // ---------------------------------------------------------------------------
  // Task domain model → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------
  static TasksTableCompanion toCompanion(Task task, {String firmId = ''}) {
    return TasksTableCompanion(
      id: Value(task.id),
      firmId: Value(firmId),
      title: Value(task.title),
      description: Value(task.description),
      clientId: Value(task.clientId),
      clientName: Value(task.clientName),
      taskType: Value(task.taskType.name),
      priority: Value(task.priority.name),
      status: Value(task.status.name),
      assignedTo: Value(task.assignedTo),
      assignedBy: Value(task.assignedBy),
      dueDate: Value(task.dueDate.toIso8601String()),
      completedDate: Value(task.completedDate?.toIso8601String()),
      createdAt: Value(task.createdAt),
      tags: Value(jsonEncode(task.tags)),
      isDirty: const Value(true),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static List<String> _parseTags(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.whereType<String>().toList();
    }
    if (raw is String) {
      return _parseTagsFromJson(raw);
    }
    return const [];
  }

  static List<String> _parseTagsFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }

  static TaskType _safeTaskType(String name) {
    try {
      return TaskType.values.byName(name);
    } catch (_) {
      return TaskType.other;
    }
  }

  static TaskPriority _safeTaskPriority(String name) {
    try {
      return TaskPriority.values.byName(name);
    } catch (_) {
      return TaskPriority.medium;
    }
  }

  static TaskStatus _safeTaskStatus(String name) {
    try {
      return TaskStatus.values.byName(name);
    } catch (_) {
      return TaskStatus.todo;
    }
  }
}

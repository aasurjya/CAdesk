import 'dart:async';

import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';
import 'package:ca_app/features/tasks/domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  static final _now = DateTime.now();

  static final List<Task> _seedTasks = [
    Task(
      id: 'mock-task-001',
      title: 'File ITR-4 for Suresh Agarwal',
      description:
          'Presumptive taxation under 44AD. Turnover below 2 Cr. Documents received.',
      clientId: 'mock-client-001',
      clientName: 'Suresh Agarwal',
      taskType: TaskType.itrFiling,
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      assignedTo: 'Amit Sharma',
      assignedBy: 'CA Vikram Mehta',
      dueDate: DateTime(_now.year, _now.month, _now.day + 7),
      createdAt: DateTime(_now.year, _now.month, _now.day - 12),
      tags: ['AY 2026-27', '44AD', 'Presumptive'],
    ),
    Task(
      id: 'mock-task-002',
      title: 'GST-3B March 2026 for Kapoor Traders',
      description:
          'Monthly GST-3B filing. ITC reconciliation with GSTR-2B pending. '
          'Input credits of approx 45K to be verified.',
      clientId: 'mock-client-002',
      clientName: 'Kapoor Traders',
      taskType: TaskType.gstReturn,
      priority: TaskPriority.urgent,
      status: TaskStatus.todo,
      assignedTo: 'Priya Patel',
      assignedBy: 'CA Vikram Mehta',
      dueDate: DateTime(_now.year, _now.month, _now.day + 3),
      createdAt: DateTime(_now.year, _now.month, _now.day - 4),
      tags: ['GST-3B', 'Monthly', 'ITC'],
    ),
    Task(
      id: 'mock-task-003',
      title: 'TDS Return Q4 FY 2025-26 for Sunrise Textiles',
      description:
          'Form 26Q for non-salary payments. Challan details and deductee '
          'PANs to be compiled before filing.',
      clientId: 'mock-client-003',
      clientName: 'Sunrise Textiles Pvt Ltd',
      taskType: TaskType.tdsReturn,
      priority: TaskPriority.high,
      status: TaskStatus.review,
      assignedTo: 'Rohit Gupta',
      assignedBy: 'CA Vikram Mehta',
      dueDate: DateTime(_now.year, _now.month, _now.day + 10),
      createdAt: DateTime(_now.year, _now.month, _now.day - 18),
      tags: ['Q4', 'Form-26Q', 'TDS'],
    ),
    Task(
      id: 'mock-task-004',
      title: 'Statutory Audit FY 2025-26 — Bharat Engineering',
      description:
          'Statutory audit under Companies Act 2013. Physical verification '
          'of fixed assets scheduled for next week. Fieldwork 60% complete.',
      clientId: 'mock-client-004',
      clientName: 'Bharat Engineering Ltd',
      taskType: TaskType.audit,
      priority: TaskPriority.medium,
      status: TaskStatus.inProgress,
      assignedTo: 'Amit Sharma',
      assignedBy: 'CA Vikram Mehta',
      dueDate: DateTime(_now.year, _now.month + 1, 20),
      createdAt: DateTime(_now.year, _now.month, _now.day - 25),
      tags: ['Statutory Audit', 'Companies Act', 'FY 2025-26'],
    ),
    Task(
      id: 'mock-task-005',
      title: 'ROC Annual Filing — Sharma & Associates LLP',
      description:
          'Form 11 (Annual Return) and Form 8 (Statement of Account) for LLP. '
          'Financial statements signed by designated partners.',
      clientId: 'mock-client-005',
      clientName: 'Sharma & Associates LLP',
      taskType: TaskType.rocFiling,
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      assignedTo: 'Neha Singh',
      assignedBy: 'CA Vikram Mehta',
      dueDate: DateTime(_now.year, _now.month + 2, 5),
      createdAt: DateTime(_now.year, _now.month, _now.day - 5),
      tags: ['Form-11', 'Form-8', 'LLP', 'ROC'],
    ),
    Task(
      id: 'mock-task-006',
      title: 'Advance Tax Q4 Payment — Verma Industries',
      description:
          'Calculate and deposit advance tax for Q4 instalment by 15 March. '
          'Estimated income revised upward due to export income.',
      clientId: 'mock-client-006',
      clientName: 'Verma Industries',
      taskType: TaskType.other,
      priority: TaskPriority.urgent,
      status: TaskStatus.overdue,
      assignedTo: 'Priya Patel',
      assignedBy: 'CA Vikram Mehta',
      dueDate: DateTime(_now.year, _now.month, _now.day - 2),
      createdAt: DateTime(_now.year, _now.month, _now.day - 9),
      tags: ['Advance Tax', 'Q4', 'Overdue'],
    ),
  ];

  final List<Task> _state = List.of(_seedTasks);
  final StreamController<List<Task>> _controller =
      StreamController<List<Task>>.broadcast();

  @override
  Future<List<Task>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<Task?> getById(String id) async {
    try {
      return _state.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Task> create(Task task) async {
    _state.add(task);
    _controller.add(List.unmodifiable(_state));
    return task;
  }

  @override
  Future<Task> update(Task task) async {
    final idx = _state.indexWhere((t) => t.id == task.id);
    if (idx == -1) throw StateError('Task not found: ${task.id}');
    final updated = List<Task>.of(_state)..[idx] = task;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return task;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((t) => t.id == id);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<Task>> getByClientId(String clientId) async =>
      List.unmodifiable(_state.where((t) => t.clientId == clientId).toList());

  @override
  Future<List<Task>> getByStatus(TaskStatus status, {String? firmId}) async =>
      List.unmodifiable(_state.where((t) => t.status == status).toList());

  @override
  Future<List<Task>> search(String query, {String? firmId}) async {
    final q = query.toLowerCase();
    return _state
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.clientName.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Stream<List<Task>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}

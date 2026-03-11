import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

/// All tasks available in the system.
final allTasksProvider =
    NotifierProvider<AllTasksNotifier, List<Task>>(AllTasksNotifier.new);

class AllTasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => _mockTasks;

  void update(List<Task> value) => state = value;
}

/// Currently selected status filter chip index (0 = All).
final taskStatusFilterProvider =
    NotifierProvider<TaskStatusFilterNotifier, int>(
        TaskStatusFilterNotifier.new);

class TaskStatusFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Currently selected task type filter (null = all types).
final taskTypeFilterProvider =
    NotifierProvider<TaskTypeFilterNotifier, TaskType?>(
        TaskTypeFilterNotifier.new);

class TaskTypeFilterNotifier extends Notifier<TaskType?> {
  @override
  TaskType? build() => null;

  void update(TaskType? value) => state = value;
}

/// Currently selected priority filter (null = all priorities).
final taskPriorityFilterProvider =
    NotifierProvider<TaskPriorityFilterNotifier, TaskPriority?>(
        TaskPriorityFilterNotifier.new);

class TaskPriorityFilterNotifier extends Notifier<TaskPriority?> {
  @override
  TaskPriority? build() => null;

  void update(TaskPriority? value) => state = value;
}

/// Currently selected assignee filter (null = all assignees).
final taskAssigneeFilterProvider =
    NotifierProvider<TaskAssigneeFilterNotifier, String?>(
        TaskAssigneeFilterNotifier.new);

class TaskAssigneeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Sort option for the task list.
enum TaskSortOption { dueDate, priority, clientName }

final taskSortOptionProvider =
    NotifierProvider<TaskSortOptionNotifier, TaskSortOption>(
        TaskSortOptionNotifier.new);

class TaskSortOptionNotifier extends Notifier<TaskSortOption> {
  @override
  TaskSortOption build() => TaskSortOption.dueDate;

  void update(TaskSortOption value) => state = value;
}

/// Unique assignee names extracted from all tasks.
final taskAssigneesProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  final names = tasks.map((t) => t.assignedTo).toSet().toList()..sort();
  return names;
});

/// Summary counts for the status filter chips.
final taskCountsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  final all = tasks.length;
  final pending =
      tasks.where((t) => t.status == TaskStatus.todo).length;
  final inProgress =
      tasks.where((t) => t.status == TaskStatus.inProgress).length;
  final overdue = tasks.where((t) => t.isOverdue).length;
  return {
    'all': all,
    'pending': pending,
    'inProgress': inProgress,
    'overdue': overdue,
  };
});

/// Filtered and sorted tasks list used by the UI.
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  final statusFilter = ref.watch(taskStatusFilterProvider);
  final typeFilter = ref.watch(taskTypeFilterProvider);
  final priorityFilter = ref.watch(taskPriorityFilterProvider);
  final assigneeFilter = ref.watch(taskAssigneeFilterProvider);
  final sortOption = ref.watch(taskSortOptionProvider);

  var filtered = List<Task>.from(tasks);

  // Status chip filter: 0=All, 1=Pending, 2=InProgress, 3=Overdue
  switch (statusFilter) {
    case 1:
      filtered = filtered.where((t) => t.status == TaskStatus.todo).toList();
    case 2:
      filtered =
          filtered.where((t) => t.status == TaskStatus.inProgress).toList();
    case 3:
      filtered = filtered.where((t) => t.isOverdue).toList();
    default:
      break;
  }

  if (typeFilter != null) {
    filtered = filtered.where((t) => t.taskType == typeFilter).toList();
  }

  if (priorityFilter != null) {
    filtered = filtered.where((t) => t.priority == priorityFilter).toList();
  }

  if (assigneeFilter != null) {
    filtered =
        filtered.where((t) => t.assignedTo == assigneeFilter).toList();
  }

  // Sort
  switch (sortOption) {
    case TaskSortOption.dueDate:
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    case TaskSortOption.priority:
      filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    case TaskSortOption.clientName:
      filtered.sort(
          (a, b) => a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase()));
  }

  return filtered;
});

// ---------------------------------------------------------------------------
// Mock data: 12 tasks across different types, priorities, and statuses
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final _mockTasks = <Task>[
  Task(
    id: 'task-001',
    title: 'File ITR-1 for Rajesh Kumar',
    description: 'Salaried individual, single house property. Documents collected.',
    clientId: 'client-001',
    clientName: 'Rajesh Kumar',
    taskType: TaskType.itrFiling,
    priority: TaskPriority.high,
    status: TaskStatus.inProgress,
    assignedTo: 'Amit Sharma',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day + 5),
    createdAt: DateTime(_now.year, _now.month, _now.day - 10),
    tags: ['AY 2026-27', 'Salaried'],
  ),
  Task(
    id: 'task-002',
    title: 'GST-3B Feb 2026 for ABC Pvt Ltd',
    description: 'Monthly GST return filing. Input credits to be verified.',
    clientId: 'client-002',
    clientName: 'ABC Pvt Ltd',
    taskType: TaskType.gstReturn,
    priority: TaskPriority.urgent,
    status: TaskStatus.todo,
    assignedTo: 'Priya Patel',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day + 2),
    createdAt: DateTime(_now.year, _now.month, _now.day - 5),
    tags: ['GST-3B', 'Monthly'],
  ),
  Task(
    id: 'task-003',
    title: 'TDS Return Q4 for Mehta & Sons',
    description: 'Quarterly TDS return for Q4 FY 2025-26.',
    clientId: 'client-003',
    clientName: 'Mehta & Sons',
    taskType: TaskType.tdsReturn,
    priority: TaskPriority.high,
    status: TaskStatus.review,
    assignedTo: 'Rohit Gupta',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day + 10),
    createdAt: DateTime(_now.year, _now.month, _now.day - 15),
    tags: ['Q4', 'TDS-24Q'],
  ),
  Task(
    id: 'task-004',
    title: 'Annual Audit for XYZ Industries',
    description: 'Statutory audit for FY 2025-26. Fieldwork pending.',
    clientId: 'client-004',
    clientName: 'XYZ Industries',
    taskType: TaskType.audit,
    priority: TaskPriority.medium,
    status: TaskStatus.inProgress,
    assignedTo: 'Amit Sharma',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month + 1, 15),
    createdAt: DateTime(_now.year, _now.month, _now.day - 20),
    tags: ['Statutory Audit', 'FY 2025-26'],
  ),
  Task(
    id: 'task-005',
    title: 'ROC Annual Filing for Sharma Enterprises',
    description: 'AOC-4 and MGT-7 annual filing with ROC.',
    clientId: 'client-005',
    clientName: 'Sharma Enterprises',
    taskType: TaskType.rocFiling,
    priority: TaskPriority.low,
    status: TaskStatus.todo,
    assignedTo: 'Neha Singh',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month + 2, 1),
    createdAt: DateTime(_now.year, _now.month, _now.day - 3),
    tags: ['AOC-4', 'MGT-7'],
  ),
  Task(
    id: 'task-006',
    title: 'File ITR-3 for Priya Sharma',
    description: 'Business income from freelance consulting. 44AD applicable.',
    clientId: 'client-006',
    clientName: 'Priya Sharma',
    taskType: TaskType.itrFiling,
    priority: TaskPriority.medium,
    status: TaskStatus.todo,
    assignedTo: 'Priya Patel',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day + 20),
    createdAt: DateTime(_now.year, _now.month, _now.day - 7),
    tags: ['AY 2026-27', 'Business'],
  ),
  Task(
    id: 'task-007',
    title: 'GST-3B Feb 2026 for Global Tech',
    description: 'Monthly GST filing. Reverse charge entries pending.',
    clientId: 'client-007',
    clientName: 'Global Tech Solutions',
    taskType: TaskType.gstReturn,
    priority: TaskPriority.urgent,
    status: TaskStatus.overdue,
    assignedTo: 'Rohit Gupta',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day - 3),
    createdAt: DateTime(_now.year, _now.month, _now.day - 12),
    tags: ['GST-3B', 'Overdue'],
  ),
  Task(
    id: 'task-008',
    title: 'TDS Return Q3 for Kapoor Holdings',
    description: 'Quarterly TDS return. Challan reconciliation done.',
    clientId: 'client-008',
    clientName: 'Kapoor Holdings',
    taskType: TaskType.tdsReturn,
    priority: TaskPriority.low,
    status: TaskStatus.completed,
    assignedTo: 'Neha Singh',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day - 15),
    completedDate: DateTime(_now.year, _now.month, _now.day - 16),
    createdAt: DateTime(_now.year, _now.month, _now.day - 30),
    tags: ['Q3', 'TDS-26Q'],
  ),
  Task(
    id: 'task-009',
    title: 'Advance Tax 4th Instalment - Rajesh Kumar',
    description: 'Calculate and pay advance tax for Q4.',
    clientId: 'client-001',
    clientName: 'Rajesh Kumar',
    taskType: TaskType.itrFiling,
    priority: TaskPriority.high,
    status: TaskStatus.overdue,
    assignedTo: 'Amit Sharma',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day - 1),
    createdAt: DateTime(_now.year, _now.month, _now.day - 8),
    tags: ['Advance Tax', 'Q4'],
  ),
  Task(
    id: 'task-010',
    title: 'GST Annual Return for ABC Pvt Ltd',
    description: 'GSTR-9 annual return for FY 2025-26.',
    clientId: 'client-002',
    clientName: 'ABC Pvt Ltd',
    taskType: TaskType.gstReturn,
    priority: TaskPriority.medium,
    status: TaskStatus.todo,
    assignedTo: 'Priya Patel',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month + 1, 30),
    createdAt: DateTime(_now.year, _now.month, _now.day - 2),
    tags: ['GSTR-9', 'Annual'],
  ),
  Task(
    id: 'task-011',
    title: 'Tax Audit Report for XYZ Industries',
    description: 'Form 3CD preparation for FY 2025-26 tax audit.',
    clientId: 'client-004',
    clientName: 'XYZ Industries',
    taskType: TaskType.audit,
    priority: TaskPriority.high,
    status: TaskStatus.inProgress,
    assignedTo: 'Rohit Gupta',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month, _now.day + 15),
    createdAt: DateTime(_now.year, _now.month, _now.day - 18),
    tags: ['Tax Audit', '3CD'],
  ),
  Task(
    id: 'task-012',
    title: 'Update client KYC documents',
    description: 'Collect updated PAN, Aadhaar, and address proof from all clients.',
    clientId: 'client-000',
    clientName: 'All Clients',
    taskType: TaskType.other,
    priority: TaskPriority.low,
    status: TaskStatus.todo,
    assignedTo: 'Neha Singh',
    assignedBy: 'CA Vikram Mehta',
    dueDate: DateTime(_now.year, _now.month + 1, 1),
    createdAt: DateTime(_now.year, _now.month, _now.day - 1),
    tags: ['KYC', 'Internal'],
  ),
];

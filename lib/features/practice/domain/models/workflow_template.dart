import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

/// Service category for a workflow template.
enum WorkflowCategory {
  /// Income Tax Return filing services.
  itrFiling(label: 'ITR Filing'),

  /// GST return filing services.
  gstFiling(label: 'GST Filing'),

  /// TDS return filing services.
  tdsFiling(label: 'TDS Filing'),

  /// Tax audit / statutory audit services.
  audit(label: 'Audit'),

  /// Bookkeeping and accounting services.
  accounting(label: 'Accounting'),

  /// Tax and financial advisory services.
  advisory(label: 'Advisory');

  const WorkflowCategory({required this.label});

  final String label;
}

/// Rule defining how to compute the deadline relative to assignment date.
class WorkflowDeadlineRule {
  const WorkflowDeadlineRule({required this.offsetDays});

  /// Number of calendar days from assignment date to compute deadline.
  final int offsetDays;

  WorkflowDeadlineRule copyWith({int? offsetDays}) {
    return WorkflowDeadlineRule(offsetDays: offsetDays ?? this.offsetDays);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowDeadlineRule && other.offsetDays == offsetDays;
  }

  @override
  int get hashCode => offsetDays.hashCode;
}

/// Immutable workflow template defining a reusable practice process.
class WorkflowTemplate {
  const WorkflowTemplate({
    required this.templateId,
    required this.name,
    required this.category,
    required this.tasks,
    required this.estimatedHours,
    required this.deadline,
  });

  /// Unique template identifier.
  final String templateId;

  /// Human-readable template name.
  final String name;

  /// Practice area this template belongs to.
  final WorkflowCategory category;

  /// Ordered list of tasks, with dependency constraints.
  final List<WorkflowTask> tasks;

  /// Total estimated hours across all tasks.
  final int estimatedHours;

  /// Rule for computing the engagement deadline.
  final WorkflowDeadlineRule deadline;

  WorkflowTemplate copyWith({
    String? templateId,
    String? name,
    WorkflowCategory? category,
    List<WorkflowTask>? tasks,
    int? estimatedHours,
    WorkflowDeadlineRule? deadline,
  }) {
    return WorkflowTemplate(
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      category: category ?? this.category,
      tasks: tasks ?? this.tasks,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      deadline: deadline ?? this.deadline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowTemplate &&
        other.templateId == templateId &&
        other.name == name &&
        other.category == category &&
        other.estimatedHours == estimatedHours &&
        other.deadline == deadline;
  }

  @override
  int get hashCode =>
      Object.hash(templateId, name, category, estimatedHours, deadline);
}

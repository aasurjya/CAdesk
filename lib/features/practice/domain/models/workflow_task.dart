/// Staff role hierarchy for CA practice.
enum StaffRole {
  /// Engagement partner — final sign-off, client relationship.
  partner(label: 'Partner'),

  /// Manager — supervises assignments, reviews work.
  manager(label: 'Manager'),

  /// Senior associate — executes complex tasks independently.
  senior(label: 'Senior'),

  /// Junior associate — executes standard tasks under supervision.
  junior(label: 'Junior'),

  /// Article clerk — trainee, handles routine/data-entry work.
  articleClerk(label: 'Article Clerk');

  const StaffRole({required this.label});

  final String label;
}

/// A single task within a workflow, with dependency tracking.
class WorkflowTask {
  const WorkflowTask({
    required this.taskId,
    required this.name,
    required this.description,
    required this.requiredRole,
    required this.estimatedHours,
    required this.dependsOn,
    required this.checklistItems,
  });

  /// Unique identifier for this task within the template.
  final String taskId;

  /// Human-readable task name.
  final String name;

  /// Detailed description of work to be performed.
  final String description;

  /// Minimum staff role required to perform this task.
  final StaffRole requiredRole;

  /// Estimated number of hours to complete this task.
  final int estimatedHours;

  /// Task IDs that must be completed before this task can start.
  final List<String> dependsOn;

  /// Checklist items to verify before marking task complete.
  final List<String> checklistItems;

  WorkflowTask copyWith({
    String? taskId,
    String? name,
    String? description,
    StaffRole? requiredRole,
    int? estimatedHours,
    List<String>? dependsOn,
    List<String>? checklistItems,
  }) {
    return WorkflowTask(
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      description: description ?? this.description,
      requiredRole: requiredRole ?? this.requiredRole,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      dependsOn: dependsOn ?? this.dependsOn,
      checklistItems: checklistItems ?? this.checklistItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowTask &&
        other.taskId == taskId &&
        other.name == name &&
        other.description == description &&
        other.requiredRole == requiredRole &&
        other.estimatedHours == estimatedHours;
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    name,
    description,
    requiredRole,
    estimatedHours,
  );
}

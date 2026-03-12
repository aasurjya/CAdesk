import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

/// Lifecycle status of a client engagement.
enum EngagementStatus {
  /// Work has not begun.
  notStarted(label: 'Not Started'),

  /// Work is actively underway.
  inProgress(label: 'In Progress'),

  /// Work is complete and under review.
  review(label: 'Under Review'),

  /// Review passed; engagement is complete.
  done(label: 'Done'),

  /// Invoice has been raised.
  billed(label: 'Billed');

  const EngagementStatus({required this.label});

  final String label;
}

/// Immutable record of a client engagement instance derived from a template.
///
/// The [templateTasks] snapshot is taken at instantiation time so that
/// the engagement is self-contained — the original template may evolve
/// independently without affecting in-flight engagements.
class Engagement {
  const Engagement({
    required this.engagementId,
    required this.clientId,
    required this.templateId,
    required this.templateTasks,
    required this.assignedStaff,
    required this.status,
    required this.dueDate,
    required this.completedDate,
    required this.billingAmount,
  });

  /// Unique engagement identifier.
  final String engagementId;

  /// Client for whom work is being performed.
  final String clientId;

  /// Template this engagement was instantiated from.
  final String templateId;

  /// Snapshot of all workflow tasks from the template at instantiation time.
  final List<WorkflowTask> templateTasks;

  /// Staff members assigned to this engagement, with task allocations.
  final List<StaffAssignment> assignedStaff;

  /// Current lifecycle status.
  final EngagementStatus status;

  /// Date by which the engagement must be completed.
  final DateTime dueDate;

  /// Date the engagement was marked done; null if not yet complete.
  final DateTime? completedDate;

  /// Agreed billing amount in paise (100 paise = ₹1).
  final int billingAmount;

  /// Returns the set of all task IDs marked as completed by assigned staff.
  Set<String> get completedTaskIds {
    final ids = <String>{};
    for (final assignment in assignedStaff) {
      ids.addAll(assignment.tasks);
    }
    return ids;
  }

  Engagement copyWith({
    String? engagementId,
    String? clientId,
    String? templateId,
    List<WorkflowTask>? templateTasks,
    List<StaffAssignment>? assignedStaff,
    EngagementStatus? status,
    DateTime? dueDate,
    DateTime? completedDate,
    int? billingAmount,
  }) {
    return Engagement(
      engagementId: engagementId ?? this.engagementId,
      clientId: clientId ?? this.clientId,
      templateId: templateId ?? this.templateId,
      templateTasks: templateTasks ?? this.templateTasks,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      billingAmount: billingAmount ?? this.billingAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Engagement &&
        other.engagementId == engagementId &&
        other.clientId == clientId &&
        other.templateId == templateId &&
        other.status == status &&
        other.dueDate == dueDate &&
        other.completedDate == completedDate &&
        other.billingAmount == billingAmount;
  }

  @override
  int get hashCode => Object.hash(
    engagementId,
    clientId,
    templateId,
    status,
    dueDate,
    completedDate,
    billingAmount,
  );
}

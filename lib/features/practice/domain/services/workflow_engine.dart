import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';

/// Risk level for meeting the engagement deadline.
enum DeadlineRisk {
  /// Sufficient time remains; completion is on track.
  onTrack,

  /// Projected completion is within 48 hours of deadline.
  atRisk,

  /// Deadline has already passed.
  overdue,
}

/// Orchestrates workflow instantiation, task sequencing, and deadline tracking.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class WorkflowEngine {
  WorkflowEngine._();

  static final WorkflowEngine instance = WorkflowEngine._();

  /// Creates a new [Engagement] from a [WorkflowTemplate].
  ///
  /// A snapshot of the template's task graph is embedded in the engagement so
  /// that [getNextTasks] and [computeProgress] work without re-supplying the
  /// template later.  The engagement starts with no staff, zero billing amount,
  /// and [EngagementStatus.notStarted].
  Engagement instantiateWorkflow(
    WorkflowTemplate template,
    String clientId,
    DateTime dueDate,
  ) {
    final id = _generateId('eng');
    return Engagement(
      engagementId: id,
      clientId: clientId,
      templateId: template.templateId,
      templateTasks: List.unmodifiable(template.tasks),
      assignedStaff: const [],
      status: EngagementStatus.notStarted,
      dueDate: dueDate,
      completedDate: null,
      billingAmount: 0,
    );
  }

  /// Returns tasks whose dependencies are all satisfied by the engagement's
  /// completed task set, excluding tasks that are already completed.
  ///
  /// Uses the [Engagement.templateTasks] snapshot embedded at instantiation.
  List<WorkflowTask> getNextTasks(Engagement engagement) {
    final completed = engagement.completedTaskIds;
    return engagement.templateTasks.where((task) {
      if (completed.contains(task.taskId)) return false;
      return task.dependsOn.every(completed.contains);
    }).toList();
  }

  /// Computes engagement progress as `completedTasks / totalTasks`.
  ///
  /// Returns a value in the range [0.0, 1.0].
  /// Returns 1.0 if the template has no tasks (trivially complete).
  double computeProgress(Engagement engagement) {
    final totalTasks = engagement.templateTasks.length;
    if (totalTasks == 0) return 1.0;
    final completedCount = engagement.completedTaskIds.length;
    return (completedCount / totalTasks).clamp(0.0, 1.0);
  }

  /// Evaluates deadline risk based on current date vs [Engagement.dueDate].
  ///
  /// - [DeadlineRisk.overdue] — due date is in the past.
  /// - [DeadlineRisk.atRisk]  — due date is within 48 hours.
  /// - [DeadlineRisk.onTrack] — more than 48 hours remain.
  DeadlineRisk checkDeadlineRisk(Engagement engagement) {
    final now = DateTime.now();
    final due = engagement.dueDate;
    if (due.isBefore(now)) return DeadlineRisk.overdue;
    final hoursRemaining = due.difference(now).inHours;
    if (hoursRemaining <= 48) return DeadlineRisk.atRisk;
    return DeadlineRisk.onTrack;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String _generateId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}

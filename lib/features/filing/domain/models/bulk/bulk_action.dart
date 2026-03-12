import 'package:ca_app/features/filing/domain/models/filing_job.dart';

/// The type of operation to apply across selected filing jobs.
enum BulkActionType { updateStatus, assignTo, setPriority, export, delete }

/// Immutable descriptor for a bulk operation to be applied to a set of
/// filing jobs.
class BulkAction {
  const BulkAction({
    required this.type,
    this.targetStatus,
    this.assignee,
    this.priority,
  });

  final BulkActionType type;
  final FilingJobStatus? targetStatus;
  final String? assignee;
  final FilingPriority? priority;

  BulkAction copyWith({
    BulkActionType? type,
    FilingJobStatus? targetStatus,
    String? assignee,
    FilingPriority? priority,
  }) {
    return BulkAction(
      type: type ?? this.type,
      targetStatus: targetStatus ?? this.targetStatus,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BulkAction &&
        other.type == type &&
        other.targetStatus == targetStatus &&
        other.assignee == assignee &&
        other.priority == priority;
  }

  @override
  int get hashCode => Object.hash(type, targetStatus, assignee, priority);
}

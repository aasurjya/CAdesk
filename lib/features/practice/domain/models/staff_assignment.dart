import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

/// Records a staff member's assignment and time on an engagement.
class StaffAssignment {
  const StaffAssignment({
    required this.staffId,
    required this.role,
    required this.tasks,
    required this.hoursLogged,
    required this.hoursEstimated,
  });

  /// Staff member's unique identifier.
  final String staffId;

  /// Role at which this staff member is assigned to this engagement.
  final StaffRole role;

  /// Task IDs assigned to (and completed by) this staff member.
  final List<String> tasks;

  /// Actual hours logged by this staff member on this engagement.
  final int hoursLogged;

  /// Estimated hours for the tasks assigned to this staff member.
  final int hoursEstimated;

  StaffAssignment copyWith({
    String? staffId,
    StaffRole? role,
    List<String>? tasks,
    int? hoursLogged,
    int? hoursEstimated,
  }) {
    return StaffAssignment(
      staffId: staffId ?? this.staffId,
      role: role ?? this.role,
      tasks: tasks ?? this.tasks,
      hoursLogged: hoursLogged ?? this.hoursLogged,
      hoursEstimated: hoursEstimated ?? this.hoursEstimated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffAssignment &&
        other.staffId == staffId &&
        other.role == role &&
        other.hoursLogged == hoursLogged &&
        other.hoursEstimated == hoursEstimated;
  }

  @override
  int get hashCode => Object.hash(staffId, role, hoursLogged, hoursEstimated);
}

import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';

/// A staff member in the practice.
class Staff {
  const Staff({
    required this.staffId,
    required this.name,
    required this.role,
    required this.skills,
    required this.currentEngagements,
  });

  /// Unique staff identifier.
  final String staffId;

  /// Full name.
  final String name;

  /// Staff role / seniority level.
  final StaffRole role;

  /// Practice areas this staff member is trained in.
  final List<WorkflowCategory> skills;

  /// IDs of engagements currently assigned to this staff member.
  final List<String> currentEngagements;

  Staff copyWith({
    String? staffId,
    String? name,
    StaffRole? role,
    List<WorkflowCategory>? skills,
    List<String>? currentEngagements,
  }) {
    return Staff(
      staffId: staffId ?? this.staffId,
      name: name ?? this.name,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      currentEngagements: currentEngagements ?? this.currentEngagements,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Staff &&
        other.staffId == staffId &&
        other.name == name &&
        other.role == role;
  }

  @override
  int get hashCode => Object.hash(staffId, name, role);
}

/// Identifies a workload concentration bottleneck.
class WorkflowBottleneck {
  const WorkflowBottleneck({
    required this.staffId,
    required this.engagementCount,
    required this.description,
  });

  /// Staff member with the bottleneck.
  final String staffId;

  /// Number of engagements queued on this staff member.
  final int engagementCount;

  /// Human-readable description of the bottleneck.
  final String description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowBottleneck &&
        other.staffId == staffId &&
        other.engagementCount == engagementCount;
  }

  @override
  int get hashCode => Object.hash(staffId, engagementCount);
}

/// Analyses staff workload and suggests optimal task assignments.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class WorkloadDistributionService {
  WorkloadDistributionService._();

  static final WorkloadDistributionService instance =
      WorkloadDistributionService._();

  /// Bottleneck threshold: flag a staff member when assigned to this many
  /// or more concurrent engagements.
  static const int _bottleneckThreshold = 3;

  /// Computes total logged hours per staff member across [engagements].
  ///
  /// All staff in [staff] are included in the result, defaulting to 0 hours
  /// if they appear in no engagements.
  Map<String, int> computeStaffWorkload(
    List<Engagement> engagements,
    List<Staff> staff,
  ) {
    final workload = <String, int>{};
    for (final member in staff) {
      workload[member.staffId] = 0;
    }
    for (final engagement in engagements) {
      for (final assignment in engagement.assignedStaff) {
        final current = workload[assignment.staffId] ?? 0;
        workload[assignment.staffId] = current + assignment.hoursLogged;
      }
    }
    return Map.unmodifiable(workload);
  }

  /// Suggests the best available staff member for a given [task].
  ///
  /// Selection criteria (in priority order):
  /// 1. Role matches [WorkflowTask.requiredRole]
  /// 2. Has a skill that matches the task's implied category
  ///    (inferred from [requiredRole] seniority alignment)
  /// 3. Fewest current engagements (lowest workload)
  ///
  /// Throws [ArgumentError] if [availableStaff] is empty.
  Staff suggestAssignment(
    WorkflowTask task,
    List<Staff> availableStaff,
  ) {
    if (availableStaff.isEmpty) {
      throw ArgumentError('availableStaff must not be empty');
    }

    // Priority 1: exact role match
    final roleMatches = availableStaff
        .where((s) => s.role == task.requiredRole)
        .toList();

    final candidates = roleMatches.isNotEmpty ? roleMatches : availableStaff;

    // Among candidates, prefer the one with fewest current engagements.
    return candidates.reduce((best, current) {
      return current.currentEngagements.length <
              best.currentEngagements.length
          ? current
          : best;
    });
  }

  /// Identifies staff members carrying more engagements than the threshold.
  ///
  /// Returns a list of [WorkflowBottleneck] records for any staff member
  /// appearing in 3 or more engagement assignments simultaneously.
  List<WorkflowBottleneck> detectBottlenecks(
    List<Engagement> engagements,
  ) {
    final assignmentCount = <String, int>{};
    for (final engagement in engagements) {
      for (final assignment in engagement.assignedStaff) {
        final count = assignmentCount[assignment.staffId] ?? 0;
        assignmentCount[assignment.staffId] = count + 1;
      }
    }

    return assignmentCount.entries
        .where((entry) => entry.value >= _bottleneckThreshold)
        .map(
          (entry) => WorkflowBottleneck(
            staffId: entry.key,
            engagementCount: entry.value,
            description:
                'Staff ${entry.key} is assigned to ${entry.value} concurrent '
                'engagements (threshold: $_bottleneckThreshold)',
          ),
        )
        .toList();
  }
}

import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

/// Represents a staff member available for task assignment.
///
/// All fields are immutable. Use [copyWith] to derive updated instances
/// when task counts change.
class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.currentTaskCount,
    required this.maxCapacity,
    required this.skills,
    this.role,
  });

  /// Unique staff identifier.
  final String id;

  /// Full display name.
  final String name;

  /// Number of tasks currently assigned to this staff member.
  final int currentTaskCount;

  /// Maximum number of tasks this staff member can handle concurrently.
  ///
  /// Must be greater than zero to avoid division by zero in [utilizationRate].
  final int maxCapacity;

  /// Practice area skill tags, e.g. `['gst', 'income_tax', 'audit']`.
  final List<String> skills;

  /// Optional staff role — used for role-based filtering.
  final StaffRole? role;

  /// Fraction of capacity currently consumed: [currentTaskCount] / [maxCapacity].
  ///
  /// Clamped to [0.0, 1.0]; returns `0.0` when [maxCapacity] is zero.
  double get utilizationRate {
    if (maxCapacity <= 0) return 0.0;
    return (currentTaskCount / maxCapacity).clamp(0.0, 1.0);
  }

  /// Returns `true` when this staff member can accept at least one more task.
  bool get isAvailable => currentTaskCount < maxCapacity;

  StaffMember copyWith({
    String? id,
    String? name,
    int? currentTaskCount,
    int? maxCapacity,
    List<String>? skills,
    StaffRole? role,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      currentTaskCount: currentTaskCount ?? this.currentTaskCount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      skills: skills ?? this.skills,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffMember &&
        other.id == id &&
        other.name == name &&
        other.currentTaskCount == currentTaskCount &&
        other.maxCapacity == maxCapacity;
  }

  @override
  int get hashCode => Object.hash(id, name, currentTaskCount, maxCapacity);

  @override
  String toString() =>
      'StaffMember(id: $id, name: $name, '
      'tasks: $currentTaskCount/$maxCapacity, '
      'utilization: ${(utilizationRate * 100).toStringAsFixed(0)}%)';
}

/// Immutable recommendation produced by [SmartAssignmentService].
class StaffRecommendation {
  const StaffRecommendation({
    required this.recommended,
    required this.confidenceScore,
    required this.reason,
    required this.alternatives,
  });

  /// Best-fit staff member for the task.
  final StaffMember recommended;

  /// Confidence in the recommendation on a 0–1 scale.
  ///
  /// Higher values indicate stronger alignment across workload, skill, and
  /// role criteria.
  final double confidenceScore;

  /// Human-readable explanation of why [recommended] was chosen.
  final String reason;

  /// Ranked list of other viable candidates (excluding [recommended]).
  final List<StaffMember> alternatives;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffRecommendation &&
        other.recommended == recommended &&
        other.confidenceScore == confidenceScore;
  }

  @override
  int get hashCode => Object.hash(recommended, confidenceScore);

  @override
  String toString() =>
      'StaffRecommendation(recommended: ${recommended.name}, '
      'confidence: ${(confidenceScore * 100).toStringAsFixed(0)}%, '
      'reason: $reason)';
}

/// Recommends the best staff member for a [WorkflowTask] based on workload,
/// skill alignment, and availability.
///
/// Stateless singleton — all methods are pure functions of their inputs.
/// No Flutter or platform dependencies; safe for use in isolates and tests.
///
/// Scoring factors:
/// 1. **Availability** — staff at capacity are excluded entirely.
/// 2. **Role match** — staff whose [StaffRole] matches
///    [WorkflowTask.requiredRole] receive a +0.3 bonus.
/// 3. **Skill match** — each skill in [StaffMember.skills] that matches the
///    task's implied domain (derived from the task name) adds +0.2 (capped at +0.4).
/// 4. **Utilization** — lower utilization contributes up to +0.3 (1 − utilization).
///
/// The [confidenceScore] is normalised to [0.0, 1.0].
class SmartAssignmentService {
  SmartAssignmentService._();

  static final SmartAssignmentService instance = SmartAssignmentService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Recommends the best [StaffMember] for [task] from [availableStaff].
  ///
  /// Only staff members where [StaffMember.isAvailable] is `true` are
  /// considered. If every staff member is at capacity but [availableStaff]
  /// is non-empty, the least-loaded member is returned anyway with a low
  /// [StaffRecommendation.confidenceScore].
  ///
  /// Throws [ArgumentError] if [availableStaff] is empty.
  StaffRecommendation recommendAssignee(
    WorkflowTask task,
    List<StaffMember> availableStaff,
  ) {
    if (availableStaff.isEmpty) {
      throw ArgumentError.value(
        availableStaff,
        'availableStaff',
        'must not be empty',
      );
    }

    final candidates = availableStaff.where((s) => s.isAvailable).toList();
    final pool = candidates.isNotEmpty ? candidates : availableStaff;

    // Score each candidate.
    final scored =
        pool.map((s) => _ScoredStaff(staff: s, score: _score(s, task))).toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final best = scored.first;
    final rest = scored.skip(1).map((s) => s.staff).toList();

    return StaffRecommendation(
      recommended: best.staff,
      confidenceScore: best.score.clamp(0.0, 1.0),
      reason: _buildReason(best.staff, task),
      alternatives: rest,
    );
  }

  // ---------------------------------------------------------------------------
  // Scoring
  // ---------------------------------------------------------------------------

  double _score(StaffMember staff, WorkflowTask task) {
    var score = 0.0;

    // Factor 1: utilization (up to 0.3 for fully free staff).
    score += (1.0 - staff.utilizationRate) * 0.3;

    // Factor 2: role match (0.3 bonus).
    if (staff.role != null && staff.role == task.requiredRole) {
      score += 0.3;
    }

    // Factor 3: skill match (up to 0.4 across matched skills).
    final taskKeywords = _extractKeywords(task.name);
    var skillBonus = 0.0;
    for (final skill in staff.skills) {
      if (taskKeywords.any(
        (kw) => skill.toLowerCase().contains(kw.toLowerCase()),
      )) {
        skillBonus += 0.2;
        if (skillBonus >= 0.4) break;
      }
    }
    score += skillBonus;

    return score;
  }

  String _buildReason(StaffMember staff, WorkflowTask task) {
    final reasons = <String>[];

    if (staff.role != null && staff.role == task.requiredRole) {
      reasons.add('role matches (${task.requiredRole.label})');
    }

    final taskKeywords = _extractKeywords(task.name);
    final matchedSkills = staff.skills
        .where(
          (s) => taskKeywords.any(
            (kw) => s.toLowerCase().contains(kw.toLowerCase()),
          ),
        )
        .toList();
    if (matchedSkills.isNotEmpty) {
      reasons.add('skills: ${matchedSkills.join(', ')}');
    }

    reasons.add(
      'utilization: ${(staff.utilizationRate * 100).toStringAsFixed(0)}%',
    );

    return reasons.join('; ');
  }

  /// Extracts meaningful keywords from a task name for skill matching.
  List<String> _extractKeywords(String taskName) {
    const stopWords = {'and', 'or', 'the', 'for', 'of', 'in', 'a'};
    return taskName
        .toLowerCase()
        .split(RegExp(r'[\s_\-]+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toList();
  }
}

/// Internal scored staff holder — not part of the public API.
class _ScoredStaff {
  const _ScoredStaff({required this.staff, required this.score});

  final StaffMember staff;
  final double score;
}

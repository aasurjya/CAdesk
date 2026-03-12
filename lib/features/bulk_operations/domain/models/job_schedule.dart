import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

/// Immutable model representing a recurring schedule for a [BatchJob] type.
///
/// Schedules drive the [JobScheduler] to automatically enqueue jobs at
/// defined intervals (e.g., GSTR-1 reminder 3 days before 11th of each month).
class JobSchedule {
  const JobSchedule({
    required this.scheduleId,
    required this.jobType,
    required this.nextRunAt,
    required this.isEnabled,
    this.cronExpression,
    this.lastRunAt,
    this.lastRunStatus,
  });

  /// Unique identifier for this schedule.
  final String scheduleId;

  /// The type of job to enqueue when this schedule fires.
  final JobType jobType;

  /// Optional cron expression describing the recurrence pattern.
  ///
  /// When null, the scheduler uses a fixed [Duration] interval instead.
  final String? cronExpression;

  /// Timestamp of the next scheduled run.
  final DateTime nextRunAt;

  /// Whether this schedule is active. Disabled schedules are skipped by
  /// [JobScheduler.getDueJobs].
  final bool isEnabled;

  /// Timestamp of the most recent execution, or null if never run.
  final DateTime? lastRunAt;

  /// Status string from the most recent run (e.g. "success", "failed"),
  /// or null if never run.
  final String? lastRunStatus;

  // ── Immutable update ───────────────────────────────────────────────────────

  JobSchedule copyWith({
    String? scheduleId,
    JobType? jobType,
    String? cronExpression,
    DateTime? nextRunAt,
    bool? isEnabled,
    DateTime? lastRunAt,
    String? lastRunStatus,
    bool clearCronExpression = false,
    bool clearLastRunAt = false,
    bool clearLastRunStatus = false,
  }) {
    return JobSchedule(
      scheduleId: scheduleId ?? this.scheduleId,
      jobType: jobType ?? this.jobType,
      cronExpression: clearCronExpression ? null : (cronExpression ?? this.cronExpression),
      nextRunAt: nextRunAt ?? this.nextRunAt,
      isEnabled: isEnabled ?? this.isEnabled,
      lastRunAt: clearLastRunAt ? null : (lastRunAt ?? this.lastRunAt),
      lastRunStatus: clearLastRunStatus ? null : (lastRunStatus ?? this.lastRunStatus),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobSchedule && other.scheduleId == scheduleId;
  }

  @override
  int get hashCode => scheduleId.hashCode;

  @override
  String toString() =>
      'JobSchedule(scheduleId: $scheduleId, jobType: $jobType, '
      'nextRunAt: $nextRunAt, enabled: $isEnabled)';
}

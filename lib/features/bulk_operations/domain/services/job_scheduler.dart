import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/job_schedule.dart';

/// Stateless service managing recurring [JobSchedule] lifecycle.
///
/// All methods are pure functions — they return new objects and never mutate
/// their inputs. Persistence of schedules is handled by the repository layer.
///
/// ### CA Practice recurring schedules:
/// | Job Type     | Trigger                                  |
/// |--------------|------------------------------------------|
/// | GSTR-1       | 3 days before 11th of each month         |
/// | GSTR-3B      | 3 days before 20th of each month         |
/// | TDS payment  | 3 days before 7th (monthly)              |
/// | ITR deadline | 15 days before July 31                   |
class JobScheduler {
  JobScheduler._();

  /// Public factory — allows tests to create independent instances.
  factory JobScheduler() => JobScheduler._();

  static final JobScheduler instance = JobScheduler._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Creates a new enabled [JobSchedule] for [type] that repeats every
  /// [interval].
  ///
  /// [nextRunAt] is set to `now + interval`.
  JobSchedule scheduleRecurring(JobType type, Duration interval) {
    final scheduleId =
        'schedule-${type.name}-${DateTime.now().millisecondsSinceEpoch}';
    return JobSchedule(
      scheduleId: scheduleId,
      jobType: type,
      nextRunAt: DateTime.now().add(interval),
      isEnabled: true,
    );
  }

  /// Computes the next run time for [schedule] starting from [from].
  ///
  /// When [interval] is provided, returns `from + interval`.
  /// Falls back to advancing by 24 hours if no interval is given.
  DateTime computeNextRun(
    JobSchedule schedule,
    DateTime from, {
    Duration interval = const Duration(hours: 24),
  }) {
    return from.add(interval);
  }

  /// Returns all [schedules] that are due to run at or before [now].
  ///
  /// A schedule is due when:
  /// - [JobSchedule.isEnabled] is true
  /// - [JobSchedule.nextRunAt] <= [now]
  List<JobSchedule> getDueJobs(List<JobSchedule> schedules, DateTime now) {
    return schedules
        .where((s) => s.isEnabled && !s.nextRunAt.isAfter(now))
        .toList();
  }

  /// Returns a new [JobSchedule] updated with the results of the most recent
  /// run.
  ///
  /// [lastRunAt] is the timestamp when the run completed.
  /// [status] is a human-readable outcome string (e.g. "success", "failed").
  /// All other fields are preserved from [schedule].
  JobSchedule updateSchedule(
    JobSchedule schedule,
    DateTime lastRunAt,
    String status,
  ) {
    return schedule.copyWith(lastRunAt: lastRunAt, lastRunStatus: status);
  }
}

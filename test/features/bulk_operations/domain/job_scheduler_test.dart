import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/job_schedule.dart';
import 'package:ca_app/features/bulk_operations/domain/services/job_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 7, 1, 10, 0);

  JobSchedule makeSchedule({
    String id = 'sched-1',
    JobType jobType = JobType.gstFiling,
    DateTime? nextRunAt,
    bool isEnabled = true,
    String? cronExpression,
    DateTime? lastRunAt,
    String? lastRunStatus,
  }) {
    return JobSchedule(
      scheduleId: id,
      jobType: jobType,
      cronExpression: cronExpression,
      nextRunAt: nextRunAt ?? now.add(const Duration(hours: 1)),
      isEnabled: isEnabled,
      lastRunAt: lastRunAt,
      lastRunStatus: lastRunStatus,
    );
  }

  group('JobScheduler.scheduleRecurring', () {
    test('returns a JobSchedule with the given jobType', () {
      final scheduler = JobScheduler();
      final schedule = scheduler.scheduleRecurring(
        JobType.gstFiling,
        const Duration(days: 1),
      );
      expect(schedule.jobType, JobType.gstFiling);
    });

    test('schedule is enabled by default', () {
      final scheduler = JobScheduler();
      final schedule = scheduler.scheduleRecurring(
        JobType.itrFiling,
        const Duration(hours: 6),
      );
      expect(schedule.isEnabled, isTrue);
    });

    test('nextRunAt is set in the future', () {
      final scheduler = JobScheduler();
      final before = DateTime.now();
      final schedule = scheduler.scheduleRecurring(
        JobType.tdsFiling,
        const Duration(hours: 1),
      );
      expect(schedule.nextRunAt.isAfter(before), isTrue);
    });

    test('scheduleId is non-empty', () {
      final scheduler = JobScheduler();
      final schedule = scheduler.scheduleRecurring(
        JobType.bulkExport,
        const Duration(days: 7),
      );
      expect(schedule.scheduleId, isNotEmpty);
    });
  });

  group('JobScheduler.computeNextRun', () {
    test('adds interval to from datetime', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule(nextRunAt: now);
      final next = scheduler.computeNextRun(
        schedule,
        now,
        interval: const Duration(hours: 24),
      );
      expect(next, now.add(const Duration(hours: 24)));
    });

    test('interval of 1 day advances by 1 day', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule();
      final from = DateTime(2025, 7, 1, 0, 0);
      final next = scheduler.computeNextRun(
        schedule,
        from,
        interval: const Duration(days: 1),
      );
      expect(next, DateTime(2025, 7, 2, 0, 0));
    });

    test('interval of 7 days advances by 7 days', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule();
      final from = DateTime(2025, 7, 1);
      final next = scheduler.computeNextRun(
        schedule,
        from,
        interval: const Duration(days: 7),
      );
      expect(next, DateTime(2025, 7, 8));
    });
  });

  group('JobScheduler.getDueJobs', () {
    test('returns schedules whose nextRunAt <= now and are enabled', () {
      final scheduler = JobScheduler();
      final schedules = [
        makeSchedule(id: 's1', nextRunAt: now.subtract(const Duration(minutes: 1))),
        makeSchedule(id: 's2', nextRunAt: now.add(const Duration(hours: 1))),
        makeSchedule(id: 's3', nextRunAt: now.subtract(const Duration(hours: 2))),
      ];
      final due = scheduler.getDueJobs(schedules, now);
      expect(due.length, 2);
      expect(due.map((s) => s.scheduleId).toList(), containsAll(['s1', 's3']));
    });

    test('disabled schedules are excluded even if due', () {
      final scheduler = JobScheduler();
      final schedules = [
        makeSchedule(id: 's1', nextRunAt: now.subtract(const Duration(hours: 1)), isEnabled: false),
        makeSchedule(id: 's2', nextRunAt: now.subtract(const Duration(hours: 1))),
      ];
      final due = scheduler.getDueJobs(schedules, now);
      expect(due.length, 1);
      expect(due.first.scheduleId, 's2');
    });

    test('returns empty list when no schedules are due', () {
      final scheduler = JobScheduler();
      final schedules = [
        makeSchedule(nextRunAt: now.add(const Duration(hours: 1))),
        makeSchedule(nextRunAt: now.add(const Duration(days: 1))),
      ];
      expect(scheduler.getDueJobs(schedules, now), isEmpty);
    });

    test('returns empty list for empty input', () {
      final scheduler = JobScheduler();
      expect(scheduler.getDueJobs([], now), isEmpty);
    });

    test('schedule exactly at now is considered due', () {
      final scheduler = JobScheduler();
      final schedules = [makeSchedule(nextRunAt: now)];
      final due = scheduler.getDueJobs(schedules, now);
      expect(due.length, 1);
    });
  });

  group('JobScheduler.updateSchedule', () {
    test('returns updated schedule with new lastRunAt', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule(id: 'sched-1');
      final updated = scheduler.updateSchedule(schedule, now, 'success');
      expect(updated.lastRunAt, now);
    });

    test('returns updated schedule with new lastRunStatus', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule(id: 'sched-1');
      final updated = scheduler.updateSchedule(schedule, now, 'failed');
      expect(updated.lastRunStatus, 'failed');
    });

    test('returns new object — original is not mutated', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule(id: 'sched-1');
      final updated = scheduler.updateSchedule(schedule, now, 'success');
      expect(identical(schedule, updated), isFalse);
      expect(schedule.lastRunAt, isNull); // original unchanged
    });

    test('preserves scheduleId and jobType', () {
      final scheduler = JobScheduler();
      final schedule = makeSchedule(id: 'my-sched', jobType: JobType.tdsFiling);
      final updated = scheduler.updateSchedule(schedule, now, 'success');
      expect(updated.scheduleId, 'my-sched');
      expect(updated.jobType, JobType.tdsFiling);
    });
  });
}

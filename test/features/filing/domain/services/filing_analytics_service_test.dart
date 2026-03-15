import 'package:ca_app/features/filing/domain/models/analytics/filing_statistics.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/services/filing_analytics_service.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final tenDaysAgo = now.subtract(const Duration(days: 10));
  final fiveDaysAgo = now.subtract(const Duration(days: 5));
  final pastDue = now.subtract(const Duration(days: 1));

  FilingJob makeJob({
    required String id,
    FilingJobStatus status = FilingJobStatus.notStarted,
    DateTime? dueDate,
    DateTime? filingDate,
    DateTime? createdAt,
    double? feeQuoted,
    double? feeReceived,
  }) {
    return FilingJob(
      id: id,
      clientId: 'c-$id',
      clientName: 'Client $id',
      pan: 'PAN$id',
      assessmentYear: '2025-26',
      itrType: ItrType.itr1,
      status: status,
      createdAt: createdAt ?? tenDaysAgo,
      updatedAt: now,
      dueDate: dueDate,
      filingDate: filingDate,
      feeQuoted: feeQuoted,
      feeReceived: feeReceived,
    );
  }

  group('FilingAnalyticsService.computeStatistics', () {
    test('computes correct counts for mixed statuses', () {
      final jobs = [
        makeJob(
          id: '1',
          status: FilingJobStatus.filed,
          filingDate: fiveDaysAgo,
          feeReceived: 5000,
        ),
        makeJob(
          id: '2',
          status: FilingJobStatus.verified,
          filingDate: fiveDaysAgo,
          feeReceived: 3000,
        ),
        makeJob(
          id: '3',
          status: FilingJobStatus.draft,
          dueDate: pastDue,
          feeQuoted: 4000,
        ),
        makeJob(id: '4', status: FilingJobStatus.notStarted, feeQuoted: 2000),
      ];

      final stats = FilingAnalyticsService.computeStatistics(jobs);

      expect(stats.totalFilings, 4);
      expect(stats.filedCount, 2);
      expect(stats.pendingCount, 2);
      expect(stats.overdueCount, 1);
      expect(stats.revenueCollected, 8000);
      expect(stats.revenueOutstanding, 6000);
    });

    test('computes average turnaround days from filed jobs', () {
      final jobs = [
        makeJob(
          id: '1',
          status: FilingJobStatus.filed,
          createdAt: tenDaysAgo,
          filingDate: fiveDaysAgo,
        ),
      ];

      final stats = FilingAnalyticsService.computeStatistics(jobs);

      expect(stats.averageTurnaroundDays, 5.0);
    });

    test('returns zero statistics for empty list', () {
      final stats = FilingAnalyticsService.computeStatistics([]);

      expect(stats.totalFilings, 0);
      expect(stats.filedCount, 0);
      expect(stats.pendingCount, 0);
      expect(stats.overdueCount, 0);
      expect(stats.averageTurnaroundDays, 0.0);
      expect(stats.revenueCollected, 0.0);
      expect(stats.revenueOutstanding, 0.0);
    });
  });

  group('FilingStatistics.completionRate', () {
    test('returns correct ratio for mixed statuses', () {
      final stats = FilingAnalyticsService.computeStatistics([
        makeJob(id: '1', status: FilingJobStatus.filed, filingDate: now),
        makeJob(id: '2', status: FilingJobStatus.draft),
        makeJob(id: '3', status: FilingJobStatus.verified, filingDate: now),
        makeJob(id: '4', status: FilingJobStatus.notStarted),
      ]);

      expect(stats.completionRate, 0.5);
    });

    test('returns 0.0 for empty list', () {
      final stats = FilingAnalyticsService.computeStatistics([]);

      expect(stats.completionRate, 0.0);
    });
  });

  group('FilingAnalyticsService.getDeadlineCalendar', () {
    test('returns 5 deadline entries for a given assessment year', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2026-27');

      expect(deadlines, hasLength(5));
    });

    test('first deadline is July 31 of AY start year', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2026-27');

      expect(deadlines.first.date, DateTime(2026, 7, 31));
      expect(deadlines.first.label, 'Original — Non-Audit');
    });

    test('last deadline (ITR-U) is March 31 two years after AY start', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2026-27');

      expect(deadlines.last.date, DateTime(2028, 3, 31));
      expect(deadlines.last.label, 'Updated Return (ITR-U)');
      expect(deadlines.last.itrTypes, contains('ITR-U'));
    });

    test('audit deadline is Oct 31 of AY start year', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2026-27');
      final auditDeadline = deadlines.firstWhere(
        (d) => d.label == 'Original — Audit',
      );

      expect(auditDeadline.date, DateTime(2026, 10, 31));
      expect(auditDeadline.itrTypes, containsAll(['ITR-3', 'ITR-5', 'ITR-6']));
    });

    test('transfer pricing deadline is Nov 30 of AY start year', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2026-27');
      final tpDeadline = deadlines.firstWhere(
        (d) => d.label == 'Original — Transfer Pricing',
      );

      expect(tpDeadline.date, DateTime(2026, 11, 30));
    });

    test('belated/revised deadline is Dec 31 of AY start year', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2026-27');
      final belatedDeadline = deadlines.firstWhere(
        (d) => d.label == 'Belated / Revised Return',
      );

      expect(belatedDeadline.date, DateTime(2026, 12, 31));
      expect(belatedDeadline.itrTypes, hasLength(6));
    });

    test('works for a different assessment year', () {
      final deadlines = FilingAnalyticsService.getDeadlineCalendar('2027-28');
      expect(deadlines.first.date, DateTime(2027, 7, 31));
      expect(deadlines.last.date, DateTime(2029, 3, 31));
    });
  });

  group('DeadlineEntry', () {
    test('equality — same fields are equal', () {
      final a = DeadlineEntry(
        label: 'Test Deadline',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1'],
        description: 'Test description',
      );
      final b = DeadlineEntry(
        label: 'Test Deadline',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1'],
        description: 'Test description',
      );

      expect(a, equals(b));
    });

    test('inequality — different itrTypes length', () {
      final a = DeadlineEntry(
        label: 'Test',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1'],
        description: 'desc',
      );
      final b = DeadlineEntry(
        label: 'Test',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1', 'ITR-2'],
        description: 'desc',
      );

      expect(a, isNot(equals(b)));
    });

    test('copyWith preserves unchanged fields', () {
      final original = DeadlineEntry(
        label: 'Test',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1'],
        description: 'desc',
      );
      final updated = original.copyWith(label: 'Updated');

      expect(updated.label, 'Updated');
      expect(updated.date, original.date);
      expect(updated.itrTypes, original.itrTypes);
    });

    test('hashCode is consistent for equal objects', () {
      final a = DeadlineEntry(
        label: 'Test',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1'],
        description: 'desc',
      );
      final b = DeadlineEntry(
        label: 'Test',
        date: DateTime(2026, 7, 31),
        itrTypes: const ['ITR-1'],
        description: 'desc',
      );

      expect(a.hashCode, b.hashCode);
    });
  });

  group('FilingStatistics', () {
    test('totalRevenue is collected + outstanding', () {
      const stats = FilingStatistics(
        totalFilings: 10,
        filedCount: 6,
        pendingCount: 4,
        overdueCount: 1,
        averageTurnaroundDays: 7.0,
        revenueCollected: 60000,
        revenueOutstanding: 40000,
      );

      expect(stats.totalRevenue, 100000.0);
    });

    test('empty() factory produces all-zero stats', () {
      final stats = FilingStatistics.empty();
      expect(stats.totalFilings, 0);
      expect(stats.totalRevenue, 0.0);
      expect(stats.completionRate, 0.0);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = FilingStatistics(
        totalFilings: 10,
        filedCount: 6,
        pendingCount: 4,
        overdueCount: 1,
        averageTurnaroundDays: 7.0,
        revenueCollected: 60000,
        revenueOutstanding: 40000,
      );
      final updated = original.copyWith(filedCount: 8);

      expect(updated.filedCount, 8);
      expect(updated.totalFilings, original.totalFilings);
    });
  });

  group('FilingAnalyticsService.computeStatistics — edge cases', () {
    test('filed jobs without filingDate are excluded from turnaround', () {
      final jobs = [
        makeJob(
          id: '1',
          status: FilingJobStatus.filed,
          filingDate: null, // no filing date
        ),
        makeJob(
          id: '2',
          status: FilingJobStatus.filed,
          createdAt: now.subtract(const Duration(days: 10)),
          filingDate: now,
        ),
      ];

      final stats = FilingAnalyticsService.computeStatistics(jobs);
      // Only job 2 contributes to turnaround
      expect(stats.averageTurnaroundDays, 10.0);
    });

    test('pending jobs without dueDate are not counted as overdue', () {
      final jobs = [
        makeJob(id: '1', status: FilingJobStatus.draft, dueDate: null),
        makeJob(id: '2', status: FilingJobStatus.notStarted, dueDate: null),
      ];

      final stats = FilingAnalyticsService.computeStatistics(jobs);
      expect(stats.overdueCount, 0);
    });

    test('filed jobs without feeReceived contribute 0 to revenue', () {
      final jobs = [
        makeJob(id: '1', status: FilingJobStatus.filed, feeReceived: null),
      ];

      final stats = FilingAnalyticsService.computeStatistics(jobs);
      expect(stats.revenueCollected, 0.0);
    });

    test('pending jobs without feeQuoted contribute 0 to outstanding', () {
      final jobs = [
        makeJob(id: '1', status: FilingJobStatus.draft, feeQuoted: null),
      ];

      final stats = FilingAnalyticsService.computeStatistics(jobs);
      expect(stats.revenueOutstanding, 0.0);
    });
  });
}

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
  });
}

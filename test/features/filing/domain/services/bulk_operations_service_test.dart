import 'package:ca_app/features/filing/domain/models/bulk/bulk_action.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/services/bulk_operations_service.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 6, 1);

  FilingJob makeJob({
    required String id,
    String clientName = 'Client',
    String pan = 'ABCDE1234F',
    String assessmentYear = '2025-26',
    FilingJobStatus status = FilingJobStatus.notStarted,
  }) {
    return FilingJob(
      id: id,
      clientId: 'c-$id',
      clientName: clientName,
      pan: pan,
      assessmentYear: assessmentYear,
      itrType: ItrType.itr1,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  final jobs = [
    makeJob(id: '1', clientName: 'Rahul Sharma', pan: 'ABCRS1234F'),
    makeJob(
      id: '2',
      clientName: 'Priya Patel',
      pan: 'XYZPP5678G',
      status: FilingJobStatus.filed,
    ),
    makeJob(
      id: '3',
      clientName: 'Amit Kumar',
      pan: 'LMNAK9012H',
      assessmentYear: '2024-25',
      status: FilingJobStatus.draft,
    ),
  ];

  group('BulkOperationsService.applyAction', () {
    test('updateStatus changes status of selected jobs only', () {
      const action = BulkAction(
        type: BulkActionType.updateStatus,
        targetStatus: FilingJobStatus.review,
      );

      final result = BulkOperationsService.applyAction(jobs, ['1'], action);

      expect(result, hasLength(3));
      expect(result[0].status, FilingJobStatus.review);
      expect(result[1].status, FilingJobStatus.filed); // unchanged
      expect(result[2].status, FilingJobStatus.draft); // unchanged
    });

    test('delete removes selected jobs from the list', () {
      const action = BulkAction(type: BulkActionType.delete);

      final result = BulkOperationsService.applyAction(jobs, [
        '1',
        '3',
      ], action);

      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('export returns a copy of the list unchanged', () {
      const action = BulkAction(type: BulkActionType.export);

      final result = BulkOperationsService.applyAction(jobs, ['1'], action);

      expect(result, hasLength(3));
      // Verify it is a new list (not identical reference)
      expect(identical(result, jobs), isFalse);
    });
  });

  group('BulkOperationsService.filterByStatus', () {
    test('returns only jobs matching the given status', () {
      final result = BulkOperationsService.filterByStatus(
        jobs,
        FilingJobStatus.filed,
      );

      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('returns empty list when no jobs match', () {
      final result = BulkOperationsService.filterByStatus(
        jobs,
        FilingJobStatus.verified,
      );

      expect(result, isEmpty);
    });
  });

  group('BulkOperationsService.filterByAssessmentYear', () {
    test('returns only jobs for the given assessment year', () {
      final result = BulkOperationsService.filterByAssessmentYear(
        jobs,
        '2024-25',
      );

      expect(result, hasLength(1));
      expect(result.first.id, '3');
    });

    test('returns empty list when no jobs match the year', () {
      final result = BulkOperationsService.filterByAssessmentYear(
        jobs,
        '2023-24',
      );

      expect(result, isEmpty);
    });
  });

  group('BulkOperationsService.searchJobs', () {
    test('searches by client name case-insensitively', () {
      final result = BulkOperationsService.searchJobs(jobs, 'rahul');

      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('searches by PAN case-insensitively', () {
      final result = BulkOperationsService.searchJobs(jobs, 'xyzpp');

      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('returns all jobs for empty query', () {
      final result = BulkOperationsService.searchJobs(jobs, '');

      expect(result, hasLength(3));
    });

    test('returns empty list when no match found', () {
      final result = BulkOperationsService.searchJobs(jobs, 'nonexistent');

      expect(result, isEmpty);
    });
  });
}

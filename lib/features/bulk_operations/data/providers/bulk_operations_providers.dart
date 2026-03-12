import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/filing_batch.dart';

// ---------------------------------------------------------------------------
// Batch list — 5 mock filing batches
// ---------------------------------------------------------------------------

final batchListProvider =
    NotifierProvider<BatchListNotifier, List<FilingBatch>>(
      BatchListNotifier.new,
    );

class BatchListNotifier extends Notifier<List<FilingBatch>> {
  @override
  List<FilingBatch> build() => List.unmodifiable(_mockBatches);

  void addBatch(FilingBatch batch) {
    state = List.unmodifiable([batch, ...state]);
  }

  void updateBatch(FilingBatch updated) {
    state = List.unmodifiable(
      state.map((b) => b.batchId == updated.batchId ? updated : b),
    );
  }

  void removeBatch(String batchId) {
    state = List.unmodifiable(state.where((b) => b.batchId != batchId));
  }

  void retryFailedJobs(String batchId) {
    state = List.unmodifiable(
      state.map((batch) {
        if (batch.batchId != batchId) return batch;
        final updatedJobs = batch.jobs.map((job) {
          if (job.status == JobStatus.failed) {
            return job.copyWith(status: JobStatus.retrying, errorMessage: null);
          }
          return job;
        }).toList();
        return batch.copyWith(
          jobs: List.unmodifiable(updatedJobs),
          status: BatchStatus.running,
        );
      }),
    );
  }

  void cancelBatch(String batchId) {
    state = List.unmodifiable(
      state.map((batch) {
        if (batch.batchId != batchId) return batch;
        return batch.copyWith(status: BatchStatus.cancelled);
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Active batch selection
// ---------------------------------------------------------------------------

final activeBatchProvider = NotifierProvider<ActiveBatchNotifier, FilingBatch?>(
  ActiveBatchNotifier.new,
);

class ActiveBatchNotifier extends Notifier<FilingBatch?> {
  @override
  FilingBatch? build() => null;

  void select(FilingBatch batch) => state = batch;

  void clear() => state = null;
}

// ---------------------------------------------------------------------------
// Batch stats — derived
// ---------------------------------------------------------------------------

class BatchStats {
  const BatchStats({
    required this.activeBatches,
    required this.totalJobs,
    required this.completedJobs,
    required this.failedJobs,
    required this.successRate,
  });

  final int activeBatches;
  final int totalJobs;
  final int completedJobs;
  final int failedJobs;
  final double successRate;
}

final batchStatsProvider = Provider<BatchStats>((ref) {
  final batches = ref.watch(batchListProvider);

  final activeBatches = batches
      .where(
        (b) =>
            b.status == BatchStatus.running || b.status == BatchStatus.queued,
      )
      .length;

  final allJobs = batches.expand((b) => b.jobs).toList();
  final totalJobs = allJobs.length;
  final completedJobs = allJobs
      .where((j) => j.status == JobStatus.success)
      .length;
  final failedJobs = allJobs.where((j) => j.status == JobStatus.failed).length;

  final finished = completedJobs + failedJobs;
  final successRate = finished > 0 ? completedJobs / finished * 100 : 0.0;

  return BatchStats(
    activeBatches: activeBatches,
    totalJobs: totalJobs,
    completedJobs: completedJobs,
    failedJobs: failedJobs,
    successRate: successRate,
  );
});

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _now = DateTime.now();

const _mockBatchJobs1 = <BatchJob>[
  BatchJob(
    jobId: 'job-101',
    clientName: 'Rajesh Kumar Sharma',
    clientId: '1',
    jobType: 'ITR-1',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-102',
    clientName: 'Priya Mehta',
    clientId: '2',
    jobType: 'ITR-1',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-103',
    clientName: 'Deepak Patel',
    clientId: '9',
    jobType: 'ITR-4',
    status: JobStatus.running,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-104',
    clientName: 'Vikram Singh Rathore',
    clientId: '14',
    jobType: 'ITR-1',
    status: JobStatus.queued,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-105',
    clientName: 'Anil Gupta HUF',
    clientId: '7',
    jobType: 'ITR-2',
    status: JobStatus.failed,
    errorMessage: 'PAN verification failed — mismatch with Form 26AS',
  ),
];

const _mockBatchJobs2 = <BatchJob>[
  BatchJob(
    jobId: 'job-201',
    clientName: 'ABC Infra Pvt Ltd',
    clientId: '3',
    jobType: 'GSTR-3B',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-202',
    clientName: 'Mehta & Sons',
    clientId: '4',
    jobType: 'GSTR-3B',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-203',
    clientName: 'TechVista Solutions LLP',
    clientId: '6',
    jobType: 'GSTR-3B',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-204',
    clientName: 'GreenLeaf Organics LLP',
    clientId: '13',
    jobType: 'GSTR-3B',
    status: JobStatus.failed,
    errorMessage: 'ITC mismatch — GSTR-2B reconciliation pending',
  ),
  BatchJob(
    jobId: 'job-205',
    clientName: 'Bharat Electronics Ltd',
    clientId: '8',
    jobType: 'GSTR-3B',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-206',
    clientName: 'Hindustan Traders AOP',
    clientId: '12',
    jobType: 'GSTR-3B',
    status: JobStatus.running,
    errorMessage: null,
  ),
];

const _mockBatchJobs3 = <BatchJob>[
  BatchJob(
    jobId: 'job-301',
    clientName: 'ABC Infra Pvt Ltd',
    clientId: '3',
    jobType: 'TDS 24Q',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-302',
    clientName: 'Bharat Electronics Ltd',
    clientId: '8',
    jobType: 'TDS 26Q',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-303',
    clientName: 'TechVista Solutions LLP',
    clientId: '6',
    jobType: 'TDS 24Q',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-304',
    clientName: 'Mehta & Sons',
    clientId: '4',
    jobType: 'TDS 26Q',
    status: JobStatus.success,
    errorMessage: null,
  ),
];

const _mockBatchJobs4 = <BatchJob>[
  BatchJob(
    jobId: 'job-401',
    clientName: 'Rajesh Kumar Sharma',
    clientId: '1',
    jobType: 'ITR-1',
    status: JobStatus.queued,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-402',
    clientName: 'Priya Mehta',
    clientId: '2',
    jobType: 'ITR-1',
    status: JobStatus.queued,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-403',
    clientName: 'Deepak Patel',
    clientId: '9',
    jobType: 'ITR-4',
    status: JobStatus.queued,
    errorMessage: null,
  ),
];

const _mockBatchJobs5 = <BatchJob>[
  BatchJob(
    jobId: 'job-501',
    clientName: 'ABC Infra Pvt Ltd',
    clientId: '3',
    jobType: 'GSTR-1',
    status: JobStatus.failed,
    errorMessage: 'HSN summary mismatch with B2B invoices',
  ),
  BatchJob(
    jobId: 'job-502',
    clientName: 'TechVista Solutions LLP',
    clientId: '6',
    jobType: 'GSTR-1',
    status: JobStatus.failed,
    errorMessage: 'E-invoice IRN not generated for 3 invoices',
  ),
  BatchJob(
    jobId: 'job-503',
    clientName: 'Bharat Electronics Ltd',
    clientId: '8',
    jobType: 'GSTR-1',
    status: JobStatus.success,
    errorMessage: null,
  ),
  BatchJob(
    jobId: 'job-504',
    clientName: 'Mehta & Sons',
    clientId: '4',
    jobType: 'GSTR-1',
    status: JobStatus.success,
    errorMessage: null,
  ),
];

final _mockBatches = <FilingBatch>[
  FilingBatch(
    batchId: 'batch-001',
    name: 'ITR Bulk — Mar 2026',
    type: BatchType.itrFiling,
    status: BatchStatus.running,
    jobs: _mockBatchJobs1,
    createdAt: _now.subtract(const Duration(hours: 3)),
    financialYear: 'AY 2026-27',
  ),
  FilingBatch(
    batchId: 'batch-002',
    name: 'GST 3B — Feb 2026',
    type: BatchType.gstFiling,
    status: BatchStatus.running,
    jobs: _mockBatchJobs2,
    createdAt: _now.subtract(const Duration(hours: 8)),
    financialYear: 'FY 2025-26',
  ),
  FilingBatch(
    batchId: 'batch-003',
    name: 'TDS Q3 Returns',
    type: BatchType.tdsReturns,
    status: BatchStatus.completed,
    jobs: _mockBatchJobs3,
    createdAt: _now.subtract(const Duration(days: 2)),
    financialYear: 'FY 2025-26 Q3',
  ),
  FilingBatch(
    batchId: 'batch-004',
    name: 'ITR Bulk — Pending Clients',
    type: BatchType.itrFiling,
    status: BatchStatus.queued,
    jobs: _mockBatchJobs4,
    createdAt: _now.subtract(const Duration(minutes: 30)),
    financialYear: 'AY 2026-27',
  ),
  FilingBatch(
    batchId: 'batch-005',
    name: 'GSTR-1 Jan 2026',
    type: BatchType.gstFiling,
    status: BatchStatus.failed,
    jobs: _mockBatchJobs5,
    createdAt: _now.subtract(const Duration(days: 1)),
    financialYear: 'FY 2025-26',
  ),
];

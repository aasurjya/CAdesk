import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
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
            return job.copyWith(status: JobStatus.queued);
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
      .where((j) => j.status == JobStatus.completed)
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

final _mockBatchJobs1 = <BatchJob>[
  BatchJob(
    jobId: 'job-101',
    name: 'Rajesh Kumar Sharma — ITR-1',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-101-1',
        clientName: 'Rajesh Kumar Sharma',
        pan: 'ABCPS1234A',
        payload: '{"form":"ITR-1","ay":"2026-27"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  BatchJob(
    jobId: 'job-102',
    name: 'Priya Mehta — ITR-1',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-102-1',
        clientName: 'Priya Mehta',
        pan: 'BMPPM5678B',
        payload: '{"form":"ITR-1","ay":"2026-27"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  BatchJob(
    jobId: 'job-103',
    name: 'Deepak Patel — ITR-4',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-103-1',
        clientName: 'Deepak Patel',
        pan: 'CNDPP9012C',
        payload: '{"form":"ITR-4","ay":"2026-27"}',
        status: BatchJobItemStatus.processing,
        attempts: 1,
      ),
    ],
    status: JobStatus.running,
    completedItems: 0,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  BatchJob(
    jobId: 'job-104',
    name: 'Vikram Singh Rathore — ITR-1',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-104-1',
        clientName: 'Vikram Singh Rathore',
        pan: 'DOVSR3456D',
        payload: '{"form":"ITR-1","ay":"2026-27"}',
        status: BatchJobItemStatus.pending,
        attempts: 0,
      ),
    ],
    status: JobStatus.queued,
    completedItems: 0,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  BatchJob(
    jobId: 'job-105',
    name: 'Anil Gupta HUF — ITR-2',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-105-1',
        clientName: 'Anil Gupta HUF',
        pan: 'EUFAG7890E',
        payload: '{"form":"ITR-2","ay":"2026-27"}',
        status: BatchJobItemStatus.failed,
        attempts: 2,
        error: 'PAN verification failed — mismatch with Form 26AS',
      ),
    ],
    status: JobStatus.failed,
    completedItems: 0,
    failedItems: 1,
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
];

final _mockBatchJobs2 = <BatchJob>[
  BatchJob(
    jobId: 'job-201',
    name: 'ABC Infra Pvt Ltd — GSTR-3B',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-201-1',
        clientName: 'ABC Infra Pvt Ltd',
        pan: '27AABCA1234A1ZA',
        payload: '{"form":"GSTR-3B","period":"022026"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
  BatchJob(
    jobId: 'job-202',
    name: 'Mehta & Sons — GSTR-3B',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-202-1',
        clientName: 'Mehta & Sons',
        pan: '24AABCM5678B1ZB',
        payload: '{"form":"GSTR-3B","period":"022026"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
  BatchJob(
    jobId: 'job-203',
    name: 'TechVista Solutions LLP — GSTR-3B',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-203-1',
        clientName: 'TechVista Solutions LLP',
        pan: '29AABCT9012C1ZC',
        payload: '{"form":"GSTR-3B","period":"022026"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
  BatchJob(
    jobId: 'job-204',
    name: 'GreenLeaf Organics LLP — GSTR-3B',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-204-1',
        clientName: 'GreenLeaf Organics LLP',
        pan: '06AABCG3456D1ZD',
        payload: '{"form":"GSTR-3B","period":"022026"}',
        status: BatchJobItemStatus.failed,
        attempts: 2,
        error: 'ITC mismatch — GSTR-2B reconciliation pending',
      ),
    ],
    status: JobStatus.failed,
    completedItems: 0,
    failedItems: 1,
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
  BatchJob(
    jobId: 'job-205',
    name: 'Bharat Electronics Ltd — GSTR-3B',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-205-1',
        clientName: 'Bharat Electronics Ltd',
        pan: '29AABCB7890E1ZE',
        payload: '{"form":"GSTR-3B","period":"022026"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
  BatchJob(
    jobId: 'job-206',
    name: 'Hindustan Traders AOP — GSTR-3B',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-206-1',
        clientName: 'Hindustan Traders AOP',
        pan: '27AABCH1234F1ZF',
        payload: '{"form":"GSTR-3B","period":"022026"}',
        status: BatchJobItemStatus.processing,
        attempts: 1,
      ),
    ],
    status: JobStatus.running,
    completedItems: 0,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
];

final _mockBatchJobs3 = <BatchJob>[
  BatchJob(
    jobId: 'job-301',
    name: 'ABC Infra Pvt Ltd — TDS 24Q',
    jobType: JobType.tdsFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-301-1',
        clientName: 'ABC Infra Pvt Ltd',
        pan: '27AABCA1234A1ZA',
        payload: '{"form":"24Q","quarter":"Q3","fy":"2025-26"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  BatchJob(
    jobId: 'job-302',
    name: 'Bharat Electronics Ltd — TDS 26Q',
    jobType: JobType.tdsFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-302-1',
        clientName: 'Bharat Electronics Ltd',
        pan: '29AABCB7890E1ZE',
        payload: '{"form":"26Q","quarter":"Q3","fy":"2025-26"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  BatchJob(
    jobId: 'job-303',
    name: 'TechVista Solutions LLP — TDS 24Q',
    jobType: JobType.tdsFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-303-1',
        clientName: 'TechVista Solutions LLP',
        pan: '29AABCT9012C1ZC',
        payload: '{"form":"24Q","quarter":"Q3","fy":"2025-26"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  BatchJob(
    jobId: 'job-304',
    name: 'Mehta & Sons — TDS 26Q',
    jobType: JobType.tdsFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-304-1',
        clientName: 'Mehta & Sons',
        pan: '24AABCM5678B1ZB',
        payload: '{"form":"26Q","quarter":"Q3","fy":"2025-26"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
];

final _mockBatchJobs4 = <BatchJob>[
  BatchJob(
    jobId: 'job-401',
    name: 'Rajesh Kumar Sharma — ITR-1',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-401-1',
        clientName: 'Rajesh Kumar Sharma',
        pan: 'ABCPS1234A',
        payload: '{"form":"ITR-1","ay":"2026-27"}',
        status: BatchJobItemStatus.pending,
        attempts: 0,
      ),
    ],
    status: JobStatus.queued,
    completedItems: 0,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(minutes: 30)),
  ),
  BatchJob(
    jobId: 'job-402',
    name: 'Priya Mehta — ITR-1',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-402-1',
        clientName: 'Priya Mehta',
        pan: 'BMPPM5678B',
        payload: '{"form":"ITR-1","ay":"2026-27"}',
        status: BatchJobItemStatus.pending,
        attempts: 0,
      ),
    ],
    status: JobStatus.queued,
    completedItems: 0,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(minutes: 30)),
  ),
  BatchJob(
    jobId: 'job-403',
    name: 'Deepak Patel — ITR-4',
    jobType: JobType.itrFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-403-1',
        clientName: 'Deepak Patel',
        pan: 'CNDPP9012C',
        payload: '{"form":"ITR-4","ay":"2026-27"}',
        status: BatchJobItemStatus.pending,
        attempts: 0,
      ),
    ],
    status: JobStatus.queued,
    completedItems: 0,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(minutes: 30)),
  ),
];

final _mockBatchJobs5 = <BatchJob>[
  BatchJob(
    jobId: 'job-501',
    name: 'ABC Infra Pvt Ltd — GSTR-1',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-501-1',
        clientName: 'ABC Infra Pvt Ltd',
        pan: '27AABCA1234A1ZA',
        payload: '{"form":"GSTR-1","period":"012026"}',
        status: BatchJobItemStatus.failed,
        attempts: 2,
        error: 'HSN summary mismatch with B2B invoices',
      ),
    ],
    status: JobStatus.failed,
    completedItems: 0,
    failedItems: 1,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
  BatchJob(
    jobId: 'job-502',
    name: 'TechVista Solutions LLP — GSTR-1',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-502-1',
        clientName: 'TechVista Solutions LLP',
        pan: '29AABCT9012C1ZC',
        payload: '{"form":"GSTR-1","period":"012026"}',
        status: BatchJobItemStatus.failed,
        attempts: 2,
        error: 'E-invoice IRN not generated for 3 invoices',
      ),
    ],
    status: JobStatus.failed,
    completedItems: 0,
    failedItems: 1,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
  BatchJob(
    jobId: 'job-503',
    name: 'Bharat Electronics Ltd — GSTR-1',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-503-1',
        clientName: 'Bharat Electronics Ltd',
        pan: '29AABCB7890E1ZE',
        payload: '{"form":"GSTR-1","period":"012026"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
  BatchJob(
    jobId: 'job-504',
    name: 'Mehta & Sons — GSTR-1',
    jobType: JobType.gstFiling,
    priority: JobPriority.normal,
    items: const [
      BatchJobItem(
        itemId: 'item-504-1',
        clientName: 'Mehta & Sons',
        pan: '24AABCM5678B1ZB',
        payload: '{"form":"GSTR-1","period":"012026"}',
        status: BatchJobItemStatus.completed,
        attempts: 1,
      ),
    ],
    status: JobStatus.completed,
    completedItems: 1,
    failedItems: 0,
    createdAt: _now.subtract(const Duration(days: 1)),
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

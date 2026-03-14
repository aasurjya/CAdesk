import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';
import 'package:ca_app/features/bulk_operations/domain/repositories/bulk_operations_repository.dart';

/// In-memory mock implementation of [BulkOperationsRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations use immutable patterns.
class MockBulkOperationsRepository implements BulkOperationsRepository {
  static final List<BatchJob> _seed = [
    BatchJob(
      jobId: 'mock-job-001',
      name: 'Bulk ITR Filing — FY 2024-25',
      jobType: JobType.itrFiling,
      priority: JobPriority.high,
      items: const [
        BatchJobItem(
          itemId: 'item-001',
          clientName: 'Ravi Kumar',
          pan: 'ABCDE1234F',
          payload: '{"assessmentYear":"2025-26","formType":"ITR-1"}',
          status: BatchJobItemStatus.completed,
          attempts: 1,
        ),
        BatchJobItem(
          itemId: 'item-002',
          clientName: 'Priya Sharma',
          pan: 'FGHIJ5678K',
          payload: '{"assessmentYear":"2025-26","formType":"ITR-2"}',
          status: BatchJobItemStatus.processing,
          attempts: 1,
        ),
      ],
      status: JobStatus.running,
      completedItems: 1,
      failedItems: 0,
      createdAt: DateTime(2026, 3, 1),
      startedAt: DateTime(2026, 3, 2),
    ),
    BatchJob(
      jobId: 'mock-job-002',
      name: 'Bulk GST Filing — February 2026',
      jobType: JobType.gstFiling,
      priority: JobPriority.normal,
      items: const [
        BatchJobItem(
          itemId: 'item-003',
          clientName: 'Mehta & Sons',
          pan: 'GSTIN27AAACM1234K1Z5',
          payload: '{"period":"2026-02","formType":"GSTR-1"}',
          status: BatchJobItemStatus.completed,
          attempts: 1,
        ),
      ],
      status: JobStatus.completed,
      completedItems: 1,
      failedItems: 0,
      createdAt: DateTime(2026, 2, 25),
      startedAt: DateTime(2026, 2, 26),
      completedAt: DateTime(2026, 2, 26),
    ),
    BatchJob(
      jobId: 'mock-job-003',
      name: 'TDS Filing — Q3 FY 2025-26',
      jobType: JobType.tdsFiling,
      priority: JobPriority.critical,
      items: const [],
      status: JobStatus.queued,
      completedItems: 0,
      failedItems: 0,
      createdAt: DateTime(2026, 3, 10),
    ),
  ];

  final List<BatchJob> _state = List.of(_seed);

  @override
  Future<List<BatchJob>> getAllJobs() async {
    return List.unmodifiable(_state);
  }

  @override
  Future<BatchJob?> getJobById(String jobId) async {
    try {
      return _state.firstWhere((j) => j.jobId == jobId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BatchJob>> getJobsByStatus(JobStatus status) async {
    return List.unmodifiable(_state.where((j) => j.status == status).toList());
  }

  @override
  Future<String> insertJob(BatchJob job) async {
    _state.add(job);
    return job.jobId;
  }

  @override
  Future<bool> updateJob(BatchJob job) async {
    final idx = _state.indexWhere((j) => j.jobId == job.jobId);
    if (idx == -1) return false;
    final updated = List<BatchJob>.of(_state)..[idx] = job;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteJob(String jobId) async {
    final before = _state.length;
    _state.removeWhere((j) => j.jobId == jobId);
    return _state.length < before;
  }
}

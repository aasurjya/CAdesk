import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';

/// Type of bulk filing operation.
enum BatchType {
  /// Bulk ITR filing.
  itrFiling(label: 'ITR Filing'),

  /// Bulk GST filing.
  gstFiling(label: 'GST Filing'),

  /// Bulk TDS returns.
  tdsReturns(label: 'TDS Returns'),

  /// Bulk Form 16 generation.
  form16Bulk(label: 'Form 16 Bulk');

  const BatchType({required this.label});

  final String label;
}

/// Overall status of a filing batch.
enum BatchStatus {
  /// All jobs are queued, none started.
  queued(label: 'Queued'),

  /// At least one job is running.
  running(label: 'Running'),

  /// All jobs completed successfully.
  completed(label: 'Completed'),

  /// Some jobs failed.
  failed(label: 'Failed'),

  /// Batch was cancelled by the user.
  cancelled(label: 'Cancelled');

  const BatchStatus({required this.label});

  final String label;
}

/// A bulk filing batch containing multiple jobs.
class FilingBatch {
  const FilingBatch({
    required this.batchId,
    required this.name,
    required this.type,
    required this.status,
    required this.jobs,
    required this.createdAt,
    required this.financialYear,
  });

  /// Unique batch identifier.
  final String batchId;

  /// Human-readable batch name.
  final String name;

  /// Type of filing in this batch.
  final BatchType type;

  /// Overall batch status.
  final BatchStatus status;

  /// All jobs in the batch.
  final List<BatchJob> jobs;

  /// When the batch was created.
  final DateTime createdAt;

  /// Financial year / period for the batch.
  final String financialYear;

  /// Number of completed (success) jobs.
  int get completedCount =>
      jobs.where((j) => j.status == JobStatus.completed).length;

  /// Number of failed jobs.
  int get failedCount => jobs.where((j) => j.status == JobStatus.failed).length;

  /// Progress as a fraction in [0.0, 1.0].
  double get progress => jobs.isEmpty ? 0.0 : completedCount / jobs.length;

  /// Success rate as a percentage.
  double get successRate {
    final finished = completedCount + failedCount;
    if (finished == 0) return 0.0;
    return completedCount / finished * 100;
  }

  FilingBatch copyWith({
    String? batchId,
    String? name,
    BatchType? type,
    BatchStatus? status,
    List<BatchJob>? jobs,
    DateTime? createdAt,
    String? financialYear,
  }) {
    return FilingBatch(
      batchId: batchId ?? this.batchId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      createdAt: createdAt ?? this.createdAt,
      financialYear: financialYear ?? this.financialYear,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingBatch &&
        other.batchId == batchId &&
        other.name == name &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(batchId, name, type, status);
}

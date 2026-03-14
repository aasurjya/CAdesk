import 'package:ca_app/features/bulk_operations/domain/models/batch_job.dart';
import 'package:ca_app/features/bulk_operations/domain/models/batch_job_item.dart';

/// Bi-directional converter between [BatchJob] domain model
/// and Supabase JSON maps.
class BulkOperationsMapper {
  const BulkOperationsMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → BatchJob domain model
  // ---------------------------------------------------------------------------
  static BatchJob fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.map((i) => _itemFromJson(i as Map<String, dynamic>)).toList()
        : <BatchJobItem>[];

    return BatchJob(
      jobId: json['job_id'] as String,
      name: json['name'] as String? ?? '',
      jobType: _parseJobType(json['job_type'] as String?),
      priority: _parsePriority(json['priority'] as String?),
      items: items,
      status: _parseStatus(json['status'] as String?),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completedItems: json['completed_items'] as int? ?? 0,
      failedItems: json['failed_items'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // BatchJob domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(BatchJob job) {
    return {
      'job_id': job.jobId,
      'name': job.name,
      'job_type': job.jobType.name,
      'priority': job.priority.name,
      'items': job.items.map(_itemToJson).toList(),
      'status': job.status.name,
      'started_at': job.startedAt?.toIso8601String(),
      'completed_at': job.completedAt?.toIso8601String(),
      'completed_items': job.completedItems,
      'failed_items': job.failedItems,
      'created_at': job.createdAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static BatchJobItem _itemFromJson(Map<String, dynamic> json) {
    return BatchJobItem(
      itemId: json['item_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      payload: json['payload'] as String? ?? '{}',
      status: _parseItemStatus(json['status'] as String?),
      attempts: json['attempts'] as int? ?? 0,
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'] as String)
          : null,
      error: json['error'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> _itemToJson(BatchJobItem item) {
    return {
      'item_id': item.itemId,
      'client_name': item.clientName,
      'pan': item.pan,
      'payload': item.payload,
      'status': item.status.name,
      'attempts': item.attempts,
      'last_attempt_at': item.lastAttemptAt?.toIso8601String(),
      'error': item.error,
      'completed_at': item.completedAt?.toIso8601String(),
    };
  }

  static JobType _parseJobType(String? raw) {
    switch (raw) {
      case 'gstFiling':
        return JobType.gstFiling;
      case 'tdsFiling':
        return JobType.tdsFiling;
      case 'bulkExport':
        return JobType.bulkExport;
      case 'bulkSigning':
        return JobType.bulkSigning;
      case 'itrFiling':
      default:
        return JobType.itrFiling;
    }
  }

  static JobPriority _parsePriority(String? raw) {
    switch (raw) {
      case 'low':
        return JobPriority.low;
      case 'high':
        return JobPriority.high;
      case 'critical':
        return JobPriority.critical;
      case 'normal':
      default:
        return JobPriority.normal;
    }
  }

  static JobStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'running':
        return JobStatus.running;
      case 'paused':
        return JobStatus.paused;
      case 'completed':
        return JobStatus.completed;
      case 'failed':
        return JobStatus.failed;
      case 'cancelled':
        return JobStatus.cancelled;
      case 'queued':
      default:
        return JobStatus.queued;
    }
  }

  static BatchJobItemStatus _parseItemStatus(String? raw) {
    switch (raw) {
      case 'processing':
        return BatchJobItemStatus.processing;
      case 'completed':
        return BatchJobItemStatus.completed;
      case 'failed':
        return BatchJobItemStatus.failed;
      case 'skipped':
        return BatchJobItemStatus.skipped;
      case 'pending':
      default:
        return BatchJobItemStatus.pending;
    }
  }
}

import 'package:ca_app/features/filing/domain/models/bulk/bulk_action.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';

/// Stateless service that applies bulk operations to filing job lists.
///
/// Every method returns a **new** list — the originals are never mutated.
class BulkOperationsService {
  const BulkOperationsService._();

  /// Applies [action] to every job whose id is in [selectedIds].
  ///
  /// Returns a new list with the affected jobs replaced by updated copies.
  /// For [BulkActionType.delete], selected jobs are removed from the list.
  /// For [BulkActionType.export], the list is returned unchanged (export is
  /// handled by the caller).
  static List<FilingJob> applyAction(
    List<FilingJob> jobs,
    List<String> selectedIds,
    BulkAction action,
  ) {
    final selectedSet = selectedIds.toSet();

    switch (action.type) {
      case BulkActionType.updateStatus:
        return _mapSelected(jobs, selectedSet, (job) {
          if (action.targetStatus == null) return job;
          return job.copyWith(status: action.targetStatus);
        });

      case BulkActionType.assignTo:
        return _mapSelected(jobs, selectedSet, (job) {
          if (action.assignee == null) return job;
          return job.copyWith(assignedTo: action.assignee);
        });

      case BulkActionType.setPriority:
        return _mapSelected(jobs, selectedSet, (job) {
          if (action.priority == null) return job;
          return job.copyWith(priority: action.priority);
        });

      case BulkActionType.delete:
        return jobs.where((job) => !selectedSet.contains(job.id)).toList();

      case BulkActionType.export:
        // Export is a side-effect handled by the caller; return as-is.
        return List<FilingJob>.of(jobs);
    }
  }

  /// Returns only jobs matching the given [status].
  static List<FilingJob> filterByStatus(
    List<FilingJob> jobs,
    FilingJobStatus status,
  ) {
    return jobs.where((job) => job.status == status).toList();
  }

  /// Returns only jobs for the given [assessmentYear] (e.g. "2025-26").
  static List<FilingJob> filterByAssessmentYear(
    List<FilingJob> jobs,
    String assessmentYear,
  ) {
    return jobs.where((job) => job.assessmentYear == assessmentYear).toList();
  }

  /// Case-insensitive search across client name and PAN.
  static List<FilingJob> searchJobs(List<FilingJob> jobs, String query) {
    if (query.isEmpty) return List<FilingJob>.of(jobs);

    final lowerQuery = query.toLowerCase();
    return jobs.where((job) {
      final nameMatch = job.clientName.toLowerCase().contains(lowerQuery);
      final panMatch = job.pan.toLowerCase().contains(lowerQuery);
      return nameMatch || panMatch;
    }).toList();
  }

  // ── Private helpers ──────────────────────────────────────────────────

  /// Maps over [jobs], applying [transform] only to jobs whose id is in
  /// [selectedIds]. Returns a new list.
  static List<FilingJob> _mapSelected(
    List<FilingJob> jobs,
    Set<String> selectedIds,
    FilingJob Function(FilingJob job) transform,
  ) {
    return jobs.map((job) {
      if (selectedIds.contains(job.id)) {
        return transform(job);
      }
      return job;
    }).toList();
  }
}

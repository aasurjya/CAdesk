import 'package:ca_app/features/filing/domain/models/filing_job.dart';

/// Abstract repository for filing job persistence.
///
/// Concrete implementations can be in-memory (dev), Drift (local), or
/// Supabase/Firebase (cloud sync). The domain layer depends only on
/// this interface.
abstract class FilingJobRepository {
  /// Retrieve all filing jobs.
  Future<List<FilingJob>> getAll();

  /// Retrieve jobs for a specific assessment year.
  Future<List<FilingJob>> getByAssessmentYear(String assessmentYear);

  /// Retrieve a single job by ID. Returns `null` if not found.
  Future<FilingJob?> getById(String id);

  /// Persist a filing job (insert or update).
  Future<void> save(FilingJob job);

  /// Delete a filing job by ID.
  Future<void> delete(String id);

  /// Search jobs by client name or PAN (case-insensitive).
  Future<List<FilingJob>> search(String query);
}

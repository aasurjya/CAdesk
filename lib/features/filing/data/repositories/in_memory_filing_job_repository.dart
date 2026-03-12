import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/repositories/filing_job_repository.dart';

/// In-memory implementation of [FilingJobRepository] for development/testing.
///
/// Data lives only in the current process — replaced by Drift or cloud
/// implementation in production.
class InMemoryFilingJobRepository implements FilingJobRepository {
  InMemoryFilingJobRepository([List<FilingJob>? seed])
    : _store = {for (final j in seed ?? <FilingJob>[]) j.id: j};

  final Map<String, FilingJob> _store;

  @override
  Future<List<FilingJob>> getAll() async {
    return List.unmodifiable(
      _store.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
  }

  @override
  Future<List<FilingJob>> getByAssessmentYear(String assessmentYear) async {
    return List.unmodifiable(
      _store.values.where((j) => j.assessmentYear == assessmentYear).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
  }

  @override
  Future<FilingJob?> getById(String id) async {
    return _store[id];
  }

  @override
  Future<void> save(FilingJob job) async {
    _store[job.id] = job;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<FilingJob>> search(String query) async {
    final q = query.toLowerCase();
    return List.unmodifiable(
      _store.values.where((j) {
        return j.clientName.toLowerCase().contains(q) ||
            j.pan.toLowerCase().contains(q);
      }).toList(),
    );
  }
}

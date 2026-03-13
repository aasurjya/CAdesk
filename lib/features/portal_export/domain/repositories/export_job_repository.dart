import 'package:ca_app/features/portal_export/domain/models/export_job.dart';

abstract class ExportJobRepository {
  Future<void> insert(ExportJob job);
  Future<List<ExportJob>> getByClient(String clientId);
  Future<List<ExportJob>> getByStatus(ExportJobStatus status);
  Future<bool> updateStatus(
    String id,
    ExportJobStatus status, {
    String? filePath,
    String? errorMessage,
    DateTime? completedAt,
  });
  Future<int> deleteOldJobs(DateTime beforeDate);
  Future<ExportJob?> getById(String id);
  Stream<List<ExportJob>> watchByClient(String clientId);
}

import 'package:ca_app/features/cma/domain/models/cma_report.dart';

/// Abstract contract for CMA data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class CmaRepository {
  /// Retrieve all CMA reports for a given [clientId].
  Future<List<CmaReport>> getReportsByClient(String clientId);

  /// Retrieve a single [CmaReport] by [id]. Returns null if not found.
  Future<CmaReport?> getReportById(String id);

  /// Insert a new [CmaReport] and return its ID.
  Future<String> insertReport(CmaReport report);

  /// Update an existing [CmaReport]. Returns true on success.
  Future<bool> updateReport(CmaReport report);

  /// Delete the CMA report identified by [id]. Returns true on success.
  Future<bool> deleteReport(String id);

  /// Retrieve all CMA reports.
  Future<List<CmaReport>> getAllReports();
}

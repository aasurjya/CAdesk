import 'package:ca_app/features/virtual_cfo/domain/models/cfo_scenario.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/mis_report.dart';

/// Abstract contract for Virtual CFO data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class VirtualCfoRepository {
  /// Retrieve all MIS reports.
  Future<List<MisReport>> getAllReports();

  /// Retrieve MIS reports for a given [clientName].
  Future<List<MisReport>> getReportsByClient(String clientName);

  /// Insert a new [MisReport]. Returns its ID.
  Future<String> insertReport(MisReport report);

  /// Update an existing [MisReport]. Returns true on success.
  Future<bool> updateReport(MisReport report);

  /// Delete a MIS report by [id]. Returns true on success.
  Future<bool> deleteReport(String id);

  /// Retrieve all CFO scenarios.
  Future<List<CfoScenario>> getAllScenarios();

  /// Retrieve scenarios for a given [clientName].
  Future<List<CfoScenario>> getScenariosByClient(String clientName);

  /// Insert a new [CfoScenario]. Returns its ID.
  Future<String> insertScenario(CfoScenario scenario);

  /// Update an existing [CfoScenario]. Returns true on success.
  Future<bool> updateScenario(CfoScenario scenario);
}

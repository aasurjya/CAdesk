import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

/// Abstract contract for ESG reporting data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class EsgReportingRepository {
  /// Insert a new [EsgDisclosure] and return its generated ID.
  Future<String> insertDisclosure(EsgDisclosure disclosure);

  /// Retrieve all ESG disclosures.
  Future<List<EsgDisclosure>> getAllDisclosures();

  /// Retrieve disclosures filtered by [status].
  Future<List<EsgDisclosure>> getDisclosuresByStatus(String status);

  /// Retrieve disclosures filtered by [clientPan].
  Future<List<EsgDisclosure>> getDisclosuresByClient(String clientPan);

  /// Update an existing [EsgDisclosure]. Returns true on success.
  Future<bool> updateDisclosure(EsgDisclosure disclosure);

  /// Delete the disclosure identified by [id]. Returns true on success.
  Future<bool> deleteDisclosure(String id);

  /// Insert a new [CarbonMetric] and return its generated ID.
  Future<String> insertCarbonMetric(CarbonMetric metric);

  /// Retrieve all carbon metrics.
  Future<List<CarbonMetric>> getAllCarbonMetrics();

  /// Retrieve carbon metrics for a specific [clientName].
  Future<List<CarbonMetric>> getCarbonMetricsByClient(String clientName);

  /// Retrieve carbon metrics for a specific [reportingYear].
  Future<List<CarbonMetric>> getCarbonMetricsByYear(String reportingYear);

  /// Update an existing [CarbonMetric]. Returns true on success.
  Future<bool> updateCarbonMetric(CarbonMetric metric);

  /// Delete the carbon metric identified by [id]. Returns true on success.
  Future<bool> deleteCarbonMetric(String id);
}

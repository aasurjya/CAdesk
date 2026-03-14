import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';

/// Abstract contract for AI automation data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class AiAutomationRepository {
  /// Insert a new [AiScanResult] and return its generated ID.
  Future<String> insertScanResult(AiScanResult result);

  /// Retrieve all AI scan results.
  Future<List<AiScanResult>> getAllScanResults();

  /// Retrieve scan results filtered by [status].
  Future<List<AiScanResult>> getScanResultsByStatus(ScanStatus status);

  /// Update an existing [AiScanResult]. Returns true on success.
  Future<bool> updateScanResult(AiScanResult result);

  /// Delete the scan result identified by [id]. Returns true on success.
  Future<bool> deleteScanResult(String id);

  /// Insert a new [AutomationInsight] and return its generated ID.
  Future<String> insertInsight(AutomationInsight insight);

  /// Retrieve all automation insights.
  Future<List<AutomationInsight>> getAllInsights();

  /// Retrieve insights filtered by [status].
  Future<List<AutomationInsight>> getInsightsByStatus(
    AutomationInsightStatus status,
  );

  /// Update an existing [AutomationInsight]. Returns true on success.
  Future<bool> updateInsight(AutomationInsight insight);

  /// Delete the insight identified by [id]. Returns true on success.
  Future<bool> deleteInsight(String id);
}

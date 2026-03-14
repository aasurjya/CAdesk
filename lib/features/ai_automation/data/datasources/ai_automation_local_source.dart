import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';

/// Local (SQLite via Drift) data source for AI automation.
///
/// Note: full DAO wiring is deferred until the AI automation tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class AiAutomationLocalSource {
  const AiAutomationLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertScanResult(AiScanResult result) async => result.id;

  Future<List<AiScanResult>> getAllScanResults() async => const [];

  Future<bool> updateScanResult(AiScanResult result) async => false;

  Future<bool> deleteScanResult(String id) async => false;

  Future<String> insertInsight(AutomationInsight insight) async => insight.id;

  Future<List<AutomationInsight>> getAllInsights() async => const [];

  Future<bool> updateInsight(AutomationInsight insight) async => false;

  Future<bool> deleteInsight(String id) async => false;
}

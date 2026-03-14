import 'package:ca_app/features/ai_automation/data/datasources/ai_automation_local_source.dart';
import 'package:ca_app/features/ai_automation/data/datasources/ai_automation_remote_source.dart';
import 'package:ca_app/features/ai_automation/data/mappers/ai_automation_mapper.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';
import 'package:ca_app/features/ai_automation/domain/repositories/ai_automation_repository.dart';

/// Real implementation of [AiAutomationRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class AiAutomationRepositoryImpl implements AiAutomationRepository {
  const AiAutomationRepositoryImpl({required this.remote, required this.local});

  final AiAutomationRemoteSource remote;
  final AiAutomationLocalSource local;

  @override
  Future<String> insertScanResult(AiScanResult result) async {
    try {
      final json = await remote.insertScanResult(
        AiAutomationMapper.scanToJson(result),
      );
      final created = AiAutomationMapper.scanFromJson(json);
      await local.insertScanResult(created);
      return created.id;
    } catch (_) {
      return local.insertScanResult(result);
    }
  }

  @override
  Future<List<AiScanResult>> getAllScanResults() async {
    try {
      final jsonList = await remote.fetchAllScanResults();
      final results = jsonList.map(AiAutomationMapper.scanFromJson).toList();
      for (final r in results) {
        await local.insertScanResult(r);
      }
      return List.unmodifiable(results);
    } catch (_) {
      return local.getAllScanResults();
    }
  }

  @override
  Future<List<AiScanResult>> getScanResultsByStatus(ScanStatus status) async {
    try {
      final jsonList = await remote.fetchScanResultsByStatus(status.name);
      final results = jsonList.map(AiAutomationMapper.scanFromJson).toList();
      return List.unmodifiable(results);
    } catch (_) {
      final all = await local.getAllScanResults();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    }
  }

  @override
  Future<bool> updateScanResult(AiScanResult result) async {
    try {
      await remote.updateScanResult(
        result.id,
        AiAutomationMapper.scanToJson(result),
      );
      await local.updateScanResult(result);
      return true;
    } catch (_) {
      return local.updateScanResult(result);
    }
  }

  @override
  Future<bool> deleteScanResult(String id) async {
    try {
      await remote.deleteScanResult(id);
      await local.deleteScanResult(id);
      return true;
    } catch (_) {
      return local.deleteScanResult(id);
    }
  }

  @override
  Future<String> insertInsight(AutomationInsight insight) async {
    try {
      final json = await remote.insertInsight(
        AiAutomationMapper.insightToJson(insight),
      );
      final created = AiAutomationMapper.insightFromJson(json);
      await local.insertInsight(created);
      return created.id;
    } catch (_) {
      return local.insertInsight(insight);
    }
  }

  @override
  Future<List<AutomationInsight>> getAllInsights() async {
    try {
      final jsonList = await remote.fetchAllInsights();
      final insights = jsonList
          .map(AiAutomationMapper.insightFromJson)
          .toList();
      for (final i in insights) {
        await local.insertInsight(i);
      }
      return List.unmodifiable(insights);
    } catch (_) {
      return local.getAllInsights();
    }
  }

  @override
  Future<List<AutomationInsight>> getInsightsByStatus(
    AutomationInsightStatus status,
  ) async {
    try {
      final all = await getAllInsights();
      return List.unmodifiable(all.where((i) => i.status == status).toList());
    } catch (_) {
      final all = await local.getAllInsights();
      return List.unmodifiable(all.where((i) => i.status == status).toList());
    }
  }

  @override
  Future<bool> updateInsight(AutomationInsight insight) async {
    try {
      await remote.updateInsight(
        insight.id,
        AiAutomationMapper.insightToJson(insight),
      );
      await local.updateInsight(insight);
      return true;
    } catch (_) {
      return local.updateInsight(insight);
    }
  }

  @override
  Future<bool> deleteInsight(String id) async {
    try {
      await remote.deleteInsight(id);
      await local.deleteInsight(id);
      return true;
    } catch (_) {
      return local.deleteInsight(id);
    }
  }
}

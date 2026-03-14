import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ai_automation/data/repositories/mock_ai_automation_repository.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';

void main() {
  late MockAiAutomationRepository repo;

  setUp(() {
    repo = MockAiAutomationRepository();
  });

  group('MockAiAutomationRepository - AiScanResult', () {
    test('getAllScanResults returns non-empty seeded list', () async {
      final results = await repo.getAllScanResults();
      expect(results, isNotEmpty);
    });

    test('getScanResultsByStatus filters correctly', () async {
      final results = await repo.getScanResultsByStatus(ScanStatus.completed);
      for (final r in results) {
        expect(r.status, ScanStatus.completed);
      }
    });

    test('insertScanResult adds entry and returns id', () async {
      final entry = AiScanResult(
        id: 'scan-new-001',
        documentName: 'Test PAN.pdf',
        documentType: DocumentType.panCard,
        extractedData: const {'pan': 'ABCDE1234F'},
        confidence: 0.92,
        scannedAt: DateTime(2026, 3, 1),
        status: ScanStatus.completed,
        clientName: 'Test Client',
      );
      final id = await repo.insertScanResult(entry);
      expect(id, 'scan-new-001');

      final all = await repo.getAllScanResults();
      expect(all.any((r) => r.id == 'scan-new-001'), isTrue);
    });

    test('updateScanResult updates status and returns true', () async {
      final all = await repo.getAllScanResults();
      final first = all.first;
      final updated = first.copyWith(status: ScanStatus.reviewNeeded);
      final success = await repo.updateScanResult(updated);
      expect(success, isTrue);

      final refetched = await repo.getAllScanResults();
      final found = refetched.firstWhere((r) => r.id == first.id);
      expect(found.status, ScanStatus.reviewNeeded);
    });

    test('updateScanResult returns false for non-existent id', () async {
      final ghost = AiScanResult(
        id: 'non-existent-scan',
        documentName: 'Ghost.pdf',
        documentType: DocumentType.other,
        extractedData: const {},
        confidence: 0.5,
        scannedAt: DateTime(2026, 1, 1),
        status: ScanStatus.failed,
        clientName: 'Nobody',
      );
      final success = await repo.updateScanResult(ghost);
      expect(success, isFalse);
    });

    test('deleteScanResult removes entry and returns true', () async {
      final all = await repo.getAllScanResults();
      final target = all.first;
      final deleted = await repo.deleteScanResult(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllScanResults();
      expect(remaining.any((r) => r.id == target.id), isFalse);
    });

    test('deleteScanResult returns false for non-existent id', () async {
      final deleted = await repo.deleteScanResult('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockAiAutomationRepository - AutomationInsight', () {
    test('getAllInsights returns non-empty seeded list', () async {
      final insights = await repo.getAllInsights();
      expect(insights, isNotEmpty);
    });

    test('getInsightsByStatus filters correctly', () async {
      final insights = await repo.getInsightsByStatus(
        AutomationInsightStatus.onTrack,
      );
      for (final i in insights) {
        expect(i.status, AutomationInsightStatus.onTrack);
      }
    });

    test('insertInsight adds entry and returns id', () async {
      final insight = AutomationInsight(
        id: 'insight-new-001',
        title: 'New Insight',
        clientName: 'Client X',
        description: 'Description',
        metricLabel: 'Accuracy',
        metricValue: '95%',
        actionLabel: 'Review',
        icon: const IconData(0xe000),
        color: const Color(0xFF1A7A3A),
        status: AutomationInsightStatus.onTrack,
      );
      final id = await repo.insertInsight(insight);
      expect(id, 'insight-new-001');
    });

    test('updateInsight returns true on success', () async {
      final all = await repo.getAllInsights();
      final first = all.first;
      final updated = first.copyWith(status: AutomationInsightStatus.blocked);
      final success = await repo.updateInsight(updated);
      expect(success, isTrue);
    });

    test('updateInsight returns false for non-existent id', () async {
      final ghost = AutomationInsight(
        id: 'non-existent-insight',
        title: 'Ghost',
        clientName: 'Nobody',
        description: 'N/A',
        metricLabel: 'N/A',
        metricValue: '0',
        actionLabel: 'None',
        icon: const IconData(0xe000),
        color: const Color(0xFF000000),
        status: AutomationInsightStatus.blocked,
      );
      final success = await repo.updateInsight(ghost);
      expect(success, isFalse);
    });

    test('deleteInsight removes entry and returns true', () async {
      final all = await repo.getAllInsights();
      final target = all.first;
      final deleted = await repo.deleteInsight(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllInsights();
      expect(remaining.any((i) => i.id == target.id), isFalse);
    });

    test('deleteInsight returns false for non-existent id', () async {
      final deleted = await repo.deleteInsight('no-such-id');
      expect(deleted, isFalse);
    });
  });
}

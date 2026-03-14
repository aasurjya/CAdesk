import 'package:flutter/material.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';
import 'package:ca_app/features/ai_automation/domain/repositories/ai_automation_repository.dart';

/// In-memory mock implementation of [AiAutomationRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockAiAutomationRepository implements AiAutomationRepository {
  static final List<AiScanResult> _seedScanResults = [
    AiScanResult(
      id: 'scan-001',
      documentName: 'Sharma_PAN_Card.pdf',
      documentType: DocumentType.panCard,
      extractedData: const {
        'pan': 'ABCDE1234F',
        'name': 'Rajesh Sharma',
        'dob': '15/08/1980',
      },
      confidence: 0.96,
      scannedAt: DateTime(2026, 3, 10),
      status: ScanStatus.completed,
      clientName: 'Rajesh Sharma',
    ),
    AiScanResult(
      id: 'scan-002',
      documentName: 'Verma_Form16_FY2526.pdf',
      documentType: DocumentType.form16,
      extractedData: const {
        'employer': 'TCS Ltd',
        'gross_salary': '1200000',
        'tds': '85000',
      },
      confidence: 0.88,
      scannedAt: DateTime(2026, 3, 11),
      status: ScanStatus.reviewNeeded,
      clientName: 'Priya Verma',
    ),
    AiScanResult(
      id: 'scan-003',
      documentName: 'Mehta_BankStatement_Feb.pdf',
      documentType: DocumentType.bankStatement,
      extractedData: const {
        'account_number': 'XXXX5678',
        'closing_balance': '250000',
      },
      confidence: 0.72,
      scannedAt: DateTime(2026, 3, 12),
      status: ScanStatus.completed,
      clientName: 'Suresh Mehta',
    ),
  ];

  static final List<AutomationInsight> _seedInsights = [
    AutomationInsight(
      id: 'insight-001',
      title: 'GST Reconciliation Alert',
      clientName: 'Tata Steel Ltd',
      description: '3 invoices with mismatched GSTIN detected in GSTR-2B.',
      metricLabel: 'Mismatch Count',
      metricValue: '3',
      actionLabel: 'Reconcile Now',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFFC62828),
      status: AutomationInsightStatus.attentionNeeded,
    ),
    AutomationInsight(
      id: 'insight-002',
      title: 'TDS Filing On Track',
      clientName: 'Infosys Ltd',
      description: 'Q4 TDS returns filed on time for all 120 deductees.',
      metricLabel: 'Completion',
      metricValue: '100%',
      actionLabel: 'View Report',
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF1A7A3A),
      status: AutomationInsightStatus.onTrack,
    ),
    AutomationInsight(
      id: 'insight-003',
      title: 'ITR Filing Blocked',
      clientName: 'Sharma & Associates',
      description:
          'Outstanding demand under section 143(1) prevents ITR filing.',
      metricLabel: 'Demand Amount',
      metricValue: '₹85,000',
      actionLabel: 'Resolve Demand',
      icon: Icons.block_rounded,
      color: const Color(0xFFD4890E),
      status: AutomationInsightStatus.blocked,
    ),
  ];

  final List<AiScanResult> _scanResults = List.of(_seedScanResults);
  final List<AutomationInsight> _insights = List.of(_seedInsights);

  @override
  Future<String> insertScanResult(AiScanResult result) async {
    _scanResults.add(result);
    return result.id;
  }

  @override
  Future<List<AiScanResult>> getAllScanResults() async =>
      List.unmodifiable(_scanResults);

  @override
  Future<List<AiScanResult>> getScanResultsByStatus(ScanStatus status) async =>
      List.unmodifiable(_scanResults.where((r) => r.status == status).toList());

  @override
  Future<bool> updateScanResult(AiScanResult result) async {
    final idx = _scanResults.indexWhere((r) => r.id == result.id);
    if (idx == -1) return false;
    final updated = List<AiScanResult>.of(_scanResults)..[idx] = result;
    _scanResults
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteScanResult(String id) async {
    final before = _scanResults.length;
    _scanResults.removeWhere((r) => r.id == id);
    return _scanResults.length < before;
  }

  @override
  Future<String> insertInsight(AutomationInsight insight) async {
    _insights.add(insight);
    return insight.id;
  }

  @override
  Future<List<AutomationInsight>> getAllInsights() async =>
      List.unmodifiable(_insights);

  @override
  Future<List<AutomationInsight>> getInsightsByStatus(
    AutomationInsightStatus status,
  ) async =>
      List.unmodifiable(_insights.where((i) => i.status == status).toList());

  @override
  Future<bool> updateInsight(AutomationInsight insight) async {
    final idx = _insights.indexWhere((i) => i.id == insight.id);
    if (idx == -1) return false;
    final updated = List<AutomationInsight>.of(_insights)..[idx] = insight;
    _insights
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteInsight(String id) async {
    final before = _insights.length;
    _insights.removeWhere((i) => i.id == id);
    return _insights.length < before;
  }
}

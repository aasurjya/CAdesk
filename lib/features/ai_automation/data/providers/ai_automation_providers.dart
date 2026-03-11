import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';
import 'package:ca_app/features/ai_automation/domain/models/bank_reconciliation.dart';
import 'package:ca_app/features/ai_automation/domain/models/anomaly_alert.dart';

// ---------------------------------------------------------------------------
// Scan Results
// ---------------------------------------------------------------------------

/// All OCR scan results.
final allScanResultsProvider =
    NotifierProvider<AllScanResultsNotifier, List<AiScanResult>>(
        AllScanResultsNotifier.new);

class AllScanResultsNotifier extends Notifier<List<AiScanResult>> {
  @override
  List<AiScanResult> build() => _mockScanResults;

  void update(List<AiScanResult> value) => state = value;
}

/// Filter index for scan status: 0=All, 1=Completed, 2=Processing, 3=Review.
final scanStatusFilterProvider =
    NotifierProvider<ScanStatusFilterNotifier, int>(
        ScanStatusFilterNotifier.new);

class ScanStatusFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Scan summary counts.
final scanCountsProvider = Provider<Map<String, int>>((ref) {
  final scans = ref.watch(allScanResultsProvider);
  return {
    'all': scans.length,
    'completed': scans.where((s) => s.status == ScanStatus.completed).length,
    'processing': scans.where((s) => s.status == ScanStatus.processing).length,
    'review':
        scans.where((s) => s.status == ScanStatus.reviewNeeded).length,
    'failed': scans.where((s) => s.status == ScanStatus.failed).length,
  };
});

/// Filtered scan results.
final filteredScanResultsProvider = Provider<List<AiScanResult>>((ref) {
  final scans = ref.watch(allScanResultsProvider);
  final filter = ref.watch(scanStatusFilterProvider);

  switch (filter) {
    case 1:
      return scans.where((s) => s.status == ScanStatus.completed).toList();
    case 2:
      return scans.where((s) => s.status == ScanStatus.processing).toList();
    case 3:
      return scans.where((s) => s.status == ScanStatus.reviewNeeded).toList();
    default:
      return scans;
  }
});

// ---------------------------------------------------------------------------
// Bank Reconciliation
// ---------------------------------------------------------------------------

/// All bank reconciliation entries.
final allReconciliationsProvider =
    NotifierProvider<AllReconciliationsNotifier, List<BankReconciliation>>(
        AllReconciliationsNotifier.new);

class AllReconciliationsNotifier extends Notifier<List<BankReconciliation>> {
  @override
  List<BankReconciliation> build() => _mockReconciliations;

  void update(List<BankReconciliation> value) => state = value;
}

/// Filter index for match status: 0=All, 1=Auto, 2=Manual, 3=Unmatched, 4=Disputed.
final reconStatusFilterProvider =
    NotifierProvider<ReconStatusFilterNotifier, int>(
        ReconStatusFilterNotifier.new);

class ReconStatusFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Reconciliation summary counts.
final reconCountsProvider = Provider<Map<String, int>>((ref) {
  final recons = ref.watch(allReconciliationsProvider);
  return {
    'all': recons.length,
    'autoMatched':
        recons.where((r) => r.matchStatus == MatchStatus.autoMatched).length,
    'manual': recons.where((r) => r.matchStatus == MatchStatus.manual).length,
    'unmatched':
        recons.where((r) => r.matchStatus == MatchStatus.unmatched).length,
    'disputed':
        recons.where((r) => r.matchStatus == MatchStatus.disputed).length,
  };
});

/// Filtered reconciliation list.
final filteredReconciliationsProvider =
    Provider<List<BankReconciliation>>((ref) {
  final recons = ref.watch(allReconciliationsProvider);
  final filter = ref.watch(reconStatusFilterProvider);

  switch (filter) {
    case 1:
      return recons
          .where((r) => r.matchStatus == MatchStatus.autoMatched)
          .toList();
    case 2:
      return recons
          .where((r) => r.matchStatus == MatchStatus.manual)
          .toList();
    case 3:
      return recons
          .where((r) => r.matchStatus == MatchStatus.unmatched)
          .toList();
    case 4:
      return recons
          .where((r) => r.matchStatus == MatchStatus.disputed)
          .toList();
    default:
      return recons;
  }
});

// ---------------------------------------------------------------------------
// Anomaly Alerts
// ---------------------------------------------------------------------------

/// All anomaly alerts.
final allAnomalyAlertsProvider =
    NotifierProvider<AllAnomalyAlertsNotifier, List<AnomalyAlert>>(
        AllAnomalyAlertsNotifier.new);

class AllAnomalyAlertsNotifier extends Notifier<List<AnomalyAlert>> {
  @override
  List<AnomalyAlert> build() => _mockAnomalyAlerts;

  void update(List<AnomalyAlert> value) => state = value;
}

/// Filter: 0=All, 1=Unresolved, 2=Resolved.
final anomalyFilterProvider =
    NotifierProvider<AnomalyFilterNotifier, int>(AnomalyFilterNotifier.new);

class AnomalyFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Anomaly summary counts.
final anomalyCountsProvider = Provider<Map<String, int>>((ref) {
  final alerts = ref.watch(allAnomalyAlertsProvider);
  return {
    'all': alerts.length,
    'unresolved': alerts.where((a) => !a.isResolved).length,
    'resolved': alerts.where((a) => a.isResolved).length,
    'critical':
        alerts.where((a) => a.severity == AlertSeverity.critical).length,
  };
});

/// Filtered anomaly alerts.
final filteredAnomalyAlertsProvider = Provider<List<AnomalyAlert>>((ref) {
  final alerts = ref.watch(allAnomalyAlertsProvider);
  final filter = ref.watch(anomalyFilterProvider);

  switch (filter) {
    case 1:
      return alerts.where((a) => !a.isResolved).toList();
    case 2:
      return alerts.where((a) => a.isResolved).toList();
    default:
      return alerts;
  }
});

final automationInsightsProvider =
    NotifierProvider<AutomationInsightsNotifier, List<AutomationInsight>>(
        AutomationInsightsNotifier.new);

class AutomationInsightsNotifier extends Notifier<List<AutomationInsight>> {
  @override
  List<AutomationInsight> build() => _mockAutomationInsights;

  void update(List<AutomationInsight> value) => state = value;
}

final automationInsightCountsProvider = Provider<Map<String, int>>((ref) {
  final insights = ref.watch(automationInsightsProvider);
  return {
    'all': insights.length,
    'attention': insights
        .where((i) => i.status == AutomationInsightStatus.attentionNeeded)
        .length,
    'blocked':
        insights.where((i) => i.status == AutomationInsightStatus.blocked).length,
    'onTrack':
        insights.where((i) => i.status == AutomationInsightStatus.onTrack).length,
  };
});

// ---------------------------------------------------------------------------
// Mock Data
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final _mockScanResults = <AiScanResult>[
  AiScanResult(
    id: 'scan-001',
    documentName: 'Rajesh_Kumar_Form16_2025.pdf',
    documentType: DocumentType.form16,
    extractedData: {
      'employerName': 'Tata Consultancy Services',
      'pan': 'ABCPK1234F',
      'grossSalary': '18,50,000',
      'taxDeducted': '2,15,000',
    },
    confidence: 0.96,
    scannedAt: _now.subtract(const Duration(hours: 2)),
    status: ScanStatus.completed,
    clientName: 'Rajesh Kumar',
  ),
  AiScanResult(
    id: 'scan-002',
    documentName: 'ABC_PvtLtd_BankStmt_Feb2026.pdf',
    documentType: DocumentType.bankStatement,
    extractedData: {
      'bankName': 'HDFC Bank',
      'accountNo': 'XXXX1234',
      'period': 'Feb 2026',
      'closingBalance': '45,23,890',
    },
    confidence: 0.92,
    scannedAt: _now.subtract(const Duration(hours: 5)),
    status: ScanStatus.completed,
    clientName: 'ABC Pvt Ltd',
  ),
  AiScanResult(
    id: 'scan-003',
    documentName: 'Priya_Sharma_PAN.jpg',
    documentType: DocumentType.panCard,
    extractedData: {
      'name': 'Priya Sharma',
      'pan': 'BGHPS5678K',
      'dob': '15/03/1990',
    },
    confidence: 0.98,
    scannedAt: _now.subtract(const Duration(hours: 8)),
    status: ScanStatus.completed,
    clientName: 'Priya Sharma',
  ),
  AiScanResult(
    id: 'scan-004',
    documentName: 'Mehta_Sons_Form26AS_2025.pdf',
    documentType: DocumentType.form26as,
    extractedData: {
      'pan': 'AABFM3456H',
      'assessmentYear': '2026-27',
      'totalTdsCredit': '8,34,500',
    },
    confidence: 0.88,
    scannedAt: _now.subtract(const Duration(hours: 12)),
    status: ScanStatus.completed,
    clientName: 'Mehta & Sons',
  ),
  AiScanResult(
    id: 'scan-005',
    documentName: 'XYZ_Industries_Invoice_Mar2026.pdf',
    documentType: DocumentType.invoice,
    extractedData: {
      'invoiceNo': 'INV-2026-0342',
      'vendor': 'Steel Authority of India',
      'amount': '12,45,000',
      'gstAmount': '2,24,100',
    },
    confidence: 0.73,
    scannedAt: _now.subtract(const Duration(minutes: 30)),
    status: ScanStatus.reviewNeeded,
    clientName: 'XYZ Industries',
  ),
  AiScanResult(
    id: 'scan-006',
    documentName: 'Sharma_Enterprises_Aadhaar.jpg',
    documentType: DocumentType.aadhaarCard,
    extractedData: {
      'name': 'Vikram Sharma',
      'aadhaarNo': 'XXXX XXXX 5678',
    },
    confidence: 0.95,
    scannedAt: _now.subtract(const Duration(days: 1)),
    status: ScanStatus.completed,
    clientName: 'Sharma Enterprises',
  ),
  AiScanResult(
    id: 'scan-007',
    documentName: 'Global_Tech_GSTReturn_Feb2026.pdf',
    documentType: DocumentType.gstReturn,
    extractedData: {
      'gstin': '27AABCG1234E1ZK',
      'period': 'Feb 2026',
      'totalTaxPayable': '3,12,450',
    },
    confidence: 0.45,
    scannedAt: _now.subtract(const Duration(hours: 1)),
    status: ScanStatus.failed,
    clientName: 'Global Tech Solutions',
  ),
  AiScanResult(
    id: 'scan-008',
    documentName: 'Kapoor_Holdings_BalSheet_2025.pdf',
    documentType: DocumentType.balanceSheet,
    extractedData: {
      'totalAssets': '5,42,00,000',
      'totalLiabilities': '2,18,00,000',
    },
    confidence: 0.67,
    scannedAt: _now.subtract(const Duration(minutes: 15)),
    status: ScanStatus.processing,
    clientName: 'Kapoor Holdings',
  ),
  AiScanResult(
    id: 'scan-009',
    documentName: 'Rajesh_Kumar_Form16_PartB.pdf',
    documentType: DocumentType.form16,
    extractedData: {
      'employerName': 'Tata Consultancy Services',
      'section80C': '1,50,000',
      'section80D': '25,000',
    },
    confidence: 0.91,
    scannedAt: _now.subtract(const Duration(hours: 3)),
    status: ScanStatus.completed,
    clientName: 'Rajesh Kumar',
  ),
  AiScanResult(
    id: 'scan-010',
    documentName: 'ABC_PvtLtd_ITR_Draft.pdf',
    documentType: DocumentType.itrForm,
    extractedData: {
      'assessmentYear': '2026-27',
      'totalIncome': '1,25,00,000',
      'taxPayable': '35,75,000',
    },
    confidence: 0.78,
    scannedAt: _now.subtract(const Duration(minutes: 45)),
    status: ScanStatus.reviewNeeded,
    clientName: 'ABC Pvt Ltd',
  ),
];

final _mockReconciliations = <BankReconciliation>[
  BankReconciliation(
    id: 'recon-001',
    bankEntry: 'NEFT Cr - TCS Salary Feb 2026',
    bookEntry: 'Salary Income - Feb 2026',
    matchConfidence: 0.98,
    matchStatus: MatchStatus.autoMatched,
    reconciledAt: _now.subtract(const Duration(hours: 1)),
    amountInr: 154167,
    clientName: 'Rajesh Kumar',
    bankName: 'SBI',
  ),
  BankReconciliation(
    id: 'recon-002',
    bankEntry: 'RTGS Cr - ABC Pvt Ltd Invoice #342',
    bookEntry: 'Sales Revenue - Invoice 342',
    matchConfidence: 0.95,
    matchStatus: MatchStatus.autoMatched,
    reconciledAt: _now.subtract(const Duration(hours: 3)),
    amountInr: 1245000,
    clientName: 'ABC Pvt Ltd',
    bankName: 'HDFC Bank',
  ),
  BankReconciliation(
    id: 'recon-003',
    bankEntry: 'UPI Dr - Vendor Payment Ref#8834',
    bookEntry: 'Office Supplies - Staples India',
    matchConfidence: 0.72,
    matchStatus: MatchStatus.manual,
    reconciledAt: _now.subtract(const Duration(hours: 6)),
    amountInr: -34500,
    clientName: 'Mehta & Sons',
    bankName: 'ICICI Bank',
  ),
  BankReconciliation(
    id: 'recon-004',
    bankEntry: 'NEFT Dr - GST Payment Feb 2026',
    bookEntry: 'GST Payable - Feb 2026',
    matchConfidence: 0.99,
    matchStatus: MatchStatus.autoMatched,
    reconciledAt: _now.subtract(const Duration(hours: 2)),
    amountInr: -312450,
    clientName: 'Global Tech Solutions',
    bankName: 'Kotak Mahindra',
  ),
  BankReconciliation(
    id: 'recon-005',
    bankEntry: 'IMPS Cr - Unknown Transfer',
    bookEntry: '',
    matchConfidence: 0.0,
    matchStatus: MatchStatus.unmatched,
    reconciledAt: _now.subtract(const Duration(hours: 4)),
    amountInr: 250000,
    clientName: 'XYZ Industries',
    bankName: 'Axis Bank',
  ),
  BankReconciliation(
    id: 'recon-006',
    bankEntry: 'Cheque Cr - Client Advance #1122',
    bookEntry: 'Advance from Customers - Kapoor',
    matchConfidence: 0.85,
    matchStatus: MatchStatus.autoMatched,
    reconciledAt: _now.subtract(const Duration(hours: 8)),
    amountInr: 500000,
    clientName: 'Kapoor Holdings',
    bankName: 'PNB',
  ),
  BankReconciliation(
    id: 'recon-007',
    bankEntry: 'NEFT Dr - TDS Payment Q4',
    bookEntry: 'TDS Payable - Q4 FY2025-26',
    matchConfidence: 0.93,
    matchStatus: MatchStatus.autoMatched,
    reconciledAt: _now.subtract(const Duration(hours: 5)),
    amountInr: -215000,
    clientName: 'Sharma Enterprises',
    bankName: 'Bank of Baroda',
  ),
  BankReconciliation(
    id: 'recon-008',
    bankEntry: 'RTGS Dr - Machinery Purchase',
    bookEntry: 'Fixed Assets - Plant & Machinery',
    matchConfidence: 0.55,
    matchStatus: MatchStatus.disputed,
    reconciledAt: _now.subtract(const Duration(days: 1)),
    amountInr: -1850000,
    clientName: 'XYZ Industries',
    bankName: 'Axis Bank',
  ),
  BankReconciliation(
    id: 'recon-009',
    bankEntry: 'UPI Cr - Rent Received Mar 2026',
    bookEntry: 'Rental Income - March',
    matchConfidence: 0.88,
    matchStatus: MatchStatus.autoMatched,
    reconciledAt: _now.subtract(const Duration(hours: 10)),
    amountInr: 75000,
    clientName: 'Priya Sharma',
    bankName: 'SBI',
  ),
  BankReconciliation(
    id: 'recon-010',
    bankEntry: 'NEFT Dr - Professional Fees',
    bookEntry: '',
    matchConfidence: 0.0,
    matchStatus: MatchStatus.unmatched,
    reconciledAt: _now.subtract(const Duration(hours: 7)),
    amountInr: -125000,
    clientName: 'ABC Pvt Ltd',
    bankName: 'HDFC Bank',
  ),
];

final _mockAnomalyAlerts = <AnomalyAlert>[
  AnomalyAlert(
    id: 'anomaly-001',
    clientId: 'client-004',
    clientName: 'XYZ Industries',
    transactionId: 'txn-4421',
    alertType: AlertType.unusualAmount,
    severity: AlertSeverity.critical,
    description:
        'Payment of INR 18.5L to unknown vendor is 4x higher than average '
        'machinery purchases for this client.',
    detectedAt: _now.subtract(const Duration(hours: 2)),
    isResolved: false,
    amountInr: 1850000,
  ),
  AnomalyAlert(
    id: 'anomaly-002',
    clientId: 'client-002',
    clientName: 'ABC Pvt Ltd',
    transactionId: 'txn-3302',
    alertType: AlertType.duplicate,
    severity: AlertSeverity.high,
    description:
        'Duplicate GST payment detected for Feb 2026. INR 3.12L paid twice '
        'on 5th and 8th March via NEFT.',
    detectedAt: _now.subtract(const Duration(hours: 6)),
    isResolved: false,
    amountInr: 312450,
  ),
  AnomalyAlert(
    id: 'anomaly-003',
    clientId: 'client-003',
    clientName: 'Mehta & Sons',
    transactionId: 'txn-2215',
    alertType: AlertType.patternBreak,
    severity: AlertSeverity.medium,
    description:
        'Monthly vendor payment to Staples India increased by 280% compared '
        'to the 6-month average. Usual range: INR 8K-12K.',
    detectedAt: _now.subtract(const Duration(days: 1)),
    isResolved: false,
    amountInr: 34500,
  ),
  AnomalyAlert(
    id: 'anomaly-004',
    clientId: 'client-007',
    clientName: 'Global Tech Solutions',
    transactionId: 'txn-5501',
    alertType: AlertType.missingEntry,
    severity: AlertSeverity.high,
    description:
        'TDS deduction of INR 1.25L recorded in Form 26AS but no '
        'corresponding book entry found for Q4 FY2025-26.',
    detectedAt: _now.subtract(const Duration(hours: 12)),
    isResolved: false,
    amountInr: 125000,
  ),
  AnomalyAlert(
    id: 'anomaly-005',
    clientId: 'client-001',
    clientName: 'Rajesh Kumar',
    transactionId: 'txn-1102',
    alertType: AlertType.unusualAmount,
    severity: AlertSeverity.low,
    description:
        'Cash deposit of INR 2.5L detected on 2nd March. This is above the '
        'client\'s usual monthly cash transaction pattern.',
    detectedAt: _now.subtract(const Duration(days: 2)),
    isResolved: true,
    amountInr: 250000,
  ),
];

final _mockAutomationInsights = <AutomationInsight>[
  AutomationInsight(
    id: 'automation-001',
    title: 'AI Notice Analyzer',
    clientName: 'Mehta & Sons',
    description:
        'Section 143(1) variance detected between AIS income and drafted ITR. '
        'Preliminary response and reconciliation note are ready.',
    metricLabel: 'Due',
    metricValue: '2 days',
    actionLabel: 'Review draft',
    icon: Icons.gavel_rounded,
    color: const Color(0xFFC62828),
    status: AutomationInsightStatus.attentionNeeded,
  ),
  AutomationInsight(
    id: 'automation-002',
    title: 'Agentic OTP Manager',
    clientName: '14 consented clients',
    description:
        'OTP capture queue processed for Income Tax, GST, and MCA logins. '
        'Most sessions completed without manual follow-up.',
    metricLabel: 'Auto-captured today',
    metricValue: '14 OTPs',
    actionLabel: 'Open queue',
    icon: Icons.password_rounded,
    color: const Color(0xFF1565C0),
    status: AutomationInsightStatus.onTrack,
  ),
  AutomationInsight(
    id: 'automation-003',
    title: 'Missing Data Identifier',
    clientName: 'Rajesh Kumar Sharma',
    description:
        'The uploaded bank statement set is missing January 2026 and one page '
        'from the CAMS capital gains statement.',
    metricLabel: 'Missing items',
    metricValue: '2 files',
    actionLabel: 'Send reminder',
    icon: Icons.find_in_page_rounded,
    color: const Color(0xFFEF6C00),
    status: AutomationInsightStatus.attentionNeeded,
  ),
  AutomationInsight(
    id: 'automation-004',
    title: 'AI Workload Balancer',
    clientName: 'Tax season queue',
    description:
        'Tasks were rebalanced across the team based on billable capacity, '
        'GST expertise, and notice-response turnaround times.',
    metricLabel: 'Tasks re-assigned',
    metricValue: '8 today',
    actionLabel: 'View workload',
    icon: Icons.hub_rounded,
    color: const Color(0xFF1A7A3A),
    status: AutomationInsightStatus.onTrack,
  ),
  AutomationInsight(
    id: 'automation-005',
    title: 'Smart Dependency Trigger',
    clientName: 'Bharat Electronics Ltd',
    description:
        'Audit completion triggered board-resolution drafting, MCA e-form prep, '
        'and client sign-off tasks automatically.',
    metricLabel: 'Downstream tasks',
    metricValue: '5 created',
    actionLabel: 'Inspect chain',
    icon: Icons.account_tree_rounded,
    color: const Color(0xFF6A1B9A),
    status: AutomationInsightStatus.onTrack,
  ),
  AutomationInsight(
    id: 'automation-006',
    title: 'Tax Advisory Opportunity Engine',
    clientName: '6 clients flagged this week',
    description:
        'Compliance review identified high-conversion advisory opportunities '
        'across capital gains, regime optimization, and SME tax planning.',
    metricLabel: 'Potential fees',
    metricValue: '₹2.7L',
    actionLabel: 'Open pipeline',
    icon: Icons.trending_up_rounded,
    color: const Color(0xFF00897B),
    status: AutomationInsightStatus.onTrack,
  ),
  AutomationInsight(
    id: 'automation-007',
    title: 'NRI Tax Desk Trigger',
    clientName: 'Priya Mehta',
    description:
        'Travel history and foreign asset disclosures suggest a cross-border '
        'filing package with FTC and DTAA review is required.',
    metricLabel: 'Next deadline',
    metricValue: '4 days',
    actionLabel: 'Request docs',
    icon: Icons.public_rounded,
    color: const Color(0xFF3949AB),
    status: AutomationInsightStatus.attentionNeeded,
  ),
  AutomationInsight(
    id: 'automation-008',
    title: 'SME CFO Retainer Upsell',
    clientName: 'Vikram Singh Rathore',
    description:
        'Repeated GST, bookkeeping, and working-capital queries indicate a '
        'strong fit for a monthly tax CFO advisory retainer.',
    metricLabel: 'Annualized value',
    metricValue: '₹96K',
    actionLabel: 'Send proposal',
    icon: Icons.business_center_rounded,
    color: const Color(0xFFEF6C00),
    status: AutomationInsightStatus.attentionNeeded,
  ),
];

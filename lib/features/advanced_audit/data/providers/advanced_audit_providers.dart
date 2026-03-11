import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/advanced_audit/domain/models/audit_checklist.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_finding.dart';

// ---------------------------------------------------------------------------
// Filter notifiers
// ---------------------------------------------------------------------------

/// Filter by audit type (null = show all).
final auditTypeFilterProvider =
    NotifierProvider<AuditTypeFilterNotifier, AuditType?>(
      AuditTypeFilterNotifier.new,
    );

class AuditTypeFilterNotifier extends Notifier<AuditType?> {
  @override
  AuditType? build() => null;

  void update(AuditType? value) => state = value;
}

/// Filter by finding severity (null = show all).
final findingSeverityFilterProvider =
    NotifierProvider<FindingSeverityFilterNotifier, FindingSeverity?>(
      FindingSeverityFilterNotifier.new,
    );

class FindingSeverityFilterNotifier extends Notifier<FindingSeverity?> {
  @override
  FindingSeverity? build() => null;

  void update(FindingSeverity? value) => state = value;
}

// ---------------------------------------------------------------------------
// Core data providers
// ---------------------------------------------------------------------------

final auditEngagementsProvider =
    NotifierProvider<AuditEngagementsNotifier, List<AuditEngagement>>(
      AuditEngagementsNotifier.new,
    );

class AuditEngagementsNotifier extends Notifier<List<AuditEngagement>> {
  @override
  List<AuditEngagement> build() => _mockEngagements;

  void add(AuditEngagement engagement) {
    state = [...state, engagement];
  }

  void updateEngagement(AuditEngagement updated) {
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e,
    ];
  }
}

final auditFindingsProvider =
    NotifierProvider<AuditFindingsNotifier, List<AuditFinding>>(
      AuditFindingsNotifier.new,
    );

class AuditFindingsNotifier extends Notifier<List<AuditFinding>> {
  @override
  List<AuditFinding> build() => _mockFindings;

  void add(AuditFinding finding) {
    state = [...state, finding];
  }

  void updateFinding(AuditFinding updated) {
    state = [
      for (final f in state)
        if (f.id == updated.id) updated else f,
    ];
  }
}

final auditChecklistsProvider =
    NotifierProvider<AuditChecklistsNotifier, List<AuditChecklist>>(
      AuditChecklistsNotifier.new,
    );

class AuditChecklistsNotifier extends Notifier<List<AuditChecklist>> {
  @override
  List<AuditChecklist> build() => _mockChecklists;

  void add(AuditChecklist checklist) {
    state = [...state, checklist];
  }

  void updateChecklist(AuditChecklist updated) {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }
}

// ---------------------------------------------------------------------------
// Derived / filtered providers
// ---------------------------------------------------------------------------

final filteredEngagementsProvider = Provider<List<AuditEngagement>>((ref) {
  final engagements = ref.watch(auditEngagementsProvider);
  final typeFilter = ref.watch(auditTypeFilterProvider);

  if (typeFilter == null) return engagements;
  return engagements.where((e) => e.auditType == typeFilter).toList();
});

final filteredFindingsProvider = Provider<List<AuditFinding>>((ref) {
  final findings = ref.watch(auditFindingsProvider);
  final severityFilter = ref.watch(findingSeverityFilterProvider);

  if (severityFilter == null) return findings;
  return findings.where((f) => f.severity == severityFilter).toList();
});

final filteredChecklistsProvider = Provider<List<AuditChecklist>>((ref) {
  final checklists = ref.watch(auditChecklistsProvider);
  final typeFilter = ref.watch(auditTypeFilterProvider);

  if (typeFilter == null) return checklists;
  return checklists.where((c) => c.auditType == typeFilter).toList();
});

// ---------------------------------------------------------------------------
// Mock data - 8 engagements
// ---------------------------------------------------------------------------

final _mockEngagements = <AuditEngagement>[
  AuditEngagement(
    id: 'ae1',
    clientId: 'c1',
    clientName: 'Reliance Retail Ltd',
    auditType: AuditType.statutory,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Rajesh Agarwal',
    teamMembers: ['Priya Nair', 'Amit Shah', 'Kavita Desai'],
    status: AuditStatus.fieldwork,
    startDate: DateTime(2026, 1, 15),
    reportDueDate: DateTime(2026, 5, 30),
    workpaperCount: 48,
    findingsCount: 5,
    riskLevel: AuditRiskLevel.high,
  ),
  AuditEngagement(
    id: 'ae2',
    clientId: 'c2',
    clientName: 'Tata Consultancy Services',
    auditType: AuditType.internal,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Meera Joshi',
    teamMembers: ['Arjun Mehta', 'Sunita Rao'],
    status: AuditStatus.review,
    startDate: DateTime(2025, 11, 1),
    reportDueDate: DateTime(2026, 3, 31),
    workpaperCount: 35,
    findingsCount: 3,
    riskLevel: AuditRiskLevel.medium,
  ),
  AuditEngagement(
    id: 'ae3',
    clientId: 'c3',
    clientName: 'Bajaj Auto Ltd',
    auditType: AuditType.stock,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Vikram Singh',
    teamMembers: ['Deepak Kumar', 'Neha Gupta'],
    status: AuditStatus.completed,
    startDate: DateTime(2025, 12, 1),
    endDate: DateTime(2026, 2, 15),
    reportDueDate: DateTime(2026, 3, 15),
    workpaperCount: 22,
    findingsCount: 1,
    riskLevel: AuditRiskLevel.low,
  ),
  AuditEngagement(
    id: 'ae4',
    clientId: 'c4',
    clientName: 'Hindalco Industries',
    auditType: AuditType.cost,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Suresh Iyer',
    teamMembers: ['Ravi Sharma', 'Asha Patel', 'Karan Malhotra'],
    status: AuditStatus.planning,
    startDate: DateTime(2026, 3, 1),
    reportDueDate: DateTime(2026, 7, 31),
    workpaperCount: 0,
    findingsCount: 0,
    riskLevel: AuditRiskLevel.medium,
  ),
  AuditEngagement(
    id: 'ae5',
    clientId: 'c5',
    clientName: 'Punjab National Bank',
    auditType: AuditType.forensic,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Rajesh Agarwal',
    teamMembers: ['Priya Nair', 'Arjun Mehta', 'Kavita Desai', 'Deepak Kumar'],
    status: AuditStatus.fieldwork,
    startDate: DateTime(2025, 10, 15),
    reportDueDate: DateTime(2026, 4, 30),
    workpaperCount: 67,
    findingsCount: 8,
    riskLevel: AuditRiskLevel.critical,
  ),
  AuditEngagement(
    id: 'ae6',
    clientId: 'c6',
    clientName: 'State Bank of India',
    auditType: AuditType.bank,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Meera Joshi',
    teamMembers: ['Sunita Rao', 'Neha Gupta', 'Ravi Sharma'],
    status: AuditStatus.reporting,
    startDate: DateTime(2025, 9, 1),
    reportDueDate: DateTime(2026, 3, 31),
    workpaperCount: 55,
    findingsCount: 4,
    riskLevel: AuditRiskLevel.high,
  ),
  AuditEngagement(
    id: 'ae7',
    clientId: 'c7',
    clientName: 'HDFC Bank Ltd',
    auditType: AuditType.concurrent,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Vikram Singh',
    teamMembers: ['Asha Patel', 'Karan Malhotra'],
    status: AuditStatus.fieldwork,
    startDate: DateTime(2026, 1, 1),
    reportDueDate: DateTime(2026, 3, 31),
    workpaperCount: 30,
    findingsCount: 2,
    riskLevel: AuditRiskLevel.medium,
  ),
  AuditEngagement(
    id: 'ae8',
    clientId: 'c8',
    clientName: 'Infosys Ltd',
    auditType: AuditType.statutory,
    financialYear: 'FY 2025-26',
    assignedPartner: 'CA Suresh Iyer',
    teamMembers: ['Amit Shah', 'Deepak Kumar'],
    status: AuditStatus.planning,
    startDate: DateTime(2026, 2, 15),
    reportDueDate: DateTime(2026, 6, 30),
    workpaperCount: 5,
    findingsCount: 0,
    riskLevel: AuditRiskLevel.low,
  ),
];

// ---------------------------------------------------------------------------
// Mock data - 15 findings
// ---------------------------------------------------------------------------

final _mockFindings = <AuditFinding>[
  AuditFinding(
    id: 'af1',
    engagementId: 'ae1',
    title: 'Revenue Recognition Timing Difference',
    description:
        'Revenue recorded in Q3 for goods shipped in Q4, resulting in '
        'early recognition of INR 2.3 Cr.',
    category: FindingCategory.materialMisstatement,
    severity: FindingSeverity.critical,
    recommendation:
        'Adjust revenue to correct period and implement cut-off '
        'procedures at quarter-end.',
    status: FindingStatus.open,
    reportedDate: DateTime(2026, 2, 10),
  ),
  AuditFinding(
    id: 'af2',
    engagementId: 'ae1',
    title: 'Inventory Obsolescence Provision Inadequate',
    description:
        'Slow-moving inventory of INR 85 lakhs not adequately '
        'provided for obsolescence.',
    category: FindingCategory.materialMisstatement,
    severity: FindingSeverity.high,
    recommendation: 'Review and adjust obsolescence provision per AS-2.',
    managementResponse: 'Will review and adjust in March closing.',
    status: FindingStatus.acknowledged,
    reportedDate: DateTime(2026, 2, 12),
  ),
  AuditFinding(
    id: 'af3',
    engagementId: 'ae1',
    title: 'Weak Segregation of Duties in Procurement',
    description: 'Same person can create PO, approve, and process payment.',
    category: FindingCategory.controlWeakness,
    severity: FindingSeverity.high,
    recommendation: 'Implement maker-checker controls in ERP system.',
    status: FindingStatus.open,
    reportedDate: DateTime(2026, 2, 15),
  ),
  AuditFinding(
    id: 'af4',
    engagementId: 'ae2',
    title: 'Data Backup Policy Not Followed',
    description: 'Weekly backup schedule not adhered to for 3 months.',
    category: FindingCategory.complianceGap,
    severity: FindingSeverity.medium,
    recommendation: 'Automate backup schedule and monitor compliance.',
    managementResponse: 'Automated backup configured effective immediately.',
    status: FindingStatus.remediated,
    reportedDate: DateTime(2026, 1, 20),
    resolvedDate: DateTime(2026, 2, 5),
  ),
  AuditFinding(
    id: 'af5',
    engagementId: 'ae2',
    title: 'Employee Expense Claims Without Receipts',
    description:
        '12% of expense claims above INR 5,000 lack supporting '
        'documentation.',
    category: FindingCategory.controlWeakness,
    severity: FindingSeverity.medium,
    recommendation: 'Enforce mandatory receipt attachment in expense system.',
    status: FindingStatus.acknowledged,
    reportedDate: DateTime(2026, 1, 25),
  ),
  AuditFinding(
    id: 'af6',
    engagementId: 'ae2',
    title: 'IT Access Rights Review Overdue',
    description: 'Quarterly access review not performed for critical systems.',
    category: FindingCategory.complianceGap,
    severity: FindingSeverity.low,
    recommendation: 'Schedule quarterly access review and document results.',
    managementResponse: 'Review completed and process documented.',
    status: FindingStatus.closed,
    reportedDate: DateTime(2026, 1, 15),
    resolvedDate: DateTime(2026, 2, 10),
  ),
  AuditFinding(
    id: 'af7',
    engagementId: 'ae3',
    title: 'Minor Stock Count Variances',
    description: 'Physical count variance of 0.3% within acceptable range.',
    category: FindingCategory.processImprovement,
    severity: FindingSeverity.low,
    recommendation: 'Implement cycle counting for high-value items.',
    managementResponse: 'Accepted. Will implement from next quarter.',
    status: FindingStatus.closed,
    reportedDate: DateTime(2026, 2, 1),
    resolvedDate: DateTime(2026, 2, 15),
  ),
  AuditFinding(
    id: 'af8',
    engagementId: 'ae5',
    title: 'Suspicious Related Party Transactions',
    description:
        'Multiple transactions with shell entities lacking '
        'business rationale, totalling INR 15 Cr.',
    category: FindingCategory.fraudIndicator,
    severity: FindingSeverity.critical,
    recommendation:
        'Escalate to Board Audit Committee and regulatory '
        'authorities immediately.',
    status: FindingStatus.open,
    reportedDate: DateTime(2025, 12, 20),
  ),
  AuditFinding(
    id: 'af9',
    engagementId: 'ae5',
    title: 'Fictitious Vendor Payments',
    description:
        'Three vendor accounts with identical bank details '
        'received payments of INR 4.5 Cr.',
    category: FindingCategory.fraudIndicator,
    severity: FindingSeverity.critical,
    recommendation:
        'Freeze vendor accounts and conduct detailed '
        'investigation with forensic evidence.',
    status: FindingStatus.open,
    reportedDate: DateTime(2025, 12, 22),
  ),
  AuditFinding(
    id: 'af10',
    engagementId: 'ae5',
    title: 'Loan Evergreening Pattern Detected',
    description:
        'Systematic renewal of NPA accounts through fresh '
        'disbursements to conceal defaults.',
    category: FindingCategory.fraudIndicator,
    severity: FindingSeverity.critical,
    recommendation: 'Report to RBI as per circular on loan classification.',
    status: FindingStatus.open,
    reportedDate: DateTime(2026, 1, 5),
  ),
  AuditFinding(
    id: 'af11',
    engagementId: 'ae6',
    title: 'KYC Documentation Gaps',
    description: '8% of high-value accounts missing updated KYC documents.',
    category: FindingCategory.complianceGap,
    severity: FindingSeverity.high,
    recommendation: 'Initiate KYC refresh drive for non-compliant accounts.',
    managementResponse: 'Drive initiated, target completion by April end.',
    status: FindingStatus.acknowledged,
    reportedDate: DateTime(2026, 2, 1),
  ),
  AuditFinding(
    id: 'af12',
    engagementId: 'ae6',
    title: 'Interest Calculation Discrepancy',
    description:
        'System-calculated interest differs from manual '
        'calculation for 15 savings accounts.',
    category: FindingCategory.controlWeakness,
    severity: FindingSeverity.medium,
    recommendation: 'Reconcile and fix interest calculation module.',
    status: FindingStatus.open,
    reportedDate: DateTime(2026, 2, 5),
  ),
  AuditFinding(
    id: 'af13',
    engagementId: 'ae7',
    title: 'Cash Handling Procedure Deviation',
    description: 'Branch cash verification not performed on 5 occasions.',
    category: FindingCategory.controlWeakness,
    severity: FindingSeverity.medium,
    recommendation: 'Reinforce daily cash verification protocol.',
    status: FindingStatus.acknowledged,
    reportedDate: DateTime(2026, 2, 8),
  ),
  AuditFinding(
    id: 'af14',
    engagementId: 'ae1',
    title: 'GST Input Credit Mismatch',
    description: 'Difference of INR 12 lakhs between GSTR-2B and books.',
    category: FindingCategory.complianceGap,
    severity: FindingSeverity.medium,
    recommendation:
        'Reconcile monthly and follow up with vendors for '
        'invoice corrections.',
    status: FindingStatus.open,
    reportedDate: DateTime(2026, 2, 18),
  ),
  AuditFinding(
    id: 'af15',
    engagementId: 'ae1',
    title: 'Fixed Asset Register Not Updated',
    description: 'Assets disposed in FY not removed from register.',
    category: FindingCategory.processImprovement,
    severity: FindingSeverity.low,
    recommendation: 'Update FAR and reconcile with physical verification.',
    status: FindingStatus.open,
    reportedDate: DateTime(2026, 2, 20),
  ),
];

// ---------------------------------------------------------------------------
// Mock data - 5 checklists
// ---------------------------------------------------------------------------

final _mockChecklists = <AuditChecklist>[
  AuditChecklist(
    id: 'ac1',
    auditType: AuditType.statutory,
    title: 'Statutory Audit - Planning Phase Checklist',
    totalItems: 10,
    completedItems: 8,
    items: [
      ChecklistItem(
        description: 'Obtain engagement letter signed by client',
        isCompleted: true,
        completedBy: 'CA Rajesh Agarwal',
        completedAt: DateTime(2026, 1, 16),
      ),
      ChecklistItem(
        description: 'Review prior year audit file and findings',
        isCompleted: true,
        completedBy: 'Priya Nair',
        completedAt: DateTime(2026, 1, 17),
      ),
      ChecklistItem(
        description: 'Assess entity-level controls (CARO 2020)',
        isCompleted: true,
        completedBy: 'Amit Shah',
        completedAt: DateTime(2026, 1, 18),
      ),
      ChecklistItem(
        description: 'Identify related parties under AS-18',
        isCompleted: true,
        completedBy: 'Kavita Desai',
        completedAt: DateTime(2026, 1, 19),
      ),
      ChecklistItem(
        description: 'Perform preliminary analytical procedures',
        isCompleted: true,
        completedBy: 'Priya Nair',
        completedAt: DateTime(2026, 1, 20),
      ),
      ChecklistItem(
        description: 'Determine materiality levels',
        isCompleted: true,
        completedBy: 'CA Rajesh Agarwal',
        completedAt: DateTime(2026, 1, 21),
      ),
      ChecklistItem(
        description: 'Prepare risk assessment matrix',
        isCompleted: true,
        completedBy: 'Amit Shah',
        completedAt: DateTime(2026, 1, 22),
      ),
      ChecklistItem(
        description: 'Design audit program and sampling plan',
        isCompleted: true,
        completedBy: 'CA Rajesh Agarwal',
        completedAt: DateTime(2026, 1, 23),
      ),
      ChecklistItem(
        description: 'Send PBC (Prepared by Client) list',
        isCompleted: false,
        notes: 'Pending client confirmation',
      ),
      ChecklistItem(
        description: 'Schedule opening meeting with management',
        isCompleted: false,
      ),
    ],
  ),
  AuditChecklist(
    id: 'ac2',
    auditType: AuditType.internal,
    title: 'Internal Audit - IT General Controls',
    totalItems: 8,
    completedItems: 6,
    items: [
      ChecklistItem(
        description: 'Review logical access controls',
        isCompleted: true,
        completedBy: 'Arjun Mehta',
        completedAt: DateTime(2025, 12, 5),
      ),
      ChecklistItem(
        description: 'Test password policy enforcement',
        isCompleted: true,
        completedBy: 'Arjun Mehta',
        completedAt: DateTime(2025, 12, 6),
      ),
      ChecklistItem(
        description: 'Verify change management procedures',
        isCompleted: true,
        completedBy: 'Sunita Rao',
        completedAt: DateTime(2025, 12, 8),
      ),
      ChecklistItem(
        description: 'Review backup and recovery procedures',
        isCompleted: true,
        completedBy: 'Sunita Rao',
        completedAt: DateTime(2025, 12, 10),
      ),
      ChecklistItem(
        description: 'Test incident response plan',
        isCompleted: true,
        completedBy: 'Arjun Mehta',
        completedAt: DateTime(2025, 12, 12),
      ),
      ChecklistItem(
        description: 'Evaluate network security controls',
        isCompleted: true,
        completedBy: 'Sunita Rao',
        completedAt: DateTime(2025, 12, 15),
      ),
      ChecklistItem(
        description: 'Review third-party vendor access',
        isCompleted: false,
        notes: 'Waiting for vendor list from IT department',
      ),
      ChecklistItem(
        description: 'Assess data encryption standards',
        isCompleted: false,
      ),
    ],
  ),
  AuditChecklist(
    id: 'ac3',
    auditType: AuditType.forensic,
    title: 'Forensic Audit - Evidence Collection',
    totalItems: 12,
    completedItems: 9,
    items: [
      ChecklistItem(
        description: 'Secure digital evidence and create forensic images',
        isCompleted: true,
        completedBy: 'CA Rajesh Agarwal',
        completedAt: DateTime(2025, 10, 20),
      ),
      ChecklistItem(
        description: 'Document chain of custody for all evidence',
        isCompleted: true,
        completedBy: 'Priya Nair',
        completedAt: DateTime(2025, 10, 21),
      ),
      ChecklistItem(
        description: 'Analyse bank statements for suspicious patterns',
        isCompleted: true,
        completedBy: 'Arjun Mehta',
        completedAt: DateTime(2025, 11, 5),
      ),
      ChecklistItem(
        description: 'Trace related party fund flows',
        isCompleted: true,
        completedBy: 'Kavita Desai',
        completedAt: DateTime(2025, 11, 15),
      ),
      ChecklistItem(
        description: 'Interview key personnel under caution',
        isCompleted: true,
        completedBy: 'CA Rajesh Agarwal',
        completedAt: DateTime(2025, 11, 20),
      ),
      ChecklistItem(
        description: 'Verify vendor existence and legitimacy',
        isCompleted: true,
        completedBy: 'Deepak Kumar',
        completedAt: DateTime(2025, 12, 1),
      ),
      ChecklistItem(
        description: 'Benford\'s Law analysis on transaction amounts',
        isCompleted: true,
        completedBy: 'Arjun Mehta',
        completedAt: DateTime(2025, 12, 10),
      ),
      ChecklistItem(
        description: 'Review email communications for red flags',
        isCompleted: true,
        completedBy: 'Kavita Desai',
        completedAt: DateTime(2025, 12, 20),
      ),
      ChecklistItem(
        description: 'Cross-reference PAN/GST of suspect entities',
        isCompleted: true,
        completedBy: 'Deepak Kumar',
        completedAt: DateTime(2026, 1, 5),
      ),
      ChecklistItem(
        description: 'Prepare quantification of loss estimate',
        isCompleted: false,
        notes: 'In progress, awaiting final bank confirmations',
      ),
      ChecklistItem(
        description: 'Draft forensic audit report',
        isCompleted: false,
      ),
      ChecklistItem(
        description: 'Present findings to Board Audit Committee',
        isCompleted: false,
      ),
    ],
  ),
  AuditChecklist(
    id: 'ac4',
    auditType: AuditType.bank,
    title: 'Bank Audit - Advances Review',
    totalItems: 8,
    completedItems: 5,
    items: [
      ChecklistItem(
        description: 'Verify NPA classification per RBI norms',
        isCompleted: true,
        completedBy: 'Sunita Rao',
        completedAt: DateTime(2025, 10, 10),
      ),
      ChecklistItem(
        description: 'Review loan sanction process and documentation',
        isCompleted: true,
        completedBy: 'Neha Gupta',
        completedAt: DateTime(2025, 10, 15),
      ),
      ChecklistItem(
        description: 'Test provisioning adequacy per IRAC norms',
        isCompleted: true,
        completedBy: 'Ravi Sharma',
        completedAt: DateTime(2025, 10, 20),
      ),
      ChecklistItem(
        description: 'Verify collateral valuation and documentation',
        isCompleted: true,
        completedBy: 'Sunita Rao',
        completedAt: DateTime(2025, 11, 1),
      ),
      ChecklistItem(
        description: 'Check compliance with exposure norms',
        isCompleted: true,
        completedBy: 'Neha Gupta',
        completedAt: DateTime(2025, 11, 10),
      ),
      ChecklistItem(
        description: 'Review restructured accounts classification',
        isCompleted: false,
        notes: 'Data extraction pending from CBS',
      ),
      ChecklistItem(
        description: 'Verify interest income recognition on NPAs',
        isCompleted: false,
      ),
      ChecklistItem(
        description: 'Test CRILC reporting compliance',
        isCompleted: false,
      ),
    ],
  ),
  AuditChecklist(
    id: 'ac5',
    auditType: AuditType.stock,
    title: 'Stock Audit - Physical Verification',
    totalItems: 6,
    completedItems: 6,
    items: [
      ChecklistItem(
        description: 'Obtain stock registers and bin cards',
        isCompleted: true,
        completedBy: 'Deepak Kumar',
        completedAt: DateTime(2025, 12, 2),
      ),
      ChecklistItem(
        description: 'Perform physical count using sampling method',
        isCompleted: true,
        completedBy: 'Neha Gupta',
        completedAt: DateTime(2025, 12, 5),
      ),
      ChecklistItem(
        description: 'Reconcile physical count with book records',
        isCompleted: true,
        completedBy: 'Deepak Kumar',
        completedAt: DateTime(2025, 12, 8),
      ),
      ChecklistItem(
        description: 'Verify valuation method (FIFO/weighted average)',
        isCompleted: true,
        completedBy: 'CA Vikram Singh',
        completedAt: DateTime(2025, 12, 10),
      ),
      ChecklistItem(
        description: 'Identify slow-moving and obsolete stock',
        isCompleted: true,
        completedBy: 'Neha Gupta',
        completedAt: DateTime(2025, 12, 12),
      ),
      ChecklistItem(
        description: 'Prepare stock audit report with observations',
        isCompleted: true,
        completedBy: 'CA Vikram Singh',
        completedAt: DateTime(2026, 1, 5),
      ),
    ],
  ),
];

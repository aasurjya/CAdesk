import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_circular.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/client_impact_alert.dart';

// ---------------------------------------------------------------------------
// Mock data — 10 circulars
// ---------------------------------------------------------------------------

final _mockCirculars = <RegulatoryCircular>[
  const RegulatoryCircular(
    id: 'rc-001',
    circularNumber: 'CBDT Circular No. 3/2026',
    issuingBody: 'CBDT',
    title: 'Updated TDS Rates for FY 2026-27 (Sections 192, 194, 194A)',
    summary:
        'CBDT has revised TDS deduction rates under Sections 192, 194, and '
        '194A effective 1 April 2026, with enhanced slab rates for senior '
        'citizens and new threshold limits.',
    issueDate: '05 Jan 2026',
    effectiveDate: '01 Apr 2026',
    category: 'Income Tax',
    impactLevel: 'High',
    affectedClientsCount: 847,
    keyChanges: [
      'TDS rates under Section 192 revised with updated basic exemption slabs',
      'Section 194A threshold for interest income raised from ₹40,000 to ₹50,000',
      'New mandatory reporting requirement for employer-provided accommodation',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-002',
    circularNumber: 'GSTN Advisory 45/2026',
    issuingBody: 'GSTN',
    title: 'HSN Code Mandatory for All Invoices Below ₹5 Lakh from April 2026',
    summary:
        'GSTN mandates 6-digit HSN codes on B2B and B2C invoices below ₹5 '
        'lakh from April 2026, impacting mid-size taxpayers previously exempt.',
    issueDate: '15 Jan 2026',
    effectiveDate: '01 Apr 2026',
    category: 'GST',
    impactLevel: 'Medium',
    affectedClientsCount: 1243,
    keyChanges: [
      'HSN code mandatory for invoices between ₹50,000 and ₹5,00,000',
      'Incorrect HSN codes attract penalty under Section 125 of CGST Act',
      'E-invoice portal will validate HSN codes from April 2026',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-003',
    circularNumber: 'MCA General Circular 02/2026',
    issuingBody: 'MCA',
    title: 'XBRL Taxonomy Update for FY 2025-26 Financial Statements',
    summary:
        'MCA has released an updated XBRL taxonomy for FY 2025-26 annual '
        'filings, requiring companies to map financial data to new element '
        'definitions before filing AOC-4 XBRL.',
    issueDate: '20 Jan 2026',
    effectiveDate: '01 Apr 2026',
    category: 'MCA',
    impactLevel: 'Medium',
    affectedClientsCount: 312,
    keyChanges: [
      'New XBRL taxonomy v3.2 replaces v3.1 for FY 2025-26 filings',
      'Revised element definitions for lease liabilities under Ind AS 116',
      'Validation rules updated; old taxonomy submissions will be rejected',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-004',
    circularNumber: 'RBI Master Circular RBI/2025-26/78',
    issuingBody: 'RBI',
    title:
        'Updated FEMA Regulations for Liberalised Remittance Scheme and '
        'Overseas Investment',
    summary:
        'RBI has consolidated FEMA regulations governing LRS remittances and '
        'overseas direct investment, introducing revised annual limit '
        'monitoring and enhanced KYC requirements for AD banks.',
    issueDate: '10 Feb 2026',
    effectiveDate: '01 Mar 2026',
    category: 'RBI',
    impactLevel: 'High',
    affectedClientsCount: 156,
    keyChanges: [
      'LRS annual limit remains \$250,000 but quarterly reporting now mandatory',
      'Overseas direct investment threshold for automatic route raised to \$1 billion',
      'Enhanced KYC and source-of-funds documentation required for remittances above \$100,000',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-005',
    circularNumber: 'SEBI/HO/CFD/CMD/CIR/P/2026/14',
    issuingBody: 'SEBI',
    title: 'BRSR Core Mandatory for Top 150 Listed Entities from FY 2026-27',
    summary:
        'SEBI extends mandatory Business Responsibility and Sustainability '
        'Reporting (BRSR) Core framework to top 150 listed entities by '
        'market capitalisation, effective FY 2026-27.',
    issueDate: '18 Feb 2026',
    effectiveDate: '01 Apr 2027',
    category: 'SEBI',
    impactLevel: 'High',
    affectedClientsCount: 28,
    keyChanges: [
      'BRSR Core replaces voluntary reporting for companies ranked 101–150',
      'Independent reasonable assurance on BRSR Core KPIs is mandatory',
      'Supply chain sustainability disclosures expanded to cover top 10 suppliers',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-006',
    circularNumber: 'CBDT Notification 15/2026',
    issuingBody: 'CBDT',
    title: 'New Form 10F Requirements for Non-Residents Claiming DTAA Benefits',
    summary:
        'CBDT has revised Form 10F and the underlying declaration process '
        'for non-resident payees claiming treaty benefits, requiring '
        'electronic filing via income tax portal before payment.',
    issueDate: '01 Feb 2026',
    effectiveDate: '01 Mar 2026',
    category: 'Income Tax',
    impactLevel: 'Medium',
    affectedClientsCount: 89,
    keyChanges: [
      'Form 10F must be filed electronically on the income tax portal before each payment',
      'Valid Tax Residency Certificate (TRC) mandatory attachment for e-filing',
      'Deductor liable for higher TDS if Form 10F is absent or expired',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-007',
    circularNumber: 'GSTN Circular 08/2026',
    issuingBody: 'GSTN',
    title: 'ITC Reversal Rules Updated for Credit Notes and Debit Notes',
    summary:
        'GSTN has issued revised guidelines on input tax credit reversal '
        'triggered by credit notes, clarifying timelines, GSTR-3B reporting '
        'obligations, and interest on delayed reversals.',
    issueDate: '25 Jan 2026',
    effectiveDate: '01 Feb 2026',
    category: 'GST',
    impactLevel: 'High',
    affectedClientsCount: 1891,
    keyChanges: [
      'ITC reversal for credit notes must be reflected in same-month GSTR-3B',
      'Interest at 18% p.a. applicable on delayed ITC reversal beyond 30 days',
      'Debit notes from suppliers must be cross-matched in GSTR-2B before claiming ITC',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-008',
    circularNumber: 'ICAI Guidance Note 2026-SA560',
    issuingBody: 'ICAI',
    title: 'Revised SA 560 (Subsequent Events) Effective April 2026',
    summary:
        'ICAI has issued a revised Standards on Auditing 560 for subsequent '
        'events, strengthening auditor obligations to evaluate post-balance '
        'sheet events up to the date of the audit report.',
    issueDate: '12 Feb 2026',
    effectiveDate: '01 Apr 2026',
    category: 'ICAI',
    impactLevel: 'Low',
    affectedClientsCount: 423,
    keyChanges: [
      'Revised SA 560 aligns with IAASB ISA 560 for enhanced subsequent events procedures',
      'Auditors must document all inquiries and management representations post-year-end',
      'New disclosure requirements when subsequent events are material but unrecognised',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-009',
    circularNumber: 'EPFO Circular 2026-03',
    issuingBody: 'EPFO',
    title: 'Enhanced PF Contribution Calculation for Variable Pay Components',
    summary:
        'EPFO has clarified that variable pay components including performance '
        'bonuses and incentives form part of "basic wages" for PF contribution '
        'purposes, aligning with the Supreme Court\'s Surya Roshni judgment.',
    issueDate: '28 Jan 2026',
    effectiveDate: '01 Apr 2026',
    category: 'Labour',
    impactLevel: 'Medium',
    affectedClientsCount: 678,
    keyChanges: [
      'Variable pay components consistently paid are included in PF basic wages',
      'Employers must recompute PF liability on revised wage structure from April 2026',
      'Retrospective liability assessment possible for non-compliant employers',
    ],
  ),
  const RegulatoryCircular(
    id: 'rc-010',
    circularNumber: 'CBDT Circular 05/2026',
    issuingBody: 'CBDT',
    title: 'Safe Harbour Rates for International Transactions Revised Upward',
    summary:
        'CBDT has revised safe harbour margins for international transactions '
        'under transfer pricing regulations, increasing rates for IT services '
        'and knowledge process outsourcing by 2-3 percentage points.',
    issueDate: '03 Feb 2026',
    effectiveDate: '01 Apr 2026',
    category: 'Income Tax',
    impactLevel: 'Medium',
    affectedClientsCount: 45,
    keyChanges: [
      'Safe harbour rate for IT-enabled services raised from 17% to 19% operating profit margin',
      'KPO safe harbour margin increased from 18% to 21%',
      'Eligibility threshold for safe harbour route raised to ₹500 crore of international transactions',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock data — 12 client impact alerts
// ---------------------------------------------------------------------------

final _mockAlerts = <ClientImpactAlert>[
  const ClientImpactAlert(
    id: 'cia-001',
    circularId: 'rc-001',
    clientName: 'Mehta Industries Pvt Ltd',
    clientPan: 'AABCM4567K',
    impactDescription:
        'TDS deduction rate on employee salaries must be recalculated using '
        'revised slabs for 412 employees before April payroll.',
    actionRequired:
        'Update payroll software with new Section 192 slab rates and run '
        'projection for Q1 FY 2026-27 for management approval.',
    dueDate: '25 Mar 2026',
    status: 'New',
    urgency: 'Urgent',
  ),
  const ClientImpactAlert(
    id: 'cia-002',
    circularId: 'rc-001',
    clientName: 'Sunrise Exports Ltd',
    clientPan: 'AABCS8901L',
    impactDescription:
        'Section 194A threshold change affects FD interest payments to '
        'vendors — TDS deductions from April 2026 need threshold review.',
    actionRequired:
        'Review all fixed deposit interest payments above ₹50,000 and '
        'advise finance team on revised TDS obligations.',
    dueDate: '31 Mar 2026',
    status: 'Reviewed',
    urgency: 'Normal',
  ),
  const ClientImpactAlert(
    id: 'cia-003',
    circularId: 'rc-002',
    clientName: 'Patel Traders',
    clientPan: 'ABCPT1234M',
    impactDescription:
        'All B2B invoices between ₹50,000 and ₹5 lakh require 6-digit HSN '
        'codes; current invoicing system uses only 4-digit codes.',
    actionRequired:
        'Assist client in updating their tally/ERP master data with 6-digit '
        'HSN codes for all stock items before April billing cycle.',
    dueDate: '28 Mar 2026',
    status: 'New',
    urgency: 'Urgent',
  ),
  const ClientImpactAlert(
    id: 'cia-004',
    circularId: 'rc-002',
    clientName: 'Gupta Wholesale Pvt Ltd',
    clientPan: 'AABCG2345N',
    impactDescription:
        'Monthly invoice volume of ~800 B2B invoices will need HSN validation '
        'starting April 2026; system integration update required.',
    actionRequired:
        'Coordinate with software vendor to enable HSN validation in billing '
        'module and test with sample invoices before go-live.',
    dueDate: '30 Mar 2026',
    status: 'Action Taken',
    urgency: 'Normal',
  ),
  const ClientImpactAlert(
    id: 'cia-005',
    circularId: 'rc-004',
    clientName: 'Sharma NRI Investments',
    clientPan: 'ABCPS5678P',
    impactDescription:
        'Client has existing LRS remittances of \$180,000 in FY 2025-26; '
        'quarterly reporting and enhanced KYC documentation now mandatory.',
    actionRequired:
        'Prepare LRS quarterly report for Q4 and collect updated KYC '
        'documents including source-of-funds letter for the bank.',
    dueDate: '15 Mar 2026',
    status: 'New',
    urgency: 'Urgent',
  ),
  const ClientImpactAlert(
    id: 'cia-006',
    circularId: 'rc-005',
    clientName: 'Reliance Infra Ltd',
    clientPan: 'AABCR6789Q',
    impactDescription:
        'Company ranks 132nd by market cap and falls within BRSR Core '
        'mandatory scope starting FY 2026-27.',
    actionRequired:
        'Initiate BRSR Core gap analysis and identify assurance firm for '
        'independent reasonable assurance engagement.',
    dueDate: '30 Jun 2026',
    status: 'New',
    urgency: 'Normal',
  ),
  const ClientImpactAlert(
    id: 'cia-007',
    circularId: 'rc-006',
    clientName: 'Tech Synergy Solutions',
    clientPan: 'AABCT3456R',
    impactDescription:
        'Client makes monthly software licence payments to US vendor; '
        'Form 10F must be filed electronically before each payment.',
    actionRequired:
        'Assist vendor in registering on income tax portal and electronically '
        'filing Form 10F with valid TRC before March payment.',
    dueDate: '20 Mar 2026',
    status: 'Reviewed',
    urgency: 'Urgent',
  ),
  const ClientImpactAlert(
    id: 'cia-008',
    circularId: 'rc-007',
    clientName: 'Kiran Steel Works Pvt Ltd',
    clientPan: 'AABCK7890S',
    impactDescription:
        'High volume of credit notes received in February 2026; ITC '
        'reversal must be reflected in February GSTR-3B to avoid interest.',
    actionRequired:
        'Reconcile all February credit notes against GSTR-2B and compute '
        'ITC reversal amount for inclusion in GSTR-3B filing.',
    dueDate: '20 Mar 2026',
    status: 'New',
    urgency: 'Urgent',
  ),
  const ClientImpactAlert(
    id: 'cia-009',
    circularId: 'rc-007',
    clientName: 'Anand Distributors',
    clientPan: 'AABCA1234T',
    impactDescription:
        'Three large debit notes from FY 2025-26 not yet cross-matched in '
        'GSTR-2B; ITC claim may be blocked if not resolved.',
    actionRequired:
        'Follow up with supplier to upload debit notes on GSTN portal and '
        'verify GSTR-2B reconciliation before March return filing.',
    dueDate: '20 Mar 2026',
    status: 'Reviewed',
    urgency: 'Normal',
  ),
  const ClientImpactAlert(
    id: 'cia-010',
    circularId: 'rc-009',
    clientName: 'BrightStar Manufacturing Ltd',
    clientPan: 'AABCB5678U',
    impactDescription:
        'Variable pay constitutes 35% of CTC for 156 employees; PF '
        'contribution structure must be revised by April 2026.',
    actionRequired:
        'Engage HR team to restructure CTC, compute revised PF liability, '
        'and obtain actuarial assessment for retrospective obligations.',
    dueDate: '31 Mar 2026',
    status: 'New',
    urgency: 'Urgent',
  ),
  const ClientImpactAlert(
    id: 'cia-011',
    circularId: 'rc-010',
    clientName: 'GlobalEdge IT Services Pvt Ltd',
    clientPan: 'AABCG9012V',
    impactDescription:
        'Client\'s IT-enabled services safe harbour margin of 17% falls '
        'below revised threshold of 19%, requiring transfer pricing study.',
    actionRequired:
        'Commission updated benchmarking study and consider whether to '
        'move from safe harbour to TNMM/CUP method for FY 2025-26.',
    dueDate: '31 Mar 2026',
    status: 'New',
    urgency: 'Normal',
  ),
  const ClientImpactAlert(
    id: 'cia-012',
    circularId: 'rc-008',
    clientName: 'Deccan Textiles Ltd',
    clientPan: 'AABCD3456W',
    impactDescription:
        'FY 2025-26 audit report date is 25 May 2026; revised SA 560 '
        'applies and subsequent events procedures must be enhanced.',
    actionRequired:
        'Update audit programme to include additional subsequent events '
        'inquiry procedures and obtain expanded management representation letter.',
    dueDate: '20 May 2026',
    status: 'Not Applicable',
    urgency: 'Low',
  ),
];

// ---------------------------------------------------------------------------
// Notifiers
// ---------------------------------------------------------------------------

/// Tracks the currently selected regulatory category filter.
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) {
    state = category;
  }
}

/// Tracks the currently selected urgency filter for client alerts.
class SelectedUrgencyNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? urgency) {
    state = urgency;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All regulatory circulars (unmodifiable).
final allCircularsProvider = Provider<List<RegulatoryCircular>>((ref) {
  return List.unmodifiable(_mockCirculars);
});

/// All client impact alerts (unmodifiable).
final allImpactAlertsProvider = Provider<List<ClientImpactAlert>>((ref) {
  return List.unmodifiable(_mockAlerts);
});

/// Currently selected category filter. Null means all categories.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

/// Currently selected urgency filter. Null means all urgencies.
final selectedUrgencyProvider =
    NotifierProvider<SelectedUrgencyNotifier, String?>(
      SelectedUrgencyNotifier.new,
    );

/// Circulars filtered by the selected category.
final filteredCircularsProvider = Provider<List<RegulatoryCircular>>((ref) {
  final all = ref.watch(allCircularsProvider);
  final cat = ref.watch(selectedCategoryProvider);
  if (cat == null) {
    return all;
  }
  return all.where((c) => c.category == cat).toList();
});

/// Alerts filtered by the selected urgency level.
final filteredAlertsProvider = Provider<List<ClientImpactAlert>>((ref) {
  final all = ref.watch(allImpactAlertsProvider);
  final urgency = ref.watch(selectedUrgencyProvider);
  if (urgency == null) {
    return all;
  }
  return all.where((a) => a.urgency == urgency).toList();
});

/// Client impact alerts for a specific circular identified by its [circularId].
final alertsForCircularProvider =
    Provider.family<List<ClientImpactAlert>, String>((ref, circularId) {
      return ref
          .watch(allImpactAlertsProvider)
          .where((a) => a.circularId == circularId)
          .toList();
    });

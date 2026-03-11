import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/knowledge_article.dart';
import '../../domain/models/sop_document.dart';

// ---------------------------------------------------------------------------
// Mock data - Knowledge Articles
// ---------------------------------------------------------------------------

final List<KnowledgeArticle> _mockArticles = [
  KnowledgeArticle(
    id: 'ka-001',
    title: 'CBDT Circular No. 7/2024 — TDS on Payments to Non-Residents',
    category: KnowledgeCategory.circulars,
    tags: const ['TDS', 'Non-Resident', 'Section 195', 'CBDT'],
    content:
        'CBDT clarifies the applicability of TDS under Section 195 on payments '
        'made to non-residents for services rendered outside India. The circular '
        'provides guidance on determining the source of income.',
    author: 'Rajesh Sharma',
    createdAt: DateTime(2024, 8, 15),
    lastUpdatedAt: DateTime(2026, 1, 10),
    viewCount: 142,
    isPinned: true,
  ),
  KnowledgeArticle(
    id: 'ka-002',
    title: 'GST AAR Ruling — Place of Supply for IT Services',
    category: KnowledgeCategory.caselaw,
    tags: const ['GST', 'Place of Supply', 'IT Services', 'AAR'],
    content:
        'Authority for Advance Rulings clarifies place of supply for software '
        'maintenance contracts where the recipient is located in a different state '
        'than the service provider.',
    author: 'Priya Mehta',
    createdAt: DateTime(2025, 3, 20),
    lastUpdatedAt: DateTime(2025, 11, 5),
    viewCount: 88,
    isPinned: false,
  ),
  KnowledgeArticle(
    id: 'ka-003',
    title: 'SOP — ITR Filing Workflow for Corporate Clients',
    category: KnowledgeCategory.sop,
    tags: const ['ITR', 'Corporate', 'Filing', 'Workflow'],
    content:
        'Standard operating procedure for end-to-end ITR-6 filing for corporate '
        'clients. Covers document collection, computation, review, and filing steps '
        'with responsibility matrix.',
    author: 'Anil Kumar',
    createdAt: DateTime(2025, 4, 1),
    lastUpdatedAt: DateTime(2026, 2, 15),
    viewCount: 210,
    isPinned: true,
  ),
  KnowledgeArticle(
    id: 'ka-004',
    title: 'Balance Sheet Reconciliation Template — FY2025-26',
    category: KnowledgeCategory.templates,
    tags: const ['Template', 'Balance Sheet', 'Reconciliation', 'Excel'],
    content:
        'Standardized Excel template for balance sheet reconciliation with '
        'automated cross-checks, variance analysis, and auditor sign-off columns '
        'updated for FY2025-26 disclosure requirements.',
    author: 'Sunita Rao',
    createdAt: DateTime(2026, 1, 5),
    lastUpdatedAt: DateTime(2026, 3, 1),
    viewCount: 175,
    isPinned: false,
  ),
  KnowledgeArticle(
    id: 'ka-005',
    title: 'ITAT Precedent — Disallowance of Expenses Under Section 40A(3)',
    category: KnowledgeCategory.precedents,
    tags: const ['ITAT', 'Section 40A(3)', 'Cash Payments', 'Disallowance'],
    content:
        'Income Tax Appellate Tribunal ruling on applicability of Section 40A(3) '
        'disallowance where cash payments exceed ₹10,000 in specific business '
        'circumstances. Useful for drafting grounds of appeal.',
    author: 'Vikram Joshi',
    createdAt: DateTime(2024, 11, 12),
    lastUpdatedAt: DateTime(2025, 6, 20),
    viewCount: 64,
    isPinned: false,
  ),
  KnowledgeArticle(
    id: 'ka-006',
    title: 'FAQ — GST Input Tax Credit on Capital Goods',
    category: KnowledgeCategory.faqs,
    tags: const ['GST', 'ITC', 'Capital Goods', 'CGST Act'],
    content:
        'Frequently asked questions on availability and reversal of input tax '
        'credit on capital goods under the CGST Act 2017, including provisions '
        'for proportional reversal on exempt supplies.',
    author: 'Deepak Verma',
    createdAt: DateTime(2025, 7, 18),
    lastUpdatedAt: DateTime(2026, 2, 28),
    viewCount: 320,
    isPinned: true,
  ),
  KnowledgeArticle(
    id: 'ka-007',
    title: 'CBDT Circular — Safe Harbour Rules for Transfer Pricing FY2025',
    category: KnowledgeCategory.circulars,
    tags: const ['Transfer Pricing', 'Safe Harbour', 'CBDT', 'ALP'],
    content:
        'Updated safe harbour margins and eligibility criteria for transfer '
        'pricing documentation. Applicable for AY2025-26 onwards with revised '
        'thresholds for IT-enabled services.',
    author: 'Rajesh Sharma',
    createdAt: DateTime(2025, 9, 30),
    lastUpdatedAt: DateTime(2026, 1, 22),
    viewCount: 97,
    isPinned: false,
  ),
  KnowledgeArticle(
    id: 'ka-008',
    title: 'Audit Working Paper Template — Substantive Testing Checklist',
    category: KnowledgeCategory.templates,
    tags: const ['Audit', 'Working Papers', 'Substantive Testing', 'SA 330'],
    content:
        'Comprehensive checklist aligned with SA 330 for substantive testing '
        'procedures. Covers revenue recognition, expense cut-off, related party '
        'transactions, and going concern assessment.',
    author: 'Kavitha Nair',
    createdAt: DateTime(2025, 12, 10),
    lastUpdatedAt: DateTime(2026, 3, 5),
    viewCount: 153,
    isPinned: false,
  ),
];

// ---------------------------------------------------------------------------
// Mock data - SOP Documents
// ---------------------------------------------------------------------------

final List<SopDocument> _mockSopDocuments = [
  SopDocument(
    id: 'sop-001',
    title: 'ITR Filing SOP — Corporate Clients',
    module: 'Income Tax',
    steps: const [
      'Collect financials and audit report from client',
      'Verify PAN, previous year ITR, and Form 26AS',
      'Compute income under all heads',
      'Prepare tax computation and check MAT/AMT applicability',
      'Draft ITR-6 and obtain client approval',
      'File on Income Tax Portal and download acknowledgement',
      'Archive all working papers in DMS',
    ],
    lastReviewedAt: DateTime(2026, 2, 15),
    version: 'v3.1',
    isActive: true,
  ),
  SopDocument(
    id: 'sop-002',
    title: 'GST Return Filing SOP — Monthly GSTR-1 & GSTR-3B',
    module: 'GST',
    steps: const [
      'Collect sales register and purchase register by 5th of month',
      'Reconcile GSTR-2B with purchase register',
      'Prepare GSTR-1 outward supply data',
      'Upload GSTR-1 on GST portal by 11th',
      'Compute ITC, reverse charges, and net tax liability',
      'File GSTR-3B and pay tax by 20th',
      'Save acknowledgement and update tracker',
    ],
    lastReviewedAt: DateTime(2026, 1, 20),
    version: 'v2.4',
    isActive: true,
  ),
  SopDocument(
    id: 'sop-003',
    title: 'Statutory Audit SOP — Risk-Based Audit Approach',
    module: 'Audit',
    steps: const [
      'Obtain and review previous year audit file',
      'Conduct risk assessment and materiality determination',
      'Prepare audit plan and allocate team resources',
      'Execute substantive testing procedures',
      'Review internal controls and document observations',
      'Prepare management letter and draft audit report',
      'Obtain signed financials and issue final report',
    ],
    lastReviewedAt: DateTime(2026, 3, 1),
    version: 'v4.0',
    isActive: true,
  ),
  SopDocument(
    id: 'sop-004',
    title: 'TDS Compliance SOP — Deduction and Deposit',
    module: 'TDS',
    steps: const [
      'Identify all payments attracting TDS during the month',
      'Verify applicable rate and threshold for each nature of payment',
      'Deduct TDS at source and maintain register',
      'Deposit TDS by 7th of following month via Challan 281',
      'File quarterly TDS returns (Form 24Q/26Q/27Q)',
      'Issue TDS certificates (Form 16/16A) to deductees',
      'Reconcile with Form 26AS of deductees',
    ],
    lastReviewedAt: DateTime(2025, 11, 30),
    version: 'v2.2',
    isActive: true,
  ),
  SopDocument(
    id: 'sop-005',
    title: 'New Client Onboarding SOP',
    module: 'Client Management',
    steps: const [
      'Conduct KYC and collect all mandatory documents',
      'Perform conflict of interest check',
      'Issue engagement letter and obtain signed copy',
      'Create client profile in practice management software',
      'Set up document folder structure in DMS',
      'Brief engagement team on client background',
      'Schedule kick-off meeting with client',
    ],
    lastReviewedAt: DateTime(2026, 2, 28),
    version: 'v1.5',
    isActive: true,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All knowledge articles.
final allKnowledgeArticlesProvider = Provider<List<KnowledgeArticle>>(
  (_) => List.unmodifiable(_mockArticles),
);

/// All SOP documents.
final allSopDocumentsProvider = Provider<List<SopDocument>>(
  (_) => List.unmodifiable(_mockSopDocuments),
);

/// Selected knowledge category filter.
final knowledgeCategoryFilterProvider =
    NotifierProvider<KnowledgeCategoryFilterNotifier, KnowledgeCategory?>(
        KnowledgeCategoryFilterNotifier.new);

class KnowledgeCategoryFilterNotifier extends Notifier<KnowledgeCategory?> {
  @override
  KnowledgeCategory? build() => null;

  void update(KnowledgeCategory? value) => state = value;
}

/// Articles filtered by category.
final filteredArticlesProvider = Provider<List<KnowledgeArticle>>((ref) {
  final category = ref.watch(knowledgeCategoryFilterProvider);
  final all = ref.watch(allKnowledgeArticlesProvider);
  if (category == null) return all;
  return all.where((a) => a.category == category).toList();
});

/// Aggregate knowledge engine summary statistics.
final knowledgeSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final articles = ref.watch(allKnowledgeArticlesProvider);
  final sops = ref.watch(allSopDocumentsProvider);

  final totalArticles = articles.length;
  final circularsCount =
      articles.where((a) => a.category == KnowledgeCategory.circulars).length;
  final sopCount =
      articles.where((a) => a.category == KnowledgeCategory.sop).length +
          sops.length;
  final templatesCount =
      articles.where((a) => a.category == KnowledgeCategory.templates).length;

  return <String, dynamic>{
    'totalArticles': totalArticles,
    'circulars': circularsCount,
    'sops': sopCount,
    'templates': templatesCount,
  };
});

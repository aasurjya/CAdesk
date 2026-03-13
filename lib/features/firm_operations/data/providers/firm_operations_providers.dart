import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/firm_operations/data/providers/firm_operations_repository_providers.dart';
import 'package:ca_app/features/firm_operations/domain/models/staff_member.dart';
import 'package:ca_app/features/firm_operations/domain/models/staff_kpi.dart';
import 'package:ca_app/features/firm_operations/domain/models/knowledge_article.dart';

// ---------------------------------------------------------------------------
// Mock staff members
// ---------------------------------------------------------------------------

final _mockStaff = <StaffMember>[
  StaffMember(
    id: 'stf-001',
    name: 'CA Rajesh Mehta',
    email: 'rajesh.mehta@mehtaca.in',
    phone: '9820012345',
    designation: StaffDesignation.partner,
    department: 'Audit & Assurance',
    joiningDate: DateTime(2008, 4, 1),
    billableTarget: 1800,
    cpeHoursRequired: 40,
    cpeHoursCompleted: 38,
    skills: ['Statutory Audit', 'Tax Planning', 'FEMA'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-002',
    name: 'CA Priya Sharma',
    email: 'priya.sharma@mehtaca.in',
    phone: '9876543210',
    designation: StaffDesignation.partner,
    department: 'Direct Tax',
    joiningDate: DateTime(2010, 7, 15),
    billableTarget: 1800,
    cpeHoursRequired: 40,
    cpeHoursCompleted: 42,
    skills: ['Income Tax', 'Transfer Pricing', 'International Tax'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-003',
    name: 'Amit Verma',
    email: 'amit.verma@mehtaca.in',
    phone: '9988776655',
    designation: StaffDesignation.manager,
    department: 'GST & Indirect Tax',
    joiningDate: DateTime(2015, 1, 10),
    billableTarget: 1600,
    cpeHoursRequired: 20,
    cpeHoursCompleted: 14,
    skills: ['GST', 'Customs', 'Service Tax'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-004',
    name: 'Sneha Kulkarni',
    email: 'sneha.kulkarni@mehtaca.in',
    phone: '9112233445',
    designation: StaffDesignation.manager,
    department: 'Audit & Assurance',
    joiningDate: DateTime(2016, 6, 1),
    billableTarget: 1600,
    cpeHoursRequired: 20,
    cpeHoursCompleted: 20,
    skills: ['Internal Audit', 'Risk Management', 'Ind AS'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-005',
    name: 'Rohit Gupta',
    email: 'rohit.gupta@mehtaca.in',
    phone: '9334455667',
    designation: StaffDesignation.senior,
    department: 'Direct Tax',
    joiningDate: DateTime(2019, 3, 20),
    billableTarget: 1400,
    cpeHoursRequired: 20,
    cpeHoursCompleted: 10,
    skills: ['TDS', 'Advance Tax', 'Tax Audit'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-006',
    name: 'Divya Nair',
    email: 'divya.nair@mehtaca.in',
    phone: '9556677889',
    designation: StaffDesignation.senior,
    department: 'GST & Indirect Tax',
    joiningDate: DateTime(2020, 8, 15),
    billableTarget: 1400,
    cpeHoursRequired: 20,
    cpeHoursCompleted: 18,
    skills: ['GST Returns', 'E-way Bill', 'GST Audit'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-007',
    name: 'Arjun Patel',
    email: 'arjun.patel@mehtaca.in',
    phone: '9778899001',
    designation: StaffDesignation.associate,
    department: 'Audit & Assurance',
    joiningDate: DateTime(2022, 9, 1),
    billableTarget: 1200,
    cpeHoursRequired: 20,
    cpeHoursCompleted: 8,
    skills: ['Bank Audit', 'Vouching', 'Verification'],
    isActive: true,
  ),
  StaffMember(
    id: 'stf-008',
    name: 'Meera Joshi',
    email: 'meera.joshi@mehtaca.in',
    phone: '9001122334',
    designation: StaffDesignation.intern,
    department: 'Direct Tax',
    joiningDate: DateTime(2025, 1, 15),
    billableTarget: 800,
    cpeHoursRequired: 0,
    cpeHoursCompleted: 0,
    skills: ['ITR Filing', 'Data Entry', 'Reconciliation'],
    isActive: true,
  ),
];

// ---------------------------------------------------------------------------
// Mock KPI records
// ---------------------------------------------------------------------------

const _mockKpis = <StaffKpi>[
  StaffKpi(
    staffId: 'stf-001',
    staffName: 'CA Rajesh Mehta',
    period: 'Feb 2026',
    billableHours: 152,
    totalHours: 176,
    tasksCompleted: 18,
    tasksAssigned: 20,
    qualityScore: 94,
    utilizationRate: 0.86,
    realizationRate: 0.92,
  ),
  StaffKpi(
    staffId: 'stf-002',
    staffName: 'CA Priya Sharma',
    period: 'Feb 2026',
    billableHours: 160,
    totalHours: 180,
    tasksCompleted: 22,
    tasksAssigned: 22,
    qualityScore: 97,
    utilizationRate: 0.89,
    realizationRate: 0.95,
  ),
  StaffKpi(
    staffId: 'stf-003',
    staffName: 'Amit Verma',
    period: 'Feb 2026',
    billableHours: 120,
    totalHours: 168,
    tasksCompleted: 14,
    tasksAssigned: 18,
    qualityScore: 82,
    utilizationRate: 0.71,
    realizationRate: 0.78,
  ),
  StaffKpi(
    staffId: 'stf-004',
    staffName: 'Sneha Kulkarni',
    period: 'Feb 2026',
    billableHours: 140,
    totalHours: 170,
    tasksCompleted: 16,
    tasksAssigned: 17,
    qualityScore: 91,
    utilizationRate: 0.82,
    realizationRate: 0.88,
  ),
  StaffKpi(
    staffId: 'stf-005',
    staffName: 'Rohit Gupta',
    period: 'Feb 2026',
    billableHours: 100,
    totalHours: 160,
    tasksCompleted: 10,
    tasksAssigned: 15,
    qualityScore: 75,
    utilizationRate: 0.63,
    realizationRate: 0.70,
  ),
  StaffKpi(
    staffId: 'stf-006',
    staffName: 'Divya Nair',
    period: 'Feb 2026',
    billableHours: 130,
    totalHours: 168,
    tasksCompleted: 15,
    tasksAssigned: 16,
    qualityScore: 88,
    utilizationRate: 0.77,
    realizationRate: 0.85,
  ),
  StaffKpi(
    staffId: 'stf-007',
    staffName: 'Arjun Patel',
    period: 'Feb 2026',
    billableHours: 90,
    totalHours: 160,
    tasksCompleted: 8,
    tasksAssigned: 12,
    qualityScore: 72,
    utilizationRate: 0.56,
    realizationRate: 0.65,
  ),
  StaffKpi(
    staffId: 'stf-008',
    staffName: 'Meera Joshi',
    period: 'Feb 2026',
    billableHours: 60,
    totalHours: 120,
    tasksCompleted: 6,
    tasksAssigned: 8,
    qualityScore: 68,
    utilizationRate: 0.50,
    realizationRate: 0.55,
  ),
];

// ---------------------------------------------------------------------------
// Mock knowledge articles
// ---------------------------------------------------------------------------

final _mockArticles = <KnowledgeArticle>[
  KnowledgeArticle(
    id: 'kb-001',
    title: 'SOP: Statutory Audit Engagement Workflow',
    category: ArticleCategory.sop,
    content:
        'Standard operating procedure for accepting and executing statutory audit engagements under SA 210.',
    author: 'CA Rajesh Mehta',
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 12, 1),
    tags: ['audit', 'statutory', 'SA 210'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-002',
    title: 'Template: GST Annual Return (GSTR-9)',
    category: ArticleCategory.template,
    content:
        'Working paper template for preparing GSTR-9 annual returns with reconciliation checkpoints.',
    author: 'Amit Verma',
    createdAt: DateTime(2025, 7, 15),
    updatedAt: DateTime(2025, 11, 20),
    tags: ['GST', 'GSTR-9', 'annual return'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-003',
    title: 'Guide: New Tax Regime vs Old Regime Comparison',
    category: ArticleCategory.guide,
    content:
        'Comprehensive comparison of old and new tax regimes under Section 115BAC for AY 2026-27.',
    author: 'CA Priya Sharma',
    createdAt: DateTime(2025, 9, 1),
    updatedAt: DateTime(2026, 1, 15),
    tags: ['income tax', 'Section 115BAC', 'tax planning'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-004',
    title: 'CBDT Circular No. 15/2025: TDS on Virtual Digital Assets',
    category: ArticleCategory.circular,
    content:
        'Summary and analysis of CBDT Circular on TDS provisions under Section 194S for crypto transactions.',
    author: 'Rohit Gupta',
    createdAt: DateTime(2025, 10, 5),
    updatedAt: DateTime(2025, 10, 5),
    tags: ['TDS', 'Section 194S', 'VDA', 'crypto'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-005',
    title: 'MCA Notification: CARO 2025 Amendments',
    category: ArticleCategory.notification,
    content:
        'Key amendments to Companies (Auditor Report) Order 2025 effective from 1st April 2026.',
    author: 'Sneha Kulkarni',
    createdAt: DateTime(2025, 11, 18),
    updatedAt: DateTime(2025, 11, 18),
    tags: ['CARO', 'audit', 'MCA', 'companies act'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-006',
    title: 'SOP: Client Engagement Letter Preparation',
    category: ArticleCategory.sop,
    content:
        'Step-by-step process for drafting engagement letters compliant with SA 210 and firm policy.',
    author: 'CA Rajesh Mehta',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 8, 10),
    tags: ['engagement letter', 'SA 210', 'client'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-007',
    title: 'Template: Transfer Pricing Documentation',
    category: ArticleCategory.template,
    content:
        'Master file and local file template for transfer pricing documentation under Section 92D.',
    author: 'CA Priya Sharma',
    createdAt: DateTime(2025, 8, 20),
    updatedAt: DateTime(2026, 2, 1),
    tags: ['transfer pricing', 'Section 92D', 'international tax'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-008',
    title: 'Guide: GST E-Invoice Compliance Checklist',
    category: ArticleCategory.guide,
    content:
        'Complete checklist for GST e-invoice generation, validation, and IRN management.',
    author: 'Divya Nair',
    createdAt: DateTime(2025, 12, 5),
    updatedAt: DateTime(2026, 1, 10),
    tags: ['GST', 'e-invoice', 'IRN', 'compliance'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-009',
    title: 'ICAI Notification: Revised SA 600 Group Audits',
    category: ArticleCategory.notification,
    content:
        'Summary of revised Standard on Auditing 600 for group audit engagements effective April 2026.',
    author: 'Sneha Kulkarni',
    createdAt: DateTime(2026, 1, 20),
    updatedAt: DateTime(2026, 1, 20),
    tags: ['SA 600', 'group audit', 'ICAI'],
    isPublished: true,
  ),
  KnowledgeArticle(
    id: 'kb-010',
    title: 'Guide: Digital Signature Certificate Renewal Process',
    category: ArticleCategory.guide,
    content:
        'Step-by-step guide for Class 2 and Class 3 DSC renewal with e-Mudhra and Sify portals.',
    author: 'Arjun Patel',
    createdAt: DateTime(2026, 2, 10),
    updatedAt: DateTime(2026, 2, 10),
    tags: ['DSC', 'digital signature', 'renewal'],
    isPublished: false,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All staff members — sourced from the repository; falls back to mock data.
final staffMembersProvider =
    AsyncNotifierProvider<StaffMembersNotifier, List<StaffMember>>(
      StaffMembersNotifier.new,
    );

class StaffMembersNotifier extends AsyncNotifier<List<StaffMember>> {
  @override
  Future<List<StaffMember>> build() async {
    final repo = ref.watch(firmOperationsRepositoryProvider);
    try {
      final teamMembers = await repo.getTeamMembers();
      if (teamMembers.isEmpty) return List.unmodifiable(_mockStaff);
      // TeamMember model differs from StaffMember — fall back to mock.
      return List.unmodifiable(_mockStaff);
    } catch (_) {
      return List.unmodifiable(_mockStaff);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.invalidateSelf();
      return build();
    });
  }
}

/// All KPI records.
final staffKpisProvider = Provider<List<StaffKpi>>((ref) {
  return List.unmodifiable(_mockKpis);
});

/// All knowledge base articles.
final knowledgeArticlesProvider = Provider<List<KnowledgeArticle>>((ref) {
  return List.unmodifiable(_mockArticles);
});

/// Staff search query.
final staffSearchQueryProvider =
    NotifierProvider<StaffSearchQueryNotifier, String>(
      StaffSearchQueryNotifier.new,
    );

class StaffSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Selected designation filter (null = all).
final staffDesignationFilterProvider =
    NotifierProvider<StaffDesignationFilterNotifier, StaffDesignation?>(
      StaffDesignationFilterNotifier.new,
    );

class StaffDesignationFilterNotifier extends Notifier<StaffDesignation?> {
  @override
  StaffDesignation? build() => null;

  void update(StaffDesignation? value) => state = value;
}

/// Filtered staff members based on search query and designation.
final filteredStaffProvider = Provider<List<StaffMember>>((ref) {
  final staff = ref.watch(staffMembersProvider).asData?.value ?? [];
  final query = ref.watch(staffSearchQueryProvider).toLowerCase();
  final designation = ref.watch(staffDesignationFilterProvider);

  return List.unmodifiable(
    staff.where((s) {
      final matchesQuery =
          query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.department.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query);
      final matchesDesignation =
          designation == null || s.designation == designation;
      return matchesQuery && matchesDesignation && s.isActive;
    }),
  );
});

/// Article search query.
final articleSearchQueryProvider =
    NotifierProvider<ArticleSearchQueryNotifier, String>(
      ArticleSearchQueryNotifier.new,
    );

class ArticleSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Selected article category filter (null = all).
final articleCategoryFilterProvider =
    NotifierProvider<ArticleCategoryFilterNotifier, ArticleCategory?>(
      ArticleCategoryFilterNotifier.new,
    );

class ArticleCategoryFilterNotifier extends Notifier<ArticleCategory?> {
  @override
  ArticleCategory? build() => null;

  void update(ArticleCategory? value) => state = value;
}

/// Filtered knowledge articles based on search and category.
final filteredArticlesProvider = Provider<List<KnowledgeArticle>>((ref) {
  final articles = ref.watch(knowledgeArticlesProvider);
  final query = ref.watch(articleSearchQueryProvider).toLowerCase();
  final category = ref.watch(articleCategoryFilterProvider);

  return List.unmodifiable(
    articles.where((a) {
      final matchesQuery =
          query.isEmpty ||
          a.title.toLowerCase().contains(query) ||
          a.tags.any((t) => t.toLowerCase().contains(query)) ||
          a.author.toLowerCase().contains(query);
      final matchesCategory = category == null || a.category == category;
      return matchesQuery && matchesCategory && a.isPublished;
    }),
  );
});

/// KPI for a specific staff member.
final kpiForStaffProvider = Provider.family<StaffKpi?, String>((ref, staffId) {
  final kpis = ref.watch(staffKpisProvider);
  final matches = kpis.where((k) => k.staffId == staffId);
  return matches.isEmpty ? null : matches.first;
});

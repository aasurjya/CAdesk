import 'package:ca_app/features/knowledge_engine/domain/models/knowledge_article.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/sop_document.dart';
import 'package:ca_app/features/knowledge_engine/domain/repositories/knowledge_engine_repository.dart';

/// In-memory mock implementation of [KnowledgeEngineRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockKnowledgeEngineRepository implements KnowledgeEngineRepository {
  static final List<KnowledgeArticle> _seedArticles = [
    KnowledgeArticle(
      id: 'mock-article-001',
      title: 'CBDT Circular on TDS on Salary (Section 192)',
      category: KnowledgeCategory.circulars,
      tags: ['TDS', 'salary', 'Section 192', 'CBDT'],
      content:
          'CBDT has clarified via Circular 4/2023 that the employer must '
          'consider all investments and deductions declared by the employee '
          'at the beginning of the year for TDS purposes...',
      author: 'CA Suresh Iyer',
      createdAt: DateTime(2026, 1, 10),
      lastUpdatedAt: DateTime(2026, 2, 5),
      viewCount: 142,
      isPinned: true,
    ),
    KnowledgeArticle(
      id: 'mock-article-002',
      title: 'SC Judgment: Taxability of Keyman Insurance Policy',
      category: KnowledgeCategory.caselaw,
      tags: ['Supreme Court', 'keyman insurance', 'business income'],
      content:
          'The Supreme Court in Commissioner of Income Tax v. Kotak Mahindra '
          'Bank held that Keyman Insurance Policy proceeds, even if assigned '
          'to the employee, are taxable as business income...',
      author: 'CA Meera Joshi',
      createdAt: DateTime(2025, 11, 15),
      lastUpdatedAt: DateTime(2026, 1, 20),
      viewCount: 87,
      isPinned: false,
    ),
    KnowledgeArticle(
      id: 'mock-article-003',
      title: 'Standard SOP: GST Reconciliation (GSTR-2A vs Books)',
      category: KnowledgeCategory.sop,
      tags: ['GST', 'GSTR-2A', 'reconciliation', 'ITC'],
      content:
          'Step 1: Download GSTR-2A from GST portal for the relevant month. '
          'Step 2: Export purchase register from accounting software. '
          'Step 3: Match GSTINs and invoice numbers...',
      author: 'CA Vikram Singh',
      createdAt: DateTime(2025, 9, 1),
      lastUpdatedAt: DateTime(2026, 3, 1),
      viewCount: 215,
      isPinned: true,
    ),
  ];

  static final List<SopDocument> _seedSops = [
    SopDocument(
      id: 'mock-sop-001',
      title: 'GST Monthly Compliance Checklist',
      module: 'GST',
      steps: [
        'Download GSTR-2B by 14th of next month',
        'Reconcile with purchase register',
        'File GSTR-1 by 11th',
        'File GSTR-3B by 20th',
        'Maintain ITC register',
      ],
      lastReviewedAt: DateTime(2026, 1, 15),
      version: 'v3.2',
      isActive: true,
    ),
    SopDocument(
      id: 'mock-sop-002',
      title: 'ITR Filing Workflow for Salaried Clients',
      module: 'Income Tax',
      steps: [
        'Collect Form 16, Form 26AS, AIS',
        'Cross-verify TDS with Form 26AS',
        'Compute income under all heads',
        'Apply deductions under Chapter VI-A',
        'Compute tax liability and advance tax credit',
        'File ITR and generate acknowledgement',
      ],
      lastReviewedAt: DateTime(2026, 2, 28),
      version: 'v2.1',
      isActive: true,
    ),
    SopDocument(
      id: 'mock-sop-003',
      title: 'TDS Return Filing (Form 24Q)',
      module: 'TDS',
      steps: [
        'Collect salary data from payroll',
        'Compute TDS as per slab rates',
        'Generate Form 24Q using TRACES utility',
        'File return by quarterly due date',
        'Download Form 16 after filing',
      ],
      lastReviewedAt: DateTime(2026, 1, 31),
      version: 'v1.5',
      isActive: true,
    ),
  ];

  final List<KnowledgeArticle> _articles = List.of(_seedArticles);
  final List<SopDocument> _sops = List.of(_seedSops);

  // -------------------------------------------------------------------------
  // KnowledgeArticle
  // -------------------------------------------------------------------------

  @override
  Future<List<KnowledgeArticle>> getArticles() async =>
      List.unmodifiable(_articles);

  @override
  Future<List<KnowledgeArticle>> getArticlesByCategory(
    KnowledgeCategory category,
  ) async => List.unmodifiable(
    _articles.where((a) => a.category == category).toList(),
  );

  @override
  Future<List<KnowledgeArticle>> searchArticles(String query) async {
    final q = query.toLowerCase();
    return List.unmodifiable(
      _articles
          .where(
            (a) =>
                a.title.toLowerCase().contains(q) ||
                a.content.toLowerCase().contains(q) ||
                a.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList(),
    );
  }

  @override
  Future<KnowledgeArticle?> getArticleById(String id) async {
    final matches = _articles.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<String> insertArticle(KnowledgeArticle article) async {
    _articles.add(article);
    return article.id;
  }

  @override
  Future<bool> updateArticle(KnowledgeArticle article) async {
    final idx = _articles.indexWhere((a) => a.id == article.id);
    if (idx == -1) return false;
    final updated = List<KnowledgeArticle>.of(_articles)..[idx] = article;
    _articles
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteArticle(String id) async {
    final before = _articles.length;
    _articles.removeWhere((a) => a.id == id);
    return _articles.length < before;
  }

  // -------------------------------------------------------------------------
  // SopDocument
  // -------------------------------------------------------------------------

  @override
  Future<List<SopDocument>> getSopDocuments() async => List.unmodifiable(_sops);

  @override
  Future<List<SopDocument>> getSopDocumentsByModule(String module) async =>
      List.unmodifiable(_sops.where((s) => s.module == module).toList());

  @override
  Future<String> insertSopDocument(SopDocument sop) async {
    _sops.add(sop);
    return sop.id;
  }

  @override
  Future<bool> updateSopDocument(SopDocument sop) async {
    final idx = _sops.indexWhere((s) => s.id == sop.id);
    if (idx == -1) return false;
    final updated = List<SopDocument>.of(_sops)..[idx] = sop;
    _sops
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteSopDocument(String id) async {
    final before = _sops.length;
    _sops.removeWhere((s) => s.id == id);
    return _sops.length < before;
  }
}

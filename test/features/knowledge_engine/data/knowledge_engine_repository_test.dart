import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/knowledge_article.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/sop_document.dart';
import 'package:ca_app/features/knowledge_engine/data/repositories/mock_knowledge_engine_repository.dart';

void main() {
  group('MockKnowledgeEngineRepository', () {
    late MockKnowledgeEngineRepository repo;

    setUp(() {
      repo = MockKnowledgeEngineRepository();
    });

    // -----------------------------------------------------------------------
    // KnowledgeArticle tests
    // -----------------------------------------------------------------------

    group('getArticles', () {
      test('returns seeded articles', () async {
        final results = await repo.getArticles();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getArticles();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getArticlesByCategory', () {
      test('returns only articles of matching category', () async {
        final all = await repo.getArticles();
        final category = all.first.category;
        final results = await repo.getArticlesByCategory(category);
        expect(results.every((a) => a.category == category), isTrue);
      });
    });

    group('searchArticles', () {
      test('returns results for title match', () async {
        final all = await repo.getArticles();
        final query = all.first.title.substring(0, 4).toLowerCase();
        final results = await repo.searchArticles(query);
        expect(results, isNotEmpty);
      });

      test('returns empty for non-matching query', () async {
        final results = await repo.searchArticles('zzznomatchzzz');
        expect(results, isEmpty);
      });
    });

    group('getArticleById', () {
      test('returns article for known id', () async {
        final all = await repo.getArticles();
        final id = all.first.id;
        final result = await repo.getArticleById(id);
        expect(result, isNotNull);
        expect(result!.id, equals(id));
      });

      test('returns null for unknown id', () async {
        final result = await repo.getArticleById('no-such-id');
        expect(result, isNull);
      });
    });

    group('insertArticle', () {
      test('inserts and returns id', () async {
        final article = KnowledgeArticle(
          id: 'test-article-001',
          title: 'Test Article on GST',
          category: KnowledgeCategory.circulars,
          tags: ['GST', 'circular'],
          content: 'This is test content.',
          author: 'CA Test Author',
          createdAt: DateTime(2026, 1, 1),
          lastUpdatedAt: DateTime(2026, 3, 1),
          viewCount: 0,
          isPinned: false,
        );
        final id = await repo.insertArticle(article);
        expect(id, equals('test-article-001'));
      });

      test('inserted article is retrievable', () async {
        final article = KnowledgeArticle(
          id: 'test-article-002',
          title: 'ITC Reversal Guide',
          category: KnowledgeCategory.sop,
          tags: ['ITC', 'reversal'],
          content: 'Detailed steps for ITC reversal.',
          author: 'CA Author Two',
          createdAt: DateTime(2026, 2, 1),
          lastUpdatedAt: DateTime(2026, 3, 1),
          viewCount: 5,
          isPinned: true,
        );
        await repo.insertArticle(article);
        final result = await repo.getArticleById('test-article-002');
        expect(result, isNotNull);
        expect(result!.isPinned, isTrue);
      });
    });

    group('updateArticle', () {
      test('increments viewCount and returns true', () async {
        final all = await repo.getArticles();
        final original = all.first;
        final updated = original.copyWith(viewCount: original.viewCount + 1);
        final success = await repo.updateArticle(updated);
        expect(success, isTrue);

        final after = await repo.getArticleById(original.id);
        expect(after?.viewCount, original.viewCount + 1);
      });

      test('returns false for non-existent id', () async {
        final ghost = KnowledgeArticle(
          id: 'no-such-article',
          title: 'Ghost',
          category: KnowledgeCategory.faqs,
          tags: [],
          content: '',
          author: 'Ghost',
          createdAt: DateTime(2026, 1, 1),
          lastUpdatedAt: DateTime(2026, 1, 1),
          viewCount: 0,
          isPinned: false,
        );
        final success = await repo.updateArticle(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteArticle', () {
      test('deletes seeded article and returns true', () async {
        final all = await repo.getArticles();
        final id = all.first.id;
        final success = await repo.deleteArticle(id);
        expect(success, isTrue);

        final after = await repo.getArticleById(id);
        expect(after, isNull);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteArticle('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // SopDocument tests
    // -----------------------------------------------------------------------

    group('getSopDocuments', () {
      test('returns seeded SOP documents', () async {
        final results = await repo.getSopDocuments();
        expect(results, isNotEmpty);
      });
    });

    group('getSopDocumentsByModule', () {
      test('returns SOPs for known module', () async {
        final all = await repo.getSopDocuments();
        final module = all.first.module;
        final results = await repo.getSopDocumentsByModule(module);
        expect(results.every((s) => s.module == module), isTrue);
      });

      test('returns empty for unknown module', () async {
        final results = await repo.getSopDocumentsByModule('no-such-module');
        expect(results, isEmpty);
      });
    });

    group('insertSopDocument', () {
      test('inserts and returns id', () async {
        final sop = SopDocument(
          id: 'test-sop-001',
          title: 'GST Filing SOP',
          module: 'GST',
          steps: ['Step 1: Login', 'Step 2: File GSTR-1'],
          lastReviewedAt: DateTime(2026, 1, 1),
          version: 'v1.0',
          isActive: true,
        );
        final id = await repo.insertSopDocument(sop);
        expect(id, equals('test-sop-001'));
      });
    });

    group('updateSopDocument', () {
      test('updates version and returns true', () async {
        final all = await repo.getSopDocuments();
        final original = all.first;
        final updated = original.copyWith(version: 'v99.0');
        final success = await repo.updateSopDocument(updated);
        expect(success, isTrue);

        final after = await repo.getSopDocuments();
        final found = after.firstWhere((s) => s.id == original.id);
        expect(found.version, equals('v99.0'));
      });

      test('returns false for non-existent id', () async {
        final ghost = SopDocument(
          id: 'no-such-sop',
          title: 'Ghost SOP',
          module: 'Ghost',
          steps: [],
          lastReviewedAt: DateTime(2026, 1, 1),
          version: 'v0',
          isActive: false,
        );
        final success = await repo.updateSopDocument(ghost);
        expect(success, isFalse);
      });
    });
  });
}

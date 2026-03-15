import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/knowledge_engine/data/providers/knowledge_engine_providers.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/knowledge_article.dart';

void main() {
  group('allKnowledgeArticlesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns exactly 8 articles', () {
      final articles = container.read(allKnowledgeArticlesProvider);
      expect(articles.length, 8);
    });

    test('all articles have non-empty ids', () {
      final articles = container.read(allKnowledgeArticlesProvider);
      expect(articles.every((a) => a.id.isNotEmpty), isTrue);
    });

    test('all articles have non-empty titles', () {
      final articles = container.read(allKnowledgeArticlesProvider);
      expect(articles.every((a) => a.title.isNotEmpty), isTrue);
    });
  });

  group('allSopDocumentsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns exactly 5 SOP documents', () {
      final sops = container.read(allSopDocumentsProvider);
      expect(sops.length, 5);
    });

    test('all SOPs have non-empty ids', () {
      final sops = container.read(allSopDocumentsProvider);
      expect(sops.every((s) => s.id.isNotEmpty), isTrue);
    });

    test('all active SOPs have isActive true', () {
      final sops = container.read(allSopDocumentsProvider);
      expect(sops.every((s) => s.isActive), isTrue);
    });
  });

  group('KnowledgeCategoryFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(knowledgeCategoryFilterProvider), isNull);
    });

    test('can be updated to circulars', () {
      container
          .read(knowledgeCategoryFilterProvider.notifier)
          .update(KnowledgeCategory.circulars);
      expect(
        container.read(knowledgeCategoryFilterProvider),
        KnowledgeCategory.circulars,
      );
    });

    test('can be updated to sop', () {
      container
          .read(knowledgeCategoryFilterProvider.notifier)
          .update(KnowledgeCategory.sop);
      expect(
        container.read(knowledgeCategoryFilterProvider),
        KnowledgeCategory.sop,
      );
    });

    test('can be reset to null', () {
      container
          .read(knowledgeCategoryFilterProvider.notifier)
          .update(KnowledgeCategory.templates);
      container.read(knowledgeCategoryFilterProvider.notifier).update(null);
      expect(container.read(knowledgeCategoryFilterProvider), isNull);
    });
  });

  group('filteredArticlesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all articles when no filter', () {
      final all = container.read(allKnowledgeArticlesProvider);
      final filtered = container.read(filteredArticlesProvider);
      expect(filtered.length, all.length);
    });

    test('filters to circulars only', () {
      container
          .read(knowledgeCategoryFilterProvider.notifier)
          .update(KnowledgeCategory.circulars);
      final filtered = container.read(filteredArticlesProvider);
      expect(
        filtered.every((a) => a.category == KnowledgeCategory.circulars),
        isTrue,
      );
    });

    test('filters to templates only', () {
      container
          .read(knowledgeCategoryFilterProvider.notifier)
          .update(KnowledgeCategory.templates);
      final filtered = container.read(filteredArticlesProvider);
      expect(
        filtered.every((a) => a.category == KnowledgeCategory.templates),
        isTrue,
      );
    });
  });

  group('knowledgeSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('contains required keys', () {
      final summary = container.read(knowledgeSummaryProvider);
      expect(summary.containsKey('totalArticles'), isTrue);
      expect(summary.containsKey('circulars'), isTrue);
      expect(summary.containsKey('sops'), isTrue);
      expect(summary.containsKey('templates'), isTrue);
    });

    test('totalArticles matches article count', () {
      final articles = container.read(allKnowledgeArticlesProvider);
      final summary = container.read(knowledgeSummaryProvider);
      expect(summary['totalArticles'], articles.length);
    });

    test('all counts are non-negative', () {
      final summary = container.read(knowledgeSummaryProvider);
      expect(summary['totalArticles'], greaterThanOrEqualTo(0));
      expect(summary['circulars'], greaterThanOrEqualTo(0));
      expect(summary['sops'], greaterThanOrEqualTo(0));
      expect(summary['templates'], greaterThanOrEqualTo(0));
    });
  });
}

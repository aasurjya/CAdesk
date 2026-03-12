import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ca_gpt/domain/models/knowledge_article.dart';
import 'package:ca_app/features/ca_gpt/domain/services/section_lookup_service.dart';

void main() {
  group('SectionLookupService — lookupSection', () {
    test('exact section number match returns results', () {
      final results = SectionLookupService.lookupSection('44AD');
      expect(results, isNotEmpty);
      expect(results.first.sections, contains('44AD'));
    });

    test('keyword search returns matching articles', () {
      final results = SectionLookupService.lookupSection('TDS interest');
      expect(results, isNotEmpty);
    });

    test('case-insensitive search', () {
      final results = SectionLookupService.lookupSection(
        'presumptive taxation',
      );
      expect(results, isNotEmpty);
    });

    test('unknown query returns empty list', () {
      final results = SectionLookupService.lookupSection(
        'xyz_nonexistent_query_abc',
      );
      expect(results, isEmpty);
    });

    test('partial section number match works', () {
      final results = SectionLookupService.lookupSection('80');
      expect(results, isNotEmpty);
    });

    test('returns KnowledgeArticle with correct fields', () {
      final results = SectionLookupService.lookupSection('44AD');
      final article = results.first;
      expect(article.articleId, isNotEmpty);
      expect(article.title, isNotEmpty);
      expect(article.content, isNotEmpty);
      expect(article.keywords, isNotEmpty);
      expect(article.sections, isNotEmpty);
      expect(article.isLatest, isTrue);
    });
  });

  group('SectionLookupService — getSectionSummary', () {
    test('returns summary for known section', () {
      final summary = SectionLookupService.getSectionSummary(
        '44AD',
        'Income Tax Act',
      );
      expect(summary, isNotEmpty);
      expect(summary.toLowerCase(), contains('presumptive'));
    });

    test('returns summary for 80C', () {
      final summary = SectionLookupService.getSectionSummary(
        '80C',
        'Income Tax Act',
      );
      expect(summary, isNotEmpty);
      expect(summary, contains('1.5'));
    });

    test('returns summary for 194A', () {
      final summary = SectionLookupService.getSectionSummary(
        '194A',
        'Income Tax Act',
      );
      expect(summary, isNotEmpty);
    });

    test('returns summary for 139(1)', () {
      final summary = SectionLookupService.getSectionSummary(
        '139(1)',
        'Income Tax Act',
      );
      expect(summary, isNotEmpty);
      expect(summary.toLowerCase(), contains('july'));
    });

    test('returns informative message for unknown section', () {
      final summary = SectionLookupService.getSectionSummary(
        '999ZZZ',
        'Income Tax Act',
      );
      expect(summary, isNotEmpty);
      expect(summary.toLowerCase(), contains('not found'));
    });

    test('sections 10(14), 115BAC, 43B(h), 194Q, 206AB all have summaries', () {
      for (final sec in ['10(14)', '115BAC', '43B(h)', '194Q', '206AB']) {
        final summary = SectionLookupService.getSectionSummary(
          sec,
          'Income Tax Act',
        );
        expect(
          summary,
          isNotEmpty,
          reason: 'Expected summary for section $sec',
        );
        expect(
          summary.toLowerCase(),
          isNot(contains('not found')),
          reason: 'Section $sec should be in knowledge base',
        );
      }
    });
  });

  group('SectionLookupService — getRelatedSections', () {
    test('44AD has related sections', () {
      final related = SectionLookupService.getRelatedSections('44AD');
      expect(related, isNotEmpty);
    });

    test('80C has related sections', () {
      final related = SectionLookupService.getRelatedSections('80C');
      expect(related, isNotEmpty);
    });

    test('returns list for unknown section (may be empty)', () {
      final related = SectionLookupService.getRelatedSections('999ZZZ');
      expect(related, isA<List<String>>());
    });

    test('related sections do not include the section itself', () {
      final related = SectionLookupService.getRelatedSections('44AD');
      expect(related, isNot(contains('44AD')));
    });
  });

  group('KnowledgeArticle model', () {
    test('const constructor and equality', () {
      final now = DateTime(2025, 1, 1);
      final a = KnowledgeArticle(
        articleId: 'a1',
        title: 'Section 44AD',
        category: KnowledgeCategory.incomeTax,
        content: 'Presumptive taxation',
        sections: const ['44AD'],
        lastUpdated: now,
        isLatest: true,
        keywords: const ['presumptive', 'business'],
      );
      final b = KnowledgeArticle(
        articleId: 'a1',
        title: 'Section 44AD',
        category: KnowledgeCategory.incomeTax,
        content: 'Presumptive taxation',
        sections: const ['44AD'],
        lastUpdated: now,
        isLatest: true,
        keywords: const ['presumptive', 'business'],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith creates new instance with updated fields', () {
      final now = DateTime(2025, 1, 1);
      final original = KnowledgeArticle(
        articleId: 'a1',
        title: 'Old Title',
        category: KnowledgeCategory.incomeTax,
        content: 'Content',
        sections: const ['44AD'],
        lastUpdated: now,
        isLatest: false,
        keywords: const ['keyword'],
      );
      final updated = original.copyWith(title: 'New Title', isLatest: true);
      expect(updated.title, equals('New Title'));
      expect(updated.isLatest, isTrue);
      expect(updated.articleId, equals('a1'));
      expect(updated.content, equals('Content'));
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/documents/data/providers/document_repository_providers.dart';
import 'package:ca_app/features/documents/data/providers/documents_providers.dart';
import 'package:ca_app/features/documents/data/repositories/mock_document_repository.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

void main() {
  group('Documents Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          featureFlagProvider.overrideWith(() => _OfflineFeatureFlagNotifier()),
          documentRepositoryProvider.overrideWithValue(
            MockDocumentRepository(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    group('allDocumentsProvider', () {
      test('builds and returns non-empty list of documents', () async {
        final docs = await container.read(allDocumentsProvider.future);
        expect(docs, isNotEmpty);
        expect(docs.length, greaterThanOrEqualTo(15));
      });

      test('setDocuments replaces state immutably', () async {
        final original = await container.read(allDocumentsProvider.future);
        final subset = original.take(5).toList();
        container.read(allDocumentsProvider.notifier).setDocuments(subset);
        final after = container.read(allDocumentsProvider).asData?.value;
        expect(after?.length, 5);
      });
    });

    group('allFoldersProvider', () {
      test('returns non-empty list of document folders', () {
        final folders = container.read(allFoldersProvider);
        expect(folders, isNotEmpty);
        expect(folders.length, greaterThanOrEqualTo(8));
      });

      test('list is unmodifiable', () {
        final folders = container.read(allFoldersProvider);
        expect(
          () => (folders as dynamic).add(folders.first),
          throwsA(isA<Error>()),
        );
      });

      test('update replaces folders state', () {
        final original = container.read(allFoldersProvider);
        final subset = original.take(3).toList();
        container.read(allFoldersProvider.notifier).update(subset);
        expect(container.read(allFoldersProvider).length, 3);
      });
    });

    group('docSearchQueryProvider', () {
      test('initial state is empty string', () {
        expect(container.read(docSearchQueryProvider), '');
      });

      test('can be updated to a query string', () {
        container.read(docSearchQueryProvider.notifier).update('ITR');
        expect(container.read(docSearchQueryProvider), 'ITR');
      });

      test('can be cleared back to empty', () {
        container.read(docSearchQueryProvider.notifier).update('Audit');
        container.read(docSearchQueryProvider.notifier).update('');
        expect(container.read(docSearchQueryProvider), '');
      });
    });

    group('docCategoryFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(docCategoryFilterProvider), isNull);
      });

      test('can be set to a category', () {
        container
            .read(docCategoryFilterProvider.notifier)
            .update(DocumentCategory.taxReturns);
        expect(
          container.read(docCategoryFilterProvider),
          DocumentCategory.taxReturns,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(docCategoryFilterProvider.notifier)
            .update(DocumentCategory.auditReports);
        container.read(docCategoryFilterProvider.notifier).update(null);
        expect(container.read(docCategoryFilterProvider), isNull);
      });
    });

    group('docClientFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(docClientFilterProvider), isNull);
      });

      test('can be set to a client ID', () {
        container.read(docClientFilterProvider.notifier).update('3');
        expect(container.read(docClientFilterProvider), '3');
      });
    });

    group('filteredDocumentsProvider', () {
      test('returns all documents when no filters are set', () async {
        final all = await container.read(allDocumentsProvider.future);
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered.length, all.length);
      });

      test('filters by category', () async {
        await container.read(allDocumentsProvider.future);
        container
            .read(docCategoryFilterProvider.notifier)
            .update(DocumentCategory.taxReturns);
        final filtered = container.read(filteredDocumentsProvider);
        for (final d in filtered) {
          expect(d.category, DocumentCategory.taxReturns);
        }
      });

      test('filters by client ID', () async {
        await container.read(allDocumentsProvider.future);
        container.read(docClientFilterProvider.notifier).update('3');
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((d) => d.clientId == '3'), isTrue);
      });

      test('filters by search query', () async {
        await container.read(allDocumentsProvider.future);
        container.read(docSearchQueryProvider.notifier).update('ITR');
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered, isNotEmpty);
        for (final d in filtered) {
          final matchesTitle = d.title.toLowerCase().contains('itr');
          final matchesClient = d.clientName.toLowerCase().contains('itr');
          final matchesTags = d.tags.any(
            (t) => t.toLowerCase().contains('itr'),
          );
          expect(matchesTitle || matchesClient || matchesTags, isTrue);
        }
      });

      test('returns empty for non-existent search query', () async {
        await container.read(allDocumentsProvider.future);
        container
            .read(docSearchQueryProvider.notifier)
            .update('xyznonexistent99999zzz');
        final filtered = container.read(filteredDocumentsProvider);
        expect(filtered, isEmpty);
      });

      test('results are sorted by uploadedAt descending', () async {
        await container.read(allDocumentsProvider.future);
        final filtered = container.read(filteredDocumentsProvider);
        for (int i = 0; i < filtered.length - 1; i++) {
          expect(
            filtered[i].uploadedAt.compareTo(filtered[i + 1].uploadedAt),
            greaterThanOrEqualTo(0),
          );
        }
      });
    });

    group('filteredFoldersProvider', () {
      test('returns all folders when no filters are set', () {
        final all = container.read(allFoldersProvider);
        final filtered = container.read(filteredFoldersProvider);
        expect(filtered.length, all.length);
      });

      test('filters folders by client ID', () async {
        await container.read(allDocumentsProvider.future);
        container.read(docClientFilterProvider.notifier).update('3');
        final filtered = container.read(filteredFoldersProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((f) => f.clientId == '3'), isTrue);
      });
    });

    group('docSummaryProvider', () {
      test('total matches allDocumentsProvider length', () async {
        final docs = await container.read(allDocumentsProvider.future);
        final summary = container.read(docSummaryProvider);
        expect(summary.total, docs.length);
      });

      test('shared count is non-negative and <= total', () async {
        await container.read(allDocumentsProvider.future);
        final summary = container.read(docSummaryProvider);
        expect(summary.shared, greaterThanOrEqualTo(0));
        expect(summary.shared, lessThanOrEqualTo(summary.total));
      });

      test('folders count matches allFoldersProvider length', () {
        final summary = container.read(docSummaryProvider);
        expect(summary.folders, container.read(allFoldersProvider).length);
      });
    });
  });
}

/// Minimal offline notifier that immediately returns FeatureFlags.empty
/// without touching Supabase, suitable for unit tests.
class _OfflineFeatureFlagNotifier extends FeatureFlagNotifier {
  @override
  Future<FeatureFlags> build() async => FeatureFlags.empty;
}

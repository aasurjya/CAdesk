import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/idp/data/providers/idp_providers.dart';

void main() {
  group('allDocumentJobsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty list of document jobs', () {
      final jobs = container.read(allDocumentJobsProvider);
      expect(jobs, isNotEmpty);
    });

    test('returns unmodifiable list', () {
      final jobs = container.read(allDocumentJobsProvider);
      expect(() => (jobs as dynamic).add(null), throwsA(isA<Error>()));
    });

    test('contains exactly 10 document jobs', () {
      final jobs = container.read(allDocumentJobsProvider);
      expect(jobs.length, 10);
    });

    test('all jobs have non-empty ids', () {
      final jobs = container.read(allDocumentJobsProvider);
      expect(jobs.every((j) => j.id.isNotEmpty), isTrue);
    });
  });

  group('allExtractedFieldsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty list of extracted fields', () {
      final fields = container.read(allExtractedFieldsProvider);
      expect(fields, isNotEmpty);
    });

    test('contains exactly 15 extracted fields', () {
      final fields = container.read(allExtractedFieldsProvider);
      expect(fields.length, 15);
    });
  });

  group('SelectedDocStatusNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedDocStatusProvider), isNull);
    });

    test('can be updated to Completed', () {
      container.read(selectedDocStatusProvider.notifier).select('Completed');
      expect(container.read(selectedDocStatusProvider), 'Completed');
    });

    test('can be updated to Review', () {
      container.read(selectedDocStatusProvider.notifier).select('Review');
      expect(container.read(selectedDocStatusProvider), 'Review');
    });

    test('can be reset to null', () {
      container.read(selectedDocStatusProvider.notifier).select('Failed');
      container.read(selectedDocStatusProvider.notifier).select(null);
      expect(container.read(selectedDocStatusProvider), isNull);
    });
  });

  group('filteredDocumentJobsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all jobs when filter is null', () {
      final all = container.read(allDocumentJobsProvider);
      final filtered = container.read(filteredDocumentJobsProvider);
      expect(filtered.length, all.length);
    });

    test('filters to only Completed jobs', () {
      container.read(selectedDocStatusProvider.notifier).select('Completed');
      final filtered = container.read(filteredDocumentJobsProvider);
      expect(filtered.every((j) => j.status == 'Completed'), isTrue);
    });

    test('filters to only Review jobs', () {
      container.read(selectedDocStatusProvider.notifier).select('Review');
      final filtered = container.read(filteredDocumentJobsProvider);
      expect(filtered.every((j) => j.status == 'Review'), isTrue);
    });

    test('returns empty for unknown status', () {
      container.read(selectedDocStatusProvider.notifier).select('NonExistent');
      final filtered = container.read(filteredDocumentJobsProvider);
      expect(filtered, isEmpty);
    });
  });

  group('fieldsForJobProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns fields only for requested job', () {
      final fields = container.read(fieldsForJobProvider('job-01'));
      expect(fields.every((f) => f.jobId == 'job-01'), isTrue);
    });

    test('returns non-empty for job-01', () {
      final fields = container.read(fieldsForJobProvider('job-01'));
      expect(fields, isNotEmpty);
    });

    test('returns empty list for unknown jobId', () {
      final fields = container.read(fieldsForJobProvider('nonexistent'));
      expect(fields, isEmpty);
    });
  });
}

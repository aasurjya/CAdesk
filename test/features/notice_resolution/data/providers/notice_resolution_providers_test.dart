import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/notice_resolution/data/providers/notice_resolution_providers.dart';
import 'package:ca_app/features/notice_resolution/domain/models/notice_case.dart';

void main() {
  group('AllNoticeCasesNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 8 mock notice cases', () {
      final cases = container.read(allNoticeCasesProvider);
      expect(cases.length, 8);
    });

    test('all cases have non-empty ids', () {
      final cases = container.read(allNoticeCasesProvider);
      expect(cases.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final cases = container.read(allNoticeCasesProvider);
      expect(() => (cases as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('NoticeSeverityFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(noticeSeverityFilterProvider), isNull);
    });

    test('can be set to critical', () {
      container
          .read(noticeSeverityFilterProvider.notifier)
          .update(NoticeSeverity.critical);
      expect(
        container.read(noticeSeverityFilterProvider),
        NoticeSeverity.critical,
      );
    });

    test('can be set to high', () {
      container
          .read(noticeSeverityFilterProvider.notifier)
          .update(NoticeSeverity.high);
      expect(container.read(noticeSeverityFilterProvider), NoticeSeverity.high);
    });

    test('can be reset to null', () {
      container
          .read(noticeSeverityFilterProvider.notifier)
          .update(NoticeSeverity.medium);
      container.read(noticeSeverityFilterProvider.notifier).update(null);
      expect(container.read(noticeSeverityFilterProvider), isNull);
    });
  });

  group('filteredNoticeCasesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all cases when no filter set', () {
      final all = container.read(allNoticeCasesProvider);
      final filtered = container.read(filteredNoticeCasesProvider);
      expect(filtered.length, all.length);
    });

    test('critical filter returns only critical severity', () {
      container
          .read(noticeSeverityFilterProvider.notifier)
          .update(NoticeSeverity.critical);
      final filtered = container.read(filteredNoticeCasesProvider);
      expect(
        filtered.every((c) => c.severity == NoticeSeverity.critical),
        isTrue,
      );
    });

    test('high filter returns only high severity', () {
      container
          .read(noticeSeverityFilterProvider.notifier)
          .update(NoticeSeverity.high);
      final filtered = container.read(filteredNoticeCasesProvider);
      expect(
        filtered.every((c) => c.severity == NoticeSeverity.high),
        isTrue,
      );
    });

    test('filtered results are a subset of all cases', () {
      container
          .read(noticeSeverityFilterProvider.notifier)
          .update(NoticeSeverity.critical);
      final all = container.read(allNoticeCasesProvider);
      final filtered = container.read(filteredNoticeCasesProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('noticeSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('contains required keys', () {
      final summary = container.read(noticeSummaryProvider);
      expect(summary.containsKey('total'), isTrue);
      expect(summary.containsKey('critical'), isTrue);
      expect(summary.containsKey('dueThisWeek'), isTrue);
      expect(summary.containsKey('closed'), isTrue);
    });

    test('total matches all cases count', () {
      final all = container.read(allNoticeCasesProvider);
      final summary = container.read(noticeSummaryProvider);
      expect(summary['total'], all.length);
    });

    test('all counts are non-negative', () {
      final summary = container.read(noticeSummaryProvider);
      expect(summary['total'], greaterThanOrEqualTo(0));
      expect(summary['critical'], greaterThanOrEqualTo(0));
      expect(summary['dueThisWeek'], greaterThanOrEqualTo(0));
      expect(summary['closed'], greaterThanOrEqualTo(0));
    });

    test('critical count does not exceed total', () {
      final summary = container.read(noticeSummaryProvider);
      expect(summary['critical']!, lessThanOrEqualTo(summary['total']!));
    });
  });
}

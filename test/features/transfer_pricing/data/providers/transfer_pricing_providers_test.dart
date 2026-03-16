import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/transfer_pricing/data/providers/transfer_pricing_providers.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_study.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_filing.dart';

void main() {
  group('tpStudiesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 6 mock TP studies', () {
      final studies = container.read(tpStudiesProvider);
      expect(studies.length, 6);
    });

    test('all studies have non-empty ids', () {
      final studies = container.read(tpStudiesProvider);
      expect(studies.every((s) => s.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final studies = container.read(tpStudiesProvider);
      expect(() => (studies as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('tpFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty TP filings', () {
      final filings = container.read(tpFilingsProvider);
      expect(filings, isNotEmpty);
    });

    test('all filings have non-empty ids', () {
      final filings = container.read(tpFilingsProvider);
      expect(filings.every((f) => f.id.isNotEmpty), isTrue);
    });
  });

  group('TpStudyStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(tpStudyStatusFilterProvider), isNull);
    });

    test('can be set to analysis', () {
      container
          .read(tpStudyStatusFilterProvider.notifier)
          .update(TpStudyStatus.analysis);
      expect(
        container.read(tpStudyStatusFilterProvider),
        TpStudyStatus.analysis,
      );
    });

    test('can be reset to null', () {
      container
          .read(tpStudyStatusFilterProvider.notifier)
          .update(TpStudyStatus.draft);
      container.read(tpStudyStatusFilterProvider.notifier).update(null);
      expect(container.read(tpStudyStatusFilterProvider), isNull);
    });
  });

  group('TpFilingStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(tpFilingStatusFilterProvider), isNull);
    });

    test('can be set to caReview', () {
      container
          .read(tpFilingStatusFilterProvider.notifier)
          .update(TpFilingStatus.caReview);
      expect(
        container.read(tpFilingStatusFilterProvider),
        TpFilingStatus.caReview,
      );
    });
  });

  group('filteredTpStudiesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all studies when no filter', () {
      final all = container.read(tpStudiesProvider);
      final filtered = container.read(filteredTpStudiesProvider);
      expect(filtered.length, all.length);
    });

    test('analysis filter narrows results', () {
      container
          .read(tpStudyStatusFilterProvider.notifier)
          .update(TpStudyStatus.analysis);
      final filtered = container.read(filteredTpStudiesProvider);
      expect(filtered.every((s) => s.status == TpStudyStatus.analysis), isTrue);
    });
  });

  group('tpSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalStudies matches studies count', () {
      final studies = container.read(tpStudiesProvider);
      final summary = container.read(tpSummaryProvider);
      expect(summary.totalStudies, studies.length);
    });

    test('inProgress and completed are non-negative', () {
      final summary = container.read(tpSummaryProvider);
      expect(summary.inProgress, greaterThanOrEqualTo(0));
      expect(summary.completed, greaterThanOrEqualTo(0));
    });
  });
}

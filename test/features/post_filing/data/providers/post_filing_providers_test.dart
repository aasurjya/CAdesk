import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/post_filing/data/providers/post_filing_providers.dart';
import 'package:ca_app/features/post_filing/domain/models/filing_status.dart';
import 'package:ca_app/features/post_filing/domain/services/demand_tracking_service.dart';
import 'package:ca_app/features/post_filing/domain/services/itr_status_tracker.dart';
import 'package:ca_app/features/post_filing/domain/services/refund_tracking_service.dart';

void main() {
  group('PostFilingFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is all', () {
      expect(container.read(postFilingFilterProvider), PostFilingFilter.all);
    });

    test('can select itr', () {
      container
          .read(postFilingFilterProvider.notifier)
          .select(PostFilingFilter.itr);
      expect(container.read(postFilingFilterProvider), PostFilingFilter.itr);
    });

    test('can select demands', () {
      container
          .read(postFilingFilterProvider.notifier)
          .select(PostFilingFilter.demands);
      expect(
        container.read(postFilingFilterProvider),
        PostFilingFilter.demands,
      );
    });
  });

  group('SelectedFilingIndexNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedFilingIndexProvider), isNull);
    });

    test('can select an index', () {
      container.read(selectedFilingIndexProvider.notifier).select(2);
      expect(container.read(selectedFilingIndexProvider), 2);
    });

    test('can clear to null', () {
      container.read(selectedFilingIndexProvider.notifier).select(1);
      container.read(selectedFilingIndexProvider.notifier).clear();
      expect(container.read(selectedFilingIndexProvider), isNull);
    });
  });

  group('FilingStatusListNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 8 mock filings', () {
      final filings = container.read(filingStatusListProvider);
      expect(filings.length, 8);
    });

    test('all filings have non-empty filingIds', () {
      final filings = container.read(filingStatusListProvider);
      expect(filings.every((f) => f.filingId.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final filings = container.read(filingStatusListProvider);
      expect(() => (filings as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('filteredFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all filings when filter is all', () {
      final all = container.read(filingStatusListProvider);
      final filtered = container.read(filteredFilingsProvider);
      expect(filtered.length, all.length);
    });

    test('itr filter returns only ITR filings', () {
      container
          .read(postFilingFilterProvider.notifier)
          .select(PostFilingFilter.itr);
      final filtered = container.read(filteredFilingsProvider);
      expect(filtered.every((f) => f.filingType == FilingType.itr), isTrue);
    });

    test('filtered list is subset of all', () {
      container
          .read(postFilingFilterProvider.notifier)
          .select(PostFilingFilter.gst);
      final all = container.read(filingStatusListProvider);
      final filtered = container.read(filteredFilingsProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('filingsSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalFiled matches filings count', () {
      final filings = container.read(filingStatusListProvider);
      final summary = container.read(filingsSummaryProvider);
      expect(summary.totalFiled, filings.length);
    });

    test('refundPending and demands are non-negative', () {
      final summary = container.read(filingsSummaryProvider);
      expect(summary.refundPending, greaterThanOrEqualTo(0));
      expect(summary.demands, greaterThanOrEqualTo(0));
    });
  });

  group('Service providers', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('itrStatusTrackerProvider returns ItrStatusTracker instance', () {
      final service = container.read(itrStatusTrackerProvider);
      expect(service, isA<ItrStatusTracker>());
    });

    test('demandTrackingServiceProvider returns DemandTrackingService', () {
      final service = container.read(demandTrackingServiceProvider);
      expect(service, isA<DemandTrackingService>());
    });

    test('refundTrackingServiceProvider returns RefundTrackingService', () {
      final service = container.read(refundTrackingServiceProvider);
      expect(service, isA<RefundTrackingService>());
    });
  });
}

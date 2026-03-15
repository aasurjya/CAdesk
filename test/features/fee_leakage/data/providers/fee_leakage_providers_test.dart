import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/fee_leakage/data/providers/fee_leakage_providers.dart';
import 'package:ca_app/features/fee_leakage/domain/models/engagement.dart';
import 'package:ca_app/features/fee_leakage/domain/models/scope_item.dart';

void main() {
  group('Fee Leakage Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('allEngagementsProvider', () {
      test('returns non-empty list of engagements', () {
        final engagements = container.read(allEngagementsProvider);
        expect(engagements, isNotEmpty);
        expect(engagements.length, greaterThanOrEqualTo(6));
      });

      test('list is unmodifiable', () {
        final engagements = container.read(allEngagementsProvider);
        expect(
          () => (engagements as dynamic).add(engagements.first),
          throwsA(isA<Error>()),
        );
      });

      test('all entries are Engagement instances', () {
        final engagements = container.read(allEngagementsProvider);
        for (final e in engagements) {
          expect(e, isA<Engagement>());
        }
      });

      test('all engagements have positive agreed fees', () {
        final engagements = container.read(allEngagementsProvider);
        for (final e in engagements) {
          expect(e.agreedFee, greaterThan(0));
        }
      });
    });

    group('allScopeItemsProvider', () {
      test('returns non-empty list of scope items', () {
        final items = container.read(allScopeItemsProvider);
        expect(items, isNotEmpty);
        expect(items.length, greaterThanOrEqualTo(6));
      });

      test('all entries are ScopeItem instances', () {
        final items = container.read(allScopeItemsProvider);
        for (final item in items) {
          expect(item, isA<ScopeItem>());
        }
      });
    });

    group('engagementStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(engagementStatusFilterProvider), isNull);
      });

      test('can be set to onTrack status', () {
        container
            .read(engagementStatusFilterProvider.notifier)
            .update(EngagementStatus.onTrack);
        expect(
          container.read(engagementStatusFilterProvider),
          EngagementStatus.onTrack,
        );
      });

      test('can be set to underBilled status', () {
        container
            .read(engagementStatusFilterProvider.notifier)
            .update(EngagementStatus.underBilled);
        expect(
          container.read(engagementStatusFilterProvider),
          EngagementStatus.underBilled,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(engagementStatusFilterProvider.notifier)
            .update(EngagementStatus.overScope);
        container.read(engagementStatusFilterProvider.notifier).update(null);
        expect(container.read(engagementStatusFilterProvider), isNull);
      });
    });

    group('filteredEngagementsProvider', () {
      test('returns all engagements when no filter is set', () {
        final all = container.read(allEngagementsProvider);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to onTrack engagements only', () {
        container
            .read(engagementStatusFilterProvider.notifier)
            .update(EngagementStatus.onTrack);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((e) => e.status == EngagementStatus.onTrack),
          isTrue,
        );
      });

      test('filters to underBilled engagements only', () {
        container
            .read(engagementStatusFilterProvider.notifier)
            .update(EngagementStatus.underBilled);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((e) => e.status == EngagementStatus.underBilled),
          isTrue,
        );
      });

      test('filters to overScope engagements only', () {
        container
            .read(engagementStatusFilterProvider.notifier)
            .update(EngagementStatus.overScope);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((e) => e.status == EngagementStatus.overScope),
          isTrue,
        );
      });
    });

    group('feeLeakageSummaryProvider', () {
      test('returns a non-null map', () {
        final summary = container.read(feeLeakageSummaryProvider);
        expect(summary, isNotNull);
      });

      test('totalLeakage is non-negative', () {
        final summary = container.read(feeLeakageSummaryProvider);
        expect(summary['totalLeakage'], greaterThanOrEqualTo(0));
      });

      test('onTrack count matches filtered count', () {
        final summary = container.read(feeLeakageSummaryProvider);
        final expected = container
            .read(allEngagementsProvider)
            .where((e) => e.status == EngagementStatus.onTrack)
            .length;
        expect(summary['onTrack'], expected);
      });

      test('overScope count matches filtered count', () {
        final summary = container.read(feeLeakageSummaryProvider);
        final expected = container
            .read(allEngagementsProvider)
            .where((e) => e.status == EngagementStatus.overScope)
            .length;
        expect(summary['overScope'], expected);
      });

      test('underBilled count matches filtered count', () {
        final summary = container.read(feeLeakageSummaryProvider);
        final expected = container
            .read(allEngagementsProvider)
            .where((e) => e.status == EngagementStatus.underBilled)
            .length;
        expect(summary['underBilled'], expected);
      });
    });
  });
}

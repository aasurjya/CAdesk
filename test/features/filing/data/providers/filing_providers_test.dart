import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/data/providers/filing_hub_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';

void main() {
  group('Filing Hub Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('selectedAssessmentYearProvider', () {
      test('initial state is AY 2026-27', () {
        expect(container.read(selectedAssessmentYearProvider), 'AY 2026-27');
      });

      test('can be updated to a different year', () {
        container
            .read(selectedAssessmentYearProvider.notifier)
            .update('AY 2025-26');
        expect(container.read(selectedAssessmentYearProvider), 'AY 2025-26');
      });
    });

    group('filingHubItemsProvider', () {
      test('returns non-empty list of filing items', () {
        final items = container.read(filingHubItemsProvider);
        expect(items, isNotEmpty);
        expect(items.length, greaterThanOrEqualTo(10));
      });

      test('all entries are FilingHubItem instances', () {
        final items = container.read(filingHubItemsProvider);
        for (final item in items) {
          expect(item, isA<FilingHubItem>());
        }
      });

      test('update replaces state', () {
        final original = container.read(filingHubItemsProvider);
        final subset = original.take(3).toList();
        container.read(filingHubItemsProvider.notifier).update(subset);
        expect(container.read(filingHubItemsProvider).length, 3);
      });
    });

    group('urgentFilingsProvider', () {
      test('returns only overdue and dueThisWeek items', () {
        final urgent = container.read(urgentFilingsProvider);
        expect(urgent, isNotEmpty);
        for (final item in urgent) {
          expect(
            item.status == FilingHubStatus.overdue ||
                item.status == FilingHubStatus.dueThisWeek,
            isTrue,
          );
        }
      });

      test('results are sorted by dueDate ascending', () {
        final urgent = container.read(urgentFilingsProvider);
        for (int i = 0; i < urgent.length - 1; i++) {
          expect(
            urgent[i].dueDate.compareTo(urgent[i + 1].dueDate),
            lessThanOrEqualTo(0),
          );
        }
      });
    });

    group('inProgressFilingsProvider', () {
      test('returns only inProgress and draft items', () {
        final inProgress = container.read(inProgressFilingsProvider);
        expect(inProgress, isNotEmpty);
        for (final item in inProgress) {
          expect(
            item.status == FilingHubStatus.inProgress ||
                item.status == FilingHubStatus.draft,
            isTrue,
          );
        }
      });

      test('results are sorted by dueDate ascending', () {
        final inProgress = container.read(inProgressFilingsProvider);
        for (int i = 0; i < inProgress.length - 1; i++) {
          expect(
            inProgress[i].dueDate.compareTo(inProgress[i + 1].dueDate),
            lessThanOrEqualTo(0),
          );
        }
      });
    });

    group('recentFilingsProvider', () {
      test('returns only filed and verified items', () {
        final recent = container.read(recentFilingsProvider);
        expect(recent, isNotEmpty);
        for (final item in recent) {
          expect(
            item.status == FilingHubStatus.filed ||
                item.status == FilingHubStatus.verified,
            isTrue,
          );
        }
      });

      test('results are sorted by filedDate descending', () {
        final recent = container.read(recentFilingsProvider);
        for (int i = 0; i < recent.length - 1; i++) {
          final aDate = recent[i].filedDate ?? DateTime(2000);
          final bDate = recent[i + 1].filedDate ?? DateTime(2000);
          expect(aDate.compareTo(bDate), greaterThanOrEqualTo(0));
        }
      });
    });

    group('urgentFilingsProvider + inProgressFilingsProvider coverage', () {
      test('urgent + inProgress + recent do not overlap', () {
        final urgentIds = container
            .read(urgentFilingsProvider)
            .map((i) => i.id)
            .toSet();
        final inProgressIds = container
            .read(inProgressFilingsProvider)
            .map((i) => i.id)
            .toSet();
        final recentIds = container
            .read(recentFilingsProvider)
            .map((i) => i.id)
            .toSet();

        expect(urgentIds.intersection(inProgressIds), isEmpty);
        expect(urgentIds.intersection(recentIds), isEmpty);
        expect(inProgressIds.intersection(recentIds), isEmpty);
      });
    });
  });
}

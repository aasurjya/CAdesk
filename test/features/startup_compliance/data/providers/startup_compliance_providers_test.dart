import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/startup_compliance/data/providers/startup_providers.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';

void main() {
  group('startupEntitiesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 5 mock startup entities', () {
      final entities = container.read(startupEntitiesProvider);
      expect(entities.length, 5);
    });

    test('all entities have non-empty ids', () {
      final entities = container.read(startupEntitiesProvider);
      expect(entities.every((e) => e.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final entities = container.read(startupEntitiesProvider);
      expect(() => (entities as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('startupFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 15 mock startup filings', () {
      final filings = container.read(startupFilingsProvider);
      expect(filings.length, 15);
    });

    test('all filings have non-empty ids', () {
      final filings = container.read(startupFilingsProvider);
      expect(filings.every((f) => f.id.isNotEmpty), isTrue);
    });
  });

  group('SelectedRecognitionStatusNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedRecognitionStatusProvider), isNull);
    });

    test('can be set to recognized', () {
      container
          .read(selectedRecognitionStatusProvider.notifier)
          .update(RecognitionStatus.recognized);
      expect(
        container.read(selectedRecognitionStatusProvider),
        RecognitionStatus.recognized,
      );
    });

    test('can be reset to null', () {
      container
          .read(selectedRecognitionStatusProvider.notifier)
          .update(RecognitionStatus.expired);
      container.read(selectedRecognitionStatusProvider.notifier).update(null);
      expect(container.read(selectedRecognitionStatusProvider), isNull);
    });
  });

  group('filteredStartupsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all entities when no filter', () {
      final all = container.read(startupEntitiesProvider);
      final filtered = container.read(filteredStartupsProvider);
      expect(filtered.length, all.length);
    });

    test('recognized filter returns only recognized entities', () {
      container
          .read(selectedRecognitionStatusProvider.notifier)
          .update(RecognitionStatus.recognized);
      final filtered = container.read(filteredStartupsProvider);
      expect(
        filtered.every(
          (s) => s.recognitionStatus == RecognitionStatus.recognized,
        ),
        isTrue,
      );
    });
  });

  group('filteredStartupFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all filings when no filter', () {
      final all = container.read(startupFilingsProvider);
      final filtered = container.read(filteredStartupFilingsProvider);
      expect(filtered.length, all.length);
    });

    test('startup filter narrows results by startup id', () {
      container.read(selectedStartupFilterProvider.notifier).update('su-001');
      final filtered = container.read(filteredStartupFilingsProvider);
      expect(filtered.every((f) => f.startupId == 'su-001'), isTrue);
    });

    test('filing type filter returns only matching type', () {
      container
          .read(selectedStartupFilingTypeProvider.notifier)
          .update(StartupFilingType.annualReturn);
      final filtered = container.read(filteredStartupFilingsProvider);
      expect(
        filtered.every((f) => f.filingType == StartupFilingType.annualReturn),
        isTrue,
      );
    });
  });

  group('upcomingStartupFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns only pending and overdue filings', () {
      final upcoming = container.read(upcomingStartupFilingsProvider);
      expect(
        upcoming.every(
          (f) =>
              f.status == StartupFilingStatus.pending ||
              f.status == StartupFilingStatus.overdue,
        ),
        isTrue,
      );
    });

    test('filings are sorted by due date ascending', () {
      final upcoming = container.read(upcomingStartupFilingsProvider);
      for (int i = 1; i < upcoming.length; i++) {
        expect(
          upcoming[i - 1].dueDate.isBefore(upcoming[i].dueDate) ||
              upcoming[i - 1].dueDate.isAtSameMomentAs(upcoming[i].dueDate),
          isTrue,
        );
      }
    });
  });

  group('startupComplianceSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalStartups is 5', () {
      final summary = container.read(startupComplianceSummaryProvider);
      expect(summary.totalStartups, 5);
    });

    test('recognizedCount is non-negative and <= total', () {
      final summary = container.read(startupComplianceSummaryProvider);
      expect(summary.recognizedCount, greaterThanOrEqualTo(0));
      expect(summary.recognizedCount, lessThanOrEqualTo(summary.totalStartups));
    });

    test('overdueFilings + pendingFilings + filedCount does not exceed 15', () {
      final summary = container.read(startupComplianceSummaryProvider);
      expect(
        summary.overdueFilings + summary.pendingFilings + summary.filedCount,
        lessThanOrEqualTo(15),
      );
    });
  });
}

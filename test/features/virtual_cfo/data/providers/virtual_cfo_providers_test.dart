import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/virtual_cfo/data/providers/virtual_cfo_providers.dart';

void main() {
  group('allMisReportsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 8 MIS reports', () {
      final reports = container.read(allMisReportsProvider);
      expect(reports.length, 8);
    });

    test('all reports have non-empty ids', () {
      final reports = container.read(allMisReportsProvider);
      expect(reports.every((r) => r.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final reports = container.read(allMisReportsProvider);
      expect(() => (reports as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('allCfoScenariosProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 10 CFO scenarios', () {
      final scenarios = container.read(allCfoScenariosProvider);
      expect(scenarios.length, 10);
    });

    test('all scenarios have non-empty ids', () {
      final scenarios = container.read(allCfoScenariosProvider);
      expect(scenarios.every((s) => s.id.isNotEmpty), isTrue);
    });
  });

  group('selectedMisStatusProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedMisStatusProvider), isNull);
    });

    test('can be set to Delivered', () {
      container.read(selectedMisStatusProvider.notifier).update('Delivered');
      expect(container.read(selectedMisStatusProvider), 'Delivered');
    });

    test('can be reset to null', () {
      container.read(selectedMisStatusProvider.notifier).update('Approved');
      container.read(selectedMisStatusProvider.notifier).update(null);
      expect(container.read(selectedMisStatusProvider), isNull);
    });
  });

  group('selectedScenarioCategoryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedScenarioCategoryProvider), isNull);
    });

    test('can be set to Revenue', () {
      container
          .read(selectedScenarioCategoryProvider.notifier)
          .update('Revenue');
      expect(container.read(selectedScenarioCategoryProvider), 'Revenue');
    });
  });

  group('filteredMisReportsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all when no filter', () {
      final all = container.read(allMisReportsProvider);
      final filtered = container.read(filteredMisReportsProvider);
      expect(filtered.length, all.length);
    });

    test('Delivered filter returns only delivered reports', () {
      container.read(selectedMisStatusProvider.notifier).update('Delivered');
      final filtered = container.read(filteredMisReportsProvider);
      expect(filtered.every((r) => r.status == 'Delivered'), isTrue);
    });
  });

  group('filteredCfoScenariosProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all when no filter', () {
      final all = container.read(allCfoScenariosProvider);
      final filtered = container.read(filteredCfoScenariosProvider);
      expect(filtered.length, all.length);
    });

    test('Revenue filter returns only Revenue scenarios', () {
      container
          .read(selectedScenarioCategoryProvider.notifier)
          .update('Revenue');
      final filtered = container.read(filteredCfoScenariosProvider);
      expect(filtered.every((s) => s.category == 'Revenue'), isTrue);
    });
  });

  group('virtualCfoKpiProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('contains required keys', () {
      final kpi = container.read(virtualCfoKpiProvider);
      expect(kpi.containsKey('clients'), isTrue);
      expect(kpi.containsKey('aum'), isTrue);
      expect(kpi.containsKey('avgEbitda'), isTrue);
      expect(kpi.containsKey('reportsThisMonth'), isTrue);
    });

    test('clients count is non-empty string', () {
      final kpi = container.read(virtualCfoKpiProvider);
      expect(kpi['clients']!.isNotEmpty, isTrue);
    });
  });
}

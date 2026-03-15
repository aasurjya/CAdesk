import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/roadmap_modules/data/providers/roadmap_modules_providers.dart';

void main() {
  group('roadmapModulesProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns a non-empty map of module definitions', () {
      final modules = container.read(roadmapModulesProvider);
      expect(modules, isNotEmpty);
    });

    test('all modules have non-empty ids as map keys', () {
      final modules = container.read(roadmapModulesProvider);
      expect(modules.keys.every((k) => k.isNotEmpty), isTrue);
    });

    test('module ids match their map keys', () {
      final modules = container.read(roadmapModulesProvider);
      expect(
        modules.entries.every((e) => e.value.id == e.key),
        isTrue,
      );
    });

    test('contains 18 module definitions', () {
      final modules = container.read(roadmapModulesProvider);
      expect(modules.length, 18);
    });
  });

  group('roadmapModuleProvider (family)', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns module for known id', () {
      final module = container.read(roadmapModuleProvider('4'));
      expect(module, isNotNull);
      expect(module!.id, '4');
    });

    test('returns null for unknown id', () {
      final module = container.read(roadmapModuleProvider('nonexistent'));
      expect(module, isNull);
    });

    test('module has non-empty title', () {
      final module = container.read(roadmapModuleProvider('4'));
      expect(module!.title.isNotEmpty, isTrue);
    });
  });

  group('roadmapModuleSummaryProvider (family)', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns summary for known module id', () {
      final summary = container.read(roadmapModuleSummaryProvider('4'));
      expect(summary, isNotNull);
    });

    test('returns null for unknown module id', () {
      final summary = container.read(roadmapModuleSummaryProvider('unknown'));
      expect(summary, isNull);
    });

    test('summary totalItems is non-negative', () {
      final summary = container.read(roadmapModuleSummaryProvider('4'));
      expect(summary!.totalItems, greaterThanOrEqualTo(0));
    });

    test('activeItems does not exceed totalItems', () {
      final summary = container.read(roadmapModuleSummaryProvider('4'));
      expect(summary!.activeItems, lessThanOrEqualTo(summary.totalItems));
    });

    test('atRiskItems does not exceed activeItems', () {
      final summary = container.read(roadmapModuleSummaryProvider('4'));
      expect(summary!.atRiskItems, lessThanOrEqualTo(summary.activeItems));
    });

    test('enabledAutomations is non-negative', () {
      final summary = container.read(roadmapModuleSummaryProvider('4'));
      expect(summary!.enabledAutomations, greaterThanOrEqualTo(0));
    });
  });
}

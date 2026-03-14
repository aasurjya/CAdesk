import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/roadmap_modules/data/repositories/mock_roadmap_modules_repository.dart';
import 'package:ca_app/features/roadmap_modules/domain/models/roadmap_module_models.dart';

void main() {
  group('MockRoadmapModulesRepository', () {
    late MockRoadmapModulesRepository repo;

    setUp(() {
      repo = MockRoadmapModulesRepository();
    });

    group('getAllModules', () {
      test('returns seeded modules', () async {
        final result = await repo.getAllModules();
        expect(result, isNotEmpty);
      });

      test('returns a typed list', () async {
        final result = await repo.getAllModules();
        expect(result, isA<List<RoadmapModuleDefinition>>());
      });
    });

    group('getModuleById', () {
      test('returns module for valid id', () async {
        final result = await repo.getModuleById('gst');
        expect(result, isNotNull);
        expect(result!.id, 'gst');
      });

      test('returns null for unknown id', () async {
        final result = await repo.getModuleById('unknown-module');
        expect(result, isNull);
      });
    });

    group('toggleAutomation', () {
      test('toggles automation enabled state', () async {
        final module = await repo.getModuleById('gst');
        expect(module, isNotNull);

        final automation = module!.automations.first;
        final originalEnabled = automation.enabled;

        final toggled = await repo.toggleAutomation('gst', automation.id);
        expect(toggled, isNotNull);
        expect(toggled!.enabled, !originalEnabled);

        // Verify state was persisted
        final updated = await repo.getModuleById('gst');
        final updatedAuto = updated!.automations.firstWhere(
          (a) => a.id == automation.id,
        );
        expect(updatedAuto.enabled, !originalEnabled);
      });

      test('returns null for unknown module', () async {
        final result = await repo.toggleAutomation(
          'unknown-module',
          'some-auto',
        );
        expect(result, isNull);
      });

      test('returns null for unknown automation', () async {
        final result = await repo.toggleAutomation('gst', 'unknown-auto');
        expect(result, isNull);
      });
    });

    group('getSummary', () {
      test('returns summary with non-negative counts', () async {
        final summary = await repo.getSummary();
        expect(summary.totalItems, greaterThanOrEqualTo(0));
        expect(summary.activeItems, greaterThanOrEqualTo(0));
        expect(summary.atRiskItems, greaterThanOrEqualTo(0));
        expect(summary.enabledAutomations, greaterThanOrEqualTo(0));
      });

      test('activeItems <= totalItems', () async {
        final summary = await repo.getSummary();
        expect(summary.activeItems, lessThanOrEqualTo(summary.totalItems));
      });

      test('reflects toggled automation count', () async {
        final before = await repo.getSummary();
        final module = await repo.getModuleById('tds');
        final disabledAuto = module!.automations.firstWhere((a) => !a.enabled);

        await repo.toggleAutomation('tds', disabledAuto.id);

        final after = await repo.getSummary();
        expect(after.enabledAutomations, before.enabledAutomations + 1);
      });
    });
  });
}

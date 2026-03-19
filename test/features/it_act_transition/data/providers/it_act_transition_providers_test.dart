import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';
import 'package:ca_app/features/it_act_transition/domain/models/section_mapping.dart';
import 'package:ca_app/features/it_act_transition/domain/models/tax_year.dart';
import 'package:ca_app/features/it_act_transition/data/providers/it_act_transition_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ActMode providers', () {
    test('currentActModeProvider returns valid ActMode', () {
      final mode = container.read(currentActModeProvider);
      expect(ActMode.values, contains(mode));
    });

    test('effectiveActModeProvider defaults to current', () {
      final effective = container.read(effectiveActModeProvider);
      final current = container.read(currentActModeProvider);
      expect(effective, current);
    });

    test('actModeOverrideProvider overrides effective mode', () {
      container.read(actModeOverrideProvider.notifier).set(ActMode.act1961);
      final effective = container.read(effectiveActModeProvider);
      expect(effective, ActMode.act1961);
    });

    test('clearing override reverts to current', () {
      container.read(actModeOverrideProvider.notifier).set(ActMode.act1961);
      container.read(actModeOverrideProvider.notifier).clear();
      final effective = container.read(effectiveActModeProvider);
      final current = container.read(currentActModeProvider);
      expect(effective, current);
    });
  });

  group('TaxYear providers', () {
    test('currentTaxYearProvider returns valid TaxYear', () {
      final ty = container.read(currentTaxYearProvider);
      expect(ty.startYear, greaterThan(2020));
    });

    test('recentTaxYearsProvider returns 6 years', () {
      final years = container.read(recentTaxYearsProvider);
      expect(years.length, 6);
    });

    test('selectedTaxYearProvider defaults to current', () {
      final selected = container.read(selectedTaxYearProvider);
      final current = container.read(currentTaxYearProvider);
      expect(selected, current);
    });

    test('selectedTaxYearProvider can be changed', () {
      container
          .read(selectedTaxYearProvider.notifier)
          .select(const TaxYear(startYear: 2024));
      final selected = container.read(selectedTaxYearProvider);
      expect(selected.startYear, 2024);
    });
  });

  group('Section mapper providers', () {
    test('allSectionMappingsProvider has 200+ entries', () {
      final mappings = container.read(allSectionMappingsProvider);
      expect(mappings.length, greaterThanOrEqualTo(200));
    });

    test('sectionsByCategoryProvider filters correctly', () {
      final tds = container.read(
        sectionsByCategoryProvider(SectionCategory.tds),
      );
      expect(tds, isNotEmpty);
      for (final m in tds) {
        expect(m.category, SectionCategory.tds);
      }
    });

    test('sectionDisplayProvider returns Section string', () {
      final display = container.read(sectionDisplayProvider('80C'));
      expect(display, contains('Section'));
    });

    test('sectionDualDisplayProvider shows both', () {
      final display = container.read(sectionDualDisplayProvider('143(1)'));
      expect(display, contains('270(1)'));
      expect(display, contains('143(1)'));
    });

    test('sectionSearchProvider returns results', () {
      final results = container.read(sectionSearchProvider('salary'));
      expect(results, isNotEmpty);
    });

    test('sectionSearchProvider returns empty for no match', () {
      final results = container.read(sectionSearchProvider('zzzznonexistent'));
      expect(results, isEmpty);
    });

    test('sectionSearchProvider returns empty for empty query', () {
      final results = container.read(sectionSearchProvider(''));
      expect(results, isEmpty);
    });
  });

  group('Derived providers', () {
    test('advanceTaxInstallmentsProvider returns 4 installments', () {
      final installments = container.read(advanceTaxInstallmentsProvider);
      expect(installments.length, 4);
    });

    test('isNewActProvider reflects selected tax year', () {
      container
          .read(selectedTaxYearProvider.notifier)
          .select(const TaxYear(startYear: 2025));
      expect(container.read(isNewActProvider), isFalse);

      container
          .read(selectedTaxYearProvider.notifier)
          .select(const TaxYear(startYear: 2026));
      expect(container.read(isNewActProvider), isTrue);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';
import 'package:ca_app/features/it_act_transition/domain/models/section_mapping.dart';
import 'package:ca_app/features/it_act_transition/domain/models/tax_year.dart';
import 'package:ca_app/features/it_act_transition/domain/services/section_mapper_service.dart';
import 'package:ca_app/features/it_act_transition/domain/services/tax_year_service.dart';

// =============================================================================
// ACT MODE
// =============================================================================

/// The current [ActMode] based on today's date.
final currentActModeProvider = Provider<ActMode>((ref) {
  return ActMode.current;
});

/// Override-able ActMode for viewing historical data under the other Act.
class ActModeOverrideNotifier extends Notifier<ActMode?> {
  @override
  ActMode? build() => null;

  void set(ActMode? mode) => state = mode;
  void clear() => state = null;
}

final actModeOverrideProvider =
    NotifierProvider<ActModeOverrideNotifier, ActMode?>(
      ActModeOverrideNotifier.new,
    );

/// Effective ActMode — uses override if set, otherwise auto-detected.
final effectiveActModeProvider = Provider<ActMode>((ref) {
  return ref.watch(actModeOverrideProvider) ??
      ref.watch(currentActModeProvider);
});

// =============================================================================
// TAX YEAR
// =============================================================================

/// The current Tax Year.
final currentTaxYearProvider = Provider<TaxYear>((ref) {
  return TaxYear.current;
});

/// Recent tax years for dropdown selectors (current + 5 prior).
final recentTaxYearsProvider = Provider<List<TaxYear>>((ref) {
  return TaxYearService.recentTaxYears();
});

/// Selected tax year — defaults to current.
class SelectedTaxYearNotifier extends Notifier<TaxYear> {
  @override
  TaxYear build() => ref.read(currentTaxYearProvider);

  void select(TaxYear taxYear) => state = taxYear;
}

final selectedTaxYearProvider =
    NotifierProvider<SelectedTaxYearNotifier, TaxYear>(
      SelectedTaxYearNotifier.new,
    );

// =============================================================================
// SECTION MAPPER
// =============================================================================

/// All section mappings.
final allSectionMappingsProvider = Provider<List<SectionMapping>>((ref) {
  return SectionMapperService.allMappings;
});

/// Section mappings filtered by category.
final sectionsByCategoryProvider =
    Provider.family<List<SectionMapping>, SectionCategory>((ref, category) {
      return SectionMapperService.byCategory(category);
    });

/// Look up a 1961 section's display string, respecting current ActMode.
final sectionDisplayProvider = Provider.family<String, String>((
  ref,
  section1961,
) {
  final mode = ref.watch(effectiveActModeProvider);
  return SectionMapperService.displaySection(
    section1961: section1961,
    mode: mode,
  );
});

/// Dual display for a section (shows both old and new).
final sectionDualDisplayProvider = Provider.family<String, String>((
  ref,
  section1961,
) {
  return SectionMapperService.dualDisplay(section1961);
});

/// Search mappings by description keyword.
final sectionSearchProvider = Provider.family<List<SectionMapping>, String>((
  ref,
  query,
) {
  if (query.isEmpty) return [];
  return SectionMapperService.searchByDescription(query);
});

// =============================================================================
// TAX YEAR SERVICE — DERIVED
// =============================================================================

/// Filing due date for the selected tax year.
final filingDueDateProvider =
    Provider.family<DateTime, ({bool isAudit, bool isTP})>((ref, params) {
      final ty = ref.watch(selectedTaxYearProvider);
      return TaxYearService.filingDueDate(
        taxYear: ty,
        isAuditCase: params.isAudit,
        isTransferPricingCase: params.isTP,
      );
    });

/// Advance tax installments for the selected tax year.
final advanceTaxInstallmentsProvider = Provider<List<AdvanceTaxInstallment>>((
  ref,
) {
  final ty = ref.watch(selectedTaxYearProvider);
  return TaxYearService.advanceTaxInstallments(ty);
});

/// Whether the selected tax year is under the new IT Act 2025.
final isNewActProvider = Provider<bool>((ref) {
  final ty = ref.watch(selectedTaxYearProvider);
  return ty.actMode == ActMode.act2025;
});

import 'package:ca_app/features/roadmap_modules/domain/models/roadmap_module_models.dart';

/// Abstract contract for Roadmap Modules data operations.
abstract class RoadmapModulesRepository {
  /// Retrieve all roadmap module definitions.
  Future<List<RoadmapModuleDefinition>> getAllModules();

  /// Retrieve a specific module by [id]. Returns null if not found.
  Future<RoadmapModuleDefinition?> getModuleById(String id);

  /// Toggle the enabled state of a [RoadmapAutomation] within a module.
  ///
  /// [moduleId] — the containing module's ID
  /// [automationId] — the automation to toggle
  /// Returns the updated [RoadmapAutomation] or null if not found.
  Future<RoadmapAutomation?> toggleAutomation(
    String moduleId,
    String automationId,
  );

  /// Retrieve aggregated summary statistics across all modules.
  Future<RoadmapModuleSummary> getSummary();
}

import 'package:ca_app/features/roadmap_modules/domain/models/roadmap_module_models.dart';
import 'package:ca_app/features/roadmap_modules/domain/repositories/roadmap_modules_repository.dart';

/// Real implementation of [RoadmapModulesRepository].
///
/// Full Drift/Supabase wiring is deferred until a later phase.
class RoadmapModulesRepositoryImpl implements RoadmapModulesRepository {
  const RoadmapModulesRepositoryImpl();

  @override
  Future<List<RoadmapModuleDefinition>> getAllModules() async => const [];

  @override
  Future<RoadmapModuleDefinition?> getModuleById(String id) async => null;

  @override
  Future<RoadmapAutomation?> toggleAutomation(
    String moduleId,
    String automationId,
  ) async => null;

  @override
  Future<RoadmapModuleSummary> getSummary() async {
    return const RoadmapModuleSummary(
      totalItems: 0,
      activeItems: 0,
      atRiskItems: 0,
      enabledAutomations: 0,
    );
  }
}

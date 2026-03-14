import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/roadmap_modules/data/repositories/mock_roadmap_modules_repository.dart';
import 'package:ca_app/features/roadmap_modules/data/repositories/roadmap_modules_repository_impl.dart';
import 'package:ca_app/features/roadmap_modules/domain/repositories/roadmap_modules_repository.dart';

/// Provides the active [RoadmapModulesRepository].
///
/// Returns [MockRoadmapModulesRepository] unless the `roadmap_modules_real_repo`
/// feature flag is enabled.
final roadmapModulesRepositoryProvider = Provider<RoadmapModulesRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('roadmap_modules_real_repo') ?? false;

  if (!useReal) {
    return MockRoadmapModulesRepository();
  }

  return const RoadmapModulesRepositoryImpl();
});

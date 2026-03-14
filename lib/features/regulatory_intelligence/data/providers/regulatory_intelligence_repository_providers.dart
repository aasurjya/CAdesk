import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/regulatory_intelligence/data/repositories/mock_regulatory_intelligence_repository.dart';
import 'package:ca_app/features/regulatory_intelligence/data/repositories/regulatory_intelligence_repository_impl.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/repositories/regulatory_intelligence_repository.dart';

/// Provides the active [RegulatoryIntelligenceRepository].
///
/// Returns [MockRegulatoryIntelligenceRepository] unless the
/// `regulatory_intelligence_real_repo` feature flag is enabled, in which case
/// [RegulatoryIntelligenceRepositoryImpl] is used.
final regulatoryIntelligenceRepositoryProvider =
    Provider<RegulatoryIntelligenceRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('regulatory_intelligence_real_repo') ??
          false;

  if (!useReal) {
    return MockRegulatoryIntelligenceRepository();
  }

  return RegulatoryIntelligenceRepositoryImpl(Supabase.instance.client);
});

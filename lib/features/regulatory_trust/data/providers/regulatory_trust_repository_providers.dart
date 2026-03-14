import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/regulatory_trust/data/repositories/mock_regulatory_trust_repository.dart';
import 'package:ca_app/features/regulatory_trust/data/repositories/regulatory_trust_repository_impl.dart';
import 'package:ca_app/features/regulatory_trust/domain/repositories/regulatory_trust_repository.dart';

/// Provides the active [RegulatoryTrustRepository].
///
/// Returns [MockRegulatoryTrustRepository] unless the
/// `regulatory_trust_real_repo` feature flag is enabled, in which case
/// [RegulatoryTrustRepositoryImpl] is used.
final regulatoryTrustRepositoryProvider = Provider<RegulatoryTrustRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('regulatory_trust_real_repo') ?? false;

  if (!useReal) {
    return MockRegulatoryTrustRepository();
  }

  return RegulatoryTrustRepositoryImpl(Supabase.instance.client);
});

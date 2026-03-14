import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/idp/data/repositories/idp_repository_impl.dart';
import 'package:ca_app/features/idp/data/repositories/mock_idp_repository.dart';
import 'package:ca_app/features/idp/domain/repositories/idp_repository.dart';

/// Provides the active [IdpRepository].
///
/// Returns [MockIdpRepository] unless the `idp_real_repo` feature flag is
/// enabled, in which case [IdpRepositoryImpl] (Supabase) is used.
final idpRepositoryProvider = Provider<IdpRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('idp_real_repo') ?? false;

  if (!useReal) {
    return MockIdpRepository();
  }

  return IdpRepositoryImpl(Supabase.instance.client);
});

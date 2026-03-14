import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/renewal_expiry/data/repositories/mock_renewal_expiry_repository.dart';
import 'package:ca_app/features/renewal_expiry/data/repositories/renewal_expiry_repository_impl.dart';
import 'package:ca_app/features/renewal_expiry/domain/repositories/renewal_expiry_repository.dart';

/// Provides the active [RenewalExpiryRepository].
///
/// Returns [MockRenewalExpiryRepository] unless the `renewal_expiry_real_repo`
/// feature flag is enabled, in which case [RenewalExpiryRepositoryImpl] is used.
final renewalExpiryRepositoryProvider = Provider<RenewalExpiryRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('renewal_expiry_real_repo') ?? false;

  if (!useReal) {
    return MockRenewalExpiryRepository();
  }

  return RenewalExpiryRepositoryImpl(Supabase.instance.client);
});

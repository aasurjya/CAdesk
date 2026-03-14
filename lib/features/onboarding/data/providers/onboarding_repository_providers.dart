import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/onboarding/data/repositories/mock_onboarding_repository.dart';
import 'package:ca_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:ca_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Provides the active [OnboardingRepository].
///
/// Returns [MockOnboardingRepository] unless the `onboarding_real_repo`
/// feature flag is enabled, in which case [OnboardingRepositoryImpl] is used.
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('onboarding_real_repo') ?? false;

  if (!useReal) {
    return MockOnboardingRepository();
  }

  return OnboardingRepositoryImpl(Supabase.instance.client);
});

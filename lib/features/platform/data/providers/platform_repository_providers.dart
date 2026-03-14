import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/platform/data/repositories/mock_platform_repository.dart';
import 'package:ca_app/features/platform/data/repositories/platform_repository_impl.dart';
import 'package:ca_app/features/platform/domain/repositories/platform_repository.dart';

/// Provides the active [PlatformRepository].
///
/// Returns [MockPlatformRepository] unless the `platform_real_repo`
/// feature flag is enabled, in which case [PlatformRepositoryImpl] is used.
final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('platform_real_repo') ?? false;

  if (!useReal) {
    return MockPlatformRepository();
  }

  return PlatformRepositoryImpl(Supabase.instance.client);
});

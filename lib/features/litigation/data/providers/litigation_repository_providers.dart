import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/litigation/data/repositories/litigation_repository_impl.dart';
import 'package:ca_app/features/litigation/data/repositories/mock_litigation_repository.dart';
import 'package:ca_app/features/litigation/domain/repositories/litigation_repository.dart';

/// Provides the active [LitigationRepository].
///
/// Returns [MockLitigationRepository] unless the `litigation_real_repo`
/// feature flag is enabled, in which case [LitigationRepositoryImpl]
/// (Supabase) is used.
final litigationRepositoryProvider = Provider<LitigationRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('litigation_real_repo') ?? false;

  if (!useReal) {
    return MockLitigationRepository();
  }

  return LitigationRepositoryImpl(Supabase.instance.client);
});

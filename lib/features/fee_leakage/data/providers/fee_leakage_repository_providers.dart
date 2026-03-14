import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/fee_leakage/data/repositories/fee_leakage_repository_impl.dart';
import 'package:ca_app/features/fee_leakage/data/repositories/mock_fee_leakage_repository.dart';
import 'package:ca_app/features/fee_leakage/domain/repositories/fee_leakage_repository.dart';

/// Provides the active [FeeLeakageRepository].
///
/// Returns [MockFeeLeakageRepository] unless the `fee_leakage_real_repo`
/// feature flag is enabled, in which case [FeeLeakageRepositoryImpl]
/// (Supabase) is used.
final feeLeakageRepositoryProvider = Provider<FeeLeakageRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('fee_leakage_real_repo') ?? false;

  if (!useReal) {
    return MockFeeLeakageRepository();
  }

  return FeeLeakageRepositoryImpl(Supabase.instance.client);
});

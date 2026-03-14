import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/virtual_cfo/data/repositories/mock_virtual_cfo_repository.dart';
import 'package:ca_app/features/virtual_cfo/data/repositories/virtual_cfo_repository_impl.dart';
import 'package:ca_app/features/virtual_cfo/domain/repositories/virtual_cfo_repository.dart';

/// Provides the active [VirtualCfoRepository].
///
/// Returns [MockVirtualCfoRepository] unless the `virtual_cfo_real_repo`
/// feature flag is enabled, in which case [VirtualCfoRepositoryImpl] is used.
final virtualCfoRepositoryProvider = Provider<VirtualCfoRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('virtual_cfo_real_repo') ?? false;

  if (!useReal) {
    return MockVirtualCfoRepository();
  }

  return const VirtualCfoRepositoryImpl();
});

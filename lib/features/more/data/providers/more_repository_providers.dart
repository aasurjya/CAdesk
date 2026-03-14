import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/more/data/repositories/mock_more_repository.dart';
import 'package:ca_app/features/more/data/repositories/more_repository_impl.dart';
import 'package:ca_app/features/more/domain/repositories/more_repository.dart';

/// Provides the active [MoreRepository].
///
/// Returns [MockMoreRepository] unless the `more_real_repo` feature flag
/// is enabled, in which case [MoreRepositoryImpl] is used.
final moreRepositoryProvider = Provider<MoreRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('more_real_repo') ?? false;

  if (!useReal) {
    return MockMoreRepository();
  }

  return const MoreRepositoryImpl();
});

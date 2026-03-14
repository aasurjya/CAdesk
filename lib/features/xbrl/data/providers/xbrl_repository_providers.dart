import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/xbrl/data/repositories/mock_xbrl_repository.dart';
import 'package:ca_app/features/xbrl/data/repositories/xbrl_repository_impl.dart';
import 'package:ca_app/features/xbrl/domain/repositories/xbrl_repository.dart';

/// Provides the active [XbrlRepository].
///
/// Returns [MockXbrlRepository] unless the `xbrl_real_repo` feature flag
/// is enabled, in which case [XbrlRepositoryImpl] is used.
final xbrlRepositoryProvider = Provider<XbrlRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('xbrl_real_repo') ?? false;

  if (!useReal) {
    return MockXbrlRepository();
  }

  return const XbrlRepositoryImpl();
});

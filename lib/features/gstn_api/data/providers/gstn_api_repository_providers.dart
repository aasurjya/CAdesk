import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/data/repositories/gstn_api_repository_impl.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';

/// Provides the active [GstnRepository].
///
/// Returns [MockGstnRepository] unless the `gstn_api_real_repo` feature flag
/// is enabled, in which case [GstnApiRepositoryImpl] is used.
final gstnApiRepositoryProvider = Provider<GstnRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('gstn_api_real_repo') ?? false;

  if (!useReal) {
    return MockGstnRepository();
  }

  return const GstnApiRepositoryImpl();
});

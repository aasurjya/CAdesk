import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/traces/data/mock_traces_repository.dart';
import 'package:ca_app/features/traces/data/repositories/traces_repository_impl.dart';
import 'package:ca_app/features/traces/domain/repositories/traces_repository.dart';

/// Provides the active [TracesRepository].
///
/// Returns [MockTracesRepository] unless the `traces_real_repo` feature flag
/// is enabled, in which case [TracesRepositoryImpl] is used.
final tracesRepositoryProvider = Provider<TracesRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('traces_real_repo') ?? false;

  if (!useReal) {
    return MockTracesRepository();
  }

  return const TracesRepositoryImpl();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/cma/data/datasources/cma_local_source.dart';
import 'package:ca_app/features/cma/data/datasources/cma_remote_source.dart';
import 'package:ca_app/features/cma/data/repositories/cma_repository_impl.dart';
import 'package:ca_app/features/cma/data/repositories/mock_cma_repository.dart';
import 'package:ca_app/features/cma/domain/repositories/cma_repository.dart';

/// Provides the [CmaRemoteSource] (Supabase client).
final cmaRemoteSourceProvider = Provider<CmaRemoteSource>((ref) {
  return CmaRemoteSource(Supabase.instance.client);
});

/// Provides the [CmaLocalSource] (in-memory cache).
final cmaLocalSourceProvider = Provider<CmaLocalSource>((ref) {
  return CmaLocalSource();
});

/// Provides the active [CmaRepository].
///
/// Returns [MockCmaRepository] unless the `cma_real_repo` feature
/// flag is enabled, in which case [CmaRepositoryImpl] is used.
final cmaRepositoryProvider = Provider<CmaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('cma_real_repo') ?? false;

  if (!useReal) {
    return MockCmaRepository();
  }

  return CmaRepositoryImpl(
    remote: ref.watch(cmaRemoteSourceProvider),
    local: ref.watch(cmaLocalSourceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/ca_gpt/data/datasources/ca_gpt_local_source.dart';
import 'package:ca_app/features/ca_gpt/data/datasources/ca_gpt_remote_source.dart';
import 'package:ca_app/features/ca_gpt/data/repositories/ca_gpt_repository_impl.dart';
import 'package:ca_app/features/ca_gpt/data/repositories/mock_ca_gpt_repository.dart';
import 'package:ca_app/features/ca_gpt/domain/repositories/ca_gpt_repository.dart';

/// Provides the [CaGptRemoteSource] (Supabase client).
final caGptRemoteSourceProvider = Provider<CaGptRemoteSource>((ref) {
  return CaGptRemoteSource(Supabase.instance.client);
});

/// Provides the [CaGptLocalSource] (in-memory cache).
final caGptLocalSourceProvider = Provider<CaGptLocalSource>((ref) {
  return CaGptLocalSource();
});

/// Provides the active [CaGptRepository].
///
/// Returns [MockCaGptRepository] unless the `ca_gpt_real_repo` feature
/// flag is enabled, in which case [CaGptRepositoryImpl] is used.
final caGptRepositoryProvider = Provider<CaGptRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('ca_gpt_real_repo') ?? false;

  if (!useReal) {
    return MockCaGptRepository();
  }

  return CaGptRepositoryImpl(
    remote: ref.watch(caGptRemoteSourceProvider),
    local: ref.watch(caGptLocalSourceProvider),
  );
});

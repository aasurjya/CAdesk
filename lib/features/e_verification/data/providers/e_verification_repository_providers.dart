import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/e_verification/data/datasources/e_verification_local_source.dart';
import 'package:ca_app/features/e_verification/data/datasources/e_verification_remote_source.dart';
import 'package:ca_app/features/e_verification/data/repositories/e_verification_repository_impl.dart';
import 'package:ca_app/features/e_verification/data/repositories/mock_e_verification_repository.dart';
import 'package:ca_app/features/e_verification/domain/repositories/e_verification_repository.dart';

/// Provides the [EVerificationRemoteSource] (Supabase client).
final eVerificationRemoteSourceProvider = Provider<EVerificationRemoteSource>((
  ref,
) {
  return EVerificationRemoteSource(Supabase.instance.client);
});

/// Provides the [EVerificationLocalSource] (Drift/SQLite).
final eVerificationLocalSourceProvider = Provider<EVerificationLocalSource>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return EVerificationLocalSource(db);
});

/// Provides the active [EVerificationRepository].
///
/// Returns [MockEVerificationRepository] unless the `e_verification_real_repo`
/// feature flag is enabled, in which case [EVerificationRepositoryImpl] is used.
final eVerificationRepositoryProvider = Provider<EVerificationRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('e_verification_real_repo') ?? false;

  if (!useReal) {
    return MockEVerificationRepository();
  }

  return EVerificationRepositoryImpl(
    remote: ref.watch(eVerificationRemoteSourceProvider),
    local: ref.watch(eVerificationLocalSourceProvider),
  );
});

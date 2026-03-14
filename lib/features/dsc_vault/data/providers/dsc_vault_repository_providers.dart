import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/dsc_vault/data/datasources/dsc_vault_local_source.dart';
import 'package:ca_app/features/dsc_vault/data/datasources/dsc_vault_remote_source.dart';
import 'package:ca_app/features/dsc_vault/data/repositories/dsc_vault_repository_impl.dart';
import 'package:ca_app/features/dsc_vault/data/repositories/mock_dsc_vault_repository.dart';
import 'package:ca_app/features/dsc_vault/domain/repositories/dsc_vault_repository.dart';

/// Provides the [DscVaultRemoteSource] (Supabase client).
final dscVaultRemoteSourceProvider = Provider<DscVaultRemoteSource>((ref) {
  return DscVaultRemoteSource(Supabase.instance.client);
});

/// Provides the [DscVaultLocalSource] (Drift/SQLite).
final dscVaultLocalSourceProvider = Provider<DscVaultLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DscVaultLocalSource(db);
});

/// Provides the active [DscVaultRepository].
///
/// Returns [MockDscVaultRepository] unless the `dsc_vault_real_repo` feature
/// flag is enabled, in which case [DscVaultRepositoryImpl] is used.
final dscVaultRepositoryProvider = Provider<DscVaultRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('dsc_vault_real_repo') ?? false;

  if (!useReal) {
    return MockDscVaultRepository();
  }

  return DscVaultRepositoryImpl(
    remote: ref.watch(dscVaultRemoteSourceProvider),
    local: ref.watch(dscVaultLocalSourceProvider),
  );
});

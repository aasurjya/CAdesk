import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/ecosystem/data/datasources/ecosystem_local_source.dart';
import 'package:ca_app/features/ecosystem/data/datasources/ecosystem_remote_source.dart';
import 'package:ca_app/features/ecosystem/data/repositories/ecosystem_repository_impl.dart';
import 'package:ca_app/features/ecosystem/data/repositories/mock_ecosystem_repository.dart';
import 'package:ca_app/features/ecosystem/domain/repositories/ecosystem_repository.dart';

/// Provides the [EcosystemRemoteSource] (Supabase client).
final ecosystemRemoteSourceProvider = Provider<EcosystemRemoteSource>((ref) {
  return EcosystemRemoteSource(Supabase.instance.client);
});

/// Provides the [EcosystemLocalSource] (Drift/SQLite).
final ecosystemLocalSourceProvider = Provider<EcosystemLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EcosystemLocalSource(db);
});

/// Provides the active [EcosystemRepository].
///
/// Returns [MockEcosystemRepository] unless the `ecosystem_real_repo` feature
/// flag is enabled, in which case [EcosystemRepositoryImpl] is used.
final ecosystemRepositoryProvider = Provider<EcosystemRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('ecosystem_real_repo') ?? false;

  if (!useReal) {
    return MockEcosystemRepository();
  }

  return EcosystemRepositoryImpl(
    remote: ref.watch(ecosystemRemoteSourceProvider),
    local: ref.watch(ecosystemLocalSourceProvider),
  );
});

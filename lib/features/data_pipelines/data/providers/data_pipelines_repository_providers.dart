import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/data_pipelines/data/datasources/data_pipelines_local_source.dart';
import 'package:ca_app/features/data_pipelines/data/datasources/data_pipelines_remote_source.dart';
import 'package:ca_app/features/data_pipelines/data/repositories/data_pipelines_repository_impl.dart';
import 'package:ca_app/features/data_pipelines/data/repositories/mock_data_pipelines_repository.dart';
import 'package:ca_app/features/data_pipelines/domain/repositories/data_pipelines_repository.dart';

/// Provides the [DataPipelinesRemoteSource] (Supabase client).
final dataPipelinesRemoteSourceProvider = Provider<DataPipelinesRemoteSource>((
  ref,
) {
  return DataPipelinesRemoteSource(Supabase.instance.client);
});

/// Provides the [DataPipelinesLocalSource] (Drift/SQLite).
final dataPipelinesLocalSourceProvider = Provider<DataPipelinesLocalSource>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return DataPipelinesLocalSource(db);
});

/// Provides the active [DataPipelinesRepository].
///
/// Returns [MockDataPipelinesRepository] unless the `data_pipelines_real_repo`
/// feature flag is enabled, in which case [DataPipelinesRepositoryImpl] is used.
final dataPipelinesRepositoryProvider = Provider<DataPipelinesRepository>((
  ref,
) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('data_pipelines_real_repo') ?? false;

  if (!useReal) {
    return MockDataPipelinesRepository();
  }

  return DataPipelinesRepositoryImpl(
    remote: ref.watch(dataPipelinesRemoteSourceProvider),
    local: ref.watch(dataPipelinesLocalSourceProvider),
  );
});

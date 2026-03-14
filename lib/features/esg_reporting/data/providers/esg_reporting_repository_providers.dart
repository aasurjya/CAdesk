import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/esg_reporting/data/datasources/esg_reporting_local_source.dart';
import 'package:ca_app/features/esg_reporting/data/datasources/esg_reporting_remote_source.dart';
import 'package:ca_app/features/esg_reporting/data/repositories/esg_reporting_repository_impl.dart';
import 'package:ca_app/features/esg_reporting/data/repositories/mock_esg_reporting_repository.dart';
import 'package:ca_app/features/esg_reporting/domain/repositories/esg_reporting_repository.dart';

/// Provides the [EsgReportingRemoteSource] (Supabase client).
final esgReportingRemoteSourceProvider = Provider<EsgReportingRemoteSource>((
  ref,
) {
  return EsgReportingRemoteSource(Supabase.instance.client);
});

/// Provides the [EsgReportingLocalSource] (Drift/SQLite).
final esgReportingLocalSourceProvider = Provider<EsgReportingLocalSource>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return EsgReportingLocalSource(db);
});

/// Provides the active [EsgReportingRepository].
///
/// Returns [MockEsgReportingRepository] unless the `esg_reporting_real_repo`
/// feature flag is enabled, in which case [EsgReportingRepositoryImpl] is used.
final esgReportingRepositoryProvider = Provider<EsgReportingRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('esg_reporting_real_repo') ?? false;

  if (!useReal) {
    return MockEsgReportingRepository();
  }

  return EsgReportingRepositoryImpl(
    remote: ref.watch(esgReportingRemoteSourceProvider),
    local: ref.watch(esgReportingLocalSourceProvider),
  );
});

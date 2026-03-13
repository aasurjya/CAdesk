import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/startup/data/datasources/startup_local_source.dart';
import 'package:ca_app/features/startup/data/datasources/startup_remote_source.dart';
import 'package:ca_app/features/startup/data/repositories/startup_repository_impl.dart';
import 'package:ca_app/features/startup/data/repositories/mock_startup_repository.dart';
import 'package:ca_app/features/startup/domain/repositories/startup_repository.dart';

final startupRemoteSourceProvider = Provider<StartupRemoteSource>((ref) {
  return StartupRemoteSource(Supabase.instance.client);
});

final startupLocalSourceProvider = Provider<StartupLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StartupLocalSource(db);
});

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('startup_real_repo') ?? false;

  if (!useReal) {
    return MockStartupRepository();
  }

  return StartupRepositoryImpl(
    remote: ref.watch(startupRemoteSourceProvider),
    local: ref.watch(startupLocalSourceProvider),
  );
});

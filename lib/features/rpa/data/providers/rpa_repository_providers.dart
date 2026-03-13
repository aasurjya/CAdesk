import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/rpa/data/datasources/rpa_local_source.dart';
import 'package:ca_app/features/rpa/data/datasources/rpa_remote_source.dart';
import 'package:ca_app/features/rpa/data/repositories/mock_rpa_repository.dart';
import 'package:ca_app/features/rpa/data/repositories/rpa_repository_impl.dart';
import 'package:ca_app/features/rpa/domain/repositories/rpa_repository.dart';

final rpaRemoteSourceProvider = Provider<RpaRemoteSource>((ref) {
  return RpaRemoteSource(Supabase.instance.client);
});

final rpaLocalSourceProvider = Provider<RpaLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RpaLocalSource(db);
});

final rpaRepositoryProvider = Provider<RpaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('rpa_real_repo') ?? false;

  if (!useReal) {
    return MockRpaRepository();
  }

  return RpaRepositoryImpl(
    remote: ref.watch(rpaRemoteSourceProvider),
    local: ref.watch(rpaLocalSourceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/mca/data/datasources/mca_local_source.dart';
import 'package:ca_app/features/mca/data/datasources/mca_remote_source.dart';
import 'package:ca_app/features/mca/data/repositories/mca_repository_impl.dart';
import 'package:ca_app/features/mca/data/repositories/mock_mca_repository.dart';
import 'package:ca_app/features/mca/domain/repositories/mca_repository.dart';

final mcaRemoteSourceProvider = Provider<McaRemoteSource>((ref) {
  return McaRemoteSource(Supabase.instance.client);
});

final mcaLocalSourceProvider = Provider<McaLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return McaLocalSource(db);
});

final mcaRepositoryProvider = Provider<McaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('mca_real_repo') ?? false;

  if (!useReal) {
    return MockMcaRepository();
  }

  return McaRepositoryImpl(
    remote: ref.watch(mcaRemoteSourceProvider),
    local: ref.watch(mcaLocalSourceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/vda/data/datasources/vda_local_source.dart';
import 'package:ca_app/features/vda/data/datasources/vda_remote_source.dart';
import 'package:ca_app/features/vda/data/repositories/mock_vda_repository.dart';
import 'package:ca_app/features/vda/data/repositories/vda_repository_impl.dart';
import 'package:ca_app/features/vda/domain/repositories/vda_repository.dart';

final vdaRemoteSourceProvider = Provider<VdaRemoteSource>((ref) {
  return VdaRemoteSource(Supabase.instance.client);
});

final vdaLocalSourceProvider = Provider<VdaLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VdaLocalSource(db);
});

final vdaRepositoryProvider = Provider<VdaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('vda_real_repo') ?? false;

  if (!useReal) {
    return MockVdaRepository();
  }

  return VdaRepositoryImpl(
    remote: ref.watch(vdaRemoteSourceProvider),
    local: ref.watch(vdaLocalSourceProvider),
  );
});

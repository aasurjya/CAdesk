import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/msme/data/datasources/msme_local_source.dart';
import 'package:ca_app/features/msme/data/datasources/msme_remote_source.dart';
import 'package:ca_app/features/msme/data/repositories/msme_repository_impl.dart';
import 'package:ca_app/features/msme/data/repositories/mock_msme_repository.dart';
import 'package:ca_app/features/msme/domain/repositories/msme_repository.dart';

final msmeRemoteSourceProvider = Provider<MsmeRemoteSource>((ref) {
  return MsmeRemoteSource(Supabase.instance.client);
});

final msmeLocalSourceProvider = Provider<MsmeLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MsmeLocalSource(db);
});

final msmeRepositoryProvider = Provider<MsmeRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('msme_real_repo') ?? false;

  if (!useReal) {
    return MockMsmeRepository();
  }

  return MsmeRepositoryImpl(
    remote: ref.watch(msmeRemoteSourceProvider),
    local: ref.watch(msmeLocalSourceProvider),
  );
});

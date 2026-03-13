import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/sebi/data/datasources/sebi_local_source.dart';
import 'package:ca_app/features/sebi/data/datasources/sebi_remote_source.dart';
import 'package:ca_app/features/sebi/data/repositories/sebi_repository_impl.dart';
import 'package:ca_app/features/sebi/data/repositories/mock_sebi_repository.dart';
import 'package:ca_app/features/sebi/domain/repositories/sebi_repository.dart';

final sebiRemoteSourceProvider = Provider<SebiRemoteSource>((ref) {
  return SebiRemoteSource(Supabase.instance.client);
});

final sebiLocalSourceProvider = Provider<SebiLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SebiLocalSource(db);
});

final sebiRepositoryProvider = Provider<SebiRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('sebi_real_repo') ?? false;

  if (!useReal) {
    return MockSebiRepository();
  }

  return SebiRepositoryImpl(
    remote: ref.watch(sebiRemoteSourceProvider),
    local: ref.watch(sebiLocalSourceProvider),
  );
});

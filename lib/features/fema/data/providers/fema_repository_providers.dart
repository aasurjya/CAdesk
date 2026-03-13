import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/fema/data/datasources/fema_local_source.dart';
import 'package:ca_app/features/fema/data/datasources/fema_remote_source.dart';
import 'package:ca_app/features/fema/data/repositories/fema_repository_impl.dart';
import 'package:ca_app/features/fema/data/repositories/mock_fema_repository.dart';
import 'package:ca_app/features/fema/domain/repositories/fema_repository.dart';

final femaRemoteSourceProvider = Provider<FemaRemoteSource>((ref) {
  return FemaRemoteSource(Supabase.instance.client);
});

final femaLocalSourceProvider = Provider<FemaLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FemaLocalSource(db);
});

final femaRepositoryProvider = Provider<FemaRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('fema_real_repo') ?? false;

  if (!useReal) {
    return MockFemaRepository();
  }

  return FemaRepositoryImpl(
    remote: ref.watch(femaRemoteSourceProvider),
    local: ref.watch(femaLocalSourceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/llp/data/datasources/llp_local_source.dart';
import 'package:ca_app/features/llp/data/datasources/llp_remote_source.dart';
import 'package:ca_app/features/llp/data/repositories/llp_repository_impl.dart';
import 'package:ca_app/features/llp/data/repositories/mock_llp_repository.dart';
import 'package:ca_app/features/llp/domain/repositories/llp_repository.dart';

final llpRemoteSourceProvider = Provider<LlpRemoteSource>((ref) {
  return LlpRemoteSource(Supabase.instance.client);
});

final llpLocalSourceProvider = Provider<LlpLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LlpLocalSource(db);
});

final llpRepositoryProvider = Provider<LlpRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal = flags.asData?.value.isEnabled('llp_real_repo') ?? false;

  if (!useReal) {
    return MockLlpRepository();
  }

  return LlpRepositoryImpl(
    remote: ref.watch(llpRemoteSourceProvider),
    local: ref.watch(llpLocalSourceProvider),
  );
});

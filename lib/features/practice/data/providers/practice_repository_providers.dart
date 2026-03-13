import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/practice/data/datasources/practice_local_source.dart';
import 'package:ca_app/features/practice/data/datasources/practice_remote_source.dart';
import 'package:ca_app/features/practice/data/repositories/mock_practice_repository.dart';
import 'package:ca_app/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:ca_app/features/practice/domain/repositories/practice_repository.dart';

final practiceRemoteSourceProvider = Provider<PracticeRemoteSource>((ref) {
  return PracticeRemoteSource(Supabase.instance.client);
});

final practiceLocalSourceProvider = Provider<PracticeLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PracticeLocalSource(db);
});

final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('practice_real_repo') ?? false;

  if (!useReal) {
    return MockPracticeRepository();
  }

  return PracticeRepositoryImpl(
    remote: ref.watch(practiceRemoteSourceProvider),
    local: ref.watch(practiceLocalSourceProvider),
  );
});

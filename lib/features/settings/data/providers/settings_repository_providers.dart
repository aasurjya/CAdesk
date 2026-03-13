import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/core/auth/firm_id_provider.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/settings/data/datasources/settings_local_source.dart';
import 'package:ca_app/features/settings/data/datasources/settings_remote_source.dart';
import 'package:ca_app/features/settings/data/repositories/mock_settings_repository.dart';
import 'package:ca_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ca_app/features/settings/domain/repositories/settings_repository.dart';

final settingsRemoteSourceProvider = Provider<SettingsRemoteSource>((ref) {
  return SettingsRemoteSource(Supabase.instance.client);
});

final settingsLocalSourceProvider = Provider<SettingsLocalSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsLocalSource(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final flags = ref.watch(featureFlagProvider);
  final useReal =
      flags.asData?.value.isEnabled('settings_real_repo') ?? false;

  if (!useReal) {
    return MockSettingsRepository();
  }

  final firmId = ref.watch(currentFirmIdProvider);
  return SettingsRepositoryImpl(
    remote: ref.watch(settingsRemoteSourceProvider),
    local: ref.watch(settingsLocalSourceProvider),
    firmId: firmId,
  );
});

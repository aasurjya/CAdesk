import 'package:ca_app/features/settings/data/datasources/settings_local_source.dart';
import 'package:ca_app/features/settings/data/datasources/settings_remote_source.dart';
import 'package:ca_app/features/settings/data/mappers/settings_mapper.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final SettingsRemoteSource remote;
  final SettingsLocalSource local;
  final String firmId;

  @override
  Future<AppSettings> getSettings() async {
    try {
      final json = await remote.fetchByFirmId(firmId);
      if (json != null) {
        final settings = SettingsMapper.fromJson(json);
        await local.upsertSettings(settings, firmId: firmId);
        return settings;
      }
    } catch (_) {
      // Fall through to local
    }
    return await local.getSettings() ?? const AppSettings();
  }

  @override
  Future<bool> updateSettings(AppSettings settings) async {
    try {
      await remote.upsert(SettingsMapper.toJson(settings, firmId));
      await local.upsertSettings(settings, firmId: firmId);
      return true;
    } catch (_) {
      await local.upsertSettings(settings, firmId: firmId);
      return true;
    }
  }

  @override
  Future<AppSettings> resetToDefaults() async {
    const defaults = AppSettings();
    await local.deleteSettings();
    try {
      await remote.upsert(SettingsMapper.toJson(defaults, firmId));
    } catch (_) {
      // Best-effort remote reset; local is cleared regardless.
    }
    return defaults;
  }
}

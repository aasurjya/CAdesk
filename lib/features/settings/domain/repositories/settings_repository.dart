import 'package:ca_app/features/settings/domain/models/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<bool> updateSettings(AppSettings settings);
  Future<AppSettings> resetToDefaults();
}

import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/domain/repositories/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  AppSettings _current = const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _current;

  @override
  Future<bool> updateSettings(AppSettings settings) async {
    _current = settings;
    return true;
  }

  @override
  Future<AppSettings> resetToDefaults() async {
    _current = const AppSettings();
    return _current;
  }
}

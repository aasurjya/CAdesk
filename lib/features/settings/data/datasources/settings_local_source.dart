import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/settings/data/mappers/settings_mapper.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';

class SettingsLocalSource {
  const SettingsLocalSource(this._db);

  final AppDatabase _db;

  Future<AppSettings?> getSettings() async {
    final row = await _db.settingsDao.getSettings();
    return row != null ? SettingsMapper.fromRow(row) : null;
  }

  Future<void> upsertSettings(AppSettings settings, {String firmId = ''}) => _db
      .settingsDao
      .upsertSettings(SettingsMapper.toCompanion(settings, firmId: firmId));

  Future<void> deleteSettings() => _db.settingsDao.deleteSettings();
}

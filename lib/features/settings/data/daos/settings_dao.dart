import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/app_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  static const _defaultId = 'default';

  /// Returns the current settings row, or null if none exists yet.
  Future<AppSettingsRow?> getSettings() => (select(
    appSettingsTable,
  )..where((t) => t.id.equals(_defaultId))).getSingleOrNull();

  /// Upserts the settings row.
  Future<void> upsertSettings(AppSettingsTableCompanion companion) =>
      into(appSettingsTable).insertOnConflictUpdate(companion);

  /// Deletes the settings row so the next read falls back to defaults.
  Future<void> deleteSettings() =>
      (delete(appSettingsTable)..where((t) => t.id.equals(_defaultId))).go();
}

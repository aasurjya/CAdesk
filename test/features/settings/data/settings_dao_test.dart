import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/data/mappers/settings_mapper.dart';

AppDatabase _createTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory());

void main() {
  late AppDatabase database;

  setUpAll(() async {
    database = _createTestDatabase();
  });

  tearDownAll(() async {
    await database.close();
  });

  group('SettingsDao', () {
    group('getSettings', () {
      test('returns null when no settings exist', () async {
        // Fresh DB — no settings row
        final row = await database.settingsDao.getSettings();
        expect(row, isNull);
      });
    });

    group('upsertSettings', () {
      test('inserts settings row successfully', () async {
        const settings = AppSettings(firmName: 'Test Firm');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row, isNotNull);
        expect(row?.firmName, 'Test Firm');
      });

      test('updates existing settings (upsert replaces)', () async {
        const first = AppSettings(firmName: 'First Firm');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(first),
        );
        const second = AppSettings(firmName: 'Second Firm');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(second),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.firmName, 'Second Firm');
      });

      test('stores themeMode correctly', () async {
        const settings = AppSettings(themeMode: AppThemeMode.dark);
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        final domain = row != null ? SettingsMapper.fromRow(row) : null;
        expect(domain?.themeMode, AppThemeMode.dark);
      });

      test('stores language correctly', () async {
        const settings = AppSettings(language: 'Hindi');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.language, 'Hindi');
      });

      test('stores notificationsEnabled correctly', () async {
        const settings = AppSettings(notificationsEnabled: false);
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.notificationsEnabled, isFalse);
      });

      test('stores autoLockMinutes correctly', () async {
        const settings = AppSettings(autoLockMinutes: 15);
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.autoLockMinutes, 15);
      });

      test('stores udinEnabled correctly', () async {
        const settings = AppSettings(udinEnabled: false);
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.udinEnabled, isFalse);
      });

      test('stores firmGstin correctly', () async {
        const settings = AppSettings(firmGstin: '27AAFPM1234A1Z5');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.firmGstin, '27AAFPM1234A1Z5');
      });

      test('stores biometricEnabled correctly', () async {
        const settings = AppSettings(biometricEnabled: true);
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.biometricEnabled, isTrue);
      });

      test('stores caRegistrationNumber correctly', () async {
        const settings = AppSettings(caRegistrationNumber: 'MRN 999999');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        expect(row?.caRegistrationNumber, 'MRN 999999');
      });
    });

    group('deleteSettings', () {
      test('deleteSettings removes the row', () async {
        const settings = AppSettings(firmName: 'To Be Deleted');
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        await database.settingsDao.deleteSettings();
        final row = await database.settingsDao.getSettings();
        expect(row, isNull);
      });

      test('deleteSettings is idempotent when no row exists', () async {
        // Delete from empty table should not throw
        await expectLater(
          database.settingsDao.deleteSettings(),
          completes,
        );
      });
    });

    group('SettingsMapper', () {
      test('fromRow round-trips light theme', () async {
        const settings = AppSettings(themeMode: AppThemeMode.light);
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        final restored = row != null ? SettingsMapper.fromRow(row) : null;
        expect(restored?.themeMode, AppThemeMode.light);
      });

      test('fromRow round-trips all notification flags', () async {
        const settings = AppSettings(
          notificationsEnabled: false,
          emailNotifications: false,
          smsNotifications: true,
          whatsappNotifications: false,
        );
        await database.settingsDao.upsertSettings(
          SettingsMapper.toCompanion(settings),
        );
        final row = await database.settingsDao.getSettings();
        final restored = row != null ? SettingsMapper.fromRow(row) : null;
        expect(restored?.notificationsEnabled, isFalse);
        expect(restored?.emailNotifications, isFalse);
        expect(restored?.smsNotifications, isTrue);
        expect(restored?.whatsappNotifications, isFalse);
      });
    });

    group('Immutability', () {
      test('AppSettings has copyWith', () {
        const s1 = AppSettings(firmName: 'Firm A');
        final s2 = s1.copyWith(firmName: 'Firm B');
        expect(s1.firmName, 'Firm A');
        expect(s2.firmName, 'Firm B');
      });

      test('copyWith preserves all unchanged fields', () {
        const s1 = AppSettings(
          firmName: 'Firm A',
          language: 'English',
          autoLockMinutes: 5,
        );
        final s2 = s1.copyWith(themeMode: AppThemeMode.dark);
        expect(s2.firmName, 'Firm A');
        expect(s2.language, 'English');
        expect(s2.autoLockMinutes, 5);
      });
    });
  });
}

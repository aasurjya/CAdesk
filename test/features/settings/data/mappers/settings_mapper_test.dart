import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/settings/data/mappers/settings_mapper.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';

void main() {
  group('SettingsMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'theme_mode': 'dark',
          'language': 'Hindi',
          'notifications_enabled': false,
          'email_notifications': false,
          'sms_notifications': true,
          'whatsapp_notifications': false,
          'biometric_enabled': true,
          'auto_lock_minutes': 10,
          'default_currency': 'USD',
          'default_financial_year': '2024-25',
          'firm_name': 'Mehta & Associates',
          'firm_address': '42, Chartered Lane, Mumbai',
          'firm_gstin': '27AAFPM1234A1Z5',
          'ca_registration_number': 'MRN 654321',
          'udin_enabled': false,
        };

        final settings = SettingsMapper.fromJson(json);

        expect(settings.themeMode, AppThemeMode.dark);
        expect(settings.language, 'Hindi');
        expect(settings.notificationsEnabled, false);
        expect(settings.emailNotifications, false);
        expect(settings.smsNotifications, true);
        expect(settings.whatsappNotifications, false);
        expect(settings.biometricEnabled, true);
        expect(settings.autoLockMinutes, 10);
        expect(settings.defaultCurrency, 'USD');
        expect(settings.defaultFinancialYear, '2024-25');
        expect(settings.firmName, 'Mehta & Associates');
        expect(settings.firmAddress, '42, Chartered Lane, Mumbai');
        expect(settings.firmGstin, '27AAFPM1234A1Z5');
        expect(settings.caRegistrationNumber, 'MRN 654321');
        expect(settings.udinEnabled, false);
      });

      test('applies defaults for all missing fields', () {
        final json = <String, dynamic>{};

        final settings = SettingsMapper.fromJson(json);

        expect(settings.themeMode, AppThemeMode.system);
        expect(settings.language, 'English');
        expect(settings.notificationsEnabled, true);
        expect(settings.emailNotifications, true);
        expect(settings.smsNotifications, false);
        expect(settings.whatsappNotifications, true);
        expect(settings.biometricEnabled, false);
        expect(settings.autoLockMinutes, 5);
        expect(settings.defaultCurrency, 'INR');
        expect(settings.defaultFinancialYear, '2025-26');
        expect(settings.firmGstin, '');
        expect(settings.caRegistrationNumber, '');
        expect(settings.udinEnabled, true);
      });

      test('defaults theme_mode to system for unknown value', () {
        final json = {'theme_mode': 'unknownTheme'};
        final settings = SettingsMapper.fromJson(json);
        expect(settings.themeMode, AppThemeMode.system);
      });

      test('handles all AppThemeMode values', () {
        for (final mode in AppThemeMode.values) {
          final json = {'theme_mode': mode.name};
          final settings = SettingsMapper.fromJson(json);
          expect(settings.themeMode, mode);
        }
      });

      test('converts numeric auto_lock_minutes to int', () {
        final json = {'auto_lock_minutes': 15.0};
        final settings = SettingsMapper.fromJson(json);
        expect(settings.autoLockMinutes, 15);
        expect(settings.autoLockMinutes, isA<int>());
      });

      test('handles null auto_lock_minutes with default 5', () {
        final json = <String, dynamic>{'auto_lock_minutes': null};
        final settings = SettingsMapper.fromJson(json);
        expect(settings.autoLockMinutes, 5);
      });
    });

    group('toJson', () {
      late AppSettings sampleSettings;

      setUp(() {
        sampleSettings = const AppSettings(
          themeMode: AppThemeMode.light,
          language: 'Gujarati',
          notificationsEnabled: true,
          emailNotifications: true,
          smsNotifications: false,
          whatsappNotifications: true,
          biometricEnabled: true,
          autoLockMinutes: 15,
          defaultCurrency: 'INR',
          defaultFinancialYear: '2025-26',
          firmName: 'Sharma & Co',
          firmAddress: 'Mumbai',
          firmGstin: '27AAFPS9876B1Z3',
          caRegistrationNumber: 'MRN 999888',
          udinEnabled: true,
        );
      });

      test('includes all fields and firm_id', () {
        final json = SettingsMapper.toJson(sampleSettings, 'firm-abc');

        expect(json['firm_id'], 'firm-abc');
        expect(json['theme_mode'], 'light');
        expect(json['language'], 'Gujarati');
        expect(json['notifications_enabled'], true);
        expect(json['email_notifications'], true);
        expect(json['sms_notifications'], false);
        expect(json['whatsapp_notifications'], true);
        expect(json['biometric_enabled'], true);
        expect(json['auto_lock_minutes'], 15);
        expect(json['default_currency'], 'INR');
        expect(json['default_financial_year'], '2025-26');
        expect(json['firm_name'], 'Sharma & Co');
        expect(json['firm_address'], 'Mumbai');
        expect(json['firm_gstin'], '27AAFPS9876B1Z3');
        expect(json['ca_registration_number'], 'MRN 999888');
        expect(json['udin_enabled'], true);
      });

      test('serializes theme_mode as enum name string', () {
        final darkSettings = sampleSettings.copyWith(
          themeMode: AppThemeMode.dark,
        );
        final json = SettingsMapper.toJson(darkSettings, 'firm-xyz');
        expect(json['theme_mode'], 'dark');
      });

      test('round-trip fromJson(toJson) preserves all settings fields', () {
        final json = SettingsMapper.toJson(sampleSettings, 'firm-rt');
        final restored = SettingsMapper.fromJson(json);

        expect(restored.themeMode, sampleSettings.themeMode);
        expect(restored.language, sampleSettings.language);
        expect(
          restored.notificationsEnabled,
          sampleSettings.notificationsEnabled,
        );
        expect(restored.smsNotifications, sampleSettings.smsNotifications);
        expect(restored.biometricEnabled, sampleSettings.biometricEnabled);
        expect(restored.autoLockMinutes, sampleSettings.autoLockMinutes);
        expect(restored.defaultCurrency, sampleSettings.defaultCurrency);
        expect(restored.firmName, sampleSettings.firmName);
        expect(restored.firmGstin, sampleSettings.firmGstin);
        expect(
          restored.caRegistrationNumber,
          sampleSettings.caRegistrationNumber,
        );
        expect(restored.udinEnabled, sampleSettings.udinEnabled);
      });

      test('serializes all boolean fields correctly', () {
        final allFalse = const AppSettings(
          notificationsEnabled: false,
          emailNotifications: false,
          smsNotifications: false,
          whatsappNotifications: false,
          biometricEnabled: false,
          udinEnabled: false,
        );
        final json = SettingsMapper.toJson(allFalse, 'firm-bool');
        expect(json['notifications_enabled'], false);
        expect(json['email_notifications'], false);
        expect(json['sms_notifications'], false);
        expect(json['whatsapp_notifications'], false);
        expect(json['biometric_enabled'], false);
        expect(json['udin_enabled'], false);
      });
    });
  });
}

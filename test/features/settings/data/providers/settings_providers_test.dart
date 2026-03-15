import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/settings/data/providers/settings_providers.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';

void main() {
  group('Settings Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('settingsProvider initial state', () {
      test('returns an AppSettings instance', () {
        final settings = container.read(settingsProvider);
        expect(settings, isA<AppSettings>());
      });

      test('default themeMode is system', () {
        expect(
          container.read(settingsProvider).themeMode,
          AppThemeMode.system,
        );
      });

      test('default language is English', () {
        expect(container.read(settingsProvider).language, 'English');
      });

      test('default notificationsEnabled is true', () {
        expect(container.read(settingsProvider).notificationsEnabled, isTrue);
      });

      test('default smsNotifications is false', () {
        expect(container.read(settingsProvider).smsNotifications, isFalse);
      });

      test('default biometricEnabled is false', () {
        expect(container.read(settingsProvider).biometricEnabled, isFalse);
      });

      test('default autoLockMinutes is 5', () {
        expect(container.read(settingsProvider).autoLockMinutes, 5);
      });

      test('default currency is INR', () {
        expect(container.read(settingsProvider).defaultCurrency, 'INR');
      });

      test('default firmName is non-empty', () {
        expect(container.read(settingsProvider).firmName, isNotEmpty);
      });
    });

    group('setThemeMode', () {
      test('sets theme to light', () {
        container.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light);
        expect(container.read(settingsProvider).themeMode, AppThemeMode.light);
      });

      test('sets theme to dark', () {
        container.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
        expect(container.read(settingsProvider).themeMode, AppThemeMode.dark);
      });

      test('sets theme back to system', () {
        container.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
        container
            .read(settingsProvider.notifier)
            .setThemeMode(AppThemeMode.system);
        expect(
          container.read(settingsProvider).themeMode,
          AppThemeMode.system,
        );
      });
    });

    group('setLanguage', () {
      test('updates language', () {
        container
            .read(settingsProvider.notifier)
            .setLanguage('Hindi');
        expect(container.read(settingsProvider).language, 'Hindi');
      });

      test('preserves other fields when language changes', () {
        final before = container.read(settingsProvider);
        container.read(settingsProvider.notifier).setLanguage('Tamil');
        final after = container.read(settingsProvider);
        expect(after.themeMode, before.themeMode);
        expect(after.notificationsEnabled, before.notificationsEnabled);
      });
    });

    group('toggleNotifications', () {
      test('toggles notifications off', () {
        // Default is true; toggle once → false
        container.read(settingsProvider.notifier).toggleNotifications();
        expect(container.read(settingsProvider).notificationsEnabled, isFalse);
      });

      test('toggle twice returns to original state', () {
        container.read(settingsProvider.notifier).toggleNotifications();
        container.read(settingsProvider.notifier).toggleNotifications();
        expect(container.read(settingsProvider).notificationsEnabled, isTrue);
      });
    });

    group('toggleEmailNotifications', () {
      test('toggles email notifications', () {
        final before = container.read(settingsProvider).emailNotifications;
        container.read(settingsProvider.notifier).toggleEmailNotifications();
        expect(container.read(settingsProvider).emailNotifications, !before);
      });
    });

    group('toggleSmsNotifications', () {
      test('toggles sms notifications (default false → true)', () {
        container.read(settingsProvider.notifier).toggleSmsNotifications();
        expect(container.read(settingsProvider).smsNotifications, isTrue);
      });
    });

    group('toggleWhatsappNotifications', () {
      test('toggles whatsapp notifications', () {
        final before = container.read(settingsProvider).whatsappNotifications;
        container.read(settingsProvider.notifier).toggleWhatsappNotifications();
        expect(container.read(settingsProvider).whatsappNotifications, !before);
      });
    });

    group('toggleBiometric', () {
      test('toggles biometric (default false → true)', () {
        container.read(settingsProvider.notifier).toggleBiometric();
        expect(container.read(settingsProvider).biometricEnabled, isTrue);
      });
    });

    group('setAutoLockMinutes', () {
      test('updates autoLockMinutes', () {
        container.read(settingsProvider.notifier).setAutoLockMinutes(15);
        expect(container.read(settingsProvider).autoLockMinutes, 15);
      });
    });

    group('setDefaultCurrency', () {
      test('updates defaultCurrency', () {
        container.read(settingsProvider.notifier).setDefaultCurrency('USD');
        expect(container.read(settingsProvider).defaultCurrency, 'USD');
      });
    });

    group('setDefaultFinancialYear', () {
      test('updates defaultFinancialYear', () {
        container
            .read(settingsProvider.notifier)
            .setDefaultFinancialYear('2026-27');
        expect(
          container.read(settingsProvider).defaultFinancialYear,
          '2026-27',
        );
      });
    });

    group('setFirmName / setFirmAddress / setFirmGstin / setCaRegistrationNumber', () {
      test('setFirmName updates firmName', () {
        container.read(settingsProvider.notifier).setFirmName('New Firm LLP');
        expect(container.read(settingsProvider).firmName, 'New Firm LLP');
      });

      test('setFirmAddress updates firmAddress', () {
        container
            .read(settingsProvider.notifier)
            .setFirmAddress('123 New Street');
        expect(container.read(settingsProvider).firmAddress, '123 New Street');
      });

      test('setFirmGstin updates firmGstin', () {
        container
            .read(settingsProvider.notifier)
            .setFirmGstin('27AABCU9603R1ZM');
        expect(container.read(settingsProvider).firmGstin, '27AABCU9603R1ZM');
      });

      test('setCaRegistrationNumber updates caRegistrationNumber', () {
        container
            .read(settingsProvider.notifier)
            .setCaRegistrationNumber('MRN 999999');
        expect(
          container.read(settingsProvider).caRegistrationNumber,
          'MRN 999999',
        );
      });
    });

    group('toggleUdin', () {
      test('toggles UDIN (default true → false)', () {
        container.read(settingsProvider.notifier).toggleUdin();
        expect(container.read(settingsProvider).udinEnabled, isFalse);
      });
    });

    group('update', () {
      test('replaces entire settings', () {
        const newSettings = AppSettings(
          themeMode: AppThemeMode.dark,
          language: 'Gujarati',
        );
        container.read(settingsProvider.notifier).update(newSettings);
        expect(container.read(settingsProvider), newSettings);
      });
    });

    group('AppThemeMode.toFlutterThemeMode', () {
      test('system maps to ThemeMode.system', () {
        expect(AppThemeMode.system.toFlutterThemeMode(), ThemeMode.system);
      });

      test('light maps to ThemeMode.light', () {
        expect(AppThemeMode.light.toFlutterThemeMode(), ThemeMode.light);
      });

      test('dark maps to ThemeMode.dark', () {
        expect(AppThemeMode.dark.toFlutterThemeMode(), ThemeMode.dark);
      });
    });
  });
}

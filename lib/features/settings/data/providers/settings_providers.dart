import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/settings/domain/models/app_settings.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void update(AppSettings value) => state = value;

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void toggleEmailNotifications() {
    state = state.copyWith(emailNotifications: !state.emailNotifications);
  }

  void toggleSmsNotifications() {
    state = state.copyWith(smsNotifications: !state.smsNotifications);
  }

  void toggleWhatsappNotifications() {
    state =
        state.copyWith(whatsappNotifications: !state.whatsappNotifications);
  }

  void toggleBiometric() {
    state = state.copyWith(biometricEnabled: !state.biometricEnabled);
  }

  void setAutoLockMinutes(int minutes) {
    state = state.copyWith(autoLockMinutes: minutes);
  }

  void setDefaultCurrency(String currency) {
    state = state.copyWith(defaultCurrency: currency);
  }

  void setDefaultFinancialYear(String year) {
    state = state.copyWith(defaultFinancialYear: year);
  }

  void setFirmName(String name) {
    state = state.copyWith(firmName: name);
  }

  void setFirmAddress(String address) {
    state = state.copyWith(firmAddress: address);
  }

  void setFirmGstin(String gstin) {
    state = state.copyWith(firmGstin: gstin);
  }

  void setCaRegistrationNumber(String number) {
    state = state.copyWith(caRegistrationNumber: number);
  }

  void toggleUdin() {
    state = state.copyWith(udinEnabled: !state.udinEnabled);
  }
}

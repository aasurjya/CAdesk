import 'package:flutter/material.dart';

enum AppThemeMode {
  system('System Default'),
  light('Light'),
  dark('Dark');

  const AppThemeMode(this.label);

  final String label;

  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = 'English',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.whatsappNotifications = true,
    this.biometricEnabled = false,
    this.autoLockMinutes = 5,
    this.defaultCurrency = 'INR',
    this.defaultFinancialYear = '2025-26',
    this.firmName = 'Mehta & Associates',
    this.firmAddress = '42, Chartered Lane, Nariman Point, Mumbai – 400 021',
    this.firmGstin = '27AAFPM1234A1Z5',
    this.caRegistrationNumber = 'MRN 123456',
    this.udinEnabled = true,
  });

  final AppThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool whatsappNotifications;
  final bool biometricEnabled;
  final int autoLockMinutes;
  final String defaultCurrency;
  final String defaultFinancialYear;
  final String firmName;
  final String firmAddress;
  final String firmGstin;
  final String caRegistrationNumber;
  final bool udinEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? whatsappNotifications,
    bool? biometricEnabled,
    int? autoLockMinutes,
    String? defaultCurrency,
    String? defaultFinancialYear,
    String? firmName,
    String? firmAddress,
    String? firmGstin,
    String? caRegistrationNumber,
    bool? udinEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      whatsappNotifications:
          whatsappNotifications ?? this.whatsappNotifications,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultFinancialYear: defaultFinancialYear ?? this.defaultFinancialYear,
      firmName: firmName ?? this.firmName,
      firmAddress: firmAddress ?? this.firmAddress,
      firmGstin: firmGstin ?? this.firmGstin,
      caRegistrationNumber: caRegistrationNumber ?? this.caRegistrationNumber,
      udinEnabled: udinEnabled ?? this.udinEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppSettings) return false;
    return themeMode == other.themeMode &&
        language == other.language &&
        notificationsEnabled == other.notificationsEnabled &&
        emailNotifications == other.emailNotifications &&
        smsNotifications == other.smsNotifications &&
        whatsappNotifications == other.whatsappNotifications &&
        biometricEnabled == other.biometricEnabled &&
        autoLockMinutes == other.autoLockMinutes &&
        defaultCurrency == other.defaultCurrency &&
        defaultFinancialYear == other.defaultFinancialYear &&
        firmName == other.firmName &&
        firmAddress == other.firmAddress &&
        firmGstin == other.firmGstin &&
        caRegistrationNumber == other.caRegistrationNumber &&
        udinEnabled == other.udinEnabled;
  }

  @override
  int get hashCode => Object.hashAll([
    themeMode,
    language,
    notificationsEnabled,
    emailNotifications,
    smsNotifications,
    whatsappNotifications,
    biometricEnabled,
    autoLockMinutes,
    defaultCurrency,
    defaultFinancialYear,
    firmName,
    firmAddress,
    firmGstin,
    caRegistrationNumber,
    udinEnabled,
  ]);
}

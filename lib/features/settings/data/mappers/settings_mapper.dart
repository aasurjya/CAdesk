import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';

class SettingsMapper {
  const SettingsMapper._();

  static const _defaultId = 'default';

  // ---------------------------------------------------------------------------
  // JSON (Supabase) ↔ domain
  // ---------------------------------------------------------------------------

  /// JSON (from Supabase) → AppSettings domain model
  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: _safeTheme(json['theme_mode'] as String? ?? 'system'),
      language: json['language'] as String? ?? 'English',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
      whatsappNotifications: json['whatsapp_notifications'] as bool? ?? true,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      autoLockMinutes: (json['auto_lock_minutes'] as num?)?.toInt() ?? 5,
      defaultCurrency: json['default_currency'] as String? ?? 'INR',
      defaultFinancialYear:
          json['default_financial_year'] as String? ?? '2025-26',
      firmName: json['firm_name'] as String? ?? '',
      firmAddress: json['firm_address'] as String? ?? '',
      firmGstin: json['firm_gstin'] as String? ?? '',
      caRegistrationNumber:
          json['ca_registration_number'] as String? ?? '',
      udinEnabled: json['udin_enabled'] as bool? ?? true,
    );
  }

  /// AppSettings domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(AppSettings settings, String firmId) {
    return {
      'firm_id': firmId,
      'theme_mode': settings.themeMode.name,
      'language': settings.language,
      'notifications_enabled': settings.notificationsEnabled,
      'email_notifications': settings.emailNotifications,
      'sms_notifications': settings.smsNotifications,
      'whatsapp_notifications': settings.whatsappNotifications,
      'biometric_enabled': settings.biometricEnabled,
      'auto_lock_minutes': settings.autoLockMinutes,
      'default_currency': settings.defaultCurrency,
      'default_financial_year': settings.defaultFinancialYear,
      'firm_name': settings.firmName,
      'firm_address': settings.firmAddress,
      'firm_gstin': settings.firmGstin,
      'ca_registration_number': settings.caRegistrationNumber,
      'udin_enabled': settings.udinEnabled,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row ↔ domain
  // ---------------------------------------------------------------------------

  /// Drift row → AppSettings domain model
  static AppSettings fromRow(AppSettingsRow row) {
    return AppSettings(
      themeMode: _safeTheme(row.themeMode),
      language: row.language,
      notificationsEnabled: row.notificationsEnabled,
      emailNotifications: row.emailNotifications,
      smsNotifications: row.smsNotifications,
      whatsappNotifications: row.whatsappNotifications,
      biometricEnabled: row.biometricEnabled,
      autoLockMinutes: row.autoLockMinutes,
      defaultCurrency: row.defaultCurrency,
      defaultFinancialYear: row.defaultFinancialYear,
      firmName: row.firmName,
      firmAddress: row.firmAddress,
      firmGstin: row.firmGstin,
      caRegistrationNumber: row.caRegistrationNumber,
      udinEnabled: row.udinEnabled,
    );
  }

  /// AppSettings → Drift companion (for insert/update)
  static AppSettingsTableCompanion toCompanion(
    AppSettings settings, {
    String firmId = '',
  }) {
    return AppSettingsTableCompanion(
      id: const Value(_defaultId),
      firmId: Value(firmId),
      themeMode: Value(settings.themeMode.name),
      language: Value(settings.language),
      notificationsEnabled: Value(settings.notificationsEnabled),
      emailNotifications: Value(settings.emailNotifications),
      smsNotifications: Value(settings.smsNotifications),
      whatsappNotifications: Value(settings.whatsappNotifications),
      biometricEnabled: Value(settings.biometricEnabled),
      autoLockMinutes: Value(settings.autoLockMinutes),
      defaultCurrency: Value(settings.defaultCurrency),
      defaultFinancialYear: Value(settings.defaultFinancialYear),
      firmName: Value(settings.firmName),
      firmAddress: Value(settings.firmAddress),
      firmGstin: Value(settings.firmGstin),
      caRegistrationNumber: Value(settings.caRegistrationNumber),
      udinEnabled: Value(settings.udinEnabled),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static AppThemeMode _safeTheme(String value) {
    try {
      return AppThemeMode.values.byName(value);
    } catch (_) {
      return AppThemeMode.system;
    }
  }
}

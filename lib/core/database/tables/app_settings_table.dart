import 'package:drift/drift.dart';

@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'local_app_settings';

  // Single-row table — use a fixed primary key of 'default'.
  TextColumn get id => text().withDefault(const Constant('default'))();
  TextColumn get firmId => text().withDefault(const Constant(''))();
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))(); // AppThemeMode.name
  TextColumn get language =>
      text().withDefault(const Constant('English'))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get emailNotifications =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get smsNotifications =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get whatsappNotifications =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get biometricEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get autoLockMinutes =>
      integer().withDefault(const Constant(5))();
  TextColumn get defaultCurrency =>
      text().withDefault(const Constant('INR'))();
  TextColumn get defaultFinancialYear =>
      text().withDefault(const Constant('2025-26'))();
  TextColumn get firmName =>
      text().withDefault(const Constant(''))();
  TextColumn get firmAddress =>
      text().withDefault(const Constant(''))();
  TextColumn get firmGstin =>
      text().withDefault(const Constant(''))();
  TextColumn get caRegistrationNumber =>
      text().withDefault(const Constant(''))();
  BoolColumn get udinEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

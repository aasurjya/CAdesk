import 'package:drift/drift.dart';

class PortalCredentialsTable extends Table {
  TextColumn get id => text()();
  TextColumn get portalType => text()();
  TextColumn get username => text().nullable()();
  TextColumn get encryptedPassword => text().nullable()();
  TextColumn get grantToken => text().nullable()();
  TextColumn get refreshToken => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get lastSyncDate => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

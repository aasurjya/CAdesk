import 'package:drift/drift.dart';

class FirmInfoTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get pincode => text().nullable()();
  TextColumn get panNumber => text().unique()();
  TextColumn get tanNumber => text().unique()();
  BlobColumn get dscCertificate => blob().nullable()();
  TextColumn get bankAccount => text().nullable()();
  DateTimeColumn get registrationDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TeamMembersTable extends Table {
  TextColumn get id => text()();
  TextColumn get firmId => text()();
  TextColumn get name => text()();
  TextColumn get pan => text().unique()();
  TextColumn get role => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get permissions => text().nullable()(); // JSON as TEXT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ClientAssignmentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get assignedToId => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get role => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

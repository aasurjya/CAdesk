import 'package:drift/drift.dart';

class MsmeRecordsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get udyamNumber => text()();
  DateTimeColumn get registrationDate => dateTime()();
  TextColumn get category => text().nullable()();
  TextColumn get annualTurnover => text().nullable()();
  IntColumn get employeeCount => integer().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

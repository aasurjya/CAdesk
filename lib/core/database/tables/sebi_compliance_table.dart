import 'package:drift/drift.dart';

class SebiComplianceTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get complianceType => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get filedDate => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get penalty => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

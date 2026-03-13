import 'package:drift/drift.dart';

class MCAFilingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get formType => text().nullable()();
  TextColumn get financialYear => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get filedDate => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get filingNumber => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

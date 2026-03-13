import 'package:drift/drift.dart';

class PayrollEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get employeeId => text().nullable()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  TextColumn get basicSalary => text().nullable()(); // DECIMAL as TEXT
  TextColumn get allowances => text().nullable()();
  TextColumn get deductions => text().nullable()();
  TextColumn get tdsDeducted => text().nullable()();
  TextColumn get pfDeducted => text().nullable()();
  TextColumn get esiDeducted => text().nullable()();
  TextColumn get netSalary => text().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

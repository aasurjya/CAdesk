import 'package:drift/drift.dart';

class AuditAssignmentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get auditorId => text().nullable()();
  TextColumn get financialYear => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get fee => text().nullable()(); // DECIMAL as TEXT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AuditReportsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  IntColumn get year => integer()();
  TextColumn get saReportNumber => text().nullable()();
  DateTimeColumn get reportDate => dateTime().nullable()();
  TextColumn get reportedBy => text().nullable()();
  TextColumn get auditFindings => text().nullable()(); // JSONB as TEXT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

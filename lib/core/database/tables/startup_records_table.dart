import 'package:drift/drift.dart';

class StartupRecordsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get dpiitNumber => text()();
  DateTimeColumn get incorporationDate => dateTime()();
  TextColumn get sectorCategory => text().nullable()();
  TextColumn get recognitionStatus => text().nullable()();
  BoolColumn get section80IacEligible =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get section56ExemptEligible =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

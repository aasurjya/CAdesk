import 'package:drift/drift.dart';

class FemaFilingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get filingType => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get amount => text().nullable()();
  TextColumn get currency => text().nullable()();
  BoolColumn get approvalRequired =>
      boolean().withDefault(const Constant(false))();
  TextColumn get status => text().nullable()();
  TextColumn get filingNumber => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

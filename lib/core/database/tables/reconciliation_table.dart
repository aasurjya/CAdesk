import 'package:drift/drift.dart';

class ReconciliationResultsTable extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get reconciliationType => text().nullable()();
  TextColumn get period => text().nullable()();
  IntColumn get totalMatched => integer().nullable()();
  IntColumn get totalUnmatched => integer().nullable()();
  TextColumn get discrepancies => text().nullable()(); // JSONB as TEXT
  TextColumn get status => text().nullable()();
  TextColumn get reviewedBy => text().nullable()();
  DateTimeColumn get reviewedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

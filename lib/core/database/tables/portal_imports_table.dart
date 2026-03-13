import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('PortalImportRow')
class PortalImportsTable extends Table {
  @override
  String get tableName => 'local_portal_imports';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get importType => text()(); // stored as enum name
  DateTimeColumn get importDate => dateTime()();
  TextColumn get rawData => text().nullable()();
  IntColumn get parsedRecords => integer().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // stored as enum name
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

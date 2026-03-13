import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('ExportJobRow')
class ExportJobsTable extends Table {
  @override
  String get tableName => 'local_export_jobs';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get exportType => text()(); // stored as enum name
  TextColumn get status =>
      text().withDefault(const Constant('queued'))(); // stored as enum name
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

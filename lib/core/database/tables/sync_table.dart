import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _syncUuid = Uuid();

@DataClassName('SyncQueueRow')
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  TextColumn get id => text().clientDefault(() => _syncUuid.v4())();
  TextColumn get sourceTable => text().named('table_name')();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // create, update, delete
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncConflictRow')
class SyncConflictsTable extends Table {
  @override
  String get tableName => 'sync_conflicts';

  TextColumn get id => text().clientDefault(() => _syncUuid.v4())();
  TextColumn get sourceTable => text().named('table_name')();
  TextColumn get recordId => text()();
  TextColumn get localPayload => text()();
  TextColumn get serverPayload => text()();
  DateTimeColumn get detectedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get resolution =>
      text().nullable()(); // server_wins, local_wins, manual

  @override
  Set<Column> get primaryKey => {id};
}

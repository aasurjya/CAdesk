import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('FilingRecordRow')
class FilingRecordsTable extends Table {
  @override
  String get tableName => 'local_filing_records';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get filingType => text()(); // stored as enum name
  TextColumn get financialYear => text()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // stored as enum name
  DateTimeColumn get filedDate => dateTime().nullable()();
  TextColumn get acknowledgementNumber => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

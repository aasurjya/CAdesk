import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('TimeEntryRow')
class TimeEntriesTable extends Table {
  @override
  String get tableName => 'local_time_entries';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get staffId => text()();
  TextColumn get staffName => text()();
  TextColumn get clientName => text()();
  TextColumn get taskDescription => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  RealColumn get billingRate => real().withDefault(const Constant(0.0))();
  BoolColumn get isBilled => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

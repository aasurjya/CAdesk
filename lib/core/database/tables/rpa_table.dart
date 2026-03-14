import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('RpaTaskRow')
class RpaTasksTable extends Table {
  @override
  String get tableName => 'local_rpa_tasks';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get taskType => text()(); // RpaTaskType enum name
  TextColumn get clientId => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('scheduled'))(); // RpaStatus enum name
  DateTimeColumn get scheduledAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get result => text().nullable()(); // JSON
  TextColumn get errorMessage => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

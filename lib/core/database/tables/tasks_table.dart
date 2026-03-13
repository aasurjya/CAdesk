import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('TaskRow')
class TasksTable extends Table {
  @override
  String get tableName => 'local_tasks';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get clientName => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get taskType => text()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get assignedTo => text()();
  TextColumn get assignedBy => text()();
  TextColumn get dueDate => text()();
  TextColumn get completedDate => text().nullable()();
  TextColumn get tags =>
      text().withDefault(const Constant('[]'))(); // JSON array
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

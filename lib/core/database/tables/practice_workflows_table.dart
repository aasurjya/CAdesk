import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('WorkflowRow')
class PracticeWorkflowsTable extends Table {
  @override
  String get tableName => 'local_practice_workflows';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get steps => text().withDefault(const Constant('[]'))(); // JSON array
  IntColumn get estimatedDays => integer().withDefault(const Constant(1))();
  TextColumn get category => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

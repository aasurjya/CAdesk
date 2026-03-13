import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('StaffActivityRow')
class StaffActivitiesTable extends Table {
  @override
  String get tableName => 'local_staff_activities';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get staffId => text()();
  TextColumn get activityType => text()(); // ActivityType enum name
  TextColumn get clientId => text().nullable()();
  TextColumn get taskId => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StaffPerformanceRow')
class StaffPerformanceTable extends Table {
  @override
  String get tableName => 'local_staff_performance';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get staffId => text()();
  TextColumn get period => text()(); // e.g. '2026-03'
  IntColumn get tasksCompleted => integer().withDefault(const Constant(0))();
  RealColumn get hoursLogged => real().withDefault(const Constant(0.0))();
  IntColumn get clientsHandled => integer().withDefault(const Constant(0))();
  RealColumn get avgCompletionTime => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

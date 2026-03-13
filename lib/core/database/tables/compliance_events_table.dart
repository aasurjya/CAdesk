import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('ComplianceEventRow')
class ComplianceEventsTable extends Table {
  @override
  String get tableName => 'local_compliance_events';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()(); // Foreign key to clients
  TextColumn get type => text()(); // Stored as string enum value (itr, gst, tds, mca, audit, payroll, other)
  TextColumn get description => text()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get filedDate => dateTime().nullable()();
  TextColumn get status => text()(); // Stored as string enum value (pending, filed, overdue, completed, rejected)
  RealColumn get penalty => real().nullable()(); // In rupees
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))(); // Needs sync

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get indexes => [
    {clientId},
    {dueDate},
    {status},
  ];
}

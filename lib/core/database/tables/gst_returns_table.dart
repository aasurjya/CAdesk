import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('GstReturnRow')
class GstReturnsTable extends Table {
  @override
  String get tableName => 'local_gst_returns';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get gstin => text()();
  TextColumn get returnType => text()();
  IntColumn get periodMonth => integer()();
  IntColumn get periodYear => integer()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get filedDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  RealColumn get taxableValue => real().withDefault(const Constant(0.0))();
  RealColumn get igst => real().withDefault(const Constant(0.0))();
  RealColumn get cgst => real().withDefault(const Constant(0.0))();
  RealColumn get sgst => real().withDefault(const Constant(0.0))();
  RealColumn get cess => real().withDefault(const Constant(0.0))();
  RealColumn get lateFee => real().withDefault(const Constant(0.0))();
  RealColumn get itcClaimed => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

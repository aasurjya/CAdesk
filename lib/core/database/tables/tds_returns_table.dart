import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('TdsReturnRow')
class TdsReturnsTable extends Table {
  @override
  String get tableName => 'local_tds_returns';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get deductorId => text()();
  TextColumn get tan => text()();
  TextColumn get formType => text()();
  TextColumn get quarter => text()();
  TextColumn get financialYear => text()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get filedDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  RealColumn get totalDeductions => real().withDefault(const Constant(0.0))();
  RealColumn get totalTaxDeducted => real().withDefault(const Constant(0.0))();
  RealColumn get totalDeposited => real().withDefault(const Constant(0.0))();
  RealColumn get lateFee => real().withDefault(const Constant(0.0))();
  TextColumn get tokenNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

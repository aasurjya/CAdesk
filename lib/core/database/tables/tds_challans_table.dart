import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('TdsChallanRow')
class TdsChallansTable extends Table {
  @override
  String get tableName => 'local_tds_challans';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get tdsReturnId => text().nullable()();
  TextColumn get deductorId => text()();
  TextColumn get challanNumber => text()();
  TextColumn get bsrCode => text()();
  TextColumn get section => text()();
  IntColumn get deducteeCount => integer().withDefault(const Constant(0))();
  RealColumn get tdsAmount => real()();
  RealColumn get surcharge => real().withDefault(const Constant(0.0))();
  RealColumn get educationCess => real().withDefault(const Constant(0.0))();
  RealColumn get interest => real().withDefault(const Constant(0.0))();
  RealColumn get penalty => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  TextColumn get paymentDate => text()();
  IntColumn get month => integer()();
  TextColumn get financialYear => text()();
  TextColumn get status => text().withDefault(const Constant('deposited'))();
  TextColumn get taxType => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

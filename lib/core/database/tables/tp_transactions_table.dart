import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('TpTransactionRow')
class TpTransactionsTable extends Table {
  @override
  String get tableName => 'local_tp_transactions';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get assessmentYear => text()();
  TextColumn get relatedParty => text()();
  TextColumn get transactionType => text()();
  RealColumn get transactionValue => real().withDefault(const Constant(0.0))();

  /// Stores [TpMethod.name].
  TextColumn get tpMethod => text().withDefault(const Constant('tnmm'))();

  TextColumn get documentationDue => text().nullable()();

  /// Stores [TpStatus.name].
  TextColumn get status => text().withDefault(const Constant('draft'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncedAt => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

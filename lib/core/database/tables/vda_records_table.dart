import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('VdaRecordRow')
class VdaRecordsTable extends Table {
  @override
  String get tableName => 'local_vda_records';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();

  /// ISO8601 date string of the transaction.
  TextColumn get transactionDate => text()();

  /// Type of VDA (e.g. "Bitcoin", "Ethereum", "NFT").
  TextColumn get assetType => text()();

  RealColumn get buyPrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellPrice => real().withDefault(const Constant(0.0))();
  RealColumn get quantity => real().withDefault(const Constant(0.0))();

  /// Net gain (positive) or loss (negative) in INR.
  RealColumn get gainLoss => real().withDefault(const Constant(0.0))();

  /// TDS deducted u/s 194S in INR.
  RealColumn get tdsDeducted => real().withDefault(const Constant(0.0))();

  TextColumn get exchange => text().nullable()();

  /// Assessment year in "YYYY-YY" format.
  TextColumn get assessmentYear => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncedAt => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

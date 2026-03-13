import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('ItrFilingRow')
class ItrFilingsTable extends Table {
  @override
  String get tableName => 'local_itr_filings';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get name => text()(); // denormalized
  TextColumn get pan => text()();
  TextColumn get aadhaar => text().nullable()(); // local only - never synced
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get itrType => text()();
  TextColumn get assessmentYear => text()();
  TextColumn get financialYear => text()();
  TextColumn get filingStatus =>
      text().withDefault(const Constant('pending'))();
  RealColumn get totalIncome => real().nullable()();
  RealColumn get taxPayable => real().nullable()();
  RealColumn get refundDue => real().nullable()();
  RealColumn get tdsAmount => real().nullable()();
  RealColumn get advanceTax => real().nullable()();
  RealColumn get selfAssessmentTax => real().nullable()();
  TextColumn get acknowledgementNumber => text().nullable()();
  TextColumn get filedDate => text().nullable()();
  TextColumn get verifiedDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

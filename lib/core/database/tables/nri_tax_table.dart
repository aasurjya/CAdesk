import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('NriTaxRow')
class NriTaxTable extends Table {
  @override
  String get tableName => 'local_nri_tax_records';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get assessmentYear => text()();

  /// Stores [ResidencyStatus.name].
  TextColumn get residencyStatus =>
      text().withDefault(const Constant('resident'))();

  TextColumn get foreignIncomeSources => text().nullable()();
  TextColumn get dtaaCountry => text().nullable()();
  RealColumn get dtaaRelief => real().nullable()();

  /// Stored as 0/1 integer (Drift BoolColumn).
  BoolColumn get scheduleFA => boolean().withDefault(const Constant(false))();
  BoolColumn get scheduleFSL => boolean().withDefault(const Constant(false))();

  /// Stores [NriTaxStatus.name].
  TextColumn get status => text().withDefault(const Constant('draft'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncedAt => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

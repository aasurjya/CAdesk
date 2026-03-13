import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('GstClientRow')
class GstClientsTable extends Table {
  @override
  String get tableName => 'local_gst_clients';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get businessName => text()();
  TextColumn get tradeName => text().nullable()();
  TextColumn get gstin => text()();
  TextColumn get pan => text()();
  TextColumn get registrationType => text()();
  TextColumn get state => text()();
  TextColumn get stateCode => text()();
  TextColumn get returnsPending =>
      text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get lastFiledDate => text().nullable()();
  IntColumn get complianceScore => integer().withDefault(const Constant(100))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get registrationDate => text().nullable()();
  TextColumn get cancellationDate => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

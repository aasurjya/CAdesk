import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('ClientRow')
class ClientsTable extends Table {
  @override
  String get tableName => 'local_clients';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get name => text()();
  TextColumn get pan => text()();
  TextColumn get aadhaarHash => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get alternatePhone => text().nullable()();
  TextColumn get clientType => text()(); // stored as string enum value
  TextColumn get dateOfBirth => text().nullable()(); // ISO8601 string
  TextColumn get dateOfIncorporation => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get pincode => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get tan => text().nullable()();
  TextColumn get servicesAvailed =>
      text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

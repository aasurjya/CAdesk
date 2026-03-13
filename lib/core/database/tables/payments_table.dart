import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('PaymentRow')
class PaymentsTable extends Table {
  @override
  String get tableName => 'local_payments';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get invoiceId => text()();
  TextColumn get clientName => text()();
  RealColumn get amount => real()();
  TextColumn get paymentDate => text()();
  TextColumn get mode => text()();
  TextColumn get reference => text()();
  TextColumn get notes => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

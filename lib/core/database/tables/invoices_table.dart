import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('InvoiceRow')
class InvoicesTable extends Table {
  @override
  String get tableName => 'local_invoices';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get firmId => text()();
  TextColumn get clientId => text()();
  TextColumn get clientName => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get gstin => text().nullable()();
  TextColumn get invoiceDate => text()();
  TextColumn get dueDate => text()();
  TextColumn get lineItems =>
      text().withDefault(const Constant('[]'))(); // JSON array
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalGst => real().withDefault(const Constant(0.0))();
  RealColumn get grandTotal => real().withDefault(const Constant(0.0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get balanceDue => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get paymentDate => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get terms => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringFrequency => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

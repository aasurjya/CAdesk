import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('DocumentRow')
class DocumentsTable extends Table {
  @override
  String get tableName => 'local_documents';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get clientName => text()();
  TextColumn get title => text()();
  TextColumn get category => text()(); // stored as string enum value
  TextColumn get fileType => text()(); // stored as string enum value
  IntColumn get fileSize => integer()(); // in bytes
  TextColumn get uploadedBy => text()();
  DateTimeColumn get uploadedAt => dateTime()();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON array
  BoolColumn get isSharedWithClient => boolean().withDefault(const Constant(false))();
  IntColumn get downloadCount => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncedAt => text().nullable()(); // ISO8601 of last sync
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // needs sync

  @override
  Set<Column> get primaryKey => {id};
}

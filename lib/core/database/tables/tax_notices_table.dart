import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('TaxNoticeRow')
class TaxNoticesTable extends Table {
  @override
  String get tableName => 'local_tax_notices';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();

  /// Stores [NoticeType.name].
  TextColumn get noticeType => text()();

  /// ISO8601 date string of the notice issue date.
  TextColumn get issuedDate => text()();

  /// ISO8601 date string of the compliance due date.
  TextColumn get dueDate => text()();

  /// Demand amount in INR (nullable — not all notices carry a demand).
  RealColumn get demandAmount => real().nullable()();

  /// Stores [NoticeStatus.name].
  TextColumn get status =>
      text().withDefault(const Constant('received'))();

  /// ISO8601 date string of when the response was filed.
  TextColumn get responseDate => text().nullable()();

  TextColumn get responseNotes => text().nullable()();

  /// JSON-encoded list of attachment paths / URLs.
  TextColumn get attachments => text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get syncedAt => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

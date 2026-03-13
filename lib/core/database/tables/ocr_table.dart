import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('OcrJobRow')
class OcrJobsTable extends Table {
  @override
  String get tableName => 'local_ocr_jobs';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get documentType => text()(); // OcrDocType enum name
  TextColumn get inputFilePath => text()();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  TextColumn get parsedData => text().nullable()(); // JSON
  RealColumn get confidence => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('AssessmentCaseRow')
class AssessmentCasesTable extends Table {
  @override
  String get tableName => 'local_assessment_cases';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text()();
  TextColumn get assessmentYear => text()();
  TextColumn get caseType => text()(); // AssessmentType.name
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // AssessmentCaseStatus.name
  TextColumn get demandAmount =>
      text().withDefault(const Constant('0.00'))(); // DECIMAL as TEXT
  TextColumn get paidAmount =>
      text().withDefault(const Constant('0.00'))(); // DECIMAL as TEXT
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

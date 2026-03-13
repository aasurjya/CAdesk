import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/assessment_cases_table.dart';

part 'assessment_dao.g.dart';

@DriftAccessor(tables: [AssessmentCasesTable])
class AssessmentDao extends DatabaseAccessor<AppDatabase>
    with _$AssessmentDaoMixin {
  AssessmentDao(super.db);

  /// Insert a new assessment case and return its ID.
  Future<String> insertCase(AssessmentCasesTableCompanion companion) async {
    await into(assessmentCasesTable).insert(companion);
    return companion.id.value;
  }

  /// Get all cases for a client ordered by created date descending.
  Future<List<AssessmentCaseRow>> getByClient(String clientId) =>
      (select(assessmentCasesTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Get all cases for a specific assessment year.
  Future<List<AssessmentCaseRow>> getByYear(String assessmentYear) =>
      (select(assessmentCasesTable)
            ..where((t) => t.assessmentYear.equals(assessmentYear))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Get all cases of a specific type.
  Future<List<AssessmentCaseRow>> getByType(String caseType) =>
      (select(assessmentCasesTable)
            ..where((t) => t.caseType.equals(caseType))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Get all cases with a specific status.
  Future<List<AssessmentCaseRow>> getByStatus(String status) =>
      (select(assessmentCasesTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Get a single case by ID.
  Future<AssessmentCaseRow?> getCaseById(String id) =>
      (select(assessmentCasesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Update the status of an assessment case.
  /// Returns true if a row was affected.
  Future<bool> updateStatus(String id, String status) async {
    final rowsAffected = await (update(assessmentCasesTable)
          ..where((t) => t.id.equals(id)))
        .write(
          AssessmentCasesTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// Get all open cases where dueDate is before [now] (overdue).
  Future<List<AssessmentCaseRow>> getOverdueDemands(DateTime now) =>
      (select(assessmentCasesTable)
            ..where(
              (t) =>
                  t.status.equals('open') &
                  t.dueDate.isSmallerThanValue(now),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();
}

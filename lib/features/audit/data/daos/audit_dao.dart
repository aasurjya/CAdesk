import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/audit_table.dart';

part 'audit_dao.g.dart';

@DriftAccessor(tables: [AuditAssignmentsTable, AuditReportsTable])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  // ---------------------------------------------------------------------------
  // Audit Assignments
  // ---------------------------------------------------------------------------

  /// Insert a new audit assignment and return its ID.
  Future<String> insertAuditAssignment(
    AuditAssignmentsTableCompanion companion,
  ) async {
    await into(auditAssignmentsTable).insert(companion);
    return companion.id.value;
  }

  /// Get an audit assignment by its ID.
  Future<AuditAssignmentsTableData?> getAssignmentById(String id) =>
      (select(auditAssignmentsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Get all audit assignments for a specific client.
  Future<List<AuditAssignmentsTableData>> getAuditsByClient(
    String clientId,
  ) =>
      (select(auditAssignmentsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Get all audit assignments for a specific auditor.
  Future<List<AuditAssignmentsTableData>> getAuditsByAuditor(
    String auditorId,
  ) =>
      (select(auditAssignmentsTable)
            ..where((t) => t.auditorId.equals(auditorId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Update the status of an audit assignment.
  /// Returns true if a row was affected, false otherwise.
  Future<bool> updateAuditStatus(String auditId, String status) async {
    final rowsAffected = await (update(auditAssignmentsTable)
          ..where((t) => t.id.equals(auditId)))
        .write(
          AuditAssignmentsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  // ---------------------------------------------------------------------------
  // Audit Reports
  // ---------------------------------------------------------------------------

  /// Insert a new audit report and return its ID.
  Future<String> insertAuditReport(
    AuditReportsTableCompanion companion,
  ) async {
    await into(auditReportsTable).insert(companion);
    return companion.id.value;
  }

  /// Get an audit report by its ID.
  Future<AuditReportsTableData?> getReportById(String id) =>
      (select(auditReportsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Get the audit report for a specific client and financial year.
  Future<AuditReportsTableData?> getAuditReportByClient(
    String clientId,
    int year,
  ) =>
      (select(auditReportsTable)
            ..where(
              (t) => t.clientId.equals(clientId) & t.year.equals(year),
            )
            ..limit(1))
          .getSingleOrNull();
}

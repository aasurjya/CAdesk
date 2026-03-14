import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/audit/data/mappers/audit_mapper.dart';
import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';

/// Local data source for audit data (SQLite via Drift).
class AuditLocalSource {
  const AuditLocalSource(this._db);

  final AppDatabase _db;

  /// Insert a new audit assignment and return its ID.
  Future<String> insertAuditAssignment(AuditAssignment assignment) => _db
      .auditDao
      .insertAuditAssignment(AuditMapper.assignmentToCompanion(assignment));

  /// Get all audit assignments for a specific client.
  Future<List<AuditAssignment>> getAuditsByClient(String clientId) async {
    final rows = await _db.auditDao.getAuditsByClient(clientId);
    return rows.map(AuditMapper.assignmentFromRow).toList();
  }

  /// Get all audit assignments for a specific auditor.
  Future<List<AuditAssignment>> getAuditsByAuditor(String auditorId) async {
    final rows = await _db.auditDao.getAuditsByAuditor(auditorId);
    return rows.map(AuditMapper.assignmentFromRow).toList();
  }

  /// Update the status of an audit assignment.
  Future<bool> updateAuditStatus(
    String auditId,
    AuditAssignmentStatus status,
  ) => _db.auditDao.updateAuditStatus(auditId, status.name);

  /// Insert a new audit report and return its ID.
  Future<String> insertAuditReport(AuditReport report) =>
      _db.auditDao.insertAuditReport(AuditMapper.reportToCompanion(report));

  /// Get the audit report for a specific client and financial year.
  Future<AuditReport?> getAuditReportByClient(String clientId, int year) async {
    final row = await _db.auditDao.getAuditReportByClient(clientId, year);
    return row != null ? AuditMapper.reportFromRow(row) : null;
  }
}

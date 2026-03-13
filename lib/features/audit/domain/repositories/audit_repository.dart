import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';

/// Repository interface for audit data access.
abstract class AuditRepository {
  /// Insert a new audit assignment and return its ID.
  Future<String> insertAuditAssignment(AuditAssignment assignment);

  /// Get all audit assignments for a specific client.
  Future<List<AuditAssignment>> getAuditsByClient(String clientId);

  /// Get all audit assignments for a specific auditor.
  Future<List<AuditAssignment>> getAuditsByAuditor(String auditorId);

  /// Update the status of an audit assignment.
  Future<bool> updateAuditStatus(String auditId, AuditAssignmentStatus status);

  /// Insert a new audit report and return its ID.
  Future<String> insertAuditReport(AuditReport report);

  /// Get the audit report for a specific client and financial year.
  Future<AuditReport?> getAuditReportByClient(String clientId, int year);
}

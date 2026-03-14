import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';
import 'package:ca_app/features/audit/domain/repositories/audit_repository.dart';

/// Mock implementation of AuditRepository for testing and offline mode.
class MockAuditRepository implements AuditRepository {
  MockAuditRepository()
    : _assignments = <String, AuditAssignment>{},
      _reports = <String, AuditReport>{};

  final Map<String, AuditAssignment> _assignments;
  final Map<String, AuditReport> _reports;

  @override
  Future<String> insertAuditAssignment(AuditAssignment assignment) async {
    _assignments[assignment.id] = assignment;
    return assignment.id;
  }

  @override
  Future<List<AuditAssignment>> getAuditsByClient(String clientId) async {
    return _assignments.values.where((a) => a.clientId == clientId).toList();
  }

  @override
  Future<List<AuditAssignment>> getAuditsByAuditor(String auditorId) async {
    return _assignments.values.where((a) => a.auditorId == auditorId).toList();
  }

  @override
  Future<bool> updateAuditStatus(
    String auditId,
    AuditAssignmentStatus status,
  ) async {
    final existing = _assignments[auditId];
    if (existing == null) return false;
    _assignments[auditId] = existing.copyWith(status: status);
    return true;
  }

  @override
  Future<String> insertAuditReport(AuditReport report) async {
    _reports[report.id] = report;
    return report.id;
  }

  @override
  Future<AuditReport?> getAuditReportByClient(String clientId, int year) async {
    try {
      return _reports.values.firstWhere(
        (r) => r.clientId == clientId && r.year == year,
      );
    } catch (_) {
      return null;
    }
  }
}

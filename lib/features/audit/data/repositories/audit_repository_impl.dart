import 'package:ca_app/features/audit/data/datasources/audit_local_source.dart';
import 'package:ca_app/features/audit/data/datasources/audit_remote_source.dart';
import 'package:ca_app/features/audit/data/mappers/audit_mapper.dart';
import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';
import 'package:ca_app/features/audit/domain/repositories/audit_repository.dart';

/// Implementation of AuditRepository with remote-first strategy and
/// local cache fallback on network failure.
class AuditRepositoryImpl implements AuditRepository {
  const AuditRepositoryImpl({required this.remote, required this.local});

  final AuditRemoteSource remote;
  final AuditLocalSource local;

  @override
  Future<String> insertAuditAssignment(AuditAssignment assignment) async {
    try {
      final json = await remote.insertAuditAssignment(
        AuditMapper.assignmentToJson(assignment),
      );
      final inserted = AuditMapper.assignmentFromJson(json);
      await local.insertAuditAssignment(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertAuditAssignment(assignment);
    }
  }

  @override
  Future<List<AuditAssignment>> getAuditsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchAuditsByClient(clientId);
      final assignments = jsonList.map(AuditMapper.assignmentFromJson).toList();
      for (final a in assignments) {
        await local.insertAuditAssignment(a);
      }
      return List.unmodifiable(assignments);
    } catch (_) {
      return local.getAuditsByClient(clientId);
    }
  }

  @override
  Future<List<AuditAssignment>> getAuditsByAuditor(String auditorId) async {
    try {
      final jsonList = await remote.fetchAuditsByAuditor(auditorId);
      final assignments = jsonList.map(AuditMapper.assignmentFromJson).toList();
      for (final a in assignments) {
        await local.insertAuditAssignment(a);
      }
      return List.unmodifiable(assignments);
    } catch (_) {
      return local.getAuditsByAuditor(auditorId);
    }
  }

  @override
  Future<bool> updateAuditStatus(
    String auditId,
    AuditAssignmentStatus status,
  ) async {
    try {
      await remote.updateAuditStatus(auditId, status.name);
      return local.updateAuditStatus(auditId, status);
    } catch (_) {
      return local.updateAuditStatus(auditId, status);
    }
  }

  @override
  Future<String> insertAuditReport(AuditReport report) async {
    try {
      final json = await remote.insertAuditReport(
        AuditMapper.reportToJson(report),
      );
      final inserted = AuditMapper.reportFromJson(json);
      await local.insertAuditReport(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertAuditReport(report);
    }
  }

  @override
  Future<AuditReport?> getAuditReportByClient(String clientId, int year) async {
    try {
      final json = await remote.fetchAuditReportByClient(clientId, year);
      if (json == null) return null;
      final report = AuditMapper.reportFromJson(json);
      await local.insertAuditReport(report);
      return report;
    } catch (_) {
      return local.getAuditReportByClient(clientId, year);
    }
  }
}

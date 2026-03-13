import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/audit/domain/models/audit_assignment.dart';
import 'package:ca_app/features/audit/domain/models/audit_report.dart';

class AuditMapper {
  const AuditMapper._();

  // ---------------------------------------------------------------------------
  // AuditAssignment — JSON ↔ domain
  // ---------------------------------------------------------------------------

  /// JSON (from Supabase) → AuditAssignment domain model
  static AuditAssignment assignmentFromJson(Map<String, dynamic> json) {
    return AuditAssignment(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      auditorId: json['auditor_id'] as String?,
      financialYear: json['financial_year'] as String?,
      startDate: _parseDateTime(json['start_date'] as String?),
      endDate: _parseDateTime(json['end_date'] as String?),
      status: _safeAuditStatus(json['status'] as String? ?? 'scheduled'),
      fee: json['fee'] as String?,
    );
  }

  /// AuditAssignment domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> assignmentToJson(AuditAssignment assignment) {
    return {
      'id': assignment.id,
      'client_id': assignment.clientId,
      'auditor_id': assignment.auditorId,
      'financial_year': assignment.financialYear,
      'start_date': assignment.startDate?.toIso8601String(),
      'end_date': assignment.endDate?.toIso8601String(),
      'status': assignment.status.name,
      'fee': assignment.fee,
    };
  }

  /// Drift row → AuditAssignment domain model
  static AuditAssignment assignmentFromRow(AuditAssignmentsTableData row) {
    return AuditAssignment(
      id: row.id,
      clientId: row.clientId,
      auditorId: row.auditorId,
      financialYear: row.financialYear,
      startDate: row.startDate,
      endDate: row.endDate,
      status: _safeAuditStatus(row.status ?? 'scheduled'),
      fee: row.fee,
    );
  }

  /// AuditAssignment → Drift companion (for insert/update)
  static AuditAssignmentsTableCompanion assignmentToCompanion(
    AuditAssignment assignment,
  ) {
    return AuditAssignmentsTableCompanion(
      id: Value(assignment.id),
      clientId: Value(assignment.clientId),
      auditorId: Value(assignment.auditorId),
      financialYear: Value(assignment.financialYear),
      startDate: Value(assignment.startDate),
      endDate: Value(assignment.endDate),
      status: Value(assignment.status.name),
      fee: Value(assignment.fee),
    );
  }

  // ---------------------------------------------------------------------------
  // AuditReport — JSON ↔ domain
  // ---------------------------------------------------------------------------

  /// JSON (from Supabase) → AuditReport domain model
  static AuditReport reportFromJson(Map<String, dynamic> json) {
    return AuditReport(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      year: (json['year'] as num).toInt(),
      saReportNumber: json['sa_report_number'] as String?,
      reportDate: _parseDateTime(json['report_date'] as String?),
      reportedBy: json['reported_by'] as String?,
      auditFindings: _parseJsonMap(json['audit_findings']),
    );
  }

  /// AuditReport domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> reportToJson(AuditReport report) {
    return {
      'id': report.id,
      'client_id': report.clientId,
      'year': report.year,
      'sa_report_number': report.saReportNumber,
      'report_date': report.reportDate?.toIso8601String(),
      'reported_by': report.reportedBy,
      'audit_findings': report.auditFindings,
    };
  }

  /// Drift row → AuditReport domain model
  static AuditReport reportFromRow(AuditReportsTableData row) {
    return AuditReport(
      id: row.id,
      clientId: row.clientId,
      year: row.year,
      saReportNumber: row.saReportNumber,
      reportDate: row.reportDate,
      reportedBy: row.reportedBy,
      auditFindings: _parseJsonString(row.auditFindings),
    );
  }

  /// AuditReport → Drift companion (for insert/update)
  static AuditReportsTableCompanion reportToCompanion(AuditReport report) {
    return AuditReportsTableCompanion(
      id: Value(report.id),
      clientId: Value(report.clientId),
      year: Value(report.year),
      saReportNumber: Value(report.saReportNumber),
      reportDate: Value(report.reportDate),
      reportedBy: Value(report.reportedBy),
      auditFindings: Value(
        report.auditFindings != null
            ? jsonEncode(report.auditFindings)
            : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  /// Parse a JSON map from a raw Supabase value (may already be a Map or a String).
  static Map<String, dynamic>? _parseJsonMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) return _parseJsonString(raw);
    return null;
  }

  /// Parse a JSON map from a stored TEXT string (Drift column).
  static Map<String, dynamic>? _parseJsonString(String? jsonStr) {
    if (jsonStr == null) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static AuditAssignmentStatus _safeAuditStatus(String value) {
    try {
      return AuditAssignmentStatus.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return AuditAssignmentStatus.scheduled;
    }
  }
}

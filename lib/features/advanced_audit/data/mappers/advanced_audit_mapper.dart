import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';

/// Bi-directional converter between [AuditEngagement] domain model
/// and Supabase JSON maps.
class AdvancedAuditMapper {
  const AdvancedAuditMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → AuditEngagement domain model
  // ---------------------------------------------------------------------------
  static AuditEngagement fromJson(Map<String, dynamic> json) {
    final members = json['team_members'];
    final teamMembers = members is List
        ? List<String>.from(members)
        : <String>[];

    return AuditEngagement(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      auditType: _parseAuditType(json['audit_type'] as String?),
      financialYear: json['financial_year'] as String? ?? '',
      assignedPartner: json['assigned_partner'] as String? ?? '',
      teamMembers: teamMembers,
      status: _parseStatus(json['status'] as String?),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      reportDueDate: DateTime.parse(json['report_due_date'] as String),
      workpaperCount: json['workpaper_count'] as int? ?? 0,
      findingsCount: json['findings_count'] as int? ?? 0,
      riskLevel: _parseRiskLevel(json['risk_level'] as String?),
    );
  }

  // ---------------------------------------------------------------------------
  // AuditEngagement domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(AuditEngagement e) {
    return {
      'id': e.id,
      'client_id': e.clientId,
      'client_name': e.clientName,
      'audit_type': e.auditType.name,
      'financial_year': e.financialYear,
      'assigned_partner': e.assignedPartner,
      'team_members': e.teamMembers,
      'status': e.status.name,
      'start_date': e.startDate.toIso8601String(),
      'end_date': e.endDate?.toIso8601String(),
      'report_due_date': e.reportDueDate.toIso8601String(),
      'workpaper_count': e.workpaperCount,
      'findings_count': e.findingsCount,
      'risk_level': e.riskLevel.name,
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static AuditType _parseAuditType(String? raw) {
    switch (raw) {
      case 'internal':
        return AuditType.internal;
      case 'stock':
        return AuditType.stock;
      case 'cost':
        return AuditType.cost;
      case 'forensic':
        return AuditType.forensic;
      case 'bank':
        return AuditType.bank;
      case 'concurrent':
        return AuditType.concurrent;
      case 'statutory':
      default:
        return AuditType.statutory;
    }
  }

  static AuditStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'fieldwork':
        return AuditStatus.fieldwork;
      case 'review':
        return AuditStatus.review;
      case 'reporting':
        return AuditStatus.reporting;
      case 'completed':
        return AuditStatus.completed;
      case 'planning':
      default:
        return AuditStatus.planning;
    }
  }

  static AuditRiskLevel _parseRiskLevel(String? raw) {
    switch (raw) {
      case 'medium':
        return AuditRiskLevel.medium;
      case 'high':
        return AuditRiskLevel.high;
      case 'critical':
        return AuditRiskLevel.critical;
      case 'low':
      default:
        return AuditRiskLevel.low;
    }
  }
}

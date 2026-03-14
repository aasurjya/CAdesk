import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/repositories/advanced_audit_repository.dart';

/// In-memory mock implementation of [AdvancedAuditRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations use immutable patterns.
class MockAdvancedAuditRepository implements AdvancedAuditRepository {
  static final List<AuditEngagement> _seed = [
    AuditEngagement(
      id: 'mock-audit-001',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar Enterprises',
      auditType: AuditType.statutory,
      financialYear: 'FY 2024-25',
      assignedPartner: 'CA Anil Sharma',
      teamMembers: const ['Rohit Verma', 'Seema Joshi'],
      status: AuditStatus.fieldwork,
      startDate: DateTime(2025, 4, 1),
      reportDueDate: DateTime(2025, 9, 30),
      workpaperCount: 42,
      findingsCount: 3,
      riskLevel: AuditRiskLevel.medium,
    ),
    AuditEngagement(
      id: 'mock-audit-002',
      clientId: 'mock-client-001',
      clientName: 'Ravi Kumar Enterprises',
      auditType: AuditType.internal,
      financialYear: 'FY 2024-25',
      assignedPartner: 'CA Anil Sharma',
      teamMembers: const ['Anita Rao'],
      status: AuditStatus.review,
      startDate: DateTime(2025, 6, 1),
      reportDueDate: DateTime(2025, 8, 31),
      workpaperCount: 18,
      findingsCount: 1,
      riskLevel: AuditRiskLevel.low,
    ),
    AuditEngagement(
      id: 'mock-audit-003',
      clientId: 'mock-client-002',
      clientName: 'Priya Textiles Pvt Ltd',
      auditType: AuditType.bank,
      financialYear: 'FY 2024-25',
      assignedPartner: 'CA Meena Iyer',
      teamMembers: const ['Vikram Singh', 'Pooja Nair', 'Dev Patel'],
      status: AuditStatus.reporting,
      startDate: DateTime(2025, 5, 1),
      reportDueDate: DateTime(2025, 10, 31),
      workpaperCount: 76,
      findingsCount: 7,
      riskLevel: AuditRiskLevel.high,
    ),
  ];

  final List<AuditEngagement> _state = List.of(_seed);

  @override
  Future<List<AuditEngagement>> getEngagementsByClient(String clientId) async {
    return List.unmodifiable(
      _state.where((e) => e.clientId == clientId).toList(),
    );
  }

  @override
  Future<AuditEngagement?> getEngagementById(String id) async {
    try {
      return _state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertEngagement(AuditEngagement engagement) async {
    _state.add(engagement);
    return engagement.id;
  }

  @override
  Future<bool> updateEngagement(AuditEngagement engagement) async {
    final idx = _state.indexWhere((e) => e.id == engagement.id);
    if (idx == -1) return false;
    final updated = List<AuditEngagement>.of(_state)..[idx] = engagement;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteEngagement(String id) async {
    final before = _state.length;
    _state.removeWhere((e) => e.id == id);
    return _state.length < before;
  }

  @override
  Future<List<AuditEngagement>> getAllEngagements() async {
    return List.unmodifiable(_state);
  }
}

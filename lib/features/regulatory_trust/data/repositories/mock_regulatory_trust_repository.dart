import 'package:ca_app/features/regulatory_trust/domain/models/security_control.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/vapt_scan.dart';
import 'package:ca_app/features/regulatory_trust/domain/repositories/regulatory_trust_repository.dart';

/// In-memory mock implementation of [RegulatoryTrustRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockRegulatoryTrustRepository implements RegulatoryTrustRepository {
  static final List<SecurityControl> _controlSeed = [
    SecurityControl(
      id: 'control-001',
      title: 'SOC 2 Type II Audit',
      category: SecurityControlCategory.soc2,
      status: SecurityControlStatus.compliant,
      severity: ControlSeverity.critical,
      lastAssessmentDate: DateTime(2025, 10, 1),
      nextDueDate: DateTime(2026, 10, 1),
      owner: 'CA Rajesh Sharma',
      notes: 'Completed by certified auditor. Report available.',
    ),
    SecurityControl(
      id: 'control-002',
      title: 'ISO 27001 Certification',
      category: SecurityControlCategory.iso27001,
      status: SecurityControlStatus.inReview,
      severity: ControlSeverity.high,
      lastAssessmentDate: DateTime(2025, 6, 15),
      nextDueDate: DateTime(2026, 6, 15),
      owner: 'Security Lead',
      notes: 'Renewal in progress; gap analysis complete.',
    ),
    SecurityControl(
      id: 'control-003',
      title: 'RBI Cyber Security Framework',
      category: SecurityControlCategory.rbiCyber,
      status: SecurityControlStatus.compliant,
      severity: ControlSeverity.critical,
      lastAssessmentDate: DateTime(2026, 1, 10),
      nextDueDate: DateTime(2027, 1, 10),
      owner: 'Compliance Officer',
    ),
  ];

  static final List<VaptScan> _scanSeed = [
    VaptScan(
      id: 'scan-001',
      title: 'Q4 2025 Web Application VAPT',
      scanDate: DateTime(2025, 12, 15),
      status: VaptScanStatus.completed,
      criticalFindings: 0,
      highFindings: 2,
      mediumFindings: 8,
      lowFindings: 15,
      remediationDeadline: DateTime(2026, 1, 15),
      vendor: 'SecureAudit Labs',
      scope: 'CADesk Web Application',
    ),
    VaptScan(
      id: 'scan-002',
      title: 'Q1 2026 Network Penetration Test',
      scanDate: DateTime(2026, 2, 10),
      status: VaptScanStatus.remediation,
      criticalFindings: 1,
      highFindings: 3,
      mediumFindings: 5,
      lowFindings: 12,
      remediationDeadline: DateTime(2026, 3, 31),
      vendor: 'CyberShield India',
      scope: 'Internal Network Infrastructure',
    ),
    VaptScan(
      id: 'scan-003',
      title: 'Q2 2026 Mobile App VAPT',
      scanDate: DateTime(2026, 5, 1),
      status: VaptScanStatus.scheduled,
      criticalFindings: 0,
      highFindings: 0,
      mediumFindings: 0,
      lowFindings: 0,
      vendor: 'MobileSec Pro',
      scope: 'CADesk iOS & macOS App',
    ),
  ];

  final List<SecurityControl> _controlState = List.of(_controlSeed);
  final List<VaptScan> _scanState = List.of(_scanSeed);

  // ---------------------------------------------------------------------------
  // SecurityControl
  // ---------------------------------------------------------------------------

  @override
  Future<List<SecurityControl>> getSecurityControls() async =>
      List.unmodifiable(_controlState);

  @override
  Future<SecurityControl?> getSecurityControlById(String id) async {
    final idx = _controlState.indexWhere((c) => c.id == id);
    return idx == -1 ? null : _controlState[idx];
  }

  @override
  Future<List<SecurityControl>> getSecurityControlsByCategory(
    SecurityControlCategory category,
  ) async => List.unmodifiable(
    _controlState.where((c) => c.category == category).toList(),
  );

  @override
  Future<List<SecurityControl>> getSecurityControlsByStatus(
    SecurityControlStatus status,
  ) async => List.unmodifiable(
    _controlState.where((c) => c.status == status).toList(),
  );

  @override
  Future<String> insertSecurityControl(SecurityControl control) async {
    _controlState.add(control);
    return control.id;
  }

  @override
  Future<bool> updateSecurityControl(SecurityControl control) async {
    final idx = _controlState.indexWhere((c) => c.id == control.id);
    if (idx == -1) return false;
    final updated = List<SecurityControl>.of(_controlState)..[idx] = control;
    _controlState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteSecurityControl(String id) async {
    final before = _controlState.length;
    _controlState.removeWhere((c) => c.id == id);
    return _controlState.length < before;
  }

  // ---------------------------------------------------------------------------
  // VaptScan
  // ---------------------------------------------------------------------------

  @override
  Future<List<VaptScan>> getVaptScans() async => List.unmodifiable(_scanState);

  @override
  Future<VaptScan?> getVaptScanById(String id) async {
    final idx = _scanState.indexWhere((s) => s.id == id);
    return idx == -1 ? null : _scanState[idx];
  }

  @override
  Future<List<VaptScan>> getVaptScansByStatus(VaptScanStatus status) async =>
      List.unmodifiable(_scanState.where((s) => s.status == status).toList());

  @override
  Future<String> insertVaptScan(VaptScan scan) async {
    _scanState.add(scan);
    return scan.id;
  }

  @override
  Future<bool> updateVaptScan(VaptScan scan) async {
    final idx = _scanState.indexWhere((s) => s.id == scan.id);
    if (idx == -1) return false;
    final updated = List<VaptScan>.of(_scanState)..[idx] = scan;
    _scanState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteVaptScan(String id) async {
    final before = _scanState.length;
    _scanState.removeWhere((s) => s.id == id);
    return _scanState.length < before;
  }
}

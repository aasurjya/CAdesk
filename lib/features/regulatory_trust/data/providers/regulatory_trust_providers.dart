import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/security_control.dart';
import '../../domain/models/vapt_scan.dart';

// ---------------------------------------------------------------------------
// Mock data - Security Controls
// ---------------------------------------------------------------------------

final List<SecurityControl> _mockControls = [
  SecurityControl(
    id: 'ctrl-001',
    title: 'Access Control & Identity Management',
    category: SecurityControlCategory.soc2,
    status: SecurityControlStatus.compliant,
    severity: ControlSeverity.critical,
    lastAssessmentDate: DateTime(2026, 1, 15),
    nextDueDate: DateTime(2026, 7, 15),
    owner: 'Priya Sharma',
    notes: 'MFA enforced for all admin accounts. Last audit passed.',
  ),
  SecurityControl(
    id: 'ctrl-002',
    title: 'Incident Response & Management',
    category: SecurityControlCategory.soc2,
    status: SecurityControlStatus.inReview,
    severity: ControlSeverity.high,
    lastAssessmentDate: DateTime(2025, 11, 20),
    nextDueDate: DateTime(2026, 3, 20),
    owner: 'Rajan Mehta',
    notes: 'Playbook update in progress for ransomware scenarios.',
  ),
  SecurityControl(
    id: 'ctrl-003',
    title: 'Information Asset Classification',
    category: SecurityControlCategory.iso27001,
    status: SecurityControlStatus.compliant,
    severity: ControlSeverity.high,
    lastAssessmentDate: DateTime(2026, 2, 5),
    nextDueDate: DateTime(2026, 8, 5),
    owner: 'Anita Rao',
    notes: 'Asset register maintained and reviewed quarterly.',
  ),
  SecurityControl(
    id: 'ctrl-004',
    title: 'Supplier & Third-Party Risk',
    category: SecurityControlCategory.iso27001,
    status: SecurityControlStatus.nonCompliant,
    severity: ControlSeverity.high,
    lastAssessmentDate: DateTime(2025, 10, 12),
    nextDueDate: DateTime(2026, 4, 12),
    owner: 'Vikram Nair',
    notes: 'Two vendors pending security questionnaire submission.',
  ),
  SecurityControl(
    id: 'ctrl-005',
    title: 'Network Perimeter Security',
    category: SecurityControlCategory.vapt,
    status: SecurityControlStatus.scheduled,
    severity: ControlSeverity.critical,
    lastAssessmentDate: DateTime(2025, 9, 30),
    nextDueDate: DateTime(2026, 3, 30),
    owner: 'Kavya Pillai',
    notes: 'Next VAPT scheduled with SecureLayer7.',
  ),
  SecurityControl(
    id: 'ctrl-006',
    title: 'Cyber Security Policy Framework',
    category: SecurityControlCategory.rbiCyber,
    status: SecurityControlStatus.compliant,
    severity: ControlSeverity.critical,
    lastAssessmentDate: DateTime(2026, 1, 8),
    nextDueDate: DateTime(2027, 1, 8),
    owner: 'Suresh Iyer',
    notes: 'RBI circular RBI/2023-24/37 compliance verified.',
  ),
  SecurityControl(
    id: 'ctrl-007',
    title: 'Data Localisation & Sovereignty',
    category: SecurityControlCategory.dataResidency,
    status: SecurityControlStatus.compliant,
    severity: ControlSeverity.medium,
    lastAssessmentDate: DateTime(2026, 2, 20),
    nextDueDate: DateTime(2026, 8, 20),
    owner: 'Deepa Krishnan',
    notes: 'All client data stored in Mumbai region data centre.',
  ),
  SecurityControl(
    id: 'ctrl-008',
    title: 'Consent Management & Data Subject Rights',
    category: SecurityControlCategory.privacy,
    status: SecurityControlStatus.inReview,
    severity: ControlSeverity.medium,
    lastAssessmentDate: DateTime(2025, 12, 15),
    nextDueDate: DateTime(2026, 6, 15),
    owner: 'Nisha Goyal',
    notes: 'DPDP Act 2023 gap analysis under review.',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - VAPT Scans
// ---------------------------------------------------------------------------

final List<VaptScan> _mockVaptScans = [
  VaptScan(
    id: 'vapt-001',
    title: 'Web Application Penetration Test Q1 2026',
    scanDate: DateTime(2026, 2, 10),
    status: VaptScanStatus.remediation,
    criticalFindings: 1,
    highFindings: 3,
    mediumFindings: 8,
    lowFindings: 12,
    remediationDeadline: DateTime(2026, 3, 31),
    vendor: 'SecureLayer7',
    scope: 'CA Portal, Client Dashboard, API Gateway',
  ),
  VaptScan(
    id: 'vapt-002',
    title: 'Network Infrastructure Assessment Q4 2025',
    scanDate: DateTime(2025, 11, 18),
    status: VaptScanStatus.completed,
    criticalFindings: 0,
    highFindings: 2,
    mediumFindings: 5,
    lowFindings: 9,
    vendor: 'Appsecco',
    scope: 'On-premise servers, VPN, Firewall rules',
  ),
  VaptScan(
    id: 'vapt-003',
    title: 'Mobile Application Security Review',
    scanDate: DateTime(2026, 3, 5),
    status: VaptScanStatus.inProgress,
    criticalFindings: 0,
    highFindings: 1,
    mediumFindings: 3,
    lowFindings: 6,
    remediationDeadline: DateTime(2026, 4, 15),
    vendor: 'SecureLayer7',
    scope: 'iOS & Android CADesk apps',
  ),
  VaptScan(
    id: 'vapt-004',
    title: 'Cloud Infrastructure Audit Q2 2026',
    scanDate: DateTime(2026, 4, 20),
    status: VaptScanStatus.scheduled,
    criticalFindings: 0,
    highFindings: 0,
    mediumFindings: 0,
    lowFindings: 0,
    vendor: 'Appsecco',
    scope: 'AWS Mumbai region, S3 buckets, IAM policies',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All security controls.
final regulatoryControlsProvider = Provider<List<SecurityControl>>(
  (_) => List.unmodifiable(_mockControls),
);

/// All VAPT scans.
final vaptScansProvider = Provider<List<VaptScan>>(
  (_) => List.unmodifiable(_mockVaptScans),
);

/// Selected security control status filter.
final controlStatusFilterProvider =
    NotifierProvider<ControlStatusFilterNotifier, SecurityControlStatus?>(
        ControlStatusFilterNotifier.new);

class ControlStatusFilterNotifier extends Notifier<SecurityControlStatus?> {
  @override
  SecurityControlStatus? build() => null;

  void update(SecurityControlStatus? value) => state = value;
}

/// Security controls filtered by selected status.
final filteredControlsProvider = Provider<List<SecurityControl>>((ref) {
  final status = ref.watch(controlStatusFilterProvider);
  final allControls = ref.watch(regulatoryControlsProvider);
  if (status == null) return allControls;
  return allControls.where((c) => c.status == status).toList();
});

/// Regulatory trust summary statistics.
final regulatoryTrustSummaryProvider =
    Provider<RegulatoryTrustSummary>((ref) {
  final controls = ref.watch(regulatoryControlsProvider);
  final scans = ref.watch(vaptScansProvider);
  final now = DateTime(2026, 3, 10);

  final totalControls = controls.length;
  final compliantControls =
      controls.where((c) => c.status == SecurityControlStatus.compliant).length;
  final nonCompliantControls = controls
      .where((c) => c.status == SecurityControlStatus.nonCompliant)
      .length;
  final upcomingVapts = scans
      .where(
        (s) =>
            s.status == VaptScanStatus.scheduled ||
            (s.status == VaptScanStatus.inProgress &&
                s.scanDate.isAfter(now.subtract(const Duration(days: 30)))),
      )
      .length;

  return RegulatoryTrustSummary(
    totalControls: totalControls,
    compliantControls: compliantControls,
    nonCompliantControls: nonCompliantControls,
    upcomingVapts: upcomingVapts,
  );
});

/// Immutable summary data class for regulatory trust dashboard.
class RegulatoryTrustSummary {
  const RegulatoryTrustSummary({
    required this.totalControls,
    required this.compliantControls,
    required this.nonCompliantControls,
    required this.upcomingVapts,
  });

  final int totalControls;
  final int compliantControls;
  final int nonCompliantControls;
  final int upcomingVapts;
}

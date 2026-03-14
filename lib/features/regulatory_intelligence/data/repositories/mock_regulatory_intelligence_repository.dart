import 'package:ca_app/features/regulatory_intelligence/domain/models/client_impact_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/compliance_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_circular.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_update.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/repositories/regulatory_intelligence_repository.dart';

/// In-memory mock implementation of [RegulatoryIntelligenceRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockRegulatoryIntelligenceRepository
    implements RegulatoryIntelligenceRepository {
  static final List<RegulatoryUpdate> _updateSeed = [
    RegulatoryUpdate(
      updateId: 'update-001',
      title: 'CBDT Circular on Advance Tax Computation',
      summary:
          'CBDT clarifies the method for computing advance tax for FY 2026-27.',
      source: RegSource.cbdt,
      category: UpdateCategory.circular,
      publicationDate: DateTime(2026, 3, 1),
      effectiveDate: DateTime(2026, 4, 1),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['Section 234B', 'Section 234C'],
      url: 'https://incometaxindia.gov.in/circular/2026/001',
      isRead: false,
    ),
    RegulatoryUpdate(
      updateId: 'update-002',
      title: 'CBIC GST Rate Revision on Construction Services',
      summary: 'GST rate on construction services revised from 12% to 18%.',
      source: RegSource.cbic,
      category: UpdateCategory.notification,
      publicationDate: DateTime(2026, 2, 15),
      effectiveDate: DateTime(2026, 3, 1),
      impactLevel: ImpactLevel.high,
      affectedSections: const ['Section 9', 'HSN 9954'],
      url: 'https://cbic.gov.in/gst/notification/2026/15',
      isRead: true,
    ),
    RegulatoryUpdate(
      updateId: 'update-003',
      title: 'MCA Amendment to Companies Act 2013 (Section 135)',
      summary: 'CSR spending threshold raised from ₹500 crore to ₹750 crore.',
      source: RegSource.mca,
      category: UpdateCategory.amendment,
      publicationDate: DateTime(2026, 1, 20),
      effectiveDate: DateTime(2026, 2, 1),
      impactLevel: ImpactLevel.medium,
      affectedSections: const ['Section 135'],
      url: null,
      isRead: false,
    ),
  ];

  static final List<ComplianceAlert> _alertSeed = [
    ComplianceAlert(
      alertId: 'alert-001',
      title: 'GSTR-3B Filing Deadline',
      description: 'Monthly GSTR-3B for March 2026 is due on 20 April 2026.',
      alertType: AlertType.deadlineApproaching,
      dueDate: DateTime(2026, 4, 20),
      daysRemaining: 37,
      applicableTo: const ['GST Registered Entities'],
      penaltyIfMissed: '₹50/day + 18% interest',
      priority: AlertPriority.critical,
    ),
    ComplianceAlert(
      alertId: 'alert-002',
      title: 'TDS Rate Change — Section 194P',
      description: 'New TDS rate of 10% applicable from 1 April 2026.',
      alertType: AlertType.rateChange,
      dueDate: null,
      daysRemaining: null,
      applicableTo: const ['Senior Citizens', 'Specified Persons'],
      penaltyIfMissed: null,
      priority: AlertPriority.high,
    ),
    ComplianceAlert(
      alertId: 'alert-003',
      title: 'Annual Information Statement Verification',
      description:
          'Verify AIS mismatch before filing ITR to avoid scrutiny notices.',
      alertType: AlertType.newCompliance,
      dueDate: DateTime(2026, 7, 31),
      daysRemaining: 139,
      applicableTo: const ['Individual', 'HUF', 'Company'],
      penaltyIfMissed: 'Scrutiny notice u/s 143(2)',
      priority: AlertPriority.medium,
    ),
  ];

  static final List<RegulatoryCircular> _circularSeed = [
    const RegulatoryCircular(
      id: 'circular-001',
      circularNumber: 'CBDT Circular No. 3/2026',
      issuingBody: 'CBDT',
      title: 'Guidelines on New Tax Regime for FY 2026-27',
      summary:
          'Detailed guidelines on the simplified new tax regime and its applicability.',
      issueDate: '10 Mar 2026',
      effectiveDate: '01 Apr 2026',
      category: 'Income Tax',
      impactLevel: 'High',
      affectedClientsCount: 45,
      keyChanges: [
        'Standard deduction raised to ₹75,000',
        'Rebate u/s 87A extended to ₹7.5 lakh',
        'HRA exemption excluded from new regime',
      ],
    ),
    const RegulatoryCircular(
      id: 'circular-002',
      circularNumber: 'GSTN Notification 08/2026',
      issuingBody: 'GSTN',
      title: 'E-invoicing Threshold Reduced to ₹5 Crore',
      summary: 'E-invoicing mandatory for turnover above ₹5 crore from April.',
      issueDate: '01 Feb 2026',
      effectiveDate: '01 Apr 2026',
      category: 'GST',
      impactLevel: 'High',
      affectedClientsCount: 28,
      keyChanges: [
        'Threshold reduced from ₹10 crore to ₹5 crore',
        'New e-invoice portal API integration required',
      ],
    ),
    const RegulatoryCircular(
      id: 'circular-003',
      circularNumber: 'MCA Notification 02/2026',
      issuingBody: 'MCA',
      title: 'Annual Return Filing — New Form MGT-7A',
      summary:
          'Revised form MGT-7A applicable for OPCs and small companies for FY 2025-26.',
      issueDate: '15 Jan 2026',
      effectiveDate: '01 Apr 2026',
      category: 'MCA',
      impactLevel: 'Medium',
      affectedClientsCount: 12,
      keyChanges: [
        'Simplified disclosure requirements',
        'Digital signature mandatory',
      ],
    ),
  ];

  static const List<ClientImpactAlert> _impactSeed = [
    ClientImpactAlert(
      id: 'impact-001',
      circularId: 'circular-001',
      clientName: 'Sharma Industries Pvt Ltd',
      clientPan: 'AABCS1234D',
      impactDescription:
          'New regime change affects advance tax planning for FY 2026-27.',
      actionRequired:
          'Review and revise advance tax payment schedule by 15 June 2026.',
      dueDate: '15 Jun 2026',
      status: 'New',
      urgency: 'Urgent',
    ),
    ClientImpactAlert(
      id: 'impact-002',
      circularId: 'circular-002',
      clientName: 'Patel Exports Ltd',
      clientPan: 'AAAPS5678E',
      impactDescription:
          'E-invoicing now mandatory; current turnover exceeds ₹5 crore threshold.',
      actionRequired: 'Integrate ERP with GSTN e-invoice API before April.',
      dueDate: '31 Mar 2026',
      status: 'Reviewed',
      urgency: 'Urgent',
    ),
    ClientImpactAlert(
      id: 'impact-003',
      circularId: 'circular-003',
      clientName: 'Reddy Tech Solutions OPC',
      clientPan: 'AAART9012F',
      impactDescription: 'Must file revised form MGT-7A for FY 2025-26.',
      actionRequired: 'Prepare and file MGT-7A by 30 September 2026.',
      dueDate: '30 Sep 2026',
      status: 'New',
      urgency: 'Normal',
    ),
  ];

  final List<RegulatoryUpdate> _updateState = List.of(_updateSeed);
  final List<ComplianceAlert> _alertState = List.of(_alertSeed);
  final List<RegulatoryCircular> _circularState = List.of(_circularSeed);
  final List<ClientImpactAlert> _impactState = List.of(_impactSeed);

  // ---------------------------------------------------------------------------
  // RegulatoryUpdate
  // ---------------------------------------------------------------------------

  @override
  Future<List<RegulatoryUpdate>> getUpdates() async =>
      List.unmodifiable(_updateState);

  @override
  Future<RegulatoryUpdate?> getUpdateById(String id) async {
    final idx = _updateState.indexWhere((u) => u.updateId == id);
    return idx == -1 ? null : _updateState[idx];
  }

  @override
  Future<List<RegulatoryUpdate>> getUpdatesBySource(RegSource source) async =>
      List.unmodifiable(_updateState.where((u) => u.source == source).toList());

  @override
  Future<List<RegulatoryUpdate>> getUpdatesByImpactLevel(
    ImpactLevel impactLevel,
  ) async => List.unmodifiable(
    _updateState.where((u) => u.impactLevel == impactLevel).toList(),
  );

  @override
  Future<String> insertUpdate(RegulatoryUpdate update) async {
    _updateState.add(update);
    return update.updateId;
  }

  @override
  Future<bool> markUpdateAsRead(String id) async {
    final idx = _updateState.indexWhere((u) => u.updateId == id);
    if (idx == -1) return false;
    final updated = List<RegulatoryUpdate>.of(_updateState)
      ..[idx] = _updateState[idx].copyWith(isRead: true);
    _updateState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteUpdate(String id) async {
    final before = _updateState.length;
    _updateState.removeWhere((u) => u.updateId == id);
    return _updateState.length < before;
  }

  // ---------------------------------------------------------------------------
  // ComplianceAlert
  // ---------------------------------------------------------------------------

  @override
  Future<List<ComplianceAlert>> getAlerts() async =>
      List.unmodifiable(_alertState);

  @override
  Future<ComplianceAlert?> getAlertById(String id) async {
    final idx = _alertState.indexWhere((a) => a.alertId == id);
    return idx == -1 ? null : _alertState[idx];
  }

  @override
  Future<List<ComplianceAlert>> getAlertsByPriority(
    AlertPriority priority,
  ) async => List.unmodifiable(
    _alertState.where((a) => a.priority == priority).toList(),
  );

  @override
  Future<String> insertAlert(ComplianceAlert alert) async {
    _alertState.add(alert);
    return alert.alertId;
  }

  @override
  Future<bool> deleteAlert(String id) async {
    final before = _alertState.length;
    _alertState.removeWhere((a) => a.alertId == id);
    return _alertState.length < before;
  }

  // ---------------------------------------------------------------------------
  // RegulatoryCircular
  // ---------------------------------------------------------------------------

  @override
  Future<List<RegulatoryCircular>> getCirculars() async =>
      List.unmodifiable(_circularState);

  @override
  Future<RegulatoryCircular?> getCircularById(String id) async {
    final idx = _circularState.indexWhere((c) => c.id == id);
    return idx == -1 ? null : _circularState[idx];
  }

  @override
  Future<String> insertCircular(RegulatoryCircular circular) async {
    _circularState.add(circular);
    return circular.id;
  }

  @override
  Future<bool> deleteCircular(String id) async {
    final before = _circularState.length;
    _circularState.removeWhere((c) => c.id == id);
    return _circularState.length < before;
  }

  // ---------------------------------------------------------------------------
  // ClientImpactAlert
  // ---------------------------------------------------------------------------

  @override
  Future<List<ClientImpactAlert>> getClientImpactAlerts() async =>
      List.unmodifiable(_impactState);

  @override
  Future<List<ClientImpactAlert>> getClientImpactAlertsByCircular(
    String circularId,
  ) async => List.unmodifiable(
    _impactState.where((a) => a.circularId == circularId).toList(),
  );

  @override
  Future<String> insertClientImpactAlert(ClientImpactAlert alert) async {
    _impactState.add(alert);
    return alert.id;
  }

  @override
  Future<bool> updateClientImpactAlertStatus(String id, String status) async {
    final idx = _impactState.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    final updated = List<ClientImpactAlert>.of(_impactState)
      ..[idx] = _impactState[idx].copyWith(status: status);
    _impactState
      ..clear()
      ..addAll(updated);
    return true;
  }
}

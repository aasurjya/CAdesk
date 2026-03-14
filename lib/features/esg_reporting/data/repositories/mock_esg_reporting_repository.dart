import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';
import 'package:ca_app/features/esg_reporting/domain/repositories/esg_reporting_repository.dart';

/// In-memory mock implementation of [EsgReportingRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockEsgReportingRepository implements EsgReportingRepository {
  static const List<EsgDisclosure> _seedDisclosures = [
    EsgDisclosure(
      id: 'esg-001',
      clientName: 'Tata Steel Ltd',
      clientPan: 'mock-client-001',
      disclosureType: 'BRSR',
      reportingYear: 'FY 2024-25',
      environmentScore: 78.5,
      socialScore: 72.0,
      governanceScore: 85.0,
      overallScore: 78.5,
      status: 'Under Review',
      sebiCategory: 'Listed Top 1000',
      pendingItems: ['Verify water consumption data', 'Board sign-off'],
    ),
    EsgDisclosure(
      id: 'esg-002',
      clientName: 'Infosys Ltd',
      clientPan: 'mock-client-002',
      disclosureType: 'Integrated Report',
      reportingYear: 'FY 2024-25',
      environmentScore: 88.0,
      socialScore: 91.5,
      governanceScore: 94.0,
      overallScore: 91.2,
      status: 'Published',
      sebiCategory: 'BRSR Core',
      pendingItems: [],
    ),
    EsgDisclosure(
      id: 'esg-003',
      clientName: 'Sharma & Associates',
      clientPan: 'mock-client-003',
      disclosureType: 'Sustainability Report',
      reportingYear: 'FY 2024-25',
      environmentScore: 55.0,
      socialScore: 60.0,
      governanceScore: 70.0,
      overallScore: 61.7,
      status: 'Draft',
      sebiCategory: 'Voluntary',
      pendingItems: ['Energy audit data', 'Employee survey', 'Legal review'],
    ),
  ];

  static const List<CarbonMetric> _seedCarbonMetrics = [
    CarbonMetric(
      id: 'carbon-001',
      clientName: 'Infosys Ltd',
      scope: 'Scope 1',
      emissionsTonnes: 12500.0,
      reductionTargetPercent: 50.0,
      achievedPercent: 28.5,
      reportingYear: 'FY 2024-25',
      unit: 'tCO2e',
    ),
    CarbonMetric(
      id: 'carbon-002',
      clientName: 'Infosys Ltd',
      scope: 'Scope 2',
      emissionsTonnes: 45000.0,
      reductionTargetPercent: 100.0,
      achievedPercent: 62.0,
      reportingYear: 'FY 2024-25',
      unit: 'tCO2e',
    ),
    CarbonMetric(
      id: 'carbon-003',
      clientName: 'Tata Steel Ltd',
      scope: 'Scope 1',
      emissionsTonnes: 980000.0,
      reductionTargetPercent: 30.0,
      achievedPercent: 8.2,
      reportingYear: 'FY 2024-25',
      unit: 'tCO2e',
    ),
  ];

  final List<EsgDisclosure> _disclosures = List.of(_seedDisclosures);
  final List<CarbonMetric> _carbonMetrics = List.of(_seedCarbonMetrics);

  @override
  Future<String> insertDisclosure(EsgDisclosure disclosure) async {
    _disclosures.add(disclosure);
    return disclosure.id;
  }

  @override
  Future<List<EsgDisclosure>> getAllDisclosures() async =>
      List.unmodifiable(_disclosures);

  @override
  Future<List<EsgDisclosure>> getDisclosuresByStatus(String status) async =>
      List.unmodifiable(_disclosures.where((d) => d.status == status).toList());

  @override
  Future<List<EsgDisclosure>> getDisclosuresByClient(String clientPan) async =>
      List.unmodifiable(
        _disclosures.where((d) => d.clientPan == clientPan).toList(),
      );

  @override
  Future<bool> updateDisclosure(EsgDisclosure disclosure) async {
    final idx = _disclosures.indexWhere((d) => d.id == disclosure.id);
    if (idx == -1) return false;
    final updated = List<EsgDisclosure>.of(_disclosures)..[idx] = disclosure;
    _disclosures
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteDisclosure(String id) async {
    final before = _disclosures.length;
    _disclosures.removeWhere((d) => d.id == id);
    return _disclosures.length < before;
  }

  @override
  Future<String> insertCarbonMetric(CarbonMetric metric) async {
    _carbonMetrics.add(metric);
    return metric.id;
  }

  @override
  Future<List<CarbonMetric>> getAllCarbonMetrics() async =>
      List.unmodifiable(_carbonMetrics);

  @override
  Future<List<CarbonMetric>> getCarbonMetricsByClient(
    String clientName,
  ) async => List.unmodifiable(
    _carbonMetrics.where((m) => m.clientName == clientName).toList(),
  );

  @override
  Future<List<CarbonMetric>> getCarbonMetricsByYear(
    String reportingYear,
  ) async => List.unmodifiable(
    _carbonMetrics.where((m) => m.reportingYear == reportingYear).toList(),
  );

  @override
  Future<bool> updateCarbonMetric(CarbonMetric metric) async {
    final idx = _carbonMetrics.indexWhere((m) => m.id == metric.id);
    if (idx == -1) return false;
    final updated = List<CarbonMetric>.of(_carbonMetrics)..[idx] = metric;
    _carbonMetrics
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteCarbonMetric(String id) async {
    final before = _carbonMetrics.length;
    _carbonMetrics.removeWhere((m) => m.id == id);
    return _carbonMetrics.length < before;
  }
}

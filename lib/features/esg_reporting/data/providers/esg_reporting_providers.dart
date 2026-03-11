import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';

// ---------------------------------------------------------------------------
// Mock data — ESG Disclosures
// ---------------------------------------------------------------------------

final List<EsgDisclosure> _mockDisclosures = [
  EsgDisclosure(
    id: 'esg-001',
    clientName: 'Tata Consultancy Services Ltd',
    clientPan: 'AAACT2727Q',
    disclosureType: 'BRSR Core',
    reportingYear: 'FY 2024-25',
    environmentScore: 88,
    socialScore: 82,
    governanceScore: 91,
    overallScore: 87,
    status: 'Filed',
    sebiCategory: 'BRSR Core',
    pendingItems: const [
      'Supplier ESG questionnaire responses pending',
      'Biodiversity impact assessment to be attached',
    ],
  ),
  EsgDisclosure(
    id: 'esg-002',
    clientName: 'Infosys Ltd',
    clientPan: 'AAACI1680H',
    disclosureType: 'Integrated Report',
    reportingYear: 'FY 2024-25',
    environmentScore: 85,
    socialScore: 80,
    governanceScore: 89,
    overallScore: 84.67,
    status: 'Published',
    sebiCategory: 'Listed Top 1000',
    pendingItems: const [
      'Third-party assurance certificate upload',
    ],
  ),
  EsgDisclosure(
    id: 'esg-003',
    clientName: 'Reliance Industries Ltd',
    clientPan: 'AAACR5055K',
    disclosureType: 'BRSR',
    reportingYear: 'FY 2024-25',
    environmentScore: 72,
    socialScore: 75,
    governanceScore: 84,
    overallScore: 77,
    status: 'Under Review',
    sebiCategory: 'Listed Top 1000',
    pendingItems: const [
      'Water consumption data for Jamnagar complex',
      'Community development spend reconciliation',
      'Board diversity disclosure update',
    ],
  ),
  EsgDisclosure(
    id: 'esg-004',
    clientName: 'Mahindra & Mahindra Ltd',
    clientPan: 'AABCM5716D',
    disclosureType: 'Sustainability Report',
    reportingYear: 'FY 2024-25',
    environmentScore: 79,
    socialScore: 78,
    governanceScore: 86,
    overallScore: 81,
    status: 'Draft',
    sebiCategory: 'Listed Top 1000',
    pendingItems: const [
      'EV fleet transition metrics to be validated',
      'Supply chain Scope 3 data collection in progress',
      'Stakeholder grievance redressal report pending',
      'Independent director ESG training records',
    ],
  ),
  EsgDisclosure(
    id: 'esg-005',
    clientName: 'HDFC Bank Ltd',
    clientPan: 'AAACH2702H',
    disclosureType: 'Voluntary ESG',
    reportingYear: 'FY 2024-25',
    environmentScore: 70,
    socialScore: 83,
    governanceScore: 92,
    overallScore: 81.67,
    status: 'Filed',
    sebiCategory: 'Voluntary',
    pendingItems: const [
      'Green finance portfolio classification update',
      'Financed emissions methodology note',
    ],
  ),
  EsgDisclosure(
    id: 'esg-006',
    clientName: 'Wipro Ltd',
    clientPan: 'AAACW0325H',
    disclosureType: 'BRSR Core',
    reportingYear: 'FY 2024-25',
    environmentScore: 84,
    socialScore: 77,
    governanceScore: 88,
    overallScore: 83,
    status: 'Published',
    sebiCategory: 'BRSR Core',
    pendingItems: const [],
  ),
  EsgDisclosure(
    id: 'esg-007',
    clientName: 'Sun Pharmaceutical Industries Ltd',
    clientPan: 'AAECS8712C',
    disclosureType: 'BRSR',
    reportingYear: 'FY 2024-25',
    environmentScore: 68,
    socialScore: 72,
    governanceScore: 80,
    overallScore: 73.33,
    status: 'Under Review',
    sebiCategory: 'Listed Top 1000',
    pendingItems: const [
      'Hazardous waste disposal audit report',
      'API manufacturing effluent treatment data',
      'Employee health & safety incident log reconciliation',
    ],
  ),
  EsgDisclosure(
    id: 'esg-008',
    clientName: 'Larsen & Toubro Construction',
    clientPan: 'AAACL0582H',
    disclosureType: 'Carbon Disclosure',
    reportingYear: 'FY 2024-25',
    environmentScore: 65,
    socialScore: 74,
    governanceScore: 82,
    overallScore: 73.67,
    status: 'Draft',
    sebiCategory: 'Listed Top 1000',
    pendingItems: const [
      'Site-level energy consumption data consolidation',
      'Cement & steel embodied carbon calculation',
      'Migrant worker welfare compliance certificates',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Carbon Metrics
// ---------------------------------------------------------------------------

final List<CarbonMetric> _mockCarbonMetrics = [
  const CarbonMetric(
    id: 'cm-001',
    clientName: 'Tata Consultancy Services Ltd',
    scope: 'Scope 1 (Direct)',
    emissionsTonnes: 12450,
    reductionTargetPercent: 30,
    achievedPercent: 22,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-002',
    clientName: 'Tata Consultancy Services Ltd',
    scope: 'Scope 2 (Electricity)',
    emissionsTonnes: 85300,
    reductionTargetPercent: 50,
    achievedPercent: 41,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-003',
    clientName: 'Infosys Ltd',
    scope: 'Scope 2 (Electricity)',
    emissionsTonnes: 0,
    reductionTargetPercent: 100,
    achievedPercent: 100,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-004',
    clientName: 'Infosys Ltd',
    scope: 'Scope 3 (Value Chain)',
    emissionsTonnes: 142600,
    reductionTargetPercent: 35,
    achievedPercent: 18,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-005',
    clientName: 'Reliance Industries Ltd',
    scope: 'Scope 1 (Direct)',
    emissionsTonnes: 3850000,
    reductionTargetPercent: 20,
    achievedPercent: 8,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-006',
    clientName: 'Reliance Industries Ltd',
    scope: 'Scope 3 (Value Chain)',
    emissionsTonnes: 9200000,
    reductionTargetPercent: 25,
    achievedPercent: 5,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-007',
    clientName: 'Mahindra & Mahindra Ltd',
    scope: 'Scope 1 (Direct)',
    emissionsTonnes: 198400,
    reductionTargetPercent: 40,
    achievedPercent: 28,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-008',
    clientName: 'Wipro Ltd',
    scope: 'Scope 2 (Electricity)',
    emissionsTonnes: 3200,
    reductionTargetPercent: 60,
    achievedPercent: 55,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-009',
    clientName: 'Sun Pharmaceutical Industries Ltd',
    scope: 'Scope 1 (Direct)',
    emissionsTonnes: 456000,
    reductionTargetPercent: 25,
    achievedPercent: 12,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
  const CarbonMetric(
    id: 'cm-010',
    clientName: 'Larsen & Toubro Construction',
    scope: 'Scope 1 (Direct)',
    emissionsTonnes: 1240000,
    reductionTargetPercent: 30,
    achievedPercent: 9,
    reportingYear: 'FY 2024-25',
    unit: 'tCO2e',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All ESG disclosures (unfiltered).
final allEsgDisclosuresProvider = Provider<List<EsgDisclosure>>(
  (ref) => _mockDisclosures,
);

/// All carbon metrics (unfiltered).
final allCarbonMetricsProvider = Provider<List<CarbonMetric>>(
  (ref) => _mockCarbonMetrics,
);

/// Currently selected status filter; `null` means "All".
final selectedEsgStatusProvider =
    NotifierProvider<SelectedEsgStatusNotifier, String?>(
        SelectedEsgStatusNotifier.new);

class SelectedEsgStatusNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Disclosures filtered by [selectedEsgStatusProvider].
final filteredEsgDisclosuresProvider = Provider<List<EsgDisclosure>>((ref) {
  final all = ref.watch(allEsgDisclosuresProvider);
  final status = ref.watch(selectedEsgStatusProvider);
  if (status == null) {
    return all;
  }
  return all.where((d) => d.status == status).toList();
});

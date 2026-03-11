import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_penalty_calculator.dart';

export 'package:ca_app/features/llp_compliance/domain/models/llp_penalty_calculator.dart';

// ---------------------------------------------------------------------------
// Mock LLP entities (6)
// ---------------------------------------------------------------------------

final _mockLLPs = <LLPEntity>[
  LLPEntity(
    id: 'llp-001',
    llpName: 'Sharma & Gupta Associates LLP',
    llpin: 'AAB-4521',
    incorporationDate: DateTime(2018, 6, 15),
    turnover: 7500000,
    capitalContribution: 3000000,
    isAuditRequired: true,
    designatedPartners: const [
      LLPPartner(
        name: 'Vikram Sharma',
        din: '07234561',
        email: 'vikram@sgallp.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Ankit Gupta',
        din: '08345672',
        email: 'ankit@sgallp.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Ravi Joshi',
        din: '09456783',
        email: 'ravi@sgallp.in',
        isDesignated: false,
      ),
    ],
    registeredOffice: '12, Connaught Place, New Delhi 110001',
    rocJurisdiction: 'ROC Delhi',
  ),
  LLPEntity(
    id: 'llp-002',
    llpName: 'TechBridge Consulting LLP',
    llpin: 'AAC-7832',
    incorporationDate: DateTime(2020, 2, 10),
    turnover: 12500000,
    capitalContribution: 5000000,
    isAuditRequired: true,
    designatedPartners: const [
      LLPPartner(
        name: 'Priya Nair',
        din: '06123450',
        email: 'priya@techbridge.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Suresh Reddy',
        din: '07234561',
        email: 'suresh@techbridge.in',
        isDesignated: true,
      ),
    ],
    registeredOffice: '5th Floor, Indiranagar, Bengaluru 560038',
    rocJurisdiction: 'ROC Bengaluru',
  ),
  LLPEntity(
    id: 'llp-003',
    llpName: 'Bharat Infrastructure LLP',
    llpin: 'AAD-1245',
    incorporationDate: DateTime(2017, 9, 22),
    turnover: 45000000,
    capitalContribution: 15000000,
    isAuditRequired: true,
    designatedPartners: const [
      LLPPartner(
        name: 'Ramesh Agarwal',
        din: '05012349',
        email: 'ramesh@bharatinfra.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Deepak Singhania',
        din: '06123451',
        email: 'deepak@bharatinfra.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Kavita Deshmukh',
        din: '08345673',
        email: 'kavita@bharatinfra.in',
        isDesignated: false,
      ),
      LLPPartner(
        name: 'Manoj Tiwari',
        din: '09456784',
        email: 'manoj@bharatinfra.in',
        isDesignated: false,
      ),
    ],
    registeredOffice: '401, Bandra Kurla Complex, Mumbai 400051',
    rocJurisdiction: 'ROC Mumbai',
  ),
  LLPEntity(
    id: 'llp-004',
    llpName: 'Pinnacle Legal Advisors LLP',
    llpin: 'AAE-3367',
    incorporationDate: DateTime(2021, 4, 1),
    turnover: 3200000,
    capitalContribution: 1500000,
    isAuditRequired: false,
    designatedPartners: const [
      LLPPartner(
        name: 'Adv. Sanjay Mishra',
        din: '08345674',
        email: 'sanjay@pinnaclelaw.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Adv. Neeta Kulkarni',
        din: '09456785',
        email: 'neeta@pinnaclelaw.in',
        isDesignated: true,
      ),
    ],
    registeredOffice: '22, MG Road, Pune 411001',
    rocJurisdiction: 'ROC Pune',
  ),
  LLPEntity(
    id: 'llp-005',
    llpName: 'Dakshin Exports LLP',
    llpin: 'AAF-5590',
    incorporationDate: DateTime(2019, 11, 18),
    turnover: 28000000,
    capitalContribution: 8000000,
    isAuditRequired: true,
    designatedPartners: const [
      LLPPartner(
        name: 'Venkatesh Rao',
        din: '06123452',
        email: 'venkatesh@dakshinexports.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Lakshmi Sundaram',
        din: '07234562',
        email: 'lakshmi@dakshinexports.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Arun Mohan',
        din: '08345675',
        email: 'arun@dakshinexports.in',
        isDesignated: false,
      ),
    ],
    registeredOffice: '18, Anna Salai, Chennai 600002',
    rocJurisdiction: 'ROC Chennai',
  ),
  LLPEntity(
    id: 'llp-006',
    llpName: 'NorthStar Ventures LLP',
    llpin: 'AAG-8812',
    incorporationDate: DateTime(2023, 8, 5),
    turnover: 1800000,
    capitalContribution: 800000,
    isAuditRequired: false,
    designatedPartners: const [
      LLPPartner(
        name: 'Harpreet Singh',
        din: '09456786',
        email: 'harpreet@northstarllp.in',
        isDesignated: true,
      ),
      LLPPartner(
        name: 'Amrita Kaur',
        din: '10567897',
        email: 'amrita@northstarllp.in',
        isDesignated: true,
      ),
    ],
    registeredOffice: '7, Sector 17, Chandigarh 160017',
    rocJurisdiction: 'ROC Chandigarh',
  ),
];

// ---------------------------------------------------------------------------
// Mock LLP filings (18: Form 11, Form 8, ITR-5 for each)
// ---------------------------------------------------------------------------

final _mockFilings = <LLPFiling>[
  // Sharma & Gupta
  LLPFiling(
    id: 'lf-001',
    llpId: 'llp-001',
    llpName: 'Sharma & Gupta Associates LLP',
    formType: LLPFormType.form11,
    dueDate: DateTime(2025, 5, 30),
    filedDate: DateTime(2025, 5, 25),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Rakesh Verma',
  ),
  LLPFiling(
    id: 'lf-002',
    llpId: 'llp-001',
    llpName: 'Sharma & Gupta Associates LLP',
    formType: LLPFormType.form8,
    dueDate: DateTime(2025, 10, 30),
    filedDate: DateTime(2025, 10, 28),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Rakesh Verma',
  ),
  LLPFiling(
    id: 'lf-003',
    llpId: 'llp-001',
    llpName: 'Sharma & Gupta Associates LLP',
    formType: LLPFormType.itr5,
    dueDate: DateTime(2025, 10, 31),
    filedDate: DateTime(2025, 10, 29),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Rakesh Verma',
  ),
  // TechBridge
  LLPFiling(
    id: 'lf-004',
    llpId: 'llp-002',
    llpName: 'TechBridge Consulting LLP',
    formType: LLPFormType.form11,
    dueDate: DateTime(2025, 5, 30),
    filedDate: DateTime(2025, 5, 28),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Meena Rao',
  ),
  LLPFiling(
    id: 'lf-005',
    llpId: 'llp-002',
    llpName: 'TechBridge Consulting LLP',
    formType: LLPFormType.form8,
    dueDate: DateTime(2025, 10, 30),
    status: LLPFilingStatus.overdue,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 13100,
    certifyingProfessional: 'CA Meena Rao',
  ),
  LLPFiling(
    id: 'lf-006',
    llpId: 'llp-002',
    llpName: 'TechBridge Consulting LLP',
    formType: LLPFormType.itr5,
    dueDate: DateTime(2025, 10, 31),
    status: LLPFilingStatus.overdue,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 13000,
  ),
  // Bharat Infrastructure
  LLPFiling(
    id: 'lf-007',
    llpId: 'llp-003',
    llpName: 'Bharat Infrastructure LLP',
    formType: LLPFormType.form11,
    dueDate: DateTime(2025, 5, 30),
    filedDate: DateTime(2025, 5, 20),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Deepika Shah',
  ),
  LLPFiling(
    id: 'lf-008',
    llpId: 'llp-003',
    llpName: 'Bharat Infrastructure LLP',
    formType: LLPFormType.form8,
    dueDate: DateTime(2025, 10, 30),
    filedDate: DateTime(2025, 10, 22),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Deepika Shah',
  ),
  LLPFiling(
    id: 'lf-009',
    llpId: 'llp-003',
    llpName: 'Bharat Infrastructure LLP',
    formType: LLPFormType.itr5,
    dueDate: DateTime(2025, 10, 31),
    filedDate: DateTime(2025, 10, 30),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Deepika Shah',
  ),
  // Pinnacle Legal
  LLPFiling(
    id: 'lf-010',
    llpId: 'llp-004',
    llpName: 'Pinnacle Legal Advisors LLP',
    formType: LLPFormType.form11,
    dueDate: DateTime(2025, 5, 30),
    status: LLPFilingStatus.overdue,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 28500,
  ),
  LLPFiling(
    id: 'lf-011',
    llpId: 'llp-004',
    llpName: 'Pinnacle Legal Advisors LLP',
    formType: LLPFormType.form8,
    dueDate: DateTime(2025, 10, 30),
    status: LLPFilingStatus.pending,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
  ),
  LLPFiling(
    id: 'lf-012',
    llpId: 'llp-004',
    llpName: 'Pinnacle Legal Advisors LLP',
    formType: LLPFormType.itr5,
    dueDate: DateTime(2026, 7, 31),
    status: LLPFilingStatus.pending,
    financialYear: '2025-26',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
  ),
  // Dakshin Exports
  LLPFiling(
    id: 'lf-013',
    llpId: 'llp-005',
    llpName: 'Dakshin Exports LLP',
    formType: LLPFormType.form11,
    dueDate: DateTime(2025, 5, 30),
    filedDate: DateTime(2025, 5, 29),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Srinivasan K',
  ),
  LLPFiling(
    id: 'lf-014',
    llpId: 'llp-005',
    llpName: 'Dakshin Exports LLP',
    formType: LLPFormType.form8,
    dueDate: DateTime(2025, 10, 30),
    status: LLPFilingStatus.overdue,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 13100,
  ),
  LLPFiling(
    id: 'lf-015',
    llpId: 'llp-005',
    llpName: 'Dakshin Exports LLP',
    formType: LLPFormType.itr5,
    dueDate: DateTime(2025, 10, 31),
    filedDate: DateTime(2025, 10, 30),
    status: LLPFilingStatus.filed,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
    certifyingProfessional: 'CA Srinivasan K',
  ),
  // NorthStar Ventures
  LLPFiling(
    id: 'lf-016',
    llpId: 'llp-006',
    llpName: 'NorthStar Ventures LLP',
    formType: LLPFormType.form11,
    dueDate: DateTime(2025, 5, 30),
    status: LLPFilingStatus.overdue,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 28500,
  ),
  LLPFiling(
    id: 'lf-017',
    llpId: 'llp-006',
    llpName: 'NorthStar Ventures LLP',
    formType: LLPFormType.form8,
    dueDate: DateTime(2025, 10, 30),
    status: LLPFilingStatus.pending,
    financialYear: '2024-25',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
  ),
  LLPFiling(
    id: 'lf-018',
    llpId: 'llp-006',
    llpName: 'NorthStar Ventures LLP',
    formType: LLPFormType.itr5,
    dueDate: DateTime(2026, 7, 31),
    status: LLPFilingStatus.pending,
    financialYear: '2025-26',
    penaltyPerDay: 100,
    maxPenalty: 100000,
    currentPenalty: 0,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All LLP entities.
final llpEntitiesProvider = Provider<List<LLPEntity>>((ref) {
  return List.unmodifiable(_mockLLPs);
});

/// All LLP filings.
final llpFilingsProvider = Provider<List<LLPFiling>>((ref) {
  return List.unmodifiable(_mockFilings);
});

/// Selected LLP filter. Null means all LLPs.
final selectedLLPFilterProvider =
    NotifierProvider<SelectedLLPFilterNotifier, String?>(
        SelectedLLPFilterNotifier.new);

class SelectedLLPFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected form type filter. Null means all types.
final selectedLLPFormTypeProvider =
    NotifierProvider<SelectedLLPFormTypeNotifier, LLPFormType?>(
        SelectedLLPFormTypeNotifier.new);

class SelectedLLPFormTypeNotifier extends Notifier<LLPFormType?> {
  @override
  LLPFormType? build() => null;

  void update(LLPFormType? value) => state = value;
}

/// Selected financial year filter.
final selectedLLPFYProvider =
    NotifierProvider<SelectedLLPFYNotifier, String>(
        SelectedLLPFYNotifier.new);

class SelectedLLPFYNotifier extends Notifier<String> {
  @override
  String build() => '2024-25';

  void update(String value) => state = value;
}

/// Currently selected tab index on the LLP screen.
final selectedLLPTabProvider =
    NotifierProvider<SelectedLLPTabNotifier, int>(
        SelectedLLPTabNotifier.new);

class SelectedLLPTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Available financial years.
final llpFinancialYearsProvider = Provider<List<String>>((ref) {
  return const ['2023-24', '2024-25', '2025-26'];
});

/// Filings filtered by LLP, form type, and FY.
final filteredLLPFilingsProvider = Provider<List<LLPFiling>>((ref) {
  final all = ref.watch(llpFilingsProvider);
  final llpId = ref.watch(selectedLLPFilterProvider);
  final formType = ref.watch(selectedLLPFormTypeProvider);
  final fy = ref.watch(selectedLLPFYProvider);

  return List.unmodifiable(
    all.where((f) {
      final matchesLlp = llpId == null || f.llpId == llpId;
      final matchesForm = formType == null || f.formType == formType;
      final matchesFy = f.financialYear == fy;
      return matchesLlp && matchesForm && matchesFy;
    }),
  );
});

/// LLPs that require audit (turnover > 40L or contribution > 25L).
final auditRequiredLLPsProvider = Provider<List<LLPEntity>>((ref) {
  final all = ref.watch(llpEntitiesProvider);
  return List.unmodifiable(all.where((e) => e.isAuditRequired));
});

/// Total penalty exposure across all overdue filings.
final totalPenaltyExposureProvider = Provider<int>((ref) {
  final filings = ref.watch(llpFilingsProvider);
  return filings
      .where((f) => f.status == LLPFilingStatus.overdue)
      .fold<int>(0, (sum, f) => sum + f.currentPenalty);
});

/// Summary statistics for the LLP compliance dashboard.
final llpComplianceSummaryProvider = Provider<LLPComplianceSummary>((ref) {
  final entities = ref.watch(llpEntitiesProvider);
  final filings = ref.watch(llpFilingsProvider);

  final auditRequired = entities.where((e) => e.isAuditRequired).length;
  final filed =
      filings.where((f) => f.status == LLPFilingStatus.filed).length;
  final overdue =
      filings.where((f) => f.status == LLPFilingStatus.overdue).length;
  final pending =
      filings.where((f) => f.status == LLPFilingStatus.pending).length;
  final totalPenalty = filings
      .where((f) => f.status == LLPFilingStatus.overdue)
      .fold<int>(0, (sum, f) => sum + f.currentPenalty);

  return LLPComplianceSummary(
    totalLLPs: entities.length,
    auditRequired: auditRequired,
    filedCount: filed,
    overdueCount: overdue,
    pendingCount: pending,
    totalPenaltyExposure: totalPenalty,
  );
});

/// Immutable summary data for dashboard cards.
class LLPComplianceSummary {
  const LLPComplianceSummary({
    required this.totalLLPs,
    required this.auditRequired,
    required this.filedCount,
    required this.overdueCount,
    required this.pendingCount,
    required this.totalPenaltyExposure,
  });

  final int totalLLPs;
  final int auditRequired;
  final int filedCount;
  final int overdueCount;
  final int pendingCount;
  final int totalPenaltyExposure;
}

// ---------------------------------------------------------------------------
// Mock LlpFilingRecords (8)
// ---------------------------------------------------------------------------

final _mockLlpFilingRecords = <LlpFilingRecord>[
  LlpFilingRecord(
    id: 'lfr-001',
    llpName: 'Sharma & Gupta Associates LLP',
    llpin: 'AAB-4521',
    form11DaysLate: 0,
    form8DaysLate: 0,
    turnoverLakhs: 75,
    contributionLakhs: 30,
    form11Status: LLPFilingStatus.filed,
    form8Status: LLPFilingStatus.filed,
    yearsSinceLastFiling: 0,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-002',
    llpName: 'TechBridge Consulting LLP',
    llpin: 'AAC-7832',
    form11DaysLate: 0,
    form8DaysLate: 131,
    turnoverLakhs: 125,
    contributionLakhs: 50,
    form11Status: LLPFilingStatus.filed,
    form8Status: LLPFilingStatus.overdue,
    yearsSinceLastFiling: 0,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-003',
    llpName: 'Bharat Infrastructure LLP',
    llpin: 'AAD-1245',
    form11DaysLate: 0,
    form8DaysLate: 0,
    turnoverLakhs: 450,
    contributionLakhs: 150,
    form11Status: LLPFilingStatus.filed,
    form8Status: LLPFilingStatus.filed,
    yearsSinceLastFiling: 0,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-004',
    llpName: 'Pinnacle Legal Advisors LLP',
    llpin: 'AAE-3367',
    form11DaysLate: 285,
    form8DaysLate: 0,
    turnoverLakhs: 32,
    contributionLakhs: 15,
    form11Status: LLPFilingStatus.overdue,
    form8Status: LLPFilingStatus.pending,
    yearsSinceLastFiling: 1,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-005',
    llpName: 'Dakshin Exports LLP',
    llpin: 'AAF-5590',
    form11DaysLate: 0,
    form8DaysLate: 131,
    turnoverLakhs: 280,
    contributionLakhs: 80,
    form11Status: LLPFilingStatus.filed,
    form8Status: LLPFilingStatus.overdue,
    yearsSinceLastFiling: 0,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-006',
    llpName: 'NorthStar Ventures LLP',
    llpin: 'AAG-8812',
    form11DaysLate: 285,
    form8DaysLate: 0,
    turnoverLakhs: 18,
    contributionLakhs: 8,
    form11Status: LLPFilingStatus.overdue,
    form8Status: LLPFilingStatus.pending,
    yearsSinceLastFiling: 2,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-007',
    llpName: 'Sunrise Agro LLP',
    llpin: 'AAH-2234',
    form11DaysLate: 420,
    form8DaysLate: 182,
    turnoverLakhs: 60,
    contributionLakhs: 20,
    form11Status: LLPFilingStatus.overdue,
    form8Status: LLPFilingStatus.overdue,
    yearsSinceLastFiling: 3,
    assessmentYear: 'AY 2025-26',
  ),
  LlpFilingRecord(
    id: 'lfr-008',
    llpName: 'Metro Logistics LLP',
    llpin: 'AAI-9901',
    form11DaysLate: 0,
    form8DaysLate: 45,
    turnoverLakhs: 95,
    contributionLakhs: 35,
    form11Status: LLPFilingStatus.filed,
    form8Status: LLPFilingStatus.overdue,
    yearsSinceLastFiling: 0,
    assessmentYear: 'AY 2025-26',
  ),
];

// ---------------------------------------------------------------------------
// New providers
// ---------------------------------------------------------------------------

/// All LlpFilingRecords.
final allLlpFilingsProvider = Provider<List<LlpFilingRecord>>((ref) {
  return List.unmodifiable(_mockLlpFilingRecords);
});

/// Penalty summary: total penalty, overdue count, strike-off risk count.
final llpPenaltySummaryProvider = Provider<LlpPenaltySummary>((ref) {
  final records = ref.watch(allLlpFilingsProvider);
  final totalPenalty = records.fold<double>(
    0,
    (sum, r) => sum + r.totalPenalty,
  );
  final overdueCount = records
      .where(
        (r) =>
            r.form11Status == LLPFilingStatus.overdue ||
            r.form8Status == LLPFilingStatus.overdue,
      )
      .length;
  final strikeOffCount =
      records.where((r) => r.hasStrikeOffRisk).length;
  return LlpPenaltySummary(
    totalPenalty: totalPenalty,
    overdueCount: overdueCount,
    strikeOffRiskCount: strikeOffCount,
  );
});

/// Immutable penalty summary for the banner.
class LlpPenaltySummary {
  const LlpPenaltySummary({
    required this.totalPenalty,
    required this.overdueCount,
    required this.strikeOffRiskCount,
  });

  final double totalPenalty;
  final int overdueCount;
  final int strikeOffRiskCount;
}

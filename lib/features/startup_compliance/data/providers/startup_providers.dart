import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_calculator.dart';

export 'package:ca_app/features/startup_compliance/domain/models/startup_calculator.dart';

// ---------------------------------------------------------------------------
// Mock startups (5 realistic Indian startups)
// ---------------------------------------------------------------------------

final _mockStartups = <StartupEntity>[
  StartupEntity(
    id: 'su-001',
    entityName: 'NovaPay Fintech Pvt Ltd',
    dpiitNumber: 'DIPP12345',
    incorporationDate: DateTime(2021, 3, 15),
    sector: 'Fintech',
    turnover: 45000000,
    isBelow100Cr: true,
    section80IACStatus: Section80IACStatus.approved,
    taxHolidayStartYear: 2022,
    taxHolidayEndYear: 2025,
    recognitionStatus: RecognitionStatus.recognized,
    investmentRounds: [
      InvestmentRound(
        roundName: 'Seed',
        amount: 5000000,
        date: DateTime(2021, 6, 1),
        investor: 'AngelList India',
      ),
      InvestmentRound(
        roundName: 'Series A',
        amount: 80000000,
        date: DateTime(2023, 2, 15),
        investor: 'Sequoia Capital India',
      ),
    ],
  ),
  StartupEntity(
    id: 'su-002',
    entityName: 'KisanMitra AgriTech Pvt Ltd',
    dpiitNumber: 'DIPP23456',
    incorporationDate: DateTime(2022, 7, 20),
    sector: 'AgriTech',
    turnover: 18000000,
    isBelow100Cr: true,
    section80IACStatus: Section80IACStatus.applied,
    taxHolidayStartYear: null,
    taxHolidayEndYear: null,
    recognitionStatus: RecognitionStatus.recognized,
    investmentRounds: [
      InvestmentRound(
        roundName: 'Pre-Seed',
        amount: 2000000,
        date: DateTime(2022, 10, 5),
        investor: 'Agri Fund India',
      ),
    ],
  ),
  StartupEntity(
    id: 'su-003',
    entityName: 'MedVault HealthTech Pvt Ltd',
    dpiitNumber: 'DIPP34567',
    incorporationDate: DateTime(2020, 1, 10),
    sector: 'HealthTech',
    turnover: 92000000,
    isBelow100Cr: true,
    section80IACStatus: Section80IACStatus.approved,
    taxHolidayStartYear: 2021,
    taxHolidayEndYear: 2024,
    recognitionStatus: RecognitionStatus.recognized,
    investmentRounds: [
      InvestmentRound(
        roundName: 'Seed',
        amount: 10000000,
        date: DateTime(2020, 5, 20),
        investor: 'HealthQuad',
      ),
      InvestmentRound(
        roundName: 'Series A',
        amount: 150000000,
        date: DateTime(2022, 8, 12),
        investor: 'Lightspeed Venture',
      ),
      InvestmentRound(
        roundName: 'Series B',
        amount: 400000000,
        date: DateTime(2024, 3, 1),
        investor: 'Tiger Global',
      ),
    ],
  ),
  StartupEntity(
    id: 'su-004',
    entityName: 'UrbanCraft D2C Pvt Ltd',
    dpiitNumber: 'DIPP45678',
    incorporationDate: DateTime(2023, 11, 5),
    sector: 'E-Commerce / D2C',
    turnover: 6500000,
    isBelow100Cr: true,
    section80IACStatus: Section80IACStatus.eligible,
    taxHolidayStartYear: null,
    taxHolidayEndYear: null,
    recognitionStatus: RecognitionStatus.pending,
    investmentRounds: const [],
  ),
  StartupEntity(
    id: 'su-005',
    entityName: 'GreenGrid CleanTech Pvt Ltd',
    dpiitNumber: 'DIPP56789',
    incorporationDate: DateTime(2019, 5, 25),
    sector: 'CleanTech / Energy',
    turnover: 125000000,
    isBelow100Cr: false,
    section80IACStatus: Section80IACStatus.expired,
    taxHolidayStartYear: 2020,
    taxHolidayEndYear: 2023,
    recognitionStatus: RecognitionStatus.expired,
    investmentRounds: [
      InvestmentRound(
        roundName: 'Seed',
        amount: 8000000,
        date: DateTime(2019, 9, 10),
        investor: 'Clean Energy Fund',
      ),
      InvestmentRound(
        roundName: 'Series A',
        amount: 200000000,
        date: DateTime(2021, 4, 22),
        investor: 'Omnivore Partners',
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock filings (15 across 5 startups)
// ---------------------------------------------------------------------------

final _mockFilings = <StartupFiling>[
  // NovaPay
  StartupFiling(
    id: 'sf-001',
    startupId: 'su-001',
    entityName: 'NovaPay Fintech Pvt Ltd',
    filingType: StartupFilingType.annualReturn,
    dueDate: DateTime(2025, 11, 30),
    filedDate: DateTime(2025, 11, 20),
    status: StartupFilingStatus.filed,
  ),
  StartupFiling(
    id: 'sf-002',
    startupId: 'su-001',
    entityName: 'NovaPay Fintech Pvt Ltd',
    filingType: StartupFilingType.form56,
    dueDate: DateTime(2026, 3, 31),
    status: StartupFilingStatus.pending,
    remarks: 'Required for 80-IAC benefit claim',
  ),
  StartupFiling(
    id: 'sf-003',
    startupId: 'su-001',
    entityName: 'NovaPay Fintech Pvt Ltd',
    filingType: StartupFilingType.itr,
    dueDate: DateTime(2025, 10, 31),
    filedDate: DateTime(2025, 10, 28),
    status: StartupFilingStatus.filed,
  ),
  // KisanMitra
  StartupFiling(
    id: 'sf-004',
    startupId: 'su-002',
    entityName: 'KisanMitra AgriTech Pvt Ltd',
    filingType: StartupFilingType.annualReturn,
    dueDate: DateTime(2025, 11, 30),
    status: StartupFilingStatus.pending,
  ),
  StartupFiling(
    id: 'sf-005',
    startupId: 'su-002',
    entityName: 'KisanMitra AgriTech Pvt Ltd',
    filingType: StartupFilingType.dpiitUpdate,
    dueDate: DateTime(2025, 9, 30),
    status: StartupFilingStatus.overdue,
    remarks: 'DPIIT annual update not submitted',
  ),
  StartupFiling(
    id: 'sf-006',
    startupId: 'su-002',
    entityName: 'KisanMitra AgriTech Pvt Ltd',
    filingType: StartupFilingType.gst,
    dueDate: DateTime(2026, 1, 20),
    status: StartupFilingStatus.pending,
  ),
  // MedVault
  StartupFiling(
    id: 'sf-007',
    startupId: 'su-003',
    entityName: 'MedVault HealthTech Pvt Ltd',
    filingType: StartupFilingType.annualReturn,
    dueDate: DateTime(2025, 11, 30),
    filedDate: DateTime(2025, 11, 15),
    status: StartupFilingStatus.filed,
  ),
  StartupFiling(
    id: 'sf-008',
    startupId: 'su-003',
    entityName: 'MedVault HealthTech Pvt Ltd',
    filingType: StartupFilingType.boardMeetingMinutes,
    dueDate: DateTime(2025, 12, 31),
    status: StartupFilingStatus.pending,
    remarks: 'Q3 board meeting minutes pending',
  ),
  StartupFiling(
    id: 'sf-009',
    startupId: 'su-003',
    entityName: 'MedVault HealthTech Pvt Ltd',
    filingType: StartupFilingType.itr,
    dueDate: DateTime(2025, 10, 31),
    filedDate: DateTime(2025, 10, 25),
    status: StartupFilingStatus.filed,
  ),
  // UrbanCraft
  StartupFiling(
    id: 'sf-010',
    startupId: 'su-004',
    entityName: 'UrbanCraft D2C Pvt Ltd',
    filingType: StartupFilingType.annualReturn,
    dueDate: DateTime(2025, 11, 30),
    status: StartupFilingStatus.overdue,
    remarks: 'First annual return — needs guidance',
  ),
  StartupFiling(
    id: 'sf-011',
    startupId: 'su-004',
    entityName: 'UrbanCraft D2C Pvt Ltd',
    filingType: StartupFilingType.gst,
    dueDate: DateTime(2026, 1, 20),
    status: StartupFilingStatus.notApplicable,
    remarks: 'Below GST threshold',
  ),
  StartupFiling(
    id: 'sf-012',
    startupId: 'su-004',
    entityName: 'UrbanCraft D2C Pvt Ltd',
    filingType: StartupFilingType.dpiitUpdate,
    dueDate: DateTime(2026, 3, 31),
    status: StartupFilingStatus.pending,
  ),
  // GreenGrid
  StartupFiling(
    id: 'sf-013',
    startupId: 'su-005',
    entityName: 'GreenGrid CleanTech Pvt Ltd',
    filingType: StartupFilingType.annualReturn,
    dueDate: DateTime(2025, 11, 30),
    filedDate: DateTime(2025, 11, 28),
    status: StartupFilingStatus.filed,
  ),
  StartupFiling(
    id: 'sf-014',
    startupId: 'su-005',
    entityName: 'GreenGrid CleanTech Pvt Ltd',
    filingType: StartupFilingType.itr,
    dueDate: DateTime(2025, 10, 31),
    status: StartupFilingStatus.overdue,
    remarks: 'Tax holiday expired — standard filing required',
  ),
  StartupFiling(
    id: 'sf-015',
    startupId: 'su-005',
    entityName: 'GreenGrid CleanTech Pvt Ltd',
    filingType: StartupFilingType.boardMeetingMinutes,
    dueDate: DateTime(2025, 12, 31),
    status: StartupFilingStatus.pending,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All startup entities.
final startupEntitiesProvider = Provider<List<StartupEntity>>((ref) {
  return List.unmodifiable(_mockStartups);
});

/// All startup filings.
final startupFilingsProvider = Provider<List<StartupFiling>>((ref) {
  return List.unmodifiable(_mockFilings);
});

/// Selected startup filter. Null means all startups.
final selectedStartupFilterProvider =
    NotifierProvider<SelectedStartupFilterNotifier, String?>(
      SelectedStartupFilterNotifier.new,
    );

class SelectedStartupFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected filing type filter. Null means all types.
final selectedStartupFilingTypeProvider =
    NotifierProvider<SelectedStartupFilingTypeNotifier, StartupFilingType?>(
      SelectedStartupFilingTypeNotifier.new,
    );

class SelectedStartupFilingTypeNotifier extends Notifier<StartupFilingType?> {
  @override
  StartupFilingType? build() => null;

  void update(StartupFilingType? value) => state = value;
}

/// Selected recognition status filter. Null means all.
final selectedRecognitionStatusProvider =
    NotifierProvider<SelectedRecognitionStatusNotifier, RecognitionStatus?>(
      SelectedRecognitionStatusNotifier.new,
    );

class SelectedRecognitionStatusNotifier extends Notifier<RecognitionStatus?> {
  @override
  RecognitionStatus? build() => null;

  void update(RecognitionStatus? value) => state = value;
}

/// Currently selected tab index on the startup screen.
final selectedStartupTabProvider =
    NotifierProvider<SelectedStartupTabNotifier, int>(
      SelectedStartupTabNotifier.new,
    );

class SelectedStartupTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

/// Startups filtered by recognition status.
final filteredStartupsProvider = Provider<List<StartupEntity>>((ref) {
  final all = ref.watch(startupEntitiesProvider);
  final status = ref.watch(selectedRecognitionStatusProvider);

  if (status == null) return all;
  return List.unmodifiable(all.where((s) => s.recognitionStatus == status));
});

/// Filings filtered by startup and filing type.
final filteredStartupFilingsProvider = Provider<List<StartupFiling>>((ref) {
  final all = ref.watch(startupFilingsProvider);
  final startupId = ref.watch(selectedStartupFilterProvider);
  final filingType = ref.watch(selectedStartupFilingTypeProvider);

  return List.unmodifiable(
    all.where((f) {
      final matchesStartup = startupId == null || f.startupId == startupId;
      final matchesType = filingType == null || f.filingType == filingType;
      return matchesStartup && matchesType;
    }),
  );
});

/// Upcoming filings sorted by due date (pending only).
final upcomingStartupFilingsProvider = Provider<List<StartupFiling>>((ref) {
  final all = ref.watch(startupFilingsProvider);
  final pending =
      all
          .where(
            (f) =>
                f.status == StartupFilingStatus.pending ||
                f.status == StartupFilingStatus.overdue,
          )
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return List.unmodifiable(pending);
});

/// Summary counts for the startup compliance dashboard.
final startupComplianceSummaryProvider = Provider<StartupComplianceSummary>((
  ref,
) {
  final startups = ref.watch(startupEntitiesProvider);
  final filings = ref.watch(startupFilingsProvider);

  final recognized = startups.where(
    (s) => s.recognitionStatus == RecognitionStatus.recognized,
  );
  final overdue = filings.where((f) => f.status == StartupFilingStatus.overdue);
  final pending = filings.where((f) => f.status == StartupFilingStatus.pending);
  final filed = filings.where((f) => f.status == StartupFilingStatus.filed);

  return StartupComplianceSummary(
    totalStartups: startups.length,
    recognizedCount: recognized.length,
    overdueFilings: overdue.length,
    pendingFilings: pending.length,
    filedCount: filed.length,
  );
});

/// Immutable summary data for dashboard cards.
class StartupComplianceSummary {
  const StartupComplianceSummary({
    required this.totalStartups,
    required this.recognizedCount,
    required this.overdueFilings,
    required this.pendingFilings,
    required this.filedCount,
  });

  final int totalStartups;
  final int recognizedCount;
  final int overdueFilings;
  final int pendingFilings;
  final int filedCount;
}

// ---------------------------------------------------------------------------
// Mock StartupProfiles (8)
// ---------------------------------------------------------------------------

final _mockStartupProfiles = <StartupProfile>[
  StartupProfile(
    id: 'sp-001',
    name: 'NovaPay Fintech Pvt Ltd',
    cin: 'U74999MH2021PTC123456',
    sectorVertical: 'Fintech',
    incorporationYear: 2021,
    isDpiitRecognized: true,
    has80IacCertificate: true,
    annualTurnoverCrore: 4.5,
    currentYearProfit: 1.2,
    raisedFundingCrore: 8.5,
    esopPoolPercent: 10,
    founderPercent: 55,
    investorPercent: 35,
    status: StartupStatus.active,
  ),
  StartupProfile(
    id: 'sp-002',
    name: 'KisanMitra AgriTech Pvt Ltd',
    cin: 'U01400DL2022PTC234567',
    sectorVertical: 'AgriTech',
    incorporationYear: 2022,
    isDpiitRecognized: true,
    has80IacCertificate: false,
    annualTurnoverCrore: 1.8,
    currentYearProfit: 0.3,
    raisedFundingCrore: 0.2,
    esopPoolPercent: 5,
    founderPercent: 80,
    investorPercent: 15,
    status: StartupStatus.fundingRound,
  ),
  StartupProfile(
    id: 'sp-003',
    name: 'MedVault HealthTech Pvt Ltd',
    cin: 'U85100KA2020PTC345678',
    sectorVertical: 'HealthTech',
    incorporationYear: 2020,
    isDpiitRecognized: true,
    has80IacCertificate: true,
    annualTurnoverCrore: 9.2,
    currentYearProfit: 2.4,
    raisedFundingCrore: 56.0,
    esopPoolPercent: 12,
    founderPercent: 35,
    investorPercent: 53,
    status: StartupStatus.active,
  ),
  StartupProfile(
    id: 'sp-004',
    name: 'UrbanCraft D2C Pvt Ltd',
    cin: 'U52100MH2023PTC456789',
    sectorVertical: 'E-Commerce / D2C',
    incorporationYear: 2023,
    isDpiitRecognized: false,
    has80IacCertificate: false,
    annualTurnoverCrore: 0.65,
    currentYearProfit: 0.05,
    raisedFundingCrore: 0.0,
    esopPoolPercent: 0,
    founderPercent: 100,
    investorPercent: 0,
    status: StartupStatus.active,
  ),
  StartupProfile(
    id: 'sp-005',
    name: 'GreenGrid CleanTech Pvt Ltd',
    cin: 'U40100TN2019PTC567890',
    sectorVertical: 'CleanTech / Energy',
    incorporationYear: 2019,
    isDpiitRecognized: false,
    has80IacCertificate: false,
    annualTurnoverCrore: 12.5,
    currentYearProfit: 1.8,
    raisedFundingCrore: 20.8,
    esopPoolPercent: 8,
    founderPercent: 28,
    investorPercent: 64,
    status: StartupStatus.exited,
  ),
  StartupProfile(
    id: 'sp-006',
    name: 'EduSpark EdTech Pvt Ltd',
    cin: 'U80301DL2021PTC678901',
    sectorVertical: 'EdTech',
    incorporationYear: 2021,
    isDpiitRecognized: true,
    has80IacCertificate: false,
    annualTurnoverCrore: 3.1,
    currentYearProfit: 0.6,
    raisedFundingCrore: 4.0,
    esopPoolPercent: 8,
    founderPercent: 60,
    investorPercent: 32,
    status: StartupStatus.active,
  ),
  StartupProfile(
    id: 'sp-007',
    name: 'SafeVault SaaS Pvt Ltd',
    cin: 'U72200KA2022PTC789012',
    sectorVertical: 'SaaS / Cybersecurity',
    incorporationYear: 2022,
    isDpiitRecognized: true,
    has80IacCertificate: true,
    annualTurnoverCrore: 5.5,
    currentYearProfit: 1.5,
    raisedFundingCrore: 12.0,
    esopPoolPercent: 15,
    founderPercent: 45,
    investorPercent: 40,
    status: StartupStatus.fundingRound,
  ),
  StartupProfile(
    id: 'sp-008',
    name: 'LogiFlow Supply Pvt Ltd',
    cin: 'U63090MH2020PTC890123',
    sectorVertical: 'Logistics / Supply Chain',
    incorporationYear: 2020,
    isDpiitRecognized: true,
    has80IacCertificate: true,
    annualTurnoverCrore: 7.8,
    currentYearProfit: 0.9,
    raisedFundingCrore: 9.5,
    esopPoolPercent: 10,
    founderPercent: 50,
    investorPercent: 40,
    status: StartupStatus.active,
  ),
];

// ---------------------------------------------------------------------------
// New providers
// ---------------------------------------------------------------------------

/// All startup profiles.
final startupProfilesProvider = Provider<List<StartupProfile>>((ref) {
  return List.unmodifiable(_mockStartupProfiles);
});

/// Aggregated 80-IAC / DPIIT summary across all startup profiles.
final startupIacSummaryProvider = Provider<StartupIacSummary>((ref) {
  final profiles = ref.watch(startupProfilesProvider);
  final total80Iac = profiles.fold<double>(
    0,
    (sum, p) => sum + p.deduction80IACCrore,
  );
  final totalTaxSaving = profiles.fold<double>(
    0,
    (sum, p) => sum + p.taxSavingCrore,
  );
  final recognizedCount = profiles.where((p) => p.isDpiitRecognized).length;
  return StartupIacSummary(
    total80IacDeductionCrore: total80Iac,
    totalTaxSavingCrore: totalTaxSaving,
    dpiitRecognizedCount: recognizedCount,
    totalStartups: profiles.length,
  );
});

/// Immutable 80-IAC / DPIIT summary for the banner.
class StartupIacSummary {
  const StartupIacSummary({
    required this.total80IacDeductionCrore,
    required this.totalTaxSavingCrore,
    required this.dpiitRecognizedCount,
    required this.totalStartups,
  });

  final double total80IacDeductionCrore;
  final double totalTaxSavingCrore;
  final int dpiitRecognizedCount;
  final int totalStartups;
}

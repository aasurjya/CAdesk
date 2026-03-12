import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/startup/domain/models/angel_tax_computation.dart';
import 'package:ca_app/features/startup/domain/services/angel_tax_service.dart';
import 'package:ca_app/features/startup/domain/services/section80iac_service.dart';

// ---------------------------------------------------------------------------
// Startup entity model (presentation-layer DTO)
// ---------------------------------------------------------------------------

/// DPIIT registration status.
enum DpiitStatus {
  registered,
  pending,
  notApplied,
}

/// Status of 80-IAC application.
enum Iac80Status {
  approved,
  applied,
  notEligible,
  notApplied,
}

/// Immutable model for a startup entity used in the presentation layer.
class StartupEntity {
  const StartupEntity({
    required this.id,
    required this.name,
    required this.cin,
    required this.pan,
    required this.incorporationDate,
    required this.entityType,
    required this.dpiitNumber,
    required this.dpiitStatus,
    required this.iac80Status,
    required this.netProfitPaise,
    required this.financialYears80IACApplied,
    required this.lastFundingIssuePricePaise,
    required this.lastFundingFmvPaise,
    required this.lastFundingAmountRaisedPaise,
  });

  final String id;
  final String name;
  final String cin;
  final String pan;
  final DateTime incorporationDate;
  final StartupEntityType entityType;
  final String dpiitNumber;
  final DpiitStatus dpiitStatus;
  final Iac80Status iac80Status;
  final int netProfitPaise;
  final List<int> financialYears80IACApplied;

  /// Latest funding round data for angel tax computation.
  final int lastFundingIssuePricePaise;
  final int lastFundingFmvPaise;
  final int lastFundingAmountRaisedPaise;
}

// ---------------------------------------------------------------------------
// Mock data — 3 startups
// ---------------------------------------------------------------------------

final _mockStartups = List<StartupEntity>.unmodifiable([
  StartupEntity(
    id: 'startup-001',
    name: 'NovaTech AI Pvt Ltd',
    cin: 'U72200MH2020PTC123456',
    pan: 'AABCN1234A',
    incorporationDate: DateTime(2020, 6, 15),
    entityType: StartupEntityType.company,
    dpiitNumber: 'DIPP12345',
    dpiitStatus: DpiitStatus.registered,
    iac80Status: Iac80Status.approved,
    netProfitPaise: 4500000 * 100, // 45 lakh
    financialYears80IACApplied: const [2024, 2025],
    lastFundingIssuePricePaise: 50000, // 500 per share
    lastFundingFmvPaise: 35000, // 350 FMV
    lastFundingAmountRaisedPaise: 200000000 * 100, // 20 Cr
  ),
  StartupEntity(
    id: 'startup-002',
    name: 'GreenWave Energy LLP',
    cin: 'AAJ-2345',
    pan: 'AABFG5678B',
    incorporationDate: DateTime(2022, 1, 10),
    entityType: StartupEntityType.llp,
    dpiitNumber: 'DIPP67890',
    dpiitStatus: DpiitStatus.registered,
    iac80Status: Iac80Status.applied,
    netProfitPaise: 1200000 * 100, // 12 lakh
    financialYears80IACApplied: const [],
    lastFundingIssuePricePaise: 0,
    lastFundingFmvPaise: 0,
    lastFundingAmountRaisedPaise: 0,
  ),
  StartupEntity(
    id: 'startup-003',
    name: 'UrbanBite Foods Pvt Ltd',
    cin: 'U56100DL2019PTC345678',
    pan: 'AABCU9012C',
    incorporationDate: DateTime(2019, 3, 22),
    entityType: StartupEntityType.company,
    dpiitNumber: '',
    dpiitStatus: DpiitStatus.notApplied,
    iac80Status: Iac80Status.notEligible,
    netProfitPaise: 800000 * 100, // 8 lakh
    financialYears80IACApplied: const [],
    lastFundingIssuePricePaise: 20000, // 200 per share
    lastFundingFmvPaise: 15000, // 150 FMV
    lastFundingAmountRaisedPaise: 50000000 * 100, // 5 Cr
  ),
]);

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All startups list.
final startupListProvider =
    NotifierProvider<StartupListNotifier, List<StartupEntity>>(
      StartupListNotifier.new,
    );

class StartupListNotifier extends Notifier<List<StartupEntity>> {
  @override
  List<StartupEntity> build() => _mockStartups;
}

/// Selected startup for detail screen.
final selectedStartupIdProvider =
    NotifierProvider<SelectedStartupIdNotifier, String>(
      SelectedStartupIdNotifier.new,
    );

class SelectedStartupIdNotifier extends Notifier<String> {
  @override
  String build() => _mockStartups.first.id;

  void select(String id) => state = id;
}

/// Current startup entity derived from selected ID.
final selectedStartupProvider = Provider<StartupEntity>((ref) {
  final id = ref.watch(selectedStartupIdProvider);
  final list = ref.watch(startupListProvider);
  return list.firstWhere(
    (s) => s.id == id,
    orElse: () => list.first,
  );
});

/// 80-IAC deduction computation for the selected startup.
final startup80IACDeductionProvider = Provider<int>((ref) {
  final startup = ref.watch(selectedStartupProvider);
  final data = StartupData(
    name: startup.name,
    pan: startup.pan,
    dpiitNumber: startup.dpiitNumber,
    incorporationDate: startup.incorporationDate,
    entityType: startup.entityType,
    netProfitPaise: startup.netProfitPaise,
    financialYears80IACApplied: startup.financialYears80IACApplied,
  );
  return Section80IACService.instance.computeDeduction(data, 2026);
});

/// Angel tax computation for the selected startup.
final startupAngelTaxProvider = Provider<AngelTaxComputation?>((ref) {
  final startup = ref.watch(selectedStartupProvider);
  if (startup.lastFundingIssuePricePaise == 0) return null;

  final isExempt = AngelTaxService.instance.isDpiitExempt(
    startup.dpiitNumber,
  );
  final input = AngelTaxInput(
    issuePricePaise: startup.lastFundingIssuePricePaise,
    fairMarketValuePaise: startup.lastFundingFmvPaise,
    amountRaisedPaise: startup.lastFundingAmountRaisedPaise,
    exemptionApplied: isExempt,
  );
  return AngelTaxService.instance.computeAngelTax(input);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/nri_client.dart';
import '../../domain/models/foreign_asset.dart';

// ---------------------------------------------------------------------------
// Mock data – NRI Clients (Indian diaspora across 8 countries)
// ---------------------------------------------------------------------------

final List<NriClient> _mockNriClients = [
  NriClient(
    id: 'nri-001',
    name: 'Suresh Krishnamurthy',
    pan: 'ABCPK1234A',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'USA',
    stayDaysIndia: 45,
    foreignIncome: 8500000,
    indianIncome: 1200000,
    dtaaApplicable: true,
    status: NriClientStatus.filingDue,
  ),
  NriClient(
    id: 'nri-002',
    name: 'Ananya Patel',
    pan: 'DEFPA5678B',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'UK',
    stayDaysIndia: 60,
    foreignIncome: 5200000,
    indianIncome: 950000,
    dtaaApplicable: true,
    status: NriClientStatus.pendingDocuments,
  ),
  NriClient(
    id: 'nri-003',
    name: 'Rajiv Malhotra',
    pan: 'GHIMR9012C',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'UAE',
    stayDaysIndia: 80,
    foreignIncome: 3800000,
    indianIncome: 2100000,
    dtaaApplicable: false,
    status: NriClientStatus.active,
  ),
  NriClient(
    id: 'nri-004',
    name: 'Preethi Subramanian',
    pan: 'JKLPS3456D',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'Canada',
    stayDaysIndia: 30,
    foreignIncome: 6700000,
    indianIncome: 450000,
    dtaaApplicable: true,
    status: NriClientStatus.completed,
  ),
  NriClient(
    id: 'nri-005',
    name: 'Vikram Chandra',
    pan: 'MNOVC7890E',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'Singapore',
    stayDaysIndia: 55,
    foreignIncome: 12400000,
    indianIncome: 3300000,
    dtaaApplicable: true,
    status: NriClientStatus.filingDue,
  ),
  NriClient(
    id: 'nri-006',
    name: 'Meenakshi Rajan',
    pan: 'PQRMR2345F',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'Australia',
    stayDaysIndia: 70,
    foreignIncome: 4100000,
    indianIncome: 780000,
    dtaaApplicable: true,
    status: NriClientStatus.pendingDocuments,
  ),
  NriClient(
    id: 'nri-007',
    name: 'Deepak Iyer',
    pan: 'STUDI6789G',
    residentialStatus: ResidentialStatus.rnor,
    countryOfResidence: 'Germany',
    stayDaysIndia: 135,
    foreignIncome: 7800000,
    indianIncome: 1850000,
    dtaaApplicable: true,
    status: NriClientStatus.active,
  ),
  NriClient(
    id: 'nri-008',
    name: 'Kavitha Nambiar',
    pan: 'VWXKN0123H',
    residentialStatus: ResidentialStatus.nri,
    countryOfResidence: 'USA',
    stayDaysIndia: 20,
    foreignIncome: 9900000,
    indianIncome: 600000,
    dtaaApplicable: true,
    status: NriClientStatus.active,
  ),
];

// ---------------------------------------------------------------------------
// Mock data – Foreign Assets (10 assets across clients)
// ---------------------------------------------------------------------------

final List<ForeignAsset> _mockForeignAssets = [
  ForeignAsset(
    id: 'fa-001',
    clientId: 'nri-001',
    clientName: 'Suresh Krishnamurthy',
    assetType: ForeignAssetType.equity,
    country: 'USA',
    valueInr: 6500000,
    incomeFromAsset: 320000,
    scheduleFARequired: true,
    reportedInItr: false,
  ),
  ForeignAsset(
    id: 'fa-002',
    clientId: 'nri-001',
    clientName: 'Suresh Krishnamurthy',
    assetType: ForeignAssetType.bankAccount,
    country: 'USA',
    valueInr: 1800000,
    incomeFromAsset: 45000,
    scheduleFARequired: true,
    reportedInItr: true,
  ),
  ForeignAsset(
    id: 'fa-003',
    clientId: 'nri-002',
    clientName: 'Ananya Patel',
    assetType: ForeignAssetType.property,
    country: 'UK',
    valueInr: 28000000,
    incomeFromAsset: 960000,
    scheduleFARequired: true,
    reportedInItr: false,
  ),
  ForeignAsset(
    id: 'fa-004',
    clientId: 'nri-003',
    clientName: 'Rajiv Malhotra',
    assetType: ForeignAssetType.bankAccount,
    country: 'UAE',
    valueInr: 2200000,
    scheduleFARequired: true,
    reportedInItr: true,
  ),
  ForeignAsset(
    id: 'fa-005',
    clientId: 'nri-004',
    clientName: 'Preethi Subramanian',
    assetType: ForeignAssetType.retirementFund,
    country: 'Canada',
    valueInr: 4800000,
    incomeFromAsset: 180000,
    scheduleFARequired: true,
    reportedInItr: true,
  ),
  ForeignAsset(
    id: 'fa-006',
    clientId: 'nri-005',
    clientName: 'Vikram Chandra',
    assetType: ForeignAssetType.equity,
    country: 'Singapore',
    valueInr: 9600000,
    incomeFromAsset: 740000,
    scheduleFARequired: true,
    reportedInItr: false,
  ),
  ForeignAsset(
    id: 'fa-007',
    clientId: 'nri-005',
    clientName: 'Vikram Chandra',
    assetType: ForeignAssetType.bonds,
    country: 'Singapore',
    valueInr: 3100000,
    incomeFromAsset: 248000,
    scheduleFARequired: true,
    reportedInItr: true,
  ),
  ForeignAsset(
    id: 'fa-008',
    clientId: 'nri-006',
    clientName: 'Meenakshi Rajan',
    assetType: ForeignAssetType.property,
    country: 'Australia',
    valueInr: 15500000,
    incomeFromAsset: 520000,
    scheduleFARequired: true,
    reportedInItr: false,
  ),
  ForeignAsset(
    id: 'fa-009',
    clientId: 'nri-007',
    clientName: 'Deepak Iyer',
    assetType: ForeignAssetType.bankAccount,
    country: 'Germany',
    valueInr: 950000,
    scheduleFARequired: false,
    reportedInItr: true,
  ),
  ForeignAsset(
    id: 'fa-010',
    clientId: 'nri-008',
    clientName: 'Kavitha Nambiar',
    assetType: ForeignAssetType.otherAsset,
    country: 'USA',
    valueInr: 2700000,
    incomeFromAsset: 90000,
    scheduleFARequired: true,
    reportedInItr: false,
  ),
];

// ---------------------------------------------------------------------------
// Notifiers
// ---------------------------------------------------------------------------

class NriClientsNotifier extends Notifier<List<NriClient>> {
  @override
  List<NriClient> build() => List.unmodifiable(_mockNriClients);
}

class ForeignAssetsNotifier extends Notifier<List<ForeignAsset>> {
  @override
  List<ForeignAsset> build() => List.unmodifiable(_mockForeignAssets);
}

class NriStatusFilterNotifier extends Notifier<NriClientStatus?> {
  @override
  NriClientStatus? build() => null;

  void update(NriClientStatus? value) => state = value;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All NRI clients.
final allNriClientsProvider =
    NotifierProvider<NriClientsNotifier, List<NriClient>>(
  NriClientsNotifier.new,
);

/// All foreign assets.
final allForeignAssetsProvider =
    NotifierProvider<ForeignAssetsNotifier, List<ForeignAsset>>(
  ForeignAssetsNotifier.new,
);

/// Selected NRI client status filter; null means show all.
final nriStatusFilterProvider =
    NotifierProvider<NriStatusFilterNotifier, NriClientStatus?>(
  NriStatusFilterNotifier.new,
);

/// NRI clients filtered by the selected status.
final filteredNriClientsProvider = Provider<List<NriClient>>((ref) {
  final status = ref.watch(nriStatusFilterProvider);
  final allClients = ref.watch(allNriClientsProvider);
  if (status == null) return allClients;
  return allClients.where((c) => c.status == status).toList();
});

/// Summary statistics for the NRI Tax Desk.
final nriSummaryProvider = Provider<Map<String, int>>((ref) {
  final clients = ref.watch(allNriClientsProvider);
  return {
    'totalClients': clients.length,
    'dtaaApplicable': clients.where((c) => c.dtaaApplicable).length,
    'pendingDocuments':
        clients.where((c) => c.status == NriClientStatus.pendingDocuments).length,
    'filingDue':
        clients.where((c) => c.status == NriClientStatus.filingDue).length,
  };
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/clients/data/providers/client_repository_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/domain/repositories/client_repository.dart';

// ---------------------------------------------------------------------------
// ClientHealthScore model
// ---------------------------------------------------------------------------

/// Computed compliance health for a client based on their services.
class ClientHealthScore {
  const ClientHealthScore({
    required this.clientId,
    required this.overallScore,
    required this.itrStatus,
    required this.gstStatus,
    required this.tdsStatus,
    required this.pendingActions,
    required this.lastUpdated,
  });

  final String clientId;

  /// Compliance score 0–100.
  final int overallScore;

  /// 'Filed', 'Pending', 'Overdue', 'N/A'
  final String itrStatus;

  /// 'Compliant', 'Returns Pending', 'Late Filed', 'N/A'
  final String gstStatus;

  /// 'Compliant', 'Challan Due', 'N/A'
  final String tdsStatus;

  /// Actionable items outstanding for this client.
  final List<String> pendingActions;

  /// Human-readable month+year label, e.g. "Mar 2026".
  final String lastUpdated;

  /// Color grade: >=80 Healthy, >=60 Attention, <60 Critical.
  String get grade => overallScore >= 80
      ? 'Healthy'
      : overallScore >= 60
      ? 'Attention'
      : 'Critical';

  ClientHealthScore copyWith({
    String? clientId,
    int? overallScore,
    String? itrStatus,
    String? gstStatus,
    String? tdsStatus,
    List<String>? pendingActions,
    String? lastUpdated,
  }) {
    return ClientHealthScore(
      clientId: clientId ?? this.clientId,
      overallScore: overallScore ?? this.overallScore,
      itrStatus: itrStatus ?? this.itrStatus,
      gstStatus: gstStatus ?? this.gstStatus,
      tdsStatus: tdsStatus ?? this.tdsStatus,
      pendingActions: pendingActions ?? this.pendingActions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// ---------------------------------------------------------------------------
// Mock health scores
// ---------------------------------------------------------------------------

final _mockHealthScores = <String, ClientHealthScore>{
  // Rajesh Kumar Sharma — individual, ITR+GST
  '1': ClientHealthScore(
    clientId: '1',
    overallScore: 92,
    itrStatus: 'Filed',
    gstStatus: 'Compliant',
    tdsStatus: 'N/A',
    pendingActions: const ['Upload Form 16 for AY 2026-27'],
    lastUpdated: 'Mar 2026',
  ),
  // Priya Mehta — individual, ITR only, capital gains pending
  '2': ClientHealthScore(
    clientId: '2',
    overallScore: 78,
    itrStatus: 'Pending',
    gstStatus: 'N/A',
    tdsStatus: 'N/A',
    pendingActions: const [
      'ITR filing due — AY 2026-27',
      'Collect capital gains statement',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // ABC Infra Pvt Ltd — company, multiple services, several items overdue
  '3': ClientHealthScore(
    clientId: '3',
    overallScore: 61,
    itrStatus: 'Pending',
    gstStatus: 'Returns Pending',
    tdsStatus: 'Challan Due',
    pendingActions: const [
      'GSTR-3B Feb 2026 pending',
      'TDS challan due 07 Mar',
      'ITR-6 filing AY 2026-27',
      'ROC Form ADT-1 due',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // Mehta & Sons — firm, ITR+GST+bookkeeping
  '4': ClientHealthScore(
    clientId: '4',
    overallScore: 85,
    itrStatus: 'Filed',
    gstStatus: 'Compliant',
    tdsStatus: 'N/A',
    pendingActions: const ['Reconcile books for Feb 2026'],
    lastUpdated: 'Mar 2026',
  ),
  // Sunita Devi Agarwal — inactive individual, ITR only
  '5': ClientHealthScore(
    clientId: '5',
    overallScore: 55,
    itrStatus: 'Overdue',
    gstStatus: 'N/A',
    tdsStatus: 'N/A',
    pendingActions: const [
      'ITR-1 AY 2025-26 not filed',
      'Collect bank interest certificates',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // TechVista Solutions LLP — ITR+GST+TDS+payroll
  '6': ClientHealthScore(
    clientId: '6',
    overallScore: 88,
    itrStatus: 'Filed',
    gstStatus: 'Compliant',
    tdsStatus: 'Compliant',
    pendingActions: const ['Process Mar 2026 payroll by 31 Mar'],
    lastUpdated: 'Mar 2026',
  ),
  // Anil Gupta HUF — ITR + bookkeeping
  '7': ClientHealthScore(
    clientId: '7',
    overallScore: 80,
    itrStatus: 'Filed',
    gstStatus: 'N/A',
    tdsStatus: 'N/A',
    pendingActions: const ['Update FY 2025-26 books'],
    lastUpdated: 'Mar 2026',
  ),
  // Bharat Electronics Ltd — all services
  '8': ClientHealthScore(
    clientId: '8',
    overallScore: 72,
    itrStatus: 'Pending',
    gstStatus: 'Returns Pending',
    tdsStatus: 'Challan Due',
    pendingActions: const [
      'GSTR-1 Mar 2026 due 11 Apr',
      'TDS Q4 challan due 30 Apr',
      'Finalise FY 2025-26 audit',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // Deepak Patel — individual, ITR+GST
  '9': ClientHealthScore(
    clientId: '9',
    overallScore: 83,
    itrStatus: 'Filed',
    gstStatus: 'Compliant',
    tdsStatus: 'N/A',
    pendingActions: const ['Collect FY 2025-26 P&L statement'],
    lastUpdated: 'Mar 2026',
  ),
  // Sharma Charitable Trust — ITR + audit
  '10': ClientHealthScore(
    clientId: '10',
    overallScore: 90,
    itrStatus: 'Filed',
    gstStatus: 'N/A',
    tdsStatus: 'N/A',
    pendingActions: const ['Renew 12A registration before Jun 2026'],
    lastUpdated: 'Mar 2026',
  ),
  // Kavita Reddy — prospect, ITR+TDS
  '11': ClientHealthScore(
    clientId: '11',
    overallScore: 58,
    itrStatus: 'Pending',
    gstStatus: 'N/A',
    tdsStatus: 'Challan Due',
    pendingActions: const [
      'ITR-4 AY 2026-27 not filed',
      'TDS on professional fees pending',
      'Onboarding KYC documents required',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // Hindustan Traders AOP — ITR+GST+bookkeeping
  '12': ClientHealthScore(
    clientId: '12',
    overallScore: 76,
    itrStatus: 'Pending',
    gstStatus: 'Compliant',
    tdsStatus: 'N/A',
    pendingActions: const [
      'ITR-5 AY 2026-27 pending',
      'Update partner capital accounts',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // GreenLeaf Organics LLP — ITR+GST+TDS
  '13': ClientHealthScore(
    clientId: '13',
    overallScore: 81,
    itrStatus: 'Filed',
    gstStatus: 'Compliant',
    tdsStatus: 'Compliant',
    pendingActions: const ['File GSTR-9 for FY 2024-25'],
    lastUpdated: 'Mar 2026',
  ),
  // Vikram Singh Rathore — individual, ITR+GST+bookkeeping
  '14': ClientHealthScore(
    clientId: '14',
    overallScore: 79,
    itrStatus: 'Pending',
    gstStatus: 'Compliant',
    tdsStatus: 'N/A',
    pendingActions: const [
      'ITR-3 AY 2026-27 pending',
      'Reconcile hotel revenue for Mar 2026',
    ],
    lastUpdated: 'Mar 2026',
  ),
  // Nirmala Textiles Pvt Ltd — inactive, all services
  '15': ClientHealthScore(
    clientId: '15',
    overallScore: 42,
    itrStatus: 'Overdue',
    gstStatus: 'Late Filed',
    tdsStatus: 'Challan Due',
    pendingActions: const [
      'ITR-6 AY 2025-26 overdue',
      'GSTR-3B pending since Jan 2026',
      'TDS default — Q3 FY 2025-26',
      'ROC Annual Return pending',
    ],
    lastUpdated: 'Mar 2026',
  ),
};

/// Returns the [ClientHealthScore] for a given client ID, or null if not found.
final clientHealthScoreProvider = Provider.family<ClientHealthScore?, String>((
  ref,
  clientId,
) {
  return _mockHealthScores[clientId];
});

final mockClients = <Client>[
  Client(
    id: '1',
    name: 'Rajesh Kumar Sharma',
    pan: 'ABCPS1234A',
    aadhaar: '1234 5678 9012',
    email: 'rajesh.sharma@gmail.com',
    phone: '9876543210',
    clientType: ClientType.individual,
    dateOfBirth: DateTime(1975, 6, 15),
    address: '42, MG Road, Bandra West',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400050',
    servicesAvailed: [ServiceType.itrFiling, ServiceType.gstFiling],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2026, 3, 1),
    notes: 'Senior manager at TCS. Files ITR-2 every year.',
  ),
  Client(
    id: '2',
    name: 'Priya Mehta',
    pan: 'BQKPM5678B',
    email: 'priya.mehta@outlook.com',
    phone: '9988776655',
    clientType: ClientType.individual,
    dateOfBirth: DateTime(1988, 11, 22),
    address: '15, Jubilee Hills',
    city: 'Hyderabad',
    state: 'Telangana',
    pincode: '500033',
    servicesAvailed: [ServiceType.itrFiling],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 4, 5),
    updatedAt: DateTime(2026, 2, 20),
    notes: 'Freelance designer. Has capital gains from equity.',
  ),
  Client(
    id: '3',
    name: 'ABC Infra Pvt Ltd',
    pan: 'AABCA1234C',
    email: 'accounts@abcinfra.in',
    phone: '9111222333',
    clientType: ClientType.company,
    dateOfIncorporation: DateTime(2015, 3, 12),
    address: '201, Business Tower, Connaught Place',
    city: 'New Delhi',
    state: 'Delhi',
    pincode: '110001',
    gstin: '07AABCA1234C1Z5',
    tan: 'DELA12345B',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.tds,
      ServiceType.audit,
      ServiceType.roc,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2023, 7, 1),
    updatedAt: DateTime(2026, 3, 5),
    notes: 'Infrastructure company. Turnover above 10 Cr.',
  ),
  Client(
    id: '4',
    name: 'Mehta & Sons',
    pan: 'AAPFM5678D',
    email: 'mehtasons@yahoo.com',
    phone: '9444555666',
    clientType: ClientType.firm,
    address: '78, Ashram Road',
    city: 'Ahmedabad',
    state: 'Gujarat',
    pincode: '380009',
    gstin: '24AAPFM5678D1Z8',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.bookkeeping,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2023, 11, 15),
    updatedAt: DateTime(2026, 2, 28),
    notes: 'Textile trading firm. 3 partners.',
  ),
  Client(
    id: '5',
    name: 'Sunita Devi Agarwal',
    pan: 'CQAPA9012E',
    phone: '9333444555',
    clientType: ClientType.individual,
    dateOfBirth: DateTime(1965, 2, 3),
    address: '12, Civil Lines',
    city: 'Jaipur',
    state: 'Rajasthan',
    pincode: '302006',
    servicesAvailed: [ServiceType.itrFiling],
    status: ClientStatus.inactive,
    createdAt: DateTime(2024, 6, 20),
    updatedAt: DateTime(2025, 8, 10),
    notes: 'Retired teacher. Only rental income.',
  ),
  Client(
    id: '6',
    name: 'TechVista Solutions LLP',
    pan: 'AAFT1234F',
    email: 'finance@techvista.co.in',
    phone: '8055667788',
    clientType: ClientType.llp,
    dateOfIncorporation: DateTime(2019, 8, 1),
    address: '504, Whitefield Tech Park',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560066',
    gstin: '29AAFT1234F1Z2',
    tan: 'BLRT56789A',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.tds,
      ServiceType.payroll,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2023, 9, 10),
    updatedAt: DateTime(2026, 3, 8),
    notes: 'IT services LLP. 25 employees.',
  ),
  Client(
    id: '7',
    name: 'Anil Gupta HUF',
    pan: 'AAHHA5678G',
    phone: '9777888999',
    clientType: ClientType.huf,
    address: '88, Model Town',
    city: 'Ludhiana',
    state: 'Punjab',
    pincode: '141002',
    servicesAvailed: [ServiceType.itrFiling, ServiceType.bookkeeping],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 2, 14),
    updatedAt: DateTime(2026, 1, 30),
    notes: 'HUF with property income and FD interest.',
  ),
  Client(
    id: '8',
    name: 'Bharat Electronics Ltd',
    pan: 'AABCB9012H',
    email: 'tax@bharatelec.com',
    phone: '8022334455',
    clientType: ClientType.company,
    dateOfIncorporation: DateTime(2008, 1, 20),
    address: '12, MIDC Industrial Area, Pimpri',
    city: 'Pune',
    state: 'Maharashtra',
    pincode: '411018',
    gstin: '27AABCB9012H1Z1',
    tan: 'PNEB34567C',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.tds,
      ServiceType.audit,
      ServiceType.roc,
      ServiceType.payroll,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2023, 4, 1),
    updatedAt: DateTime(2026, 3, 9),
    notes: 'Manufacturing company. 200+ employees. Statutory audit.',
  ),
  Client(
    id: '9',
    name: 'Deepak Patel',
    pan: 'DLKPP3456I',
    email: 'deepak.patel@gmail.com',
    phone: '9666777888',
    clientType: ClientType.individual,
    dateOfBirth: DateTime(1992, 9, 8),
    address: '45, SG Highway',
    city: 'Ahmedabad',
    state: 'Gujarat',
    pincode: '380054',
    gstin: '24DLKPP3456I1Z4',
    servicesAvailed: [ServiceType.itrFiling, ServiceType.gstFiling],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 8, 12),
    updatedAt: DateTime(2026, 2, 15),
    notes: 'Freelance consultant. GST registered.',
  ),
  Client(
    id: '10',
    name: 'Sharma Charitable Trust',
    pan: 'AACTS7890J',
    email: 'trust@sharmafoundation.org',
    phone: '7055112233',
    clientType: ClientType.trust,
    dateOfIncorporation: DateTime(2010, 4, 14),
    address: '1, Gandhi Nagar',
    city: 'Lucknow',
    state: 'Uttar Pradesh',
    pincode: '226001',
    servicesAvailed: [ServiceType.itrFiling, ServiceType.audit],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2026, 1, 15),
    notes: 'Registered charitable trust under 12A.',
  ),
  Client(
    id: '11',
    name: 'Kavita Reddy',
    pan: 'BNRPK1234K',
    email: 'kavita.r@yahoo.com',
    phone: '9222333444',
    clientType: ClientType.individual,
    dateOfBirth: DateTime(1980, 12, 1),
    address: '33, Banjara Hills',
    city: 'Hyderabad',
    state: 'Telangana',
    pincode: '500034',
    servicesAvailed: [ServiceType.itrFiling, ServiceType.tds],
    status: ClientStatus.prospect,
    createdAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 1),
    notes: 'Doctor with hospital salary + private practice.',
  ),
  Client(
    id: '12',
    name: 'Hindustan Traders AOP',
    pan: 'AAAHA5678L',
    phone: '8111222333',
    clientType: ClientType.aop,
    address: '22, Chandni Chowk',
    city: 'New Delhi',
    state: 'Delhi',
    pincode: '110006',
    gstin: '07AAAHA5678L1Z9',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.bookkeeping,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 5, 20),
    updatedAt: DateTime(2026, 3, 2),
    notes: 'Association of 5 traders. Wholesale business.',
  ),
  Client(
    id: '13',
    name: 'GreenLeaf Organics LLP',
    pan: 'AAFG9012M',
    email: 'accounts@greenleaf.in',
    phone: '9555666777',
    clientType: ClientType.llp,
    dateOfIncorporation: DateTime(2021, 6, 15),
    address: '10, Electronic City Phase 2',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560100',
    gstin: '29AAFG9012M1Z7',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.tds,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2024, 3, 10),
    updatedAt: DateTime(2026, 3, 7),
    notes: 'Organic food distribution. Growing rapidly.',
  ),
  Client(
    id: '14',
    name: 'Vikram Singh Rathore',
    pan: 'EVQPS3456N',
    email: 'vikram.rathore@gmail.com',
    phone: '9888777666',
    clientType: ClientType.individual,
    dateOfBirth: DateTime(1970, 3, 25),
    address: '55, C-Scheme',
    city: 'Jaipur',
    state: 'Rajasthan',
    pincode: '302001',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.bookkeeping,
    ],
    status: ClientStatus.active,
    createdAt: DateTime(2023, 12, 1),
    updatedAt: DateTime(2026, 2, 25),
    notes: 'Runs a boutique hotel. Multiple income sources.',
  ),
  Client(
    id: '15',
    name: 'Nirmala Textiles Pvt Ltd',
    pan: 'AABCN7890P',
    email: 'finance@nirmalatextiles.com',
    phone: '8444555666',
    clientType: ClientType.company,
    dateOfIncorporation: DateTime(2000, 11, 5),
    address: '35, Ring Road, Surat Textile Market',
    city: 'Surat',
    state: 'Gujarat',
    pincode: '395002',
    gstin: '24AABCN7890P1Z3',
    tan: 'SRTN98765D',
    servicesAvailed: [
      ServiceType.itrFiling,
      ServiceType.gstFiling,
      ServiceType.tds,
      ServiceType.audit,
      ServiceType.roc,
      ServiceType.bookkeeping,
    ],
    status: ClientStatus.inactive,
    createdAt: DateTime(2023, 6, 1),
    updatedAt: DateTime(2025, 12, 31),
    notes: 'Textile manufacturing. Dormant since Dec 2025.',
  ),
];

enum ClientSortOption {
  name('Name'),
  recent('Recent'),
  type('Type');

  const ClientSortOption(this.label);

  final String label;
}

final allClientsProvider =
    AsyncNotifierProvider<AllClientsNotifier, List<Client>>(
      AllClientsNotifier.new,
    );

class AllClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    final repo = ref.watch(clientRepositoryProvider);
    return _fetchAndWatch(repo);
  }

  Future<List<Client>> _fetchAndWatch(ClientRepository repo) async {
    final stream = repo.watchAll();

    // Subscribe to local stream for live updates.
    final sub = stream.listen((clients) {
      if (state.hasValue) {
        state = AsyncData(List.unmodifiable(clients));
      }
    });
    ref.onDispose(sub.cancel);

    // Fetch from remote to populate local cache; fall back to stream on error.
    try {
      return await repo.getAll();
    } catch (_) {
      return stream.first;
    }
  }

  /// Replaces the client with [updated.id] in the state list.
  void updateClient(Client updated) {
    final current = state.asData?.value ?? [];
    final idx = current.indexWhere((c) => c.id == updated.id);
    if (idx == -1) return;
    final next = List<Client>.of(current)..[idx] = updated;
    state = AsyncData(List.unmodifiable(next));
  }

  /// Removes the client with [id] from the state list.
  void removeClient(String id) {
    final current = state.asData?.value ?? [];
    final next = current.where((c) => c.id != id).toList();
    state = AsyncData(List.unmodifiable(next));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clientRepositoryProvider).getAll(),
    );
  }
}

/// Deletes a client by [id] via the repository and updates the client list.
///
/// Returns a [Future] that resolves when the deletion is complete.
final deleteClientProvider = Provider.family<Future<void> Function(), String>((
  ref,
  clientId,
) {
  return () async {
    final repo = ref.read(clientRepositoryProvider);
    await repo.delete(clientId);
    ref.read(allClientsProvider.notifier).removeClient(clientId);
  };
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final selectedStatusFilterProvider =
    NotifierProvider<SelectedStatusFilterNotifier, ClientStatus?>(
      SelectedStatusFilterNotifier.new,
    );

class SelectedStatusFilterNotifier extends Notifier<ClientStatus?> {
  @override
  ClientStatus? build() => null;

  void update(ClientStatus? value) => state = value;
}

final selectedTypeFilterProvider =
    NotifierProvider<SelectedTypeFilterNotifier, ClientType?>(
      SelectedTypeFilterNotifier.new,
    );

class SelectedTypeFilterNotifier extends Notifier<ClientType?> {
  @override
  ClientType? build() => null;

  void update(ClientType? value) => state = value;
}

final sortOptionProvider =
    NotifierProvider<SortOptionNotifier, ClientSortOption>(
      SortOptionNotifier.new,
    );

class SortOptionNotifier extends Notifier<ClientSortOption> {
  @override
  ClientSortOption build() => ClientSortOption.name;

  void update(ClientSortOption value) => state = value;
}

final filteredClientsProvider = Provider<List<Client>>((ref) {
  final clients = ref.watch(allClientsProvider).asData?.value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(selectedStatusFilterProvider);
  final typeFilter = ref.watch(selectedTypeFilterProvider);
  final sortOption = ref.watch(sortOptionProvider);

  var filtered = clients.where((client) {
    if (statusFilter != null && client.status != statusFilter) {
      return false;
    }
    if (typeFilter != null && client.clientType != typeFilter) {
      return false;
    }
    if (query.isNotEmpty) {
      final matchesName = client.name.toLowerCase().contains(query);
      final matchesPan = client.pan.toLowerCase().contains(query);
      final matchesPhone = client.phone?.contains(query) ?? false;
      final matchesEmail = client.email?.toLowerCase().contains(query) ?? false;
      final matchesGstin = client.gstin?.toLowerCase().contains(query) ?? false;
      return matchesName ||
          matchesPan ||
          matchesPhone ||
          matchesEmail ||
          matchesGstin;
    }
    return true;
  }).toList();

  switch (sortOption) {
    case ClientSortOption.name:
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case ClientSortOption.recent:
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    case ClientSortOption.type:
      filtered.sort((a, b) => a.clientType.index.compareTo(b.clientType.index));
  }

  return List.unmodifiable(filtered);
});

final clientByIdProvider = Provider.family<Client?, String>((ref, id) {
  final clients = ref.watch(allClientsProvider).asData?.value ?? [];
  try {
    return clients.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

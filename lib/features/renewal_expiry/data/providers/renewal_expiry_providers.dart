import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/renewal_item.dart';
import '../../domain/models/retainer_contract.dart';

// ---------------------------------------------------------------------------
// Mock data — Renewal Items
// ---------------------------------------------------------------------------

final List<RenewalItem> _mockRenewalItems = [
  RenewalItem(
    id: 'ri-001',
    clientId: 'cl-001',
    clientName: 'Tata Consultancy Services Ltd',
    itemType: RenewalItemType.dscCertificate,
    dueDate: DateTime(2026, 3, 20),
    status: RenewalStatus.dueSoon,
    fee: 2500,
    notes: 'Class 3 DSC for authorized signatory Ratan Singh',
    reminderSentAt: DateTime(2026, 3, 10),
  ),
  RenewalItem(
    id: 'ri-002',
    clientId: 'cl-002',
    clientName: 'Infosys BPM Limited',
    itemType: RenewalItemType.gstRegistration,
    dueDate: DateTime(2026, 4, 30),
    status: RenewalStatus.dueSoon,
    fee: 5000,
    notes: 'Annual GST registration renewal — Karnataka state',
    reminderSentAt: null,
  ),
  RenewalItem(
    id: 'ri-003',
    clientId: 'cl-003',
    clientName: 'Mahindra & Mahindra Ltd',
    itemType: RenewalItemType.trademarkLicense,
    dueDate: DateTime(2026, 2, 28),
    status: RenewalStatus.overdue,
    fee: 18000,
    notes: 'Trademark class 12 — automotive goods',
  ),
  RenewalItem(
    id: 'ri-004',
    clientId: 'cl-004',
    clientName: 'Bajaj Finserv Ltd',
    itemType: RenewalItemType.shopAct,
    dueDate: DateTime(2026, 6, 15),
    status: RenewalStatus.upToDate,
    fee: 3000,
    notes: 'Pune head office shop and establishment license',
  ),
  RenewalItem(
    id: 'ri-005',
    clientId: 'cl-005',
    clientName: 'Wipro Technologies Ltd',
    itemType: RenewalItemType.isoAudit,
    dueDate: DateTime(2026, 1, 31),
    status: RenewalStatus.overdue,
    fee: 45000,
    notes: 'ISO 9001:2015 surveillance audit',
  ),
  RenewalItem(
    id: 'ri-006',
    clientId: 'cl-006',
    clientName: 'HDFC Bank Ltd',
    itemType: RenewalItemType.digitalSignature,
    dueDate: DateTime(2026, 5, 10),
    status: RenewalStatus.upToDate,
    fee: 1800,
    notes: 'Token-based DSC for HDFC treasury team',
    reminderSentAt: null,
  ),
  RenewalItem(
    id: 'ri-007',
    clientId: 'cl-007',
    clientName: 'Godrej Properties Ltd',
    itemType: RenewalItemType.professionalTax,
    dueDate: DateTime(2026, 3, 31),
    status: RenewalStatus.dueSoon,
    fee: 2400,
    notes: 'Maharashtra PT registration for 48 employees',
    reminderSentAt: DateTime(2026, 3, 11),
  ),
  RenewalItem(
    id: 'ri-008',
    clientId: 'cl-008',
    clientName: 'Reliance Retail Ventures',
    itemType: RenewalItemType.gstRegistration,
    dueDate: DateTime(2026, 7, 31),
    status: RenewalStatus.upToDate,
    fee: 5000,
    notes: 'Multi-state GST registration renewal — Maharashtra & UP',
  ),
  RenewalItem(
    id: 'ri-009',
    clientId: 'cl-009',
    clientName: 'Sun Pharmaceutical Industries',
    itemType: RenewalItemType.dscCertificate,
    dueDate: DateTime(2026, 2, 14),
    status: RenewalStatus.renewed,
    fee: 2500,
    renewedDate: DateTime(2026, 2, 10),
    notes: 'Renewed 4 days before expiry — all clear',
  ),
  RenewalItem(
    id: 'ri-010',
    clientId: 'cl-010',
    clientName: 'Adani Ports & SEZ Ltd',
    itemType: RenewalItemType.trademarkLicense,
    dueDate: DateTime(2025, 12, 31),
    status: RenewalStatus.cancelled,
    fee: 20000,
    notes: 'Trademark abandoned on client instruction',
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Retainer Contracts
// ---------------------------------------------------------------------------

final List<RetainerContract> _mockRetainerContracts = [
  RetainerContract(
    id: 'rc-001',
    clientId: 'cl-001',
    clientName: 'Tata Consultancy Services Ltd',
    serviceScope: 'Statutory Audit, Tax Filing & GST Compliance',
    monthlyFee: 85000,
    startDate: DateTime(2025, 4, 1),
    endDate: DateTime(2026, 3, 31),
    autoRenew: true,
    status: RetainerStatus.expiringSoon,
  ),
  RetainerContract(
    id: 'rc-002',
    clientId: 'cl-002',
    clientName: 'Infosys BPM Limited',
    serviceScope: 'Transfer Pricing & FEMA Advisory',
    monthlyFee: 60000,
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2026, 12, 31),
    autoRenew: true,
    status: RetainerStatus.active,
  ),
  RetainerContract(
    id: 'rc-003',
    clientId: 'cl-004',
    clientName: 'Bajaj Finserv Ltd',
    serviceScope: 'Monthly MIS, NBFC Compliance & RBI Reporting',
    monthlyFee: 1,
    startDate: DateTime(2024, 7, 1),
    endDate: DateTime(2026, 1, 31),
    autoRenew: false,
    status: RetainerStatus.expired,
  ),
  RetainerContract(
    id: 'rc-004',
    clientId: 'cl-007',
    clientName: 'Godrej Properties Ltd',
    serviceScope: 'Project Accounts & Tax Audit',
    monthlyFee: 40000,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 12, 31),
    autoRenew: true,
    status: RetainerStatus.active,
  ),
  RetainerContract(
    id: 'rc-005',
    clientId: 'cl-005',
    clientName: 'Wipro Technologies Ltd',
    serviceScope: 'Internal Audit Support & Compliance Review',
    monthlyFee: 55000,
    startDate: DateTime(2025, 10, 1),
    endDate: DateTime(2026, 3, 31),
    autoRenew: false,
    status: RetainerStatus.expiringSoon,
  ),
  RetainerContract(
    id: 'rc-006',
    clientId: 'cl-011',
    clientName: 'Larsen & Toubro Ltd',
    serviceScope: 'Payroll Processing & PF/ESIC Administration',
    monthlyFee: 35000,
    startDate: DateTime(2025, 6, 1),
    endDate: DateTime(2026, 5, 31),
    autoRenew: true,
    status: RetainerStatus.paused,
  ),
];

// ---------------------------------------------------------------------------
// Notifiers
// ---------------------------------------------------------------------------

class AllRenewalItemsNotifier extends Notifier<List<RenewalItem>> {
  @override
  List<RenewalItem> build() => List.unmodifiable(_mockRenewalItems);

  void update(List<RenewalItem> items) => state = List.unmodifiable(items);
}

class AllRetainerContractsNotifier extends Notifier<List<RetainerContract>> {
  @override
  List<RetainerContract> build() => List.unmodifiable(_mockRetainerContracts);

  void update(List<RetainerContract> contracts) =>
      state = List.unmodifiable(contracts);
}

class RenewalStatusFilterNotifier extends Notifier<RenewalStatus?> {
  @override
  RenewalStatus? build() => null;

  void update(RenewalStatus? value) => state = value;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All renewal items.
final allRenewalItemsProvider =
    NotifierProvider<AllRenewalItemsNotifier, List<RenewalItem>>(
      AllRenewalItemsNotifier.new,
    );

/// All retainer contracts.
final allRetainerContractsProvider =
    NotifierProvider<AllRetainerContractsNotifier, List<RetainerContract>>(
      AllRetainerContractsNotifier.new,
    );

/// Selected renewal status filter; null means show all.
final renewalStatusFilterProvider =
    NotifierProvider<RenewalStatusFilterNotifier, RenewalStatus?>(
      RenewalStatusFilterNotifier.new,
    );

/// Renewal items filtered by the selected status.
final filteredRenewalItemsProvider = Provider<List<RenewalItem>>((ref) {
  final status = ref.watch(renewalStatusFilterProvider);
  final all = ref.watch(allRenewalItemsProvider);
  if (status == null) return all;
  return all.where((item) => item.status == status).toList();
});

/// Summary counts for the dashboard cards.
final renewalSummaryProvider = Provider<Map<String, int>>((ref) {
  final all = ref.watch(allRenewalItemsProvider);
  final total = all.length;
  final overdue = all.where((i) => i.status == RenewalStatus.overdue).length;
  final dueSoon = all.where((i) => i.status == RenewalStatus.dueSoon).length;
  final upToDate = all.where((i) => i.status == RenewalStatus.upToDate).length;

  return {
    'total': total,
    'overdue': overdue,
    'dueSoon': dueSoon,
    'upToDate': upToDate,
  };
});

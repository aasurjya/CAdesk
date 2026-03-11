import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/sebi_disclosure.dart';
import '../../domain/models/material_event.dart';

// ---------------------------------------------------------------------------
// Mock data - SEBI Disclosures
// ---------------------------------------------------------------------------

final List<SebiDisclosure> _mockDisclosures = [
  SebiDisclosure(
    id: 'sebi-001',
    clientId: 'cl-301',
    companyName: 'HDFC Bank Ltd',
    disclosureType: DisclosureType.quarterlyFinancial,
    exchange: StockExchange.both,
    dueDate: DateTime(2026, 4, 14),
    status: DisclosureStatus.pending,
    period: 'Q4 FY 2025-26',
    remarks: 'Audited quarterly results awaited',
  ),
  SebiDisclosure(
    id: 'sebi-002',
    clientId: 'cl-302',
    companyName: 'Larsen & Toubro Ltd',
    disclosureType: DisclosureType.corporateGovernance,
    exchange: StockExchange.both,
    dueDate: DateTime(2026, 4, 15),
    status: DisclosureStatus.draft,
    period: 'Q4 FY 2025-26',
    remarks: 'Board composition details pending',
  ),
  SebiDisclosure(
    id: 'sebi-003',
    clientId: 'cl-303',
    companyName: 'Bharti Airtel Ltd',
    disclosureType: DisclosureType.relatedParty,
    exchange: StockExchange.nse,
    dueDate: DateTime(2026, 3, 15),
    filedDate: DateTime(2026, 3, 8),
    status: DisclosureStatus.filed,
    period: 'H2 FY 2025-26',
  ),
  SebiDisclosure(
    id: 'sebi-004',
    clientId: 'cl-304',
    companyName: 'Sun Pharmaceutical Industries Ltd',
    disclosureType: DisclosureType.materialEvent,
    exchange: StockExchange.both,
    dueDate: DateTime(2026, 3, 5),
    status: DisclosureStatus.overdue,
    remarks: 'Acquisition of US subsidiary pending disclosure',
  ),
  SebiDisclosure(
    id: 'sebi-005',
    clientId: 'cl-305',
    companyName: 'Bajaj Finance Ltd',
    disclosureType: DisclosureType.shareholding,
    exchange: StockExchange.bse,
    dueDate: DateTime(2026, 4, 21),
    status: DisclosureStatus.pending,
    period: 'Q4 FY 2025-26',
  ),
  SebiDisclosure(
    id: 'sebi-006',
    clientId: 'cl-306',
    companyName: 'Asian Paints Ltd',
    disclosureType: DisclosureType.quarterlyFinancial,
    exchange: StockExchange.both,
    dueDate: DateTime(2026, 3, 31),
    status: DisclosureStatus.underReview,
    period: 'Q4 FY 2025-26',
    remarks: 'Internal audit review in progress',
  ),
  SebiDisclosure(
    id: 'sebi-007',
    clientId: 'cl-307',
    companyName: 'Titan Company Ltd',
    disclosureType: DisclosureType.corporateGovernance,
    exchange: StockExchange.nse,
    dueDate: DateTime(2026, 3, 20),
    filedDate: DateTime(2026, 3, 18),
    status: DisclosureStatus.filed,
    period: 'Q3 FY 2025-26',
  ),
  SebiDisclosure(
    id: 'sebi-008',
    clientId: 'cl-308',
    companyName: 'Hindustan Unilever Ltd',
    disclosureType: DisclosureType.relatedParty,
    exchange: StockExchange.both,
    dueDate: DateTime(2026, 4, 30),
    status: DisclosureStatus.draft,
    period: 'FY 2025-26',
    remarks: 'Unilever group transactions being compiled',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - Material Events
// ---------------------------------------------------------------------------

final List<MaterialEvent> _mockMaterialEvents = [
  MaterialEvent(
    id: 'me-001',
    clientId: 'cl-304',
    companyName: 'Sun Pharmaceutical Industries Ltd',
    eventType: MaterialEventType.acquisition,
    description:
        'Acquisition of 100% stake in Taro Pharmaceutical Industries '
        'for USD 510 million',
    eventDate: DateTime(2026, 3, 1),
    disclosureDeadline: DateTime(2026, 3, 2),
    isDisclosed: false,
  ),
  MaterialEvent(
    id: 'me-002',
    clientId: 'cl-301',
    companyName: 'HDFC Bank Ltd',
    eventType: MaterialEventType.boardChange,
    description:
        'Appointment of Mr. Rajesh Kumar as Independent Director '
        'effective 1 April 2026',
    eventDate: DateTime(2026, 3, 10),
    disclosureDeadline: DateTime(2026, 3, 11, 18, 0),
    isDisclosed: false,
  ),
  MaterialEvent(
    id: 'me-003',
    clientId: 'cl-305',
    companyName: 'Bajaj Finance Ltd',
    eventType: MaterialEventType.dividend,
    description:
        'Board recommends final dividend of Rs 28 per share '
        'for FY 2025-26',
    eventDate: DateTime(2026, 3, 8),
    disclosureDeadline: DateTime(2026, 3, 9, 12, 0),
    isDisclosed: true,
    filingReference: 'NSE/BSE/2026/BFL/DIV/001',
  ),
  MaterialEvent(
    id: 'me-004',
    clientId: 'cl-306',
    companyName: 'Asian Paints Ltd',
    eventType: MaterialEventType.litigation,
    description:
        'CCI orders investigation into alleged anti-competitive '
        'practices in decorative paints segment',
    eventDate: DateTime(2026, 3, 5),
    disclosureDeadline: DateTime(2026, 3, 6),
    isDisclosed: true,
    filingReference: 'NSE/2026/ASIANPAINT/LIT/002',
  ),
  MaterialEvent(
    id: 'me-005',
    clientId: 'cl-303',
    companyName: 'Bharti Airtel Ltd',
    eventType: MaterialEventType.restructuring,
    description:
        'Demerger of Airtel Digital business into wholly owned subsidiary '
        'Airtel Digital Ltd',
    eventDate: DateTime(2026, 3, 12),
    disclosureDeadline: DateTime(2026, 3, 13, 18, 0),
    isDisclosed: false,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All SEBI disclosures.
final sebiDisclosuresProvider = Provider<List<SebiDisclosure>>(
  (_) => List.unmodifiable(_mockDisclosures),
);

/// All material events.
final materialEventsProvider = Provider<List<MaterialEvent>>(
  (_) => List.unmodifiable(_mockMaterialEvents),
);

/// Selected disclosure status filter.
final disclosureStatusFilterProvider =
    NotifierProvider<DisclosureStatusFilterNotifier, DisclosureStatus?>(
        DisclosureStatusFilterNotifier.new);

class DisclosureStatusFilterNotifier extends Notifier<DisclosureStatus?> {
  @override
  DisclosureStatus? build() => null;

  void update(DisclosureStatus? value) => state = value;
}

/// Selected material event type filter.
final materialEventTypeFilterProvider =
    NotifierProvider<MaterialEventTypeFilterNotifier, MaterialEventType?>(
        MaterialEventTypeFilterNotifier.new);

class MaterialEventTypeFilterNotifier extends Notifier<MaterialEventType?> {
  @override
  MaterialEventType? build() => null;

  void update(MaterialEventType? value) => state = value;
}

/// Disclosures filtered by selected status.
final filteredDisclosuresProvider = Provider<List<SebiDisclosure>>((ref) {
  final status = ref.watch(disclosureStatusFilterProvider);
  final all = ref.watch(sebiDisclosuresProvider);
  if (status == null) return all;
  return all.where((d) => d.status == status).toList();
});

/// Material events filtered by selected type.
final filteredMaterialEventsProvider = Provider<List<MaterialEvent>>((ref) {
  final type = ref.watch(materialEventTypeFilterProvider);
  final all = ref.watch(materialEventsProvider);
  if (type == null) return all;
  return all.where((e) => e.eventType == type).toList();
});

/// SEBI summary statistics.
final sebiSummaryProvider = Provider<SebiSummary>((ref) {
  final disclosures = ref.watch(sebiDisclosuresProvider);
  final events = ref.watch(materialEventsProvider);
  final now = DateTime(2026, 3, 10);

  final totalDisclosures = disclosures.length;
  final pendingDisclosures = disclosures
      .where((d) =>
          d.status == DisclosureStatus.pending ||
          d.status == DisclosureStatus.draft)
      .length;
  final overdueDisclosures =
      disclosures.where((d) => d.status == DisclosureStatus.overdue).length;
  final undisclosedEvents =
      events.where((e) => !e.isDisclosed).length;
  final urgentEvents =
      events.where((e) => !e.isDisclosed && e.hoursUntilDeadline(now) < 48)
          .length;

  return SebiSummary(
    totalDisclosures: totalDisclosures,
    pendingDisclosures: pendingDisclosures,
    overdueDisclosures: overdueDisclosures,
    undisclosedEvents: undisclosedEvents,
    urgentEvents: urgentEvents,
  );
});

/// Simple immutable summary data class.
class SebiSummary {
  const SebiSummary({
    required this.totalDisclosures,
    required this.pendingDisclosures,
    required this.overdueDisclosures,
    required this.undisclosedEvents,
    required this.urgentEvents,
  });

  final int totalDisclosures;
  final int pendingDisclosures;
  final int overdueDisclosures;
  final int undisclosedEvents;
  final int urgentEvents;
}

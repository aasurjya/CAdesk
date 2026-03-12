import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/post_filing/domain/models/demand_tracker.dart';
import 'package:ca_app/features/post_filing/domain/models/filing_status.dart';
import 'package:ca_app/features/post_filing/domain/models/filing_status_transition.dart';
import 'package:ca_app/features/post_filing/domain/models/refund_tracker.dart';
import 'package:ca_app/features/post_filing/domain/services/demand_tracking_service.dart';
import 'package:ca_app/features/post_filing/domain/services/itr_status_tracker.dart';
import 'package:ca_app/features/post_filing/domain/services/refund_tracking_service.dart';

// ---------------------------------------------------------------------------
// Filter
// ---------------------------------------------------------------------------

/// Filter options for the post-filing dashboard.
enum PostFilingFilter {
  all('All'),
  itr('ITR'),
  gst('GST'),
  tds('TDS'),
  refundPending('Refund Pending'),
  demands('Demands');

  const PostFilingFilter(this.label);
  final String label;
}

final postFilingFilterProvider =
    NotifierProvider<PostFilingFilterNotifier, PostFilingFilter>(
      PostFilingFilterNotifier.new,
    );

class PostFilingFilterNotifier extends Notifier<PostFilingFilter> {
  @override
  PostFilingFilter build() => PostFilingFilter.all;

  void select(PostFilingFilter value) => state = value;
}

// ---------------------------------------------------------------------------
// Selected filing
// ---------------------------------------------------------------------------

final selectedFilingIndexProvider =
    NotifierProvider<SelectedFilingIndexNotifier, int?>(
      SelectedFilingIndexNotifier.new,
    );

class SelectedFilingIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int index) => state = index;

  void clear() => state = null;
}

// ---------------------------------------------------------------------------
// Filing status list — 8 mock records
// ---------------------------------------------------------------------------

final filingStatusListProvider =
    NotifierProvider<FilingStatusListNotifier, List<FilingStatus>>(
      FilingStatusListNotifier.new,
    );

class FilingStatusListNotifier extends Notifier<List<FilingStatus>> {
  @override
  List<FilingStatus> build() => List.unmodifiable(_mockFilings);
}

// ---------------------------------------------------------------------------
// Refund tracker list
// ---------------------------------------------------------------------------

final refundTrackerListProvider =
    NotifierProvider<RefundTrackerListNotifier, List<RefundTracker>>(
      RefundTrackerListNotifier.new,
    );

class RefundTrackerListNotifier extends Notifier<List<RefundTracker>> {
  @override
  List<RefundTracker> build() => List.unmodifiable(_mockRefunds);
}

// ---------------------------------------------------------------------------
// Demand tracker list
// ---------------------------------------------------------------------------

final demandTrackerListProvider =
    NotifierProvider<DemandTrackerListNotifier, List<DemandTracker>>(
      DemandTrackerListNotifier.new,
    );

class DemandTrackerListNotifier extends Notifier<List<DemandTracker>> {
  @override
  List<DemandTracker> build() => List.unmodifiable(_mockDemands);
}

// ---------------------------------------------------------------------------
// Derived / computed providers
// ---------------------------------------------------------------------------

/// Filings filtered by the current [PostFilingFilter].
final filteredFilingsProvider = Provider<List<FilingStatus>>((ref) {
  final filter = ref.watch(postFilingFilterProvider);
  final filings = ref.watch(filingStatusListProvider);

  switch (filter) {
    case PostFilingFilter.all:
      return filings;
    case PostFilingFilter.itr:
      return filings
          .where((f) => f.filingType == FilingType.itr)
          .toList(growable: false);
    case PostFilingFilter.gst:
      return filings
          .where((f) => f.filingType == FilingType.gst)
          .toList(growable: false);
    case PostFilingFilter.tds:
      return filings
          .where((f) => f.filingType == FilingType.tds)
          .toList(growable: false);
    case PostFilingFilter.refundPending:
      return filings
          .where((f) => f.currentState == FilingState.refundInitiated)
          .toList(growable: false);
    case PostFilingFilter.demands:
      return filings
          .where((f) => f.currentState == FilingState.demandRaised)
          .toList(growable: false);
  }
});

/// Summary counts for the dashboard cards.
final filingsSummaryProvider = Provider<FilingsSummary>((ref) {
  final filings = ref.watch(filingStatusListProvider);
  final totalFiled = filings.length;
  final processed = filings
      .where(
        (f) =>
            f.currentState == FilingState.processed ||
            f.currentState == FilingState.refundInitiated ||
            f.currentState == FilingState.demandRaised ||
            f.currentState == FilingState.intimationIssued,
      )
      .length;
  final refundPending = filings
      .where((f) => f.currentState == FilingState.refundInitiated)
      .length;
  final demands = filings
      .where((f) => f.currentState == FilingState.demandRaised)
      .length;

  return FilingsSummary(
    totalFiled: totalFiled,
    processed: processed,
    refundPending: refundPending,
    demands: demands,
  );
});

/// Refund summary totals (in paise).
final refundSummaryProvider = Provider<RefundSummary>((ref) {
  final refunds = ref.watch(refundTrackerListProvider);
  final totalExpected = refunds.fold<int>(0, (sum, r) => sum + r.refundAmount);
  final received = refunds
      .where((r) => r.status == RefundTrackerStatus.issued)
      .fold<int>(0, (sum, r) => sum + r.refundAmount);
  final pending = totalExpected - received;

  return RefundSummary(
    totalExpected: totalExpected,
    received: received,
    pending: pending,
  );
});

/// Total outstanding demand (in paise).
final totalOutstandingDemandProvider = Provider<int>((ref) {
  final demands = ref.watch(demandTrackerListProvider);
  return DemandTrackingService.instance.runtimeType == DemandTrackingService
      ? demands.fold<int>(0, (sum, d) => sum + d.outstandingAmount)
      : 0;
});

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

final itrStatusTrackerProvider = Provider<ItrStatusTracker>(
  (_) => ItrStatusTracker.instance,
);

final demandTrackingServiceProvider = Provider<DemandTrackingService>(
  (_) => DemandTrackingService.instance,
);

final refundTrackingServiceProvider = Provider<RefundTrackingService>(
  (_) => RefundTrackingService.instance,
);

// ---------------------------------------------------------------------------
// Value objects
// ---------------------------------------------------------------------------

class FilingsSummary {
  const FilingsSummary({
    required this.totalFiled,
    required this.processed,
    required this.refundPending,
    required this.demands,
  });

  final int totalFiled;
  final int processed;
  final int refundPending;
  final int demands;
}

class RefundSummary {
  const RefundSummary({
    required this.totalExpected,
    required this.received,
    required this.pending,
  });

  final int totalExpected;
  final int received;
  final int pending;
}

// ---------------------------------------------------------------------------
// Mock data — 8 filing status records
// ---------------------------------------------------------------------------

final _mockFilings = <FilingStatus>[
  FilingStatus(
    filingId: 'PF-001',
    filingType: FilingType.itr,
    pan: 'ABCDE1234F',
    period: '2024-25',
    submittedAt: DateTime(2025, 7, 15),
    currentState: FilingState.processed,
    acknowledgementNumber: 'ITR-V-ACK-2025-001',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 7, 15),
        reason: 'ITR-1 filed for AY 2024-25',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.eVerificationPending,
        transitionedAt: DateTime(2025, 7, 15),
        reason: 'ITR-V generated',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerificationPending,
        toState: FilingState.eVerified,
        transitionedAt: DateTime(2025, 7, 16),
        reason: 'E-verified via Aadhaar OTP',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerified,
        toState: FilingState.processing,
        transitionedAt: DateTime(2025, 8, 1),
        reason: 'Picked up by CPC',
      ),
      FilingStatusTransition(
        fromState: FilingState.processing,
        toState: FilingState.processed,
        transitionedAt: DateTime(2025, 9, 10),
        reason: 'CPC processing complete',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-002',
    filingType: FilingType.itr,
    pan: 'FGHIJ5678K',
    period: '2024-25',
    submittedAt: DateTime(2025, 7, 20),
    currentState: FilingState.refundInitiated,
    acknowledgementNumber: 'ITR-V-ACK-2025-002',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 7, 20),
        reason: 'ITR-4 filed for AY 2024-25',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.eVerificationPending,
        transitionedAt: DateTime(2025, 7, 20),
        reason: 'ITR-V generated',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerificationPending,
        toState: FilingState.eVerified,
        transitionedAt: DateTime(2025, 7, 21),
        reason: 'E-verified via net banking',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerified,
        toState: FilingState.processing,
        transitionedAt: DateTime(2025, 8, 5),
        reason: 'Picked up by CPC',
      ),
      FilingStatusTransition(
        fromState: FilingState.processing,
        toState: FilingState.processed,
        transitionedAt: DateTime(2025, 9, 15),
        reason: 'CPC processing complete',
      ),
      FilingStatusTransition(
        fromState: FilingState.processed,
        toState: FilingState.refundInitiated,
        transitionedAt: DateTime(2025, 9, 20),
        reason: 'Refund of Rs 45,000 initiated',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-003',
    filingType: FilingType.itr,
    pan: 'KLMNO9012P',
    period: '2024-25',
    submittedAt: DateTime(2025, 7, 25),
    currentState: FilingState.demandRaised,
    acknowledgementNumber: 'ITR-V-ACK-2025-003',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 7, 25),
        reason: 'ITR-2 filed for AY 2024-25',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.eVerificationPending,
        transitionedAt: DateTime(2025, 7, 25),
        reason: 'ITR-V generated',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerificationPending,
        toState: FilingState.eVerified,
        transitionedAt: DateTime(2025, 7, 26),
        reason: 'E-verified via Aadhaar OTP',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerified,
        toState: FilingState.processing,
        transitionedAt: DateTime(2025, 8, 10),
        reason: 'Picked up by CPC',
      ),
      FilingStatusTransition(
        fromState: FilingState.processing,
        toState: FilingState.processed,
        transitionedAt: DateTime(2025, 10, 1),
        reason: 'CPC processing complete',
      ),
      FilingStatusTransition(
        fromState: FilingState.processed,
        toState: FilingState.demandRaised,
        transitionedAt: DateTime(2025, 10, 5),
        reason: 'Demand of Rs 1,20,000 raised u/s 143(1)',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-004',
    filingType: FilingType.gst,
    pan: '27ABCDE1234F1Z5',
    period: '032025',
    submittedAt: DateTime(2025, 4, 11),
    currentState: FilingState.processed,
    acknowledgementNumber: 'GSTR3B-ARN-2025-004',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 4, 11),
        reason: 'GSTR-3B filed for March 2025',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.processed,
        transitionedAt: DateTime(2025, 4, 20),
        reason: 'GSTN processed successfully',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-005',
    filingType: FilingType.gst,
    pan: '29FGHIJ5678K1Z3',
    period: '032025',
    submittedAt: DateTime(2025, 4, 10),
    currentState: FilingState.submitted,
    acknowledgementNumber: 'GSTR1-ARN-2025-005',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 4, 10),
        reason: 'GSTR-1 filed for March 2025',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-006',
    filingType: FilingType.tds,
    pan: 'DELP12345E',
    period: 'Q4 FY2024-25',
    submittedAt: DateTime(2025, 5, 15),
    currentState: FilingState.processed,
    acknowledgementNumber: '24Q-ACK-2025-006',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 5, 15),
        reason: 'Form 24Q filed for Q4 FY2024-25',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.processed,
        transitionedAt: DateTime(2025, 6, 1),
        reason: 'TRACES processing complete',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-007',
    filingType: FilingType.itr,
    pan: 'PQRST6789U',
    period: '2024-25',
    submittedAt: DateTime(2025, 7, 30),
    currentState: FilingState.eVerificationPending,
    acknowledgementNumber: 'ITR-V-ACK-2025-007',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 7, 30),
        reason: 'ITR-1 filed for AY 2024-25',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.eVerificationPending,
        transitionedAt: DateTime(2025, 7, 30),
        reason: 'ITR-V generated, awaiting e-verification',
      ),
    ],
  ),
  FilingStatus(
    filingId: 'PF-008',
    filingType: FilingType.itr,
    pan: 'UVWXY0123Z',
    period: '2024-25',
    submittedAt: DateTime(2025, 7, 28),
    currentState: FilingState.intimationIssued,
    acknowledgementNumber: 'ITR-V-ACK-2025-008',
    history: [
      FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: DateTime(2025, 7, 28),
        reason: 'ITR-3 filed for AY 2024-25',
      ),
      FilingStatusTransition(
        fromState: FilingState.submitted,
        toState: FilingState.eVerificationPending,
        transitionedAt: DateTime(2025, 7, 28),
        reason: 'ITR-V generated',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerificationPending,
        toState: FilingState.eVerified,
        transitionedAt: DateTime(2025, 7, 29),
        reason: 'E-verified via Aadhaar OTP',
      ),
      FilingStatusTransition(
        fromState: FilingState.eVerified,
        toState: FilingState.processing,
        transitionedAt: DateTime(2025, 8, 12),
        reason: 'Picked up by CPC',
      ),
      FilingStatusTransition(
        fromState: FilingState.processing,
        toState: FilingState.processed,
        transitionedAt: DateTime(2025, 10, 15),
        reason: 'CPC processing complete',
      ),
      FilingStatusTransition(
        fromState: FilingState.processed,
        toState: FilingState.intimationIssued,
        transitionedAt: DateTime(2025, 10, 20),
        reason: 'Intimation u/s 143(1) issued — no demand, no refund',
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock refund data
// ---------------------------------------------------------------------------

final _mockRefunds = <RefundTracker>[
  RefundTracker(
    pan: 'FGHIJ5678K',
    assessmentYear: '2024-25',
    refundAmount: 4500000, // ₹45,000
    status: RefundTrackerStatus.initiated,
    refundBankAccount: 'XXXX4567',
    expectedDate: DateTime(2025, 11, 5),
  ),
  RefundTracker(
    pan: 'ABCDE1234F',
    assessmentYear: '2023-24',
    refundAmount: 1250000, // ₹12,500
    status: RefundTrackerStatus.issued,
    refundBankAccount: 'XXXX1234',
    issuedDate: DateTime(2025, 3, 15),
  ),
  RefundTracker(
    pan: 'PQRST6789U',
    assessmentYear: '2024-25',
    refundAmount: 8700000, // ₹87,000
    status: RefundTrackerStatus.processing,
    refundBankAccount: 'XXXX8901',
    expectedDate: DateTime(2026, 1, 10),
  ),
];

// ---------------------------------------------------------------------------
// Mock demand data
// ---------------------------------------------------------------------------

final _mockDemands = <DemandTracker>[
  DemandTracker(
    pan: 'KLMNO9012P',
    assessmentYear: '2024-25',
    demandId: 'DEM-001',
    section: '143(1)',
    demandAmount: 12000000, // ₹1,20,000
    outstandingAmount: 12000000,
    status: DemandTrackerStatus.raised,
    dueDate: DateTime(2025, 11, 5),
    interestAccruing: true,
  ),
];

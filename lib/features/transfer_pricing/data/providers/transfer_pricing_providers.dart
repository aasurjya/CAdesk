import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tp_study.dart';
import '../../domain/models/tp_filing.dart';

// ---------------------------------------------------------------------------
// Mock data - TP Studies
// ---------------------------------------------------------------------------

final List<TpStudy> _mockStudies = [
  TpStudy(
    id: 'tp-001',
    clientId: 'cl-401',
    clientName: 'Tata Consultancy Services Ltd',
    financialYear: '2025-26',
    studyType: TpStudyType.localFile,
    status: TpStudyStatus.analysis,
    analystName: 'CA Priya Sharma',
    dueDate: DateTime(2026, 11, 30),
    transactionValue: 4500000000,
    method: TpMethod.tnmm,
  ),
  TpStudy(
    id: 'tp-002',
    clientId: 'cl-402',
    clientName: 'Infosys Ltd',
    financialYear: '2025-26',
    studyType: TpStudyType.masterFile,
    status: TpStudyStatus.dataCollection,
    analystName: 'CA Rahul Gupta',
    dueDate: DateTime(2026, 11, 30),
    transactionValue: 8200000000,
    method: TpMethod.tnmm,
  ),
  TpStudy(
    id: 'tp-003',
    clientId: 'cl-403',
    clientName: 'Wipro Technologies Ltd',
    financialYear: '2025-26',
    studyType: TpStudyType.cbcr,
    status: TpStudyStatus.draft,
    analystName: 'CA Ananya Reddy',
    dueDate: DateTime(2026, 11, 30),
    transactionValue: 6100000000,
    method: TpMethod.psm,
  ),
  TpStudy(
    id: 'tp-004',
    clientId: 'cl-404',
    clientName: 'Mahindra & Mahindra Ltd',
    financialYear: '2025-26',
    studyType: TpStudyType.localFile,
    status: TpStudyStatus.review,
    analystName: 'CA Vikram Patel',
    dueDate: DateTime(2026, 11, 30),
    transactionValue: 2800000000,
    method: TpMethod.cup,
  ),
  TpStudy(
    id: 'tp-005',
    clientId: 'cl-405',
    clientName: 'Dr. Reddy\'s Laboratories Ltd',
    financialYear: '2024-25',
    studyType: TpStudyType.localFile,
    status: TpStudyStatus.final_,
    analystName: 'CA Priya Sharma',
    dueDate: DateTime(2025, 11, 30),
    completedDate: DateTime(2025, 10, 15),
    transactionValue: 3200000000,
    method: TpMethod.rpm,
  ),
  TpStudy(
    id: 'tp-006',
    clientId: 'cl-406',
    clientName: 'Lupin Ltd',
    financialYear: '2025-26',
    studyType: TpStudyType.localFile,
    status: TpStudyStatus.notStarted,
    analystName: 'CA Rahul Gupta',
    dueDate: DateTime(2026, 11, 30),
    transactionValue: 1900000000,
    method: TpMethod.cpm,
  ),
];

// ---------------------------------------------------------------------------
// Mock data - Form 3CEB Filings
// ---------------------------------------------------------------------------

final List<TpFiling> _mockFilings = [
  TpFiling(
    id: 'tpf-001',
    clientId: 'cl-401',
    clientName: 'Tata Consultancy Services Ltd',
    assessmentYear: '2026-27',
    certifyingCA: 'CA Suresh Iyer, FRN 012345S',
    dueDate: DateTime(2026, 10, 31),
    status: TpFilingStatus.underPreparation,
    internationalTransactions: const [
      TpTransaction(
        description: 'Software development services to TCS USA',
        method: 'TNMM',
        alpValue: 2800000000,
        actualValue: 2750000000,
        adjustment: 50000000,
      ),
      TpTransaction(
        description: 'Management fees from TCS UK',
        method: 'CUP',
        alpValue: 450000000,
        actualValue: 420000000,
        adjustment: 30000000,
      ),
      TpTransaction(
        description: 'Brand royalty from TCS Japan',
        method: 'CUP',
        alpValue: 180000000,
        actualValue: 175000000,
        adjustment: 5000000,
      ),
    ],
  ),
  TpFiling(
    id: 'tpf-002',
    clientId: 'cl-402',
    clientName: 'Infosys Ltd',
    assessmentYear: '2026-27',
    certifyingCA: 'CA Meena Krishnan, FRN 067890S',
    dueDate: DateTime(2026, 10, 31),
    status: TpFilingStatus.dataCollection,
    internationalTransactions: const [
      TpTransaction(
        description: 'IT consulting to Infosys BPO Americas',
        method: 'TNMM',
        alpValue: 5200000000,
        actualValue: 5100000000,
        adjustment: 100000000,
      ),
      TpTransaction(
        description: 'License fees from Infosys Australia',
        method: 'CUP',
        alpValue: 320000000,
        actualValue: 310000000,
        adjustment: 10000000,
      ),
    ],
  ),
  TpFiling(
    id: 'tpf-003',
    clientId: 'cl-404',
    clientName: 'Mahindra & Mahindra Ltd',
    assessmentYear: '2026-27',
    certifyingCA: 'CA Deepak Joshi, FRN 034567W',
    dueDate: DateTime(2026, 10, 31),
    status: TpFilingStatus.caReview,
    internationalTransactions: const [
      TpTransaction(
        description: 'Export of auto components to M&M South Africa',
        method: 'CUP',
        alpValue: 1200000000,
        actualValue: 1180000000,
        adjustment: 20000000,
      ),
      TpTransaction(
        description: 'Technical know-how fee from Ssangyong Motor',
        method: 'CPM',
        alpValue: 650000000,
        actualValue: 640000000,
        adjustment: 10000000,
      ),
    ],
  ),
  TpFiling(
    id: 'tpf-004',
    clientId: 'cl-405',
    clientName: 'Dr. Reddy\'s Laboratories Ltd',
    assessmentYear: '2025-26',
    certifyingCA: 'CA Suresh Iyer, FRN 012345S',
    dueDate: DateTime(2025, 10, 31),
    filingDate: DateTime(2025, 10, 28),
    status: TpFilingStatus.filed,
    internationalTransactions: const [
      TpTransaction(
        description: 'API exports to Dr. Reddy\'s Germany',
        method: 'RPM',
        alpValue: 1800000000,
        actualValue: 1760000000,
        adjustment: 40000000,
      ),
      TpTransaction(
        description: 'Contract research for US entity',
        method: 'TNMM',
        alpValue: 950000000,
        actualValue: 930000000,
        adjustment: 20000000,
      ),
    ],
  ),
  TpFiling(
    id: 'tpf-005',
    clientId: 'cl-406',
    clientName: 'Lupin Ltd',
    assessmentYear: '2026-27',
    certifyingCA: 'CA Meena Krishnan, FRN 067890S',
    dueDate: DateTime(2026, 10, 31),
    status: TpFilingStatus.notStarted,
    internationalTransactions: const [
      TpTransaction(
        description: 'Finished dosage exports to Lupin Pharma Inc, USA',
        method: 'TNMM',
        alpValue: 1400000000,
        actualValue: 1370000000,
        adjustment: 30000000,
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All TP studies.
final tpStudiesProvider = Provider<List<TpStudy>>(
  (_) => List.unmodifiable(_mockStudies),
);

/// All Form 3CEB filings.
final tpFilingsProvider = Provider<List<TpFiling>>(
  (_) => List.unmodifiable(_mockFilings),
);

/// Selected TP study status filter.
final tpStudyStatusFilterProvider =
    NotifierProvider<TpStudyStatusFilterNotifier, TpStudyStatus?>(
        TpStudyStatusFilterNotifier.new);

class TpStudyStatusFilterNotifier extends Notifier<TpStudyStatus?> {
  @override
  TpStudyStatus? build() => null;

  void update(TpStudyStatus? value) => state = value;
}

/// Selected TP filing status filter.
final tpFilingStatusFilterProvider =
    NotifierProvider<TpFilingStatusFilterNotifier, TpFilingStatus?>(
        TpFilingStatusFilterNotifier.new);

class TpFilingStatusFilterNotifier extends Notifier<TpFilingStatus?> {
  @override
  TpFilingStatus? build() => null;

  void update(TpFilingStatus? value) => state = value;
}

/// TP studies filtered by status.
final filteredTpStudiesProvider = Provider<List<TpStudy>>((ref) {
  final status = ref.watch(tpStudyStatusFilterProvider);
  final all = ref.watch(tpStudiesProvider);
  if (status == null) return all;
  return all.where((s) => s.status == status).toList();
});

/// Form 3CEB filings filtered by status.
final filteredTpFilingsProvider = Provider<List<TpFiling>>((ref) {
  final status = ref.watch(tpFilingStatusFilterProvider);
  final all = ref.watch(tpFilingsProvider);
  if (status == null) return all;
  return all.where((f) => f.status == status).toList();
});

/// Transfer Pricing summary statistics.
final tpSummaryProvider = Provider<TpSummary>((ref) {
  final studies = ref.watch(tpStudiesProvider);
  final filings = ref.watch(tpFilingsProvider);

  final totalStudies = studies.length;
  final inProgress = studies
      .where((s) =>
          s.status != TpStudyStatus.notStarted &&
          s.status != TpStudyStatus.final_)
      .length;
  final completed =
      studies.where((s) => s.status == TpStudyStatus.final_).length;
  final filingsPending =
      filings.where((f) => f.status != TpFilingStatus.filed).length;

  return TpSummary(
    totalStudies: totalStudies,
    inProgress: inProgress,
    completed: completed,
    filingsPending: filingsPending,
  );
});

/// Simple immutable summary data class.
class TpSummary {
  const TpSummary({
    required this.totalStudies,
    required this.inProgress,
    required this.completed,
    required this.filingsPending,
  });

  final int totalStudies;
  final int inProgress;
  final int completed;
  final int filingsPending;
}

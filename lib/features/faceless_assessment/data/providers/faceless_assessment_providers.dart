import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';

// ---------------------------------------------------------------------------
// Filter notifiers
// ---------------------------------------------------------------------------

/// Filter by proceeding type (null = show all).
final proceedingTypeFilterProvider =
    NotifierProvider<ProceedingTypeFilterNotifier, ProceedingType?>(
      ProceedingTypeFilterNotifier.new,
    );

class ProceedingTypeFilterNotifier extends Notifier<ProceedingType?> {
  @override
  ProceedingType? build() => null;

  void update(ProceedingType? value) => state = value;
}

/// Filter by proceeding status (null = show all).
final proceedingStatusFilterProvider =
    NotifierProvider<ProceedingStatusFilterNotifier, ProceedingStatus?>(
      ProceedingStatusFilterNotifier.new,
    );

class ProceedingStatusFilterNotifier extends Notifier<ProceedingStatus?> {
  @override
  ProceedingStatus? build() => null;

  void update(ProceedingStatus? value) => state = value;
}

/// Filter by hearing status (null = show all).
final hearingStatusFilterProvider =
    NotifierProvider<HearingStatusFilterNotifier, HearingStatus?>(
      HearingStatusFilterNotifier.new,
    );

class HearingStatusFilterNotifier extends Notifier<HearingStatus?> {
  @override
  HearingStatus? build() => null;

  void update(HearingStatus? value) => state = value;
}

// ---------------------------------------------------------------------------
// Core data providers
// ---------------------------------------------------------------------------

final eProceedingsProvider =
    NotifierProvider<EProceedingsNotifier, List<EProceeding>>(
      EProceedingsNotifier.new,
    );

class EProceedingsNotifier extends Notifier<List<EProceeding>> {
  @override
  List<EProceeding> build() => _mockProceedings;

  void add(EProceeding proceeding) {
    state = [...state, proceeding];
  }

  void updateProceeding(EProceeding updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }
}

final itrUFilingsProvider =
    NotifierProvider<ItrUFilingsNotifier, List<ItrUFiling>>(
      ItrUFilingsNotifier.new,
    );

class ItrUFilingsNotifier extends Notifier<List<ItrUFiling>> {
  @override
  List<ItrUFiling> build() => _mockItrUFilings;

  void add(ItrUFiling filing) {
    state = [...state, filing];
  }

  void updateFiling(ItrUFiling updated) {
    state = [
      for (final f in state)
        if (f.id == updated.id) updated else f,
    ];
  }
}

final hearingSchedulesProvider =
    NotifierProvider<HearingSchedulesNotifier, List<HearingSchedule>>(
      HearingSchedulesNotifier.new,
    );

class HearingSchedulesNotifier extends Notifier<List<HearingSchedule>> {
  @override
  List<HearingSchedule> build() => _mockHearings;

  void add(HearingSchedule hearing) {
    state = [...state, hearing];
  }

  void updateHearing(HearingSchedule updated) {
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h,
    ];
  }
}

// ---------------------------------------------------------------------------
// Derived / filtered providers
// ---------------------------------------------------------------------------

final filteredProceedingsProvider = Provider<List<EProceeding>>((ref) {
  final proceedings = ref.watch(eProceedingsProvider);
  final typeFilter = ref.watch(proceedingTypeFilterProvider);
  final statusFilter = ref.watch(proceedingStatusFilterProvider);

  return proceedings.where((p) {
    if (typeFilter != null && p.proceedingType != typeFilter) return false;
    if (statusFilter != null && p.status != statusFilter) return false;
    return true;
  }).toList();
});

final filteredHearingsProvider = Provider<List<HearingSchedule>>((ref) {
  final hearings = ref.watch(hearingSchedulesProvider);
  final statusFilter = ref.watch(hearingStatusFilterProvider);

  if (statusFilter == null) return hearings;
  return hearings.where((h) => h.status == statusFilter).toList();
});

// ---------------------------------------------------------------------------
// Mock data - 8 e-proceedings
// ---------------------------------------------------------------------------

final _mockProceedings = <EProceeding>[
  EProceeding(
    id: 'ep1',
    clientId: 'c1',
    clientName: 'Rajesh Kumar Sharma',
    pan: 'ABCPS1234K',
    assessmentYear: 'AY 2023-24',
    proceedingType: ProceedingType.scrutiny143_3,
    noticeDate: DateTime(2025, 12, 15),
    responseDeadline: DateTime(2026, 3, 15),
    status: ProceedingStatus.responseDrafted,
    nfacReferenceNumber: 'NFAC/SCR/2025/MUM/001234',
    assignedOfficer: 'DCIT Circle 3(1), Mumbai',
    demandAmount: 285000,
    remarks: 'Mismatch in capital gains reported vs Form 26AS',
  ),
  EProceeding(
    id: 'ep2',
    clientId: 'c2',
    clientName: 'Priya Nair',
    pan: 'BKNPN5678L',
    assessmentYear: 'AY 2022-23',
    proceedingType: ProceedingType.reassessment147,
    noticeDate: DateTime(2025, 11, 20),
    responseDeadline: DateTime(2026, 3, 20),
    status: ProceedingStatus.responseSubmitted,
    nfacReferenceNumber: 'NFAC/RAS/2025/DEL/005678',
    assignedOfficer: 'ITO Ward 2(4), Delhi',
    demandAmount: 520000,
    remarks: 'Undisclosed foreign income from NRE account interest',
  ),
  EProceeding(
    id: 'ep3',
    clientId: 'c3',
    clientName: 'Patel Trading Company',
    pan: 'AABFP9012M',
    assessmentYear: 'AY 2024-25',
    proceedingType: ProceedingType.scrutiny143_3,
    noticeDate: DateTime(2026, 1, 10),
    responseDeadline: DateTime(2026, 3, 10),
    status: ProceedingStatus.noticeReceived,
    nfacReferenceNumber: 'NFAC/SCR/2026/AHM/002345',
    demandAmount: 1250000,
    remarks: 'Large cash deposits during demonetization period',
  ),
  EProceeding(
    id: 'ep4',
    clientId: 'c4',
    clientName: 'Sunita Deshmukh',
    pan: 'DHMPD3456N',
    assessmentYear: 'AY 2023-24',
    proceedingType: ProceedingType.rectification154,
    noticeDate: DateTime(2026, 2, 1),
    responseDeadline: DateTime(2026, 4, 1),
    status: ProceedingStatus.responseDrafted,
    nfacReferenceNumber: 'NFAC/REC/2026/PUN/003456',
    demandAmount: 45000,
    remarks: 'Arithmetical error in TDS credit computation',
  ),
  EProceeding(
    id: 'ep5',
    clientId: 'c5',
    clientName: 'Vikram Industries Pvt Ltd',
    pan: 'AABCV7890P',
    assessmentYear: 'AY 2021-22',
    proceedingType: ProceedingType.search153A,
    noticeDate: DateTime(2025, 8, 15),
    responseDeadline: DateTime(2026, 2, 15),
    status: ProceedingStatus.hearingScheduled,
    nfacReferenceNumber: 'NFAC/SRC/2025/JAI/004567',
    assignedOfficer: 'Addl. CIT Range 1, Jaipur',
    demandAmount: 4500000,
    remarks: 'Post-search assessment for unexplained investments',
  ),
  EProceeding(
    id: 'ep6',
    clientId: 'c6',
    clientName: 'Meera Joshi',
    pan: 'FLJPM2345Q',
    assessmentYear: 'AY 2022-23',
    proceedingType: ProceedingType.penalty,
    noticeDate: DateTime(2026, 1, 25),
    responseDeadline: DateTime(2026, 3, 25),
    status: ProceedingStatus.noticeReceived,
    nfacReferenceNumber: 'NFAC/PEN/2026/BLR/005678',
    demandAmount: 175000,
    remarks: 'Penalty u/s 271(1)(c) for concealment of income',
  ),
  EProceeding(
    id: 'ep7',
    clientId: 'c7',
    clientName: 'Arjun Mehta HUF',
    pan: 'AAAHA6789R',
    assessmentYear: 'AY 2023-24',
    proceedingType: ProceedingType.appealEffect,
    noticeDate: DateTime(2025, 10, 5),
    responseDeadline: DateTime(2026, 4, 5),
    status: ProceedingStatus.orderPassed,
    nfacReferenceNumber: 'NFAC/APE/2025/CHN/006789',
    assignedOfficer: 'ACIT Circle 1(2), Chennai',
    demandAmount: 0,
    remarks: 'CIT(A) partially allowed appeal, demand reduced to nil',
  ),
  EProceeding(
    id: 'ep8',
    clientId: 'c8',
    clientName: 'Deepika Iyer',
    pan: 'HQIPD1234S',
    assessmentYear: 'AY 2024-25',
    proceedingType: ProceedingType.scrutiny143_3,
    noticeDate: DateTime(2026, 2, 20),
    responseDeadline: DateTime(2026, 4, 20),
    status: ProceedingStatus.noticeReceived,
    nfacReferenceNumber: 'NFAC/SCR/2026/HYD/007890',
    demandAmount: 350000,
    remarks: 'Discrepancy in rent income vs TDS certificates',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - 4 ITR-U filings
// ---------------------------------------------------------------------------

final _mockItrUFilings = <ItrUFiling>[
  ItrUFiling(
    id: 'iu1',
    clientId: 'c1',
    clientName: 'Rajesh Kumar Sharma',
    pan: 'ABCPS1234K',
    originalAssessmentYear: 'AY 2023-24',
    originalFilingDate: DateTime(2023, 7, 25),
    updateReason: UpdateReason.incomeNotReported,
    additionalTax: 85000,
    penaltyPercentage: 25,
    penaltyAmount: 21250,
    totalPayable: 106250,
    status: ItrUStatus.computationDone,
    filingDeadline: DateTime(2026, 3, 31),
  ),
  ItrUFiling(
    id: 'iu2',
    clientId: 'c3',
    clientName: 'Amit Patel',
    pan: 'CFGPP9012M',
    originalAssessmentYear: 'AY 2022-23',
    originalFilingDate: DateTime(2022, 7, 30),
    updateReason: UpdateReason.wrongHead,
    additionalTax: 150000,
    penaltyPercentage: 50,
    penaltyAmount: 75000,
    totalPayable: 225000,
    status: ItrUStatus.paymentPending,
    filingDeadline: DateTime(2026, 3, 31),
  ),
  ItrUFiling(
    id: 'iu3',
    clientId: 'c6',
    clientName: 'Meera Joshi',
    pan: 'FLJPM2345Q',
    originalAssessmentYear: 'AY 2024-25',
    originalFilingDate: DateTime(2024, 7, 15),
    updateReason: UpdateReason.carriedForwardLoss,
    additionalTax: 0,
    penaltyPercentage: 25,
    penaltyAmount: 0,
    totalPayable: 0,
    status: ItrUStatus.draft,
    filingDeadline: DateTime(2026, 12, 31),
  ),
  ItrUFiling(
    id: 'iu4',
    clientId: 'c9',
    clientName: 'Karan Malhotra',
    pan: 'JRKPK5678T',
    originalAssessmentYear: 'AY 2023-24',
    originalFilingDate: DateTime(2023, 7, 28),
    updateReason: UpdateReason.wrongRate,
    additionalTax: 42000,
    penaltyPercentage: 25,
    penaltyAmount: 10500,
    totalPayable: 52500,
    status: ItrUStatus.filed,
    filingDeadline: DateTime(2026, 3, 31),
  ),
];

// ---------------------------------------------------------------------------
// Mock data - 6 hearing schedules
// ---------------------------------------------------------------------------

final _mockHearings = <HearingSchedule>[
  HearingSchedule(
    id: 'hs1',
    proceedingId: 'ep1',
    clientName: 'Rajesh Kumar Sharma',
    hearingDate: DateTime(2026, 3, 15),
    hearingTime: '11:00 AM',
    platform: HearingPlatform.nfacPortal,
    agenda: 'Submission of capital gains computation and broker statements',
    documentsToSubmit: [
      'Capital gains statement from broker',
      'Bank statement showing sale proceeds',
      'Form 26AS reconciliation',
    ],
    representativeName: 'CA Suresh Iyer',
    status: HearingStatus.scheduled,
  ),
  HearingSchedule(
    id: 'hs2',
    proceedingId: 'ep2',
    clientName: 'Priya Nair',
    hearingDate: DateTime(2026, 3, 18),
    hearingTime: '02:30 PM',
    platform: HearingPlatform.videoConference,
    agenda: 'Clarification on NRE account interest taxability',
    documentsToSubmit: [
      'NRE account statements',
      'FEMA compliance certificate',
      'Tax residency certificate',
      'DTAA benefit computation',
    ],
    representativeName: 'CA Meera Joshi',
    status: HearingStatus.scheduled,
  ),
  HearingSchedule(
    id: 'hs3',
    proceedingId: 'ep5',
    clientName: 'Vikram Industries Pvt Ltd',
    hearingDate: DateTime(2026, 2, 28),
    hearingTime: '10:00 AM',
    platform: HearingPlatform.nfacPortal,
    agenda: 'Examination of books of accounts post-search',
    documentsToSubmit: [
      'Audited financial statements for 3 years',
      'Investment register with source documents',
      'Cash flow statement',
      'Sworn statement of directors',
    ],
    representativeName: 'CA Rajesh Agarwal',
    status: HearingStatus.completed,
    notes: 'AO requested additional documents for share premium valuation',
  ),
  HearingSchedule(
    id: 'hs4',
    proceedingId: 'ep5',
    clientName: 'Vikram Industries Pvt Ltd',
    hearingDate: DateTime(2026, 3, 25),
    hearingTime: '11:30 AM',
    platform: HearingPlatform.nfacPortal,
    agenda: 'Follow-up hearing on share premium valuation',
    documentsToSubmit: [
      'DCF valuation report from registered valuer',
      'Board resolution for share allotment',
      'Shareholder agreement',
    ],
    representativeName: 'CA Rajesh Agarwal',
    status: HearingStatus.scheduled,
  ),
  HearingSchedule(
    id: 'hs5',
    proceedingId: 'ep3',
    clientName: 'Patel Trading Company',
    hearingDate: DateTime(2026, 3, 12),
    hearingTime: '03:00 PM',
    platform: HearingPlatform.videoConference,
    agenda: 'Initial hearing for scrutiny assessment',
    documentsToSubmit: [
      'Audited balance sheet and P&L',
      'Bank statements for FY 2024-25',
      'Sales and purchase registers',
    ],
    representativeName: 'CA Vikram Singh',
    status: HearingStatus.adjourned,
    notes: 'Adjourned due to technical issues. Rescheduled to March 22.',
  ),
  HearingSchedule(
    id: 'hs6',
    proceedingId: 'ep6',
    clientName: 'Meera Joshi',
    hearingDate: DateTime(2026, 4, 2),
    hearingTime: '10:30 AM',
    platform: HearingPlatform.nfacPortal,
    agenda: 'Show cause hearing for penalty u/s 271(1)(c)',
    documentsToSubmit: [
      'Written submission against penalty',
      'Case law compilation supporting bonafide claim',
      'Original ITR and revised computation',
    ],
    representativeName: 'CA Meera Joshi',
    status: HearingStatus.scheduled,
  ),
];

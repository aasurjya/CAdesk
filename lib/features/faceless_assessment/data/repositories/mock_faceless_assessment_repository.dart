import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';
import 'package:ca_app/features/faceless_assessment/domain/repositories/faceless_assessment_repository.dart';

/// In-memory mock implementation of [FacelessAssessmentRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockFacelessAssessmentRepository implements FacelessAssessmentRepository {
  static final List<EProceeding> _seedProceedings = [
    EProceeding(
      id: 'mock-ep-001',
      clientId: 'mock-client-001',
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
      id: 'mock-ep-002',
      clientId: 'mock-client-002',
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
    ),
    EProceeding(
      id: 'mock-ep-003',
      clientId: 'mock-client-003',
      clientName: 'Patel Trading Company',
      pan: 'AABFP9012M',
      assessmentYear: 'AY 2024-25',
      proceedingType: ProceedingType.penalty,
      noticeDate: DateTime(2026, 1, 10),
      responseDeadline: DateTime(2026, 4, 10),
      status: ProceedingStatus.noticeReceived,
      nfacReferenceNumber: 'NFAC/PEN/2026/AHM/002345',
      demandAmount: 175000,
    ),
  ];

  static final List<HearingSchedule> _seedHearings = [
    HearingSchedule(
      id: 'mock-hs-001',
      proceedingId: 'mock-ep-001',
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
      id: 'mock-hs-002',
      proceedingId: 'mock-ep-002',
      clientName: 'Priya Nair',
      hearingDate: DateTime(2026, 3, 20),
      hearingTime: '02:30 PM',
      platform: HearingPlatform.videoConference,
      agenda: 'Clarification on NRE account interest taxability',
      documentsToSubmit: [
        'NRE account statements',
        'Tax residency certificate',
      ],
      representativeName: 'CA Meera Joshi',
      status: HearingStatus.scheduled,
    ),
    HearingSchedule(
      id: 'mock-hs-003',
      proceedingId: 'mock-ep-003',
      clientName: 'Patel Trading Company',
      hearingDate: DateTime(2026, 4, 5),
      hearingTime: '10:00 AM',
      platform: HearingPlatform.nfacPortal,
      agenda: 'Initial hearing for penalty proceeding',
      documentsToSubmit: [
        'Written submission against penalty',
        'Case law compilation',
      ],
      representativeName: 'CA Vikram Singh',
      status: HearingStatus.scheduled,
    ),
  ];

  static final List<ItrUFiling> _seedItrUFilings = [
    ItrUFiling(
      id: 'mock-iu-001',
      clientId: 'mock-client-001',
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
      id: 'mock-iu-002',
      clientId: 'mock-client-002',
      clientName: 'Priya Nair',
      pan: 'BKNPN5678L',
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
      id: 'mock-iu-003',
      clientId: 'mock-client-003',
      clientName: 'Patel Trading Company',
      pan: 'AABFP9012M',
      originalAssessmentYear: 'AY 2024-25',
      originalFilingDate: DateTime(2024, 7, 31),
      updateReason: UpdateReason.other,
      additionalTax: 42000,
      penaltyPercentage: 25,
      penaltyAmount: 10500,
      totalPayable: 52500,
      status: ItrUStatus.draft,
      filingDeadline: DateTime(2026, 12, 31),
    ),
  ];

  final List<EProceeding> _proceedings = List.of(_seedProceedings);
  final List<HearingSchedule> _hearings = List.of(_seedHearings);
  final List<ItrUFiling> _itrUFilings = List.of(_seedItrUFilings);

  // -------------------------------------------------------------------------
  // EProceeding
  // -------------------------------------------------------------------------

  @override
  Future<List<EProceeding>> getProceedings() async =>
      List.unmodifiable(_proceedings);

  @override
  Future<List<EProceeding>> getProceedingsByClient(String clientId) async =>
      List.unmodifiable(
        _proceedings.where((p) => p.clientId == clientId).toList(),
      );

  @override
  Future<String> insertProceeding(EProceeding proceeding) async {
    _proceedings.add(proceeding);
    return proceeding.id;
  }

  @override
  Future<bool> updateProceeding(EProceeding proceeding) async {
    final idx = _proceedings.indexWhere((p) => p.id == proceeding.id);
    if (idx == -1) return false;
    final updated = List<EProceeding>.of(_proceedings)..[idx] = proceeding;
    _proceedings
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteProceeding(String id) async {
    final before = _proceedings.length;
    _proceedings.removeWhere((p) => p.id == id);
    return _proceedings.length < before;
  }

  // -------------------------------------------------------------------------
  // HearingSchedule
  // -------------------------------------------------------------------------

  @override
  Future<List<HearingSchedule>> getHearings() async =>
      List.unmodifiable(_hearings);

  @override
  Future<List<HearingSchedule>> getHearingsByProceeding(
    String proceedingId,
  ) async => List.unmodifiable(
    _hearings.where((h) => h.proceedingId == proceedingId).toList(),
  );

  @override
  Future<String> insertHearing(HearingSchedule hearing) async {
    _hearings.add(hearing);
    return hearing.id;
  }

  @override
  Future<bool> updateHearing(HearingSchedule hearing) async {
    final idx = _hearings.indexWhere((h) => h.id == hearing.id);
    if (idx == -1) return false;
    final updated = List<HearingSchedule>.of(_hearings)..[idx] = hearing;
    _hearings
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteHearing(String id) async {
    final before = _hearings.length;
    _hearings.removeWhere((h) => h.id == id);
    return _hearings.length < before;
  }

  // -------------------------------------------------------------------------
  // ItrUFiling
  // -------------------------------------------------------------------------

  @override
  Future<List<ItrUFiling>> getItrUFilings() async =>
      List.unmodifiable(_itrUFilings);

  @override
  Future<List<ItrUFiling>> getItrUFilingsByClient(String clientId) async =>
      List.unmodifiable(
        _itrUFilings.where((f) => f.clientId == clientId).toList(),
      );

  @override
  Future<String> insertItrUFiling(ItrUFiling filing) async {
    _itrUFilings.add(filing);
    return filing.id;
  }

  @override
  Future<bool> updateItrUFiling(ItrUFiling filing) async {
    final idx = _itrUFilings.indexWhere((f) => f.id == filing.id);
    if (idx == -1) return false;
    final updated = List<ItrUFiling>.of(_itrUFilings)..[idx] = filing;
    _itrUFilings
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteItrUFiling(String id) async {
    final before = _itrUFilings.length;
    _itrUFilings.removeWhere((f) => f.id == id);
    return _itrUFilings.length < before;
  }
}

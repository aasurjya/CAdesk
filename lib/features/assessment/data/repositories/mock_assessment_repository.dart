import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';
import 'package:ca_app/features/assessment/domain/repositories/assessment_repository.dart';

class MockAssessmentRepository implements AssessmentRepository {
  static final List<AssessmentCase> _seed = [
    AssessmentCase(
      id: 'ac-001',
      clientId: 'client-1',
      assessmentYear: 'AY 2023-24',
      caseType: AssessmentType.intimation143_1,
      status: AssessmentCaseStatus.open,
      demandAmount: '25000.00',
      paidAmount: '0.00',
      dueDate: DateTime(2026, 3, 31),
      notes: 'TDS mismatch in 143(1) intimation',
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 1, 15),
    ),
    AssessmentCase(
      id: 'ac-002',
      clientId: 'client-1',
      assessmentYear: 'AY 2022-23',
      caseType: AssessmentType.scrutiny143_3,
      status: AssessmentCaseStatus.pending,
      demandAmount: '150000.00',
      paidAmount: '50000.00',
      dueDate: DateTime(2026, 6, 30),
      notes: 'Scrutiny notice for large cash deposits',
      createdAt: DateTime(2025, 11, 10),
      updatedAt: DateTime(2026, 2, 1),
    ),
    AssessmentCase(
      id: 'ac-003',
      clientId: 'client-2',
      assessmentYear: 'AY 2023-24',
      caseType: AssessmentType.intimation143_1,
      status: AssessmentCaseStatus.closed,
      demandAmount: '8500.00',
      paidAmount: '8500.00',
      dueDate: DateTime(2025, 12, 31),
      notes: 'Demand paid in full',
      createdAt: DateTime(2025, 9, 20),
      updatedAt: DateTime(2025, 12, 28),
    ),
    AssessmentCase(
      id: 'ac-004',
      clientId: 'client-3',
      assessmentYear: 'AY 2021-22',
      caseType: AssessmentType.appealCit,
      status: AssessmentCaseStatus.appealed,
      demandAmount: '500000.00',
      paidAmount: '100000.00',
      dueDate: DateTime(2025, 12, 1),
      notes: 'CIT(A) appeal filed against addition under section 68',
      createdAt: DateTime(2025, 6, 1),
      updatedAt: DateTime(2025, 10, 15),
    ),
  ];

  final List<AssessmentCase> _state = List.of(_seed);

  @override
  Future<String> insertCase(AssessmentCase assessmentCase) async {
    _state.add(assessmentCase);
    return assessmentCase.id;
  }

  @override
  Future<List<AssessmentCase>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((c) => c.clientId == clientId).toList());

  @override
  Future<List<AssessmentCase>> getByYear(String assessmentYear) async =>
      List.unmodifiable(
        _state.where((c) => c.assessmentYear == assessmentYear).toList(),
      );

  @override
  Future<List<AssessmentCase>> getByType(AssessmentType caseType) async =>
      List.unmodifiable(_state.where((c) => c.caseType == caseType).toList());

  @override
  Future<List<AssessmentCase>> getByStatus(AssessmentCaseStatus status) async =>
      List.unmodifiable(_state.where((c) => c.status == status).toList());

  @override
  Future<bool> updateStatus(String id, AssessmentCaseStatus status) async {
    final idx = _state.indexWhere((c) => c.id == id);
    if (idx == -1) return false;
    final updated = List<AssessmentCase>.of(_state)
      ..[idx] = _state[idx].copyWith(status: status);
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<List<AssessmentCase>> getOverdueDemands() async {
    final now = DateTime.now();
    return List.unmodifiable(
      _state
          .where(
            (c) =>
                c.status == AssessmentCaseStatus.open &&
                c.dueDate != null &&
                c.dueDate!.isBefore(now),
          )
          .toList(),
    );
  }
}

import 'package:ca_app/features/llp/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp/domain/repositories/llp_repository.dart';

/// In-memory mock implementation of [LlpRepository].
class MockLlpRepository implements LlpRepository {
  static final _now = DateTime.now();

  static final List<LlpFiling> _seedFilings = [
    LlpFiling(
      id: 'llp-001',
      clientId: 'mock-client-001',
      formType: LlpFormType.form11,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month, _now.day + 30),
      status: 'pending',
    ),
    LlpFiling(
      id: 'llp-002',
      clientId: 'mock-client-001',
      formType: LlpFormType.form8,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month, _now.day + 60),
      status: 'pending',
    ),
    LlpFiling(
      id: 'llp-003',
      clientId: 'mock-client-002',
      formType: LlpFormType.form3,
      financialYear: '2024-25',
      dueDate: DateTime(_now.year, _now.month - 1, 15),
      filedDate: DateTime(_now.year, _now.month - 1, 10),
      status: 'approved',
      filingNumber: 'L12345678',
    ),
    LlpFiling(
      id: 'llp-004',
      clientId: 'mock-client-002',
      formType: LlpFormType.form11,
      financialYear: '2023-24',
      dueDate: DateTime(_now.year, _now.month, _now.day - 10),
      status: 'pending',
    ),
  ];

  final List<LlpFiling> _state = List.of(_seedFilings);

  @override
  Future<String> insertLlpFiling(LlpFiling filing) async {
    _state.add(filing);
    return filing.id;
  }

  @override
  Future<List<LlpFiling>> getByClient(String clientId) async =>
      List.unmodifiable(
        _state.where((f) => f.clientId == clientId).toList(),
      );

  @override
  Future<List<LlpFiling>> getByYear(String clientId, String year) async =>
      List.unmodifiable(
        _state
            .where((f) => f.clientId == clientId && f.financialYear == year)
            .toList(),
      );

  @override
  Future<bool> updateStatus(String id, String status) async {
    final idx = _state.indexWhere((f) => f.id == id);
    if (idx == -1) return false;
    final updated = List<LlpFiling>.of(_state)..[idx] =
        _state[idx].copyWith(status: status);
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<List<LlpFiling>> getOverdue() async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    return List.unmodifiable(
      _state
          .where(
            (f) =>
                f.dueDate.isBefore(todayMidnight) &&
                f.status != 'filed' &&
                f.status != 'approved',
          )
          .toList(),
    );
  }

  @override
  Future<List<LlpFiling>> getDue(int daysAhead) async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final cutoff = todayMidnight.add(Duration(days: daysAhead));
    return List.unmodifiable(
      _state
          .where(
            (f) =>
                !f.dueDate.isBefore(todayMidnight) &&
                !f.dueDate.isAfter(cutoff) &&
                f.status != 'filed' &&
                f.status != 'approved',
          )
          .toList(),
    );
  }
}

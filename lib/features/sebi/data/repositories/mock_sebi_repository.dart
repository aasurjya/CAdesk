import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';
import 'package:ca_app/features/sebi/domain/repositories/sebi_repository.dart';

/// In-memory mock implementation of [SebiRepository].
class MockSebiRepository implements SebiRepository {
  static final _now = DateTime.now();

  static final List<SebiComplianceData> _seedRecords = [
    SebiComplianceData(
      id: 'sebi-001',
      clientId: 'mock-client-001',
      complianceType: SebiType.pit,
      dueDate: DateTime(_now.year, _now.month, _now.day + 15),
      status: 'pending',
      description: 'Quarterly disclosure by designated person',
    ),
    SebiComplianceData(
      id: 'sebi-002',
      clientId: 'mock-client-001',
      complianceType: SebiType.lodr,
      dueDate: DateTime(_now.year, _now.month - 1, 25),
      filedDate: DateTime(_now.year, _now.month - 1, 22),
      status: 'filed',
      description: 'LODR Regulation 33 quarterly financial results',
    ),
    SebiComplianceData(
      id: 'sebi-003',
      clientId: 'mock-client-002',
      complianceType: SebiType.sast,
      dueDate: DateTime(_now.year, _now.month, _now.day - 5),
      status: 'overdue',
      description: 'SAST Regulation 30 acquisition disclosure',
    ),
    SebiComplianceData(
      id: 'sebi-004',
      clientId: 'mock-client-003',
      complianceType: SebiType.insiderTrading,
      dueDate: DateTime(_now.year, _now.month, _now.day + 30),
      status: 'pending',
      description: 'Annual disclosure under PIT Regulations',
    ),
  ];

  final List<SebiComplianceData> _state = List.of(_seedRecords);

  @override
  Future<String> insert(SebiComplianceData compliance) async {
    _state.add(compliance);
    return compliance.id;
  }

  @override
  Future<List<SebiComplianceData>> getByClient(String clientId) async =>
      List.unmodifiable(
        _state.where((r) => r.clientId == clientId).toList(),
      );

  @override
  Future<List<SebiComplianceData>> getByType(SebiType complianceType) async =>
      List.unmodifiable(
        _state.where((r) => r.complianceType == complianceType).toList(),
      );

  @override
  Future<List<SebiComplianceData>> getOverdue() async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    return List.unmodifiable(
      _state
          .where(
            (r) =>
                r.dueDate.isBefore(todayMidnight) &&
                r.status != 'filed' &&
                r.status != 'exempted',
          )
          .toList(),
    );
  }

  @override
  Future<bool> updateStatus(String id, String status) async {
    final idx = _state.indexWhere((r) => r.id == id);
    if (idx == -1) return false;
    final updated = List<SebiComplianceData>.of(_state)..[idx] =
        _state[idx].copyWith(status: status);
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }
}

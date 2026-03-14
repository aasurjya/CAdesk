import 'package:ca_app/features/msme/domain/models/msme_record.dart';
import 'package:ca_app/features/msme/domain/repositories/msme_repository.dart';

/// In-memory mock implementation of [MsmeRepository].
class MockMsmeRepository implements MsmeRepository {
  static final List<MsmeRecord> _seedRecords = [
    MsmeRecord(
      id: 'msme-001',
      clientId: 'mock-client-001',
      udyamNumber: 'UDYAM-MH-01-0012345',
      registrationDate: DateTime(2021, 7, 1),
      category: MsmeCategory.micro,
      annualTurnover: '4500000',
      employeeCount: 8,
      status: 'active',
    ),
    MsmeRecord(
      id: 'msme-002',
      clientId: 'mock-client-002',
      udyamNumber: 'UDYAM-DL-07-0023456',
      registrationDate: DateTime(2022, 4, 15),
      category: MsmeCategory.small,
      annualTurnover: '45000000',
      employeeCount: 42,
      status: 'active',
    ),
    MsmeRecord(
      id: 'msme-003',
      clientId: 'mock-client-003',
      udyamNumber: 'UDYAM-KA-29-0034567',
      registrationDate: DateTime(2020, 10, 10),
      category: MsmeCategory.medium,
      annualTurnover: '180000000',
      employeeCount: 120,
      status: 'active',
    ),
  ];

  final List<MsmeRecord> _state = List.of(_seedRecords);

  @override
  Future<String> insert(MsmeRecord record) async {
    _state.add(record);
    return record.id;
  }

  @override
  Future<List<MsmeRecord>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((r) => r.clientId == clientId).toList());

  @override
  Future<bool> update(MsmeRecord record) async {
    final idx = _state.indexWhere((r) => r.id == record.id);
    if (idx == -1) return false;
    final updated = List<MsmeRecord>.of(_state)..[idx] = record;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<List<MsmeRecord>> getByCategory(MsmeCategory category) async =>
      List.unmodifiable(_state.where((r) => r.category == category).toList());

  @override
  Future<List<MsmeRecord>> getByStatus(String status) async =>
      List.unmodifiable(_state.where((r) => r.status == status).toList());
}

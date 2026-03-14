import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';
import 'package:ca_app/features/fema/domain/repositories/fema_repository.dart';

/// In-memory mock implementation of [FemaRepository].
class MockFemaRepository implements FemaRepository {
  static final _now = DateTime.now();

  static final List<FemaFilingData> _seedFilings = [
    FemaFilingData(
      id: 'fema-001',
      clientId: 'mock-client-001',
      filingType: FemaType.fdi,
      transactionDate: DateTime(_now.year, _now.month - 2, 15),
      amount: '5000000',
      currency: 'USD',
      approvalRequired: true,
      status: 'approved',
      filingNumber: 'RBI/FDI/2024/001',
    ),
    FemaFilingData(
      id: 'fema-002',
      clientId: 'mock-client-001',
      filingType: FemaType.form15ca,
      transactionDate: DateTime(_now.year, _now.month, 1),
      amount: '200000',
      currency: 'USD',
      approvalRequired: false,
      status: 'pending',
    ),
    FemaFilingData(
      id: 'fema-003',
      clientId: 'mock-client-002',
      filingType: FemaType.ecb,
      transactionDate: DateTime(_now.year - 1, 9, 10),
      amount: '10000000',
      currency: 'USD',
      approvalRequired: true,
      status: 'filed',
      filingNumber: 'ECB/2023/456',
      remarks: 'External commercial borrowing from parent company',
    ),
    FemaFilingData(
      id: 'fema-004',
      clientId: 'mock-client-003',
      filingType: FemaType.compounding,
      transactionDate: DateTime(_now.year, _now.month - 1, 5),
      amount: '50000',
      currency: 'INR',
      approvalRequired: false,
      status: 'pending',
      remarks: 'Compounding application for delay in FC-GPR filing',
    ),
  ];

  final List<FemaFilingData> _state = List.of(_seedFilings);

  @override
  Future<String> insert(FemaFilingData filing) async {
    _state.add(filing);
    return filing.id;
  }

  @override
  Future<List<FemaFilingData>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((f) => f.clientId == clientId).toList());

  @override
  Future<List<FemaFilingData>> getByType(FemaType filingType) async =>
      List.unmodifiable(
        _state.where((f) => f.filingType == filingType).toList(),
      );

  @override
  Future<bool> updateStatus(String id, String status) async {
    final idx = _state.indexWhere((f) => f.id == id);
    if (idx == -1) return false;
    final updated = List<FemaFilingData>.of(_state)
      ..[idx] = _state[idx].copyWith(status: status);
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<List<FemaFilingData>> getByYear(String clientId, int year) async =>
      List.unmodifiable(
        _state
            .where(
              (f) => f.clientId == clientId && f.transactionDate.year == year,
            )
            .toList(),
      );
}

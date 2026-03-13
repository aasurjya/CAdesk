import 'dart:async';

import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/domain/repositories/itr_filing_repository.dart';

class MockItrFilingRepository implements ItrFilingRepository {
  static final List<ItrClient> _seedFilings = [
    ItrClient(
      id: 'mock-itr-001',
      name: 'Rajesh Kumar Sharma',
      pan: 'ABCPS1234K',
      aadhaar: '9876 5432 1098',
      email: 'rajesh.sharma@email.com',
      phone: '+91 98765 43210',
      itrType: ItrType.itr1,
      assessmentYear: 'AY 2026-27',
      filingStatus: FilingStatus.filed,
      totalIncome: 850000,
      taxPayable: 32500,
      refundDue: 0,
      filedDate: DateTime(2025, 7, 15),
      acknowledgementNumber: 'ACK2025071500001',
    ),
    ItrClient(
      id: 'mock-itr-002',
      name: 'Priya Nair',
      pan: 'BKNPN5678L',
      aadhaar: '8765 4321 0987',
      email: 'priya.nair@email.com',
      phone: '+91 87654 32109',
      itrType: ItrType.itr2,
      assessmentYear: 'AY 2026-27',
      filingStatus: FilingStatus.verified,
      totalIncome: 2450000,
      taxPayable: 375000,
      refundDue: 12000,
      filedDate: DateTime(2025, 7, 20),
      acknowledgementNumber: 'ACK2025072000002',
    ),
    ItrClient(
      id: 'mock-itr-003',
      name: 'Amit Patel',
      pan: 'CFGPP9012M',
      aadhaar: '7654 3210 9876',
      email: 'amit.patel@email.com',
      phone: '+91 76543 21098',
      itrType: ItrType.itr3,
      assessmentYear: 'AY 2026-27',
      filingStatus: FilingStatus.inProgress,
      totalIncome: 4200000,
      taxPayable: 825000,
      refundDue: 0,
    ),
    ItrClient(
      id: 'mock-itr-004',
      name: 'Sunita Deshmukh',
      pan: 'DHMPD3456N',
      aadhaar: '6543 2109 8765',
      email: 'sunita.d@email.com',
      phone: '+91 65432 10987',
      itrType: ItrType.itr4,
      assessmentYear: 'AY 2026-27',
      filingStatus: FilingStatus.processed,
      totalIncome: 1200000,
      taxPayable: 117000,
      refundDue: 5400,
      filedDate: DateTime(2025, 6, 28),
      acknowledgementNumber: 'ACK2025062800004',
    ),
    ItrClient(
      id: 'mock-itr-005',
      name: 'Vikram Singh Rathore',
      pan: 'EKRPV7890P',
      aadhaar: '5432 1098 7654',
      email: 'vikram.rathore@email.com',
      phone: '+91 54321 09876',
      itrType: ItrType.itr5,
      assessmentYear: 'AY 2026-27',
      filingStatus: FilingStatus.pending,
      totalIncome: 720000,
      taxPayable: 22100,
      refundDue: 0,
    ),
  ];

  final List<ItrClient> _state = List.of(_seedFilings);
  final StreamController<List<ItrClient>> _controller =
      StreamController<List<ItrClient>>.broadcast();

  @override
  Future<List<ItrClient>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<ItrClient?> getById(String id) async {
    try {
      return _state.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ItrClient> create(ItrClient filing) async {
    _state.add(filing);
    _controller.add(List.unmodifiable(_state));
    return filing;
  }

  @override
  Future<ItrClient> update(ItrClient filing) async {
    final idx = _state.indexWhere((f) => f.id == filing.id);
    if (idx == -1) throw StateError('ItrClient not found: ${filing.id}');
    final updated = List<ItrClient>.of(_state)..[idx] = filing;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return filing;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((f) => f.id == id);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<ItrClient>> search(String query, {String? firmId}) async {
    final q = query.toLowerCase();
    return _state
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.pan.toLowerCase().contains(q) ||
              f.assessmentYear.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<List<ItrClient>> getByAssessmentYear(
    String ay, {
    String? firmId,
  }) async => _state.where((f) => f.assessmentYear == ay).toList();

  @override
  Stream<List<ItrClient>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}

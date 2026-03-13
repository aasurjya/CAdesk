import 'dart:async';

import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/repositories/tds_challan_repository.dart';

class MockTdsChallanRepository implements TdsChallanRepository {
  static const List<TdsChallan> _seedChallans = [
    TdsChallan(
      id: 'challan-1',
      deductorId: 'deductor-abc-infra',
      challanNumber: 'ITNS281-2025-0101',
      bsrCode: '0002390',
      section: '192',
      deducteeCount: 45,
      tdsAmount: 85000.0,
      surcharge: 0.0,
      educationCess: 3400.0,
      interest: 0.0,
      penalty: 0.0,
      totalAmount: 88400.0,
      paymentDate: '07 Apr 2025',
      month: 4,
      financialYear: '2025-26',
      status: 'Paid',
    ),
    TdsChallan(
      id: 'challan-2',
      deductorId: 'deductor-abc-infra',
      challanNumber: 'ITNS281-2025-0202',
      bsrCode: '0002390',
      section: '194J',
      deducteeCount: 12,
      tdsAmount: 45000.0,
      surcharge: 0.0,
      educationCess: 1800.0,
      interest: 500.0,
      penalty: 0.0,
      totalAmount: 47300.0,
      paymentDate: '12 Jun 2025',
      month: 6,
      financialYear: '2025-26',
      status: 'Paid',
    ),
    TdsChallan(
      id: 'challan-3',
      deductorId: 'deductor-techvista',
      challanNumber: 'ITNS281-2025-0303',
      bsrCode: '0004510',
      section: '194C',
      deducteeCount: 8,
      tdsAmount: 22000.0,
      surcharge: 0.0,
      educationCess: 880.0,
      interest: 0.0,
      penalty: 0.0,
      totalAmount: 22880.0,
      paymentDate: '07 Sep 2025',
      month: 9,
      financialYear: '2025-26',
      status: 'Paid',
    ),
    TdsChallan(
      id: 'challan-4',
      deductorId: 'deductor-techvista',
      challanNumber: 'ITNS281-2025-0404',
      bsrCode: '0004510',
      section: '194I',
      deducteeCount: 3,
      tdsAmount: 36000.0,
      surcharge: 0.0,
      educationCess: 1440.0,
      interest: 1800.0,
      penalty: 0.0,
      totalAmount: 39240.0,
      paymentDate: '15 Nov 2025',
      month: 11,
      financialYear: '2025-26',
      status: 'Overdue',
    ),
    TdsChallan(
      id: 'challan-5',
      deductorId: 'deductor-abc-infra',
      challanNumber: 'ITNS281-2026-0101',
      bsrCode: '0002390',
      section: '192',
      deducteeCount: 47,
      tdsAmount: 92000.0,
      surcharge: 0.0,
      educationCess: 3680.0,
      interest: 0.0,
      penalty: 0.0,
      totalAmount: 95680.0,
      paymentDate: '07 Jan 2026',
      month: 1,
      financialYear: '2025-26',
      status: 'Due',
    ),
  ];

  final List<TdsChallan> _state = List.of(_seedChallans);
  final StreamController<List<TdsChallan>> _controller =
      StreamController<List<TdsChallan>>.broadcast();

  @override
  Future<List<TdsChallan>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<TdsChallan?> getById(String id) async {
    try {
      return _state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TdsChallan> create(TdsChallan challan) async {
    _state.add(challan);
    _controller.add(List.unmodifiable(_state));
    return challan;
  }

  @override
  Future<TdsChallan> update(TdsChallan challan) async {
    final idx = _state.indexWhere((c) => c.id == challan.id);
    if (idx == -1) {
      throw StateError('TdsChallan not found: ${challan.id}');
    }
    final updated = List<TdsChallan>.of(_state)..[idx] = challan;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return challan;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((c) => c.id == id);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<TdsChallan>> getByDeductorId(String deductorId) async =>
      List.unmodifiable(
        _state.where((c) => c.deductorId == deductorId).toList(),
      );

  @override
  Stream<List<TdsChallan>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}

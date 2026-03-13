import 'dart:async';

import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/repositories/tds_return_repository.dart';

class MockTdsReturnRepository implements TdsReturnRepository {
  static final List<TdsReturn> _seedReturns = [
    const TdsReturn(
      id: 'tds-return-1',
      deductorId: 'deductor-abc-infra',
      tan: 'DELA12345B',
      formType: TdsFormType.form24Q,
      quarter: TdsQuarter.q1,
      financialYear: '2025-26',
      status: TdsReturnStatus.filed,
      totalDeductions: 850000.0,
      totalTaxDeducted: 85000.0,
      totalDeposited: 85000.0,
      filedDate: null,
      tokenNumber: 'TOKEN-24Q-Q1-2025',
    ),
    const TdsReturn(
      id: 'tds-return-2',
      deductorId: 'deductor-abc-infra',
      tan: 'DELA12345B',
      formType: TdsFormType.form26Q,
      quarter: TdsQuarter.q2,
      financialYear: '2025-26',
      status: TdsReturnStatus.prepared,
      totalDeductions: 320000.0,
      totalTaxDeducted: 32000.0,
      totalDeposited: 32000.0,
      filedDate: null,
      tokenNumber: null,
    ),
    const TdsReturn(
      id: 'tds-return-3',
      deductorId: 'deductor-techvista',
      tan: 'BLRT56789A',
      formType: TdsFormType.form24Q,
      quarter: TdsQuarter.q3,
      financialYear: '2025-26',
      status: TdsReturnStatus.pending,
      totalDeductions: 1200000.0,
      totalTaxDeducted: 156000.0,
      totalDeposited: 156000.0,
      filedDate: null,
      tokenNumber: null,
    ),
    const TdsReturn(
      id: 'tds-return-4',
      deductorId: 'deductor-techvista',
      tan: 'BLRT56789A',
      formType: TdsFormType.form26Q,
      quarter: TdsQuarter.q1,
      financialYear: '2024-25',
      status: TdsReturnStatus.revised,
      totalDeductions: 480000.0,
      totalTaxDeducted: 48000.0,
      totalDeposited: 48000.0,
      filedDate: null,
      tokenNumber: 'TOKEN-26Q-Q1-2024-REV',
    ),
  ];

  final List<TdsReturn> _state = List.of(_seedReturns);
  final StreamController<List<TdsReturn>> _controller =
      StreamController<List<TdsReturn>>.broadcast();

  @override
  Future<List<TdsReturn>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<TdsReturn?> getById(String id) async {
    try {
      return _state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TdsReturn> create(TdsReturn tdsReturn) async {
    _state.add(tdsReturn);
    _controller.add(List.unmodifiable(_state));
    return tdsReturn;
  }

  @override
  Future<TdsReturn> update(TdsReturn tdsReturn) async {
    final idx = _state.indexWhere((r) => r.id == tdsReturn.id);
    if (idx == -1) {
      throw StateError('TdsReturn not found: ${tdsReturn.id}');
    }
    final updated = List<TdsReturn>.of(_state)..[idx] = tdsReturn;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return tdsReturn;
  }

  @override
  Future<void> delete(String id) async {
    _state.removeWhere((r) => r.id == id);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<TdsReturn>> getByFinancialYear(
    String fy, {
    String? firmId,
  }) async =>
      List.unmodifiable(_state.where((r) => r.financialYear == fy).toList());

  @override
  Future<List<TdsReturn>> getByDeductorId(String deductorId) async =>
      List.unmodifiable(
        _state.where((r) => r.deductorId == deductorId).toList(),
      );

  @override
  Stream<List<TdsReturn>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}

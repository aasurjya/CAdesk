import 'dart:async';

import 'package:ca_app/features/gst/domain/models/gst_return.dart';
import 'package:ca_app/features/gst/domain/repositories/gst_return_repository.dart';

class MockGstReturnRepository implements GstReturnRepository {
  static final List<GstReturn> _seedReturns = [
    GstReturn(
      id: 'gst-return-1',
      clientId: 'gst-client-1',
      gstin: '27AABCA1234C1Z5',
      returnType: GstReturnType.gstr1,
      periodMonth: 2,
      periodYear: 2026,
      dueDate: DateTime(2026, 3, 11),
      status: GstReturnStatus.pending,
      taxableValue: 850000,
      igst: 0,
      cgst: 76500,
      sgst: 76500,
      cess: 0,
      itcClaimed: 0,
    ),
    GstReturn(
      id: 'gst-return-2',
      clientId: 'gst-client-1',
      gstin: '27AABCA1234C1Z5',
      returnType: GstReturnType.gstr3b,
      periodMonth: 2,
      periodYear: 2026,
      dueDate: DateTime(2026, 3, 20),
      status: GstReturnStatus.pending,
      taxableValue: 850000,
      igst: 0,
      cgst: 76500,
      sgst: 76500,
      cess: 0,
      itcClaimed: 45000,
    ),
    GstReturn(
      id: 'gst-return-3',
      clientId: 'gst-client-2',
      gstin: '24AAPFM5678D1Z8',
      returnType: GstReturnType.gstr1,
      periodMonth: 1,
      periodYear: 2026,
      dueDate: DateTime(2026, 2, 11),
      filedDate: DateTime(2026, 2, 18),
      status: GstReturnStatus.filed,
      taxableValue: 320000,
      igst: 0,
      cgst: 16000,
      sgst: 16000,
      cess: 0,
      itcClaimed: 0,
    ),
    GstReturn(
      id: 'gst-return-4',
      clientId: 'gst-client-3',
      gstin: '29AAFT1234F1Z2',
      returnType: GstReturnType.gstr3b,
      periodMonth: 1,
      periodYear: 2026,
      dueDate: DateTime(2026, 2, 20),
      filedDate: DateTime(2026, 2, 28),
      status: GstReturnStatus.lateFiled,
      taxableValue: 1250000,
      igst: 125000,
      cgst: 0,
      sgst: 0,
      cess: 0,
      itcClaimed: 98000,
    ),
    GstReturn(
      id: 'gst-return-5',
      clientId: 'gst-client-3',
      gstin: '29AAFT1234F1Z2',
      returnType: GstReturnType.gstr9,
      periodMonth: 3,
      periodYear: 2025,
      dueDate: DateTime(2025, 12, 31),
      filedDate: DateTime(2025, 12, 20),
      status: GstReturnStatus.filed,
      taxableValue: 14500000,
      igst: 650000,
      cgst: 0,
      sgst: 0,
      cess: 12000,
      itcClaimed: 580000,
    ),
  ];

  final List<GstReturn> _state = List.of(_seedReturns);
  final StreamController<List<GstReturn>> _controller =
      StreamController<List<GstReturn>>.broadcast();

  @override
  Future<List<GstReturn>> getAll({String? firmId}) async =>
      List.unmodifiable(_state);

  @override
  Future<List<GstReturn>> getByClientId(String clientId) async =>
      _state.where((r) => r.clientId == clientId).toList();

  @override
  Future<GstReturn?> getById(String id) async {
    try {
      return _state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<GstReturn> create(GstReturn gstReturn) async {
    final updated = List<GstReturn>.of(_state)..add(gstReturn);
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return gstReturn;
  }

  @override
  Future<GstReturn> update(GstReturn gstReturn) async {
    final idx = _state.indexWhere((r) => r.id == gstReturn.id);
    if (idx == -1) throw StateError('GstReturn not found: ${gstReturn.id}');
    final updated = List<GstReturn>.of(_state)..[idx] = gstReturn;
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return gstReturn;
  }

  @override
  Future<void> delete(String id) async {
    final updated = List<GstReturn>.of(_state)..removeWhere((r) => r.id == id);
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<GstReturn>> getByPeriod(
    int month,
    int year, {
    String? firmId,
  }) async => _state
      .where((r) => r.periodMonth == month && r.periodYear == year)
      .toList();

  @override
  Stream<List<GstReturn>> watchAll({String? firmId}) => _controller.stream;

  void dispose() => _controller.close();
}

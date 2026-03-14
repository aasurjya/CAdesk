import 'dart:async';

import 'package:ca_app/features/filing/domain/models/filing_record.dart';
import 'package:ca_app/features/filing/domain/repositories/filing_record_repository.dart';

class MockFilingRecordRepository implements FilingRecordRepository {
  static final List<FilingRecord> _seed = [
    FilingRecord(
      id: 'fr-001',
      clientId: 'client-1',
      filingType: FilingType.itr1,
      financialYear: '2024-25',
      status: FilingStatus.filed,
      filedDate: DateTime(2025, 7, 15),
      acknowledgementNumber: 'ITR-ACK-2025-001',
      createdAt: DateTime(2025, 4, 1),
      updatedAt: DateTime(2025, 7, 15),
    ),
    FilingRecord(
      id: 'fr-002',
      clientId: 'client-1',
      filingType: FilingType.gstr1,
      financialYear: '2024-25',
      status: FilingStatus.pending,
      createdAt: DateTime(2025, 3, 1),
      updatedAt: DateTime(2025, 3, 1),
    ),
    FilingRecord(
      id: 'fr-003',
      clientId: 'client-2',
      filingType: FilingType.tds24q,
      financialYear: '2024-25',
      status: FilingStatus.verified,
      filedDate: DateTime(2025, 5, 15),
      acknowledgementNumber: 'TDS-ACK-2025-001',
      createdAt: DateTime(2025, 4, 1),
      updatedAt: DateTime(2025, 5, 15),
    ),
  ];

  final List<FilingRecord> _state = List.of(_seed);
  final StreamController<List<FilingRecord>> _controller =
      StreamController<List<FilingRecord>>.broadcast();

  @override
  Future<void> insert(FilingRecord record) async {
    _state.add(record);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<FilingRecord>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((r) => r.clientId == clientId).toList());

  @override
  Future<List<FilingRecord>> getByType(FilingType type) async =>
      List.unmodifiable(_state.where((r) => r.filingType == type).toList());

  @override
  Future<List<FilingRecord>> getByStatus(FilingStatus status) async =>
      List.unmodifiable(_state.where((r) => r.status == status).toList());

  @override
  Future<bool> updateStatus(String id, FilingStatus status) async {
    final idx = _state.indexWhere((r) => r.id == id);
    if (idx == -1) return false;
    final updated = List<FilingRecord>.of(_state);
    updated[idx] = _state[idx].copyWith(status: status);
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return true;
  }

  @override
  Future<List<FilingRecord>> getOverdue() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return List.unmodifiable(
      _state
          .where(
            (r) =>
                r.filedDate == null &&
                (r.status == FilingStatus.pending ||
                    r.status == FilingStatus.inProgress) &&
                r.createdAt.isBefore(cutoff),
          )
          .toList(),
    );
  }

  @override
  Future<FilingRecord?> getById(String id) async {
    try {
      return _state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<FilingRecord>> watchByClient(String clientId) => _controller
      .stream
      .map((list) => list.where((r) => r.clientId == clientId).toList());

  void dispose() => _controller.close();
}

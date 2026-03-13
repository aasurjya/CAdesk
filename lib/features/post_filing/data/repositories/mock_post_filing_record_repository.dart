import 'dart:async';

import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';
import 'package:ca_app/features/post_filing/domain/repositories/post_filing_record_repository.dart';

class MockPostFilingRecordRepository implements PostFilingRecordRepository {
  static final List<PostFilingRecord> _seed = [
    PostFilingRecord(
      id: 'pfr-001',
      clientId: 'client-1',
      filingId: 'fr-001',
      activityType: PostFilingActivity.itrVDownload,
      status: PostFilingStatus.completed,
      completedAt: DateTime(2025, 7, 15, 10),
      createdAt: DateTime(2025, 7, 15),
    ),
    PostFilingRecord(
      id: 'pfr-002',
      clientId: 'client-1',
      filingId: 'fr-001',
      activityType: PostFilingActivity.eVerification,
      status: PostFilingStatus.completed,
      completedAt: DateTime(2025, 7, 16),
      notes: 'Verified via Aadhaar OTP',
      createdAt: DateTime(2025, 7, 15),
    ),
    PostFilingRecord(
      id: 'pfr-003',
      clientId: 'client-2',
      filingId: 'fr-003',
      activityType: PostFilingActivity.refundClaim,
      status: PostFilingStatus.pending,
      createdAt: DateTime(2025, 9, 20),
    ),
  ];

  final List<PostFilingRecord> _state = List.of(_seed);
  final StreamController<List<PostFilingRecord>> _controller =
      StreamController<List<PostFilingRecord>>.broadcast();

  @override
  Future<void> insert(PostFilingRecord record) async {
    _state.add(record);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<PostFilingRecord>> getByFiling(String filingId) async =>
      List.unmodifiable(
        _state.where((r) => r.filingId == filingId).toList(),
      );

  @override
  Future<List<PostFilingRecord>> getByClient(String clientId) async =>
      List.unmodifiable(
        _state.where((r) => r.clientId == clientId).toList(),
      );

  @override
  Future<bool> updateStatus(
    String id,
    PostFilingStatus status, {
    DateTime? completedAt,
    String? notes,
  }) async {
    final idx = _state.indexWhere((r) => r.id == id);
    if (idx == -1) return false;
    final updated = List<PostFilingRecord>.of(_state);
    updated[idx] = _state[idx].copyWith(
      status: status,
      completedAt: completedAt,
      notes: notes,
    );
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return true;
  }

  @override
  Future<List<PostFilingRecord>> getPending() async =>
      List.unmodifiable(
        _state.where((r) => r.status == PostFilingStatus.pending).toList(),
      );

  @override
  Future<PostFilingRecord?> getById(String id) async {
    try {
      return _state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<PostFilingRecord>> watchByClient(String clientId) =>
      _controller.stream.map(
        (list) => list.where((r) => r.clientId == clientId).toList(),
      );

  void dispose() => _controller.close();
}

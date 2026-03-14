import 'dart:async';

import 'package:ca_app/features/portal_export/domain/models/export_job.dart';
import 'package:ca_app/features/portal_export/domain/repositories/export_job_repository.dart';

class MockExportJobRepository implements ExportJobRepository {
  static final List<ExportJob> _seed = [
    ExportJob(
      id: 'ej-001',
      clientId: 'client-1',
      exportType: ExportType.itrXml,
      status: ExportJobStatus.completed,
      createdAt: DateTime(2025, 7, 1),
      completedAt: DateTime(2025, 7, 1, 1),
      filePath: '/exports/itr_client1_2025.xml',
    ),
    ExportJob(
      id: 'ej-002',
      clientId: 'client-1',
      exportType: ExportType.gstrJson,
      status: ExportJobStatus.queued,
      createdAt: DateTime(2025, 7, 10),
    ),
    ExportJob(
      id: 'ej-003',
      clientId: 'client-2',
      exportType: ExportType.tdsFvu,
      status: ExportJobStatus.failed,
      createdAt: DateTime(2025, 6, 15),
      errorMessage: 'FVU validation failed: challan mismatch',
    ),
  ];

  final List<ExportJob> _state = List.of(_seed);
  final StreamController<List<ExportJob>> _controller =
      StreamController<List<ExportJob>>.broadcast();

  @override
  Future<void> insert(ExportJob job) async {
    _state.add(job);
    _controller.add(List.unmodifiable(_state));
  }

  @override
  Future<List<ExportJob>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((j) => j.clientId == clientId).toList());

  @override
  Future<List<ExportJob>> getByStatus(ExportJobStatus status) async =>
      List.unmodifiable(_state.where((j) => j.status == status).toList());

  @override
  Future<bool> updateStatus(
    String id,
    ExportJobStatus status, {
    String? filePath,
    String? errorMessage,
    DateTime? completedAt,
  }) async {
    final idx = _state.indexWhere((j) => j.id == id);
    if (idx == -1) return false;
    final updated = List<ExportJob>.of(_state);
    updated[idx] = _state[idx].copyWith(
      status: status,
      filePath: filePath,
      errorMessage: errorMessage,
      completedAt: completedAt,
    );
    _state
      ..clear()
      ..addAll(updated);
    _controller.add(List.unmodifiable(_state));
    return true;
  }

  @override
  Future<int> deleteOldJobs(DateTime beforeDate) async {
    final before = _state.where((j) => j.createdAt.isBefore(beforeDate));
    final count = before.length;
    _state.removeWhere((j) => j.createdAt.isBefore(beforeDate));
    _controller.add(List.unmodifiable(_state));
    return count;
  }

  @override
  Future<ExportJob?> getById(String id) async {
    try {
      return _state.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<ExportJob>> watchByClient(String clientId) => _controller.stream
      .map((list) => list.where((j) => j.clientId == clientId).toList());

  void dispose() => _controller.close();
}

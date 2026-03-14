import 'package:uuid/uuid.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';
import 'package:ca_app/features/ocr/domain/repositories/ocr_repository.dart';

const _uuid = Uuid();

class MockOcrRepository implements OcrRepository {
  final List<OcrJob> _jobs = [];

  @override
  Future<void> insert(OcrJob job) async {
    final effective = job.id.isEmpty ? job.copyWith(id: _uuid.v4()) : job;
    _jobs.add(effective);
  }

  @override
  Future<List<OcrJob>> getByClient(String clientId) async {
    return List.unmodifiable(
      _jobs.where((j) => j.clientId == clientId).toList(),
    );
  }

  @override
  Future<List<OcrJob>> getByStatus(OcrStatus status) async {
    return List.unmodifiable(_jobs.where((j) => j.status == status).toList());
  }

  @override
  Future<bool> updateStatus(
    String id,
    OcrStatus status, {
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return false;
    final updated = _jobs[idx].copyWith(
      status: status,
      completedAt: completedAt,
      errorMessage: errorMessage,
    );
    _jobs[idx] = updated;
    return true;
  }

  @override
  Future<bool> updateParsedData(
    String id,
    String parsedDataJson,
    double confidence,
  ) async {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return false;
    final updated = _jobs[idx].copyWith(
      parsedData: parsedDataJson,
      confidence: confidence,
    );
    _jobs[idx] = updated;
    return true;
  }

  @override
  Future<List<OcrJob>> getByDocType(OcrDocType documentType) async {
    return List.unmodifiable(
      _jobs.where((j) => j.documentType == documentType).toList(),
    );
  }

  @override
  Future<int> cleanup(DateTime beforeDate) async {
    final before = _jobs.where((j) => j.createdAt.isBefore(beforeDate)).length;
    _jobs.removeWhere((j) => j.createdAt.isBefore(beforeDate));
    return before;
  }
}

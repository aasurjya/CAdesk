import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/ocr/data/mappers/ocr_mapper.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';

class OcrLocalSource {
  const OcrLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(OcrJob job) =>
      _db.ocrDao.insert(OcrMapper.toCompanion(job));

  Future<List<OcrJob>> getByClient(String clientId) async {
    final rows = await _db.ocrDao.getByClient(clientId);
    return rows.map(OcrMapper.fromRow).toList();
  }

  Future<List<OcrJob>> getByStatus(OcrStatus status) async {
    final rows = await _db.ocrDao.getByStatus(status.name);
    return rows.map(OcrMapper.fromRow).toList();
  }

  Future<bool> updateStatus(
    String id,
    OcrStatus status, {
    DateTime? completedAt,
    String? errorMessage,
  }) => _db.ocrDao.updateStatus(
    id,
    status.name,
    completedAt: completedAt,
    errorMessage: errorMessage,
  );

  Future<bool> updateParsedData(
    String id,
    String parsedDataJson,
    double confidence,
  ) => _db.ocrDao.updateParsedData(id, parsedDataJson, confidence);

  Future<List<OcrJob>> getByDocType(OcrDocType documentType) async {
    final rows = await _db.ocrDao.getByDocType(documentType.name);
    return rows.map(OcrMapper.fromRow).toList();
  }

  Future<int> cleanup(DateTime beforeDate) => _db.ocrDao.cleanup(beforeDate);
}

import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';

abstract class OcrRepository {
  Future<void> insert(OcrJob job);
  Future<List<OcrJob>> getByClient(String clientId);
  Future<List<OcrJob>> getByStatus(OcrStatus status);
  Future<bool> updateStatus(
    String id,
    OcrStatus status, {
    DateTime? completedAt,
    String? errorMessage,
  });
  Future<bool> updateParsedData(
    String id,
    String parsedDataJson,
    double confidence,
  );
  Future<List<OcrJob>> getByDocType(OcrDocType documentType);
  Future<int> cleanup(DateTime beforeDate);
}

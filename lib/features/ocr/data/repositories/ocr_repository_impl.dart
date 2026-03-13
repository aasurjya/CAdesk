import 'package:ca_app/features/ocr/data/datasources/ocr_local_source.dart';
import 'package:ca_app/features/ocr/data/datasources/ocr_remote_source.dart';
import 'package:ca_app/features/ocr/data/mappers/ocr_mapper.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';
import 'package:ca_app/features/ocr/domain/repositories/ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository {
  const OcrRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final OcrRemoteSource remote;
  final OcrLocalSource local;

  @override
  Future<void> insert(OcrJob job) async {
    try {
      await remote.insert(OcrMapper.toJson(job));
    } catch (_) {
      // No-op — fall through to local write
    }
    await local.insert(job);
  }

  @override
  Future<List<OcrJob>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final jobs = jsonList.map(OcrMapper.fromJson).toList();
      for (final job in jobs) {
        await local.insert(job);
      }
      return List.unmodifiable(jobs);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<OcrJob>> getByStatus(OcrStatus status) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      final jobs = jsonList.map(OcrMapper.fromJson).toList();
      return List.unmodifiable(jobs);
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<bool> updateStatus(
    String id,
    OcrStatus status, {
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    try {
      await remote.updateStatus(
        id,
        status.name,
        completedAt: completedAt,
        errorMessage: errorMessage,
      );
    } catch (_) {
      // No-op — always update local
    }
    return local.updateStatus(
      id,
      status,
      completedAt: completedAt,
      errorMessage: errorMessage,
    );
  }

  @override
  Future<bool> updateParsedData(
    String id,
    String parsedDataJson,
    double confidence,
  ) async {
    try {
      await remote.updateParsedData(id, parsedDataJson, confidence);
    } catch (_) {
      // No-op — always update local
    }
    return local.updateParsedData(id, parsedDataJson, confidence);
  }

  @override
  Future<List<OcrJob>> getByDocType(OcrDocType documentType) async {
    try {
      final jsonList = await remote.fetchByDocType(documentType.name);
      final jobs = jsonList.map(OcrMapper.fromJson).toList();
      return List.unmodifiable(jobs);
    } catch (_) {
      return local.getByDocType(documentType);
    }
  }

  @override
  Future<int> cleanup(DateTime beforeDate) => local.cleanup(beforeDate);
}

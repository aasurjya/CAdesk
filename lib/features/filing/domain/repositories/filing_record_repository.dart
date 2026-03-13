import 'package:ca_app/features/filing/domain/models/filing_record.dart';

abstract class FilingRecordRepository {
  Future<void> insert(FilingRecord record);
  Future<List<FilingRecord>> getByClient(String clientId);
  Future<List<FilingRecord>> getByType(FilingType type);
  Future<List<FilingRecord>> getByStatus(FilingStatus status);
  Future<bool> updateStatus(String id, FilingStatus status);
  Future<List<FilingRecord>> getOverdue();
  Future<FilingRecord?> getById(String id);
  Stream<List<FilingRecord>> watchByClient(String clientId);
}

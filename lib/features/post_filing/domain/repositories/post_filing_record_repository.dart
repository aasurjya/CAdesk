import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';

abstract class PostFilingRecordRepository {
  Future<void> insert(PostFilingRecord record);
  Future<List<PostFilingRecord>> getByFiling(String filingId);
  Future<List<PostFilingRecord>> getByClient(String clientId);
  Future<bool> updateStatus(
    String id,
    PostFilingStatus status, {
    DateTime? completedAt,
    String? notes,
  });
  Future<List<PostFilingRecord>> getPending();
  Future<PostFilingRecord?> getById(String id);
  Stream<List<PostFilingRecord>> watchByClient(String clientId);
}

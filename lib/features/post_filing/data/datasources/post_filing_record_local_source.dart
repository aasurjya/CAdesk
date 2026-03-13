import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/post_filing/data/mappers/post_filing_record_mapper.dart';
import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';

class PostFilingRecordLocalSource {
  const PostFilingRecordLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(PostFilingRecord record) async {
    await _db.postFilingRecordsDao.insertRecord(
      PostFilingRecordMapper.toCompanion(record),
    );
  }

  Future<List<PostFilingRecord>> getByFiling(String filingId) async {
    final rows = await _db.postFilingRecordsDao.getByFiling(filingId);
    return rows.map(PostFilingRecordMapper.fromRow).toList();
  }

  Future<List<PostFilingRecord>> getByClient(String clientId) async {
    final rows = await _db.postFilingRecordsDao.getByClient(clientId);
    return rows.map(PostFilingRecordMapper.fromRow).toList();
  }

  Stream<List<PostFilingRecord>> watchByClient(String clientId) {
    return _db.postFilingRecordsDao
        .watchByClient(clientId)
        .map((rows) => rows.map(PostFilingRecordMapper.fromRow).toList());
  }

  Future<bool> updateStatus(
    String id,
    PostFilingStatus status, {
    DateTime? completedAt,
    String? notes,
  }) =>
      _db.postFilingRecordsDao.updateStatus(
        id,
        status.name,
        completedAt: completedAt,
        notes: notes,
      );

  Future<List<PostFilingRecord>> getPending() async {
    final rows = await _db.postFilingRecordsDao.getPending();
    return rows.map(PostFilingRecordMapper.fromRow).toList();
  }

  Future<PostFilingRecord?> getById(String id) async {
    final row = await _db.postFilingRecordsDao.getById(id);
    return row != null ? PostFilingRecordMapper.fromRow(row) : null;
  }

  Future<void> upsert(PostFilingRecord record) async {
    await _db.postFilingRecordsDao.upsert(
      PostFilingRecordMapper.toCompanion(record),
    );
  }
}

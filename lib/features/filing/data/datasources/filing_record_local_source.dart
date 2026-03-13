import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/filing/data/mappers/filing_record_mapper.dart';
import 'package:ca_app/features/filing/domain/models/filing_record.dart';

class FilingRecordLocalSource {
  const FilingRecordLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(FilingRecord record) async {
    await _db.filingRecordsDao.insertRecord(
      FilingRecordMapper.toCompanion(record),
    );
  }

  Future<List<FilingRecord>> getByClient(String clientId) async {
    final rows = await _db.filingRecordsDao.getByClient(clientId);
    return rows.map(FilingRecordMapper.fromRow).toList();
  }

  Stream<List<FilingRecord>> watchByClient(String clientId) {
    return _db.filingRecordsDao
        .watchByClient(clientId)
        .map((rows) => rows.map(FilingRecordMapper.fromRow).toList());
  }

  Future<List<FilingRecord>> getByType(FilingType type) async {
    final rows = await _db.filingRecordsDao.getByType(type.name);
    return rows.map(FilingRecordMapper.fromRow).toList();
  }

  Future<List<FilingRecord>> getByStatus(FilingStatus status) async {
    final rows = await _db.filingRecordsDao.getByStatus(status.name);
    return rows.map(FilingRecordMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, FilingStatus status) =>
      _db.filingRecordsDao.updateStatus(id, status.name);

  Future<List<FilingRecord>> getOverdue() async {
    final rows = await _db.filingRecordsDao.getOverdue();
    return rows.map(FilingRecordMapper.fromRow).toList();
  }

  Future<FilingRecord?> getById(String id) async {
    final row = await _db.filingRecordsDao.getById(id);
    return row != null ? FilingRecordMapper.fromRow(row) : null;
  }

  Future<void> upsert(FilingRecord record) async {
    await _db.filingRecordsDao.upsert(FilingRecordMapper.toCompanion(record));
  }
}

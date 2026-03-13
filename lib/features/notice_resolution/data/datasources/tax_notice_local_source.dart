import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/notice_resolution/data/mappers/tax_notice_mapper.dart';
import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';

class TaxNoticeLocalSource {
  const TaxNoticeLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(TaxNotice notice) =>
      _db.taxNoticesDao.insertNotice(TaxNoticeMapper.toCompanion(notice));

  Future<List<TaxNotice>> getByClient(String clientId) async {
    final rows = await _db.taxNoticesDao.getByClient(clientId);
    return rows.map(TaxNoticeMapper.fromRow).toList();
  }

  Future<List<TaxNotice>> getByType(NoticeType noticeType) async {
    final rows = await _db.taxNoticesDao.getByType(noticeType.name);
    return rows.map(TaxNoticeMapper.fromRow).toList();
  }

  Future<List<TaxNotice>> getByStatus(NoticeStatus status) async {
    final rows = await _db.taxNoticesDao.getByStatus(status.name);
    return rows.map(TaxNoticeMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, NoticeStatus status) =>
      _db.taxNoticesDao.updateStatus(id, status.name);

  Future<List<TaxNotice>> getOverdue(DateTime asOf) async {
    final rows = await _db.taxNoticesDao.getOverdue(asOf);
    return rows.map(TaxNoticeMapper.fromRow).toList();
  }

  Future<TaxNotice?> getById(String id) async {
    final row = await _db.taxNoticesDao.getById(id);
    return row != null ? TaxNoticeMapper.fromRow(row) : null;
  }

  Future<void> delete(String id) => _db.taxNoticesDao.deleteNotice(id);
}

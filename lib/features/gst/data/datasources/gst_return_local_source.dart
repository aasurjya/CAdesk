import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/gst/data/mappers/gst_return_mapper.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';

class GstReturnLocalSource {
  const GstReturnLocalSource(this._db);

  final AppDatabase _db;

  Future<List<GstReturn>> getAll({String firmId = ''}) async {
    final rows = await _db.gstDao.getAllReturns(firmId);
    return rows.map(GstReturnMapper.fromRow).toList();
  }

  Future<List<GstReturn>> getByClientId(String clientId) async {
    final rows = await _db.gstDao.getReturnsByClientId(clientId);
    return rows.map(GstReturnMapper.fromRow).toList();
  }

  Future<GstReturn?> getById(String id) async {
    final row = await _db.gstDao.getReturnById(id);
    return row != null ? GstReturnMapper.fromRow(row) : null;
  }

  Future<List<GstReturn>> getByPeriod(
    int month,
    int year, {
    String firmId = '',
  }) async {
    final rows = await _db.gstDao.getReturnsByPeriod(firmId, month, year);
    return rows.map(GstReturnMapper.fromRow).toList();
  }

  Future<void> upsert(GstReturn gstReturn, {String firmId = ''}) async {
    await _db.gstDao.upsertReturn(
      GstReturnMapper.toCompanion(gstReturn, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.gstDao.deleteReturn(id);

  Stream<List<GstReturn>> watchAll({String firmId = ''}) {
    return _db.gstDao
        .watchAllReturns(firmId)
        .map((rows) => rows.map(GstReturnMapper.fromRow).toList());
  }
}

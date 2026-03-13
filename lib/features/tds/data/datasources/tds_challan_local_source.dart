import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/tds/data/mappers/tds_challan_mapper.dart';
import 'package:ca_app/features/tds/domain/models/tds_challan.dart';

class TdsChallanLocalSource {
  const TdsChallanLocalSource(this._db);

  final AppDatabase _db;

  Future<List<TdsChallan>> getAll({String firmId = ''}) async {
    final rows = await _db.tdsDao.getAllChallans(firmId);
    return rows.map(TdsChallanMapper.fromRow).toList();
  }

  Future<TdsChallan?> getById(String id) async {
    final row = await _db.tdsDao.getChallanById(id);
    return row != null ? TdsChallanMapper.fromRow(row) : null;
  }

  Future<List<TdsChallan>> getByDeductorId(String deductorId) async {
    final rows = await _db.tdsDao.getChallansByDeductorId(deductorId);
    return rows.map(TdsChallanMapper.fromRow).toList();
  }

  Future<void> upsert(TdsChallan challan, {String firmId = ''}) async {
    await _db.tdsDao.upsertChallan(
      TdsChallanMapper.toCompanion(challan, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.tdsDao.deleteChallan(id);

  Stream<List<TdsChallan>> watchAll({String firmId = ''}) {
    return _db.tdsDao
        .watchAllChallans(firmId)
        .map((rows) => rows.map(TdsChallanMapper.fromRow).toList());
  }
}

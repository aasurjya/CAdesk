import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/tds/data/mappers/tds_return_mapper.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

class TdsReturnLocalSource {
  const TdsReturnLocalSource(this._db);

  final AppDatabase _db;

  Future<List<TdsReturn>> getAll({String firmId = ''}) async {
    final rows = await _db.tdsDao.getAllReturns(firmId);
    return rows.map(TdsReturnMapper.fromRow).toList();
  }

  Future<TdsReturn?> getById(String id) async {
    final row = await _db.tdsDao.getReturnById(id);
    return row != null ? TdsReturnMapper.fromRow(row) : null;
  }

  Future<List<TdsReturn>> getByFinancialYear(
    String fy, {
    String firmId = '',
  }) async {
    final rows = await _db.tdsDao.getReturnsByFY(firmId, fy);
    return rows.map(TdsReturnMapper.fromRow).toList();
  }

  Future<List<TdsReturn>> getByDeductorId(String deductorId) async {
    final rows = await _db.tdsDao.getReturnsByDeductorId(deductorId);
    return rows.map(TdsReturnMapper.fromRow).toList();
  }

  Future<void> upsert(TdsReturn tdsReturn, {String firmId = ''}) async {
    await _db.tdsDao.upsertReturn(
      TdsReturnMapper.toCompanion(tdsReturn, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.tdsDao.deleteReturn(id);

  Stream<List<TdsReturn>> watchAll({String firmId = ''}) {
    return _db.tdsDao
        .watchAllReturns(firmId)
        .map((rows) => rows.map(TdsReturnMapper.fromRow).toList());
  }
}

import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/vda/data/mappers/vda_record_mapper.dart';
import 'package:ca_app/features/vda/domain/models/vda_record.dart';

class VdaLocalSource {
  const VdaLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(VdaRecord record) =>
      _db.vdaDao.insertRecord(VdaRecordMapper.toCompanion(record));

  Future<List<VdaRecord>> getByClient(String clientId) async {
    final rows = await _db.vdaDao.getByClient(clientId);
    return rows.map(VdaRecordMapper.fromRow).toList();
  }

  Future<List<VdaRecord>> getByYear(String assessmentYear) async {
    final rows = await _db.vdaDao.getByYear(assessmentYear);
    return rows.map(VdaRecordMapper.fromRow).toList();
  }

  Future<double> getTotalGainLoss(
    String clientId,
    String assessmentYear,
  ) =>
      _db.vdaDao.getTotalGainLoss(clientId, assessmentYear);

  Future<double> getTdsDeducted(
    String clientId,
    String assessmentYear,
  ) =>
      _db.vdaDao.getTdsDeducted(clientId, assessmentYear);

  Future<VdaRecord?> getById(String id) async {
    final row = await _db.vdaDao.getById(id);
    return row != null ? VdaRecordMapper.fromRow(row) : null;
  }

  Future<void> delete(String id) => _db.vdaDao.deleteRecord(id);
}

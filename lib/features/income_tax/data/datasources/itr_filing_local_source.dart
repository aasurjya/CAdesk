import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/income_tax/data/mappers/itr_filing_mapper.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';

class ItrFilingLocalSource {
  const ItrFilingLocalSource(this._db);

  final AppDatabase _db;

  Future<List<ItrClient>> getAll({String firmId = ''}) async {
    final rows = await _db.itrFilingsDao.getAll(firmId);
    return rows.map(ItrFilingMapper.fromRow).toList();
  }

  Future<ItrClient?> getById(String id) async {
    final row = await _db.itrFilingsDao.getById(id);
    return row != null ? ItrFilingMapper.fromRow(row) : null;
  }

  Future<void> upsert(ItrClient filing, {String firmId = ''}) async {
    await _db.itrFilingsDao.upsert(
      ItrFilingMapper.toCompanion(filing, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.itrFilingsDao.deleteRecord(id);

  Stream<List<ItrClient>> watchAll({String firmId = ''}) {
    return _db.itrFilingsDao
        .watchAll(firmId)
        .map((rows) => rows.map(ItrFilingMapper.fromRow).toList());
  }

  Future<List<ItrClient>> search(String query, {String firmId = ''}) async {
    final rows = await _db.itrFilingsDao.searchFilings(firmId, query);
    return rows.map(ItrFilingMapper.fromRow).toList();
  }

  Future<List<ItrClient>> getByAssessmentYear(
    String ay, {
    String firmId = '',
  }) async {
    final rows = await _db.itrFilingsDao.getByAssessmentYear(firmId, ay);
    return rows.map(ItrFilingMapper.fromRow).toList();
  }
}

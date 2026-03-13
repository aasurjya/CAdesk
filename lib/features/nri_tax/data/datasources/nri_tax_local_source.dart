import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/nri_tax/data/mappers/nri_tax_mapper.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';

class NriTaxLocalSource {
  const NriTaxLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(NriTaxRecord record) =>
      _db.nriTaxDao.insertRecord(NriTaxMapper.toCompanion(record));

  Future<List<NriTaxRecord>> getByClient(String clientId) async {
    final rows = await _db.nriTaxDao.getByClient(clientId);
    return rows.map(NriTaxMapper.fromRow).toList();
  }

  Future<List<NriTaxRecord>> getByYear(String assessmentYear) async {
    final rows = await _db.nriTaxDao.getByYear(assessmentYear);
    return rows.map(NriTaxMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, NriTaxStatus status) =>
      _db.nriTaxDao.updateStatus(id, status.name);

  Future<List<NriTaxRecord>> getScheduleFARequired() async {
    final rows = await _db.nriTaxDao.getScheduleFARequired();
    return rows.map(NriTaxMapper.fromRow).toList();
  }

  Future<NriTaxRecord?> getById(String id) async {
    final row = await _db.nriTaxDao.getById(id);
    return row != null ? NriTaxMapper.fromRow(row) : null;
  }

  Future<void> delete(String id) => _db.nriTaxDao.deleteRecord(id);
}

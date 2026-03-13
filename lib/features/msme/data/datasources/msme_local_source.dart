import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/msme/data/daos/msme_dao.dart';
import 'package:ca_app/features/msme/data/mappers/msme_mapper.dart';
import 'package:ca_app/features/msme/domain/models/msme_record.dart';

/// Local (SQLite via Drift) data source for MSME records.
class MsmeLocalSource {
  const MsmeLocalSource(this._db);

  final AppDatabase _db;

  MsmeDao get _dao => _db.msmeDao;

  Future<String> insert(MsmeRecord record) =>
      _dao.insertMsmeRecord(MsmeMapper.toCompanion(record));

  Future<List<MsmeRecord>> getByClient(String clientId) async {
    final rows = await _dao.getMsmeRecordsByClient(clientId);
    return rows.map(MsmeMapper.fromRow).toList();
  }

  Future<bool> update(MsmeRecord record) =>
      _dao.updateMsmeRecord(MsmeMapper.toCompanion(record));

  Future<List<MsmeRecord>> getByCategory(MsmeCategory category) async {
    final rows = await _dao.getMsmeRecordsByCategory(category.name);
    return rows.map(MsmeMapper.fromRow).toList();
  }

  Future<List<MsmeRecord>> getByStatus(String status) async {
    final rows = await _dao.getMsmeRecordsByStatus(status);
    return rows.map(MsmeMapper.fromRow).toList();
  }
}

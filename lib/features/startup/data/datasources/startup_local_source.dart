import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/startup/data/daos/startup_dao.dart';
import 'package:ca_app/features/startup/data/mappers/startup_mapper.dart';
import 'package:ca_app/features/startup/domain/models/startup_record.dart';

/// Local (SQLite via Drift) data source for Startup India records.
class StartupLocalSource {
  const StartupLocalSource(this._db);

  final AppDatabase _db;

  StartupDao get _dao => _db.startupDao;

  Future<String> insert(StartupRecord record) =>
      _dao.insertStartupRecord(StartupMapper.toCompanion(record));

  Future<List<StartupRecord>> getByClient(String clientId) async {
    final rows = await _dao.getStartupRecordsByClient(clientId);
    return rows.map(StartupMapper.fromRow).toList();
  }

  Future<bool> update(StartupRecord record) =>
      _dao.updateStartupRecord(StartupMapper.toCompanion(record));

  Future<List<StartupRecord>> getByStatus(String status) async {
    final rows = await _dao.getStartupRecordsByStatus(status);
    return rows.map(StartupMapper.fromRow).toList();
  }

  Future<List<StartupRecord>> getEligibleForExemptions() async {
    final rows = await _dao.getEligibleForExemptions();
    return rows.map(StartupMapper.fromRow).toList();
  }
}

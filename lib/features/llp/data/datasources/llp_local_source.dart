import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/llp/data/daos/llp_dao.dart';
import 'package:ca_app/features/llp/data/mappers/llp_mapper.dart';
import 'package:ca_app/features/llp/domain/models/llp_filing.dart';

/// Local (SQLite via Drift) data source for LLP filings.
class LlpLocalSource {
  const LlpLocalSource(this._db);

  final AppDatabase _db;

  LlpDao get _dao => _db.llpDao;

  Future<String> insertLlpFiling(LlpFiling filing) =>
      _dao.insertLlpFiling(LlpMapper.toCompanion(filing));

  Future<List<LlpFiling>> getByClient(String clientId) async {
    final rows = await _dao.getLlpFilingsByClient(clientId);
    return rows.map(LlpMapper.fromRow).toList();
  }

  Future<List<LlpFiling>> getByYear(String clientId, String year) async {
    final rows = await _dao.getLlpFilingsByYear(clientId, year);
    return rows.map(LlpMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, String status) =>
      _dao.updateLlpFilingStatus(id, status);

  Future<List<LlpFiling>> getOverdue() async {
    final rows = await _dao.getOverdueLlpFilings();
    return rows.map(LlpMapper.fromRow).toList();
  }

  Future<List<LlpFiling>> getDue(int daysAhead) async {
    final rows = await _dao.getDueLlpFilings(daysAhead);
    return rows.map(LlpMapper.fromRow).toList();
  }
}

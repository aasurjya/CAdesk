import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/mca/data/daos/mca_dao.dart';
import 'package:ca_app/features/mca/data/mappers/mca_mapper.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';

/// Local (SQLite via Drift) data source for MCA filings.
class McaLocalSource {
  const McaLocalSource(this._db);

  final AppDatabase _db;

  McaDao get _dao => _db.mcaDao;

  Future<String> insertMCAFiling(McaFilingData filing) =>
      _dao.insertMCAFiling(McaMapper.toCompanion(filing));

  Future<List<McaFilingData>> getMCAFilingsByClient(String clientId) async {
    final rows = await _dao.getMCAFilingsByClient(clientId);
    return rows.map(McaMapper.fromRow).toList();
  }

  Future<List<McaFilingData>> getMCAFilingsByYear(
    String clientId,
    String year,
  ) async {
    final rows = await _dao.getMCAFilingsByYear(clientId, year);
    return rows.map(McaMapper.fromRow).toList();
  }

  Future<bool> updateMCAFiling(McaFilingData filing) =>
      _dao.updateMCAFiling(McaMapper.toCompanion(filing));

  Future<List<McaFilingData>> getMCAFilingsByStatus(String status) async {
    final rows = await _dao.getMCAFilingsByStatus(status);
    return rows.map(McaMapper.fromRow).toList();
  }

  Future<List<McaFilingData>> getDueMCAFilings(int daysAhead) async {
    final rows = await _dao.getDueMCAFilings(daysAhead);
    return rows.map(McaMapper.fromRow).toList();
  }

  Future<McaFilingData?> getMCAFilingById(String id) async {
    final row = await _dao.getMCAFilingById(id);
    return row != null ? McaMapper.fromRow(row) : null;
  }

  Stream<List<McaFilingData>> watchMCAFilingsByClient(String clientId) =>
      _dao
          .watchMCAFilingsByClient(clientId)
          .map((rows) => rows.map(McaMapper.fromRow).toList());
}

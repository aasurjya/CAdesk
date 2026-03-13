import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/fema/data/daos/fema_dao.dart';
import 'package:ca_app/features/fema/data/mappers/fema_mapper.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';

/// Local (SQLite via Drift) data source for FEMA filings.
class FemaLocalSource {
  const FemaLocalSource(this._db);

  final AppDatabase _db;

  FemaDao get _dao => _db.femaDao;

  Future<String> insert(FemaFilingData filing) =>
      _dao.insertFemaFiling(FemaMapper.toCompanion(filing));

  Future<List<FemaFilingData>> getByClient(String clientId) async {
    final rows = await _dao.getFemaFilingsByClient(clientId);
    return rows.map(FemaMapper.fromRow).toList();
  }

  Future<List<FemaFilingData>> getByType(FemaType filingType) async {
    final rows = await _dao.getFemaFilingsByType(filingType.name);
    return rows.map(FemaMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, String status) =>
      _dao.updateFemaFilingStatus(id, status);

  Future<List<FemaFilingData>> getByYear(String clientId, int year) async {
    final rows = await _dao.getFemaFilingsByYear(clientId, year);
    return rows.map(FemaMapper.fromRow).toList();
  }
}

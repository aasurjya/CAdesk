import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/sebi/data/daos/sebi_dao.dart';
import 'package:ca_app/features/sebi/data/mappers/sebi_mapper.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';

/// Local (SQLite via Drift) data source for SEBI compliance records.
class SebiLocalSource {
  const SebiLocalSource(this._db);

  final AppDatabase _db;

  SebiDao get _dao => _db.sebiDao;

  Future<String> insert(SebiComplianceData compliance) =>
      _dao.insertSebiCompliance(SebiMapper.toCompanion(compliance));

  Future<List<SebiComplianceData>> getByClient(String clientId) async {
    final rows = await _dao.getSebiComplianceByClient(clientId);
    return rows.map(SebiMapper.fromRow).toList();
  }

  Future<List<SebiComplianceData>> getByType(SebiType complianceType) async {
    final rows = await _dao.getSebiComplianceByType(complianceType.name);
    return rows.map(SebiMapper.fromRow).toList();
  }

  Future<List<SebiComplianceData>> getOverdue() async {
    final rows = await _dao.getOverdueSebiCompliance();
    return rows.map(SebiMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, String status) =>
      _dao.updateSebiComplianceStatus(id, status);
}

import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/clients/data/mappers/client_mapper.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';

class ClientsLocalSource {
  const ClientsLocalSource(this._db);

  final AppDatabase _db;

  Future<List<Client>> getAll({String firmId = ''}) async {
    final rows = await _db.clientsDao.getAllClients(firmId);
    return rows.map(ClientMapper.fromRow).toList();
  }

  Future<Client?> getById(String id) async {
    final row = await _db.clientsDao.getClientById(id);
    return row != null ? ClientMapper.fromRow(row) : null;
  }

  Future<void> upsert(Client client, {String firmId = ''}) async {
    await _db.clientsDao.upsertClient(
      ClientMapper.toCompanion(client, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.clientsDao.deleteClient(id);

  Stream<List<Client>> watchAll({String firmId = ''}) {
    return _db.clientsDao
        .watchAllClients(firmId)
        .map((rows) => rows.map(ClientMapper.fromRow).toList());
  }

  Future<List<Client>> search(String query, {String firmId = ''}) async {
    final rows = await _db.clientsDao.searchClients(firmId, query);
    return rows.map(ClientMapper.fromRow).toList();
  }
}

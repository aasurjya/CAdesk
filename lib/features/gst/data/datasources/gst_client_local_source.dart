import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/gst/data/mappers/gst_client_mapper.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';

class GstClientLocalSource {
  const GstClientLocalSource(this._db);

  final AppDatabase _db;

  Future<List<GstClient>> getAll({String firmId = ''}) async {
    final rows = await _db.gstDao.getAllClients(firmId);
    return rows.map(GstClientMapper.fromRow).toList();
  }

  Future<GstClient?> getById(String id) async {
    final row = await _db.gstDao.getClientById(id);
    return row != null ? GstClientMapper.fromRow(row) : null;
  }

  Future<GstClient?> getByGstin(String gstin) async {
    final row = await _db.gstDao.getByGstin(gstin);
    return row != null ? GstClientMapper.fromRow(row) : null;
  }

  Future<void> upsert(GstClient client, {String firmId = ''}) async {
    await _db.gstDao.upsertClient(
      GstClientMapper.toCompanion(client, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.gstDao.deleteClient(id);

  Stream<List<GstClient>> watchAll({String firmId = ''}) {
    return _db.gstDao
        .watchAllClients(firmId)
        .map((rows) => rows.map(GstClientMapper.fromRow).toList());
  }
}

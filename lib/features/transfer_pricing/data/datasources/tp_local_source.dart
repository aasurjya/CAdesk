import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/transfer_pricing/data/mappers/tp_transaction_mapper.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';

class TpLocalSource {
  const TpLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(TpTransaction transaction) =>
      _db.tpDao.insertTransaction(TpTransactionMapper.toCompanion(transaction));

  Future<List<TpTransaction>> getByClient(String clientId) async {
    final rows = await _db.tpDao.getByClient(clientId);
    return rows.map(TpTransactionMapper.fromRow).toList();
  }

  Future<List<TpTransaction>> getByYear(String assessmentYear) async {
    final rows = await _db.tpDao.getByYear(assessmentYear);
    return rows.map(TpTransactionMapper.fromRow).toList();
  }

  Future<bool> updateStatus(String id, TpStatus status) =>
      _db.tpDao.updateStatus(id, status.name);

  Future<List<TpTransaction>> getByMethod(TpMethod method) async {
    final rows = await _db.tpDao.getByMethod(method.name);
    return rows.map(TpTransactionMapper.fromRow).toList();
  }

  Future<TpTransaction?> getById(String id) async {
    final row = await _db.tpDao.getById(id);
    return row != null ? TpTransactionMapper.fromRow(row) : null;
  }

  Future<void> delete(String id) => _db.tpDao.deleteTransaction(id);
}

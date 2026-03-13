import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/billing/data/mappers/invoice_mapper.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';

class InvoiceLocalSource {
  const InvoiceLocalSource(this._db);

  final AppDatabase _db;

  Future<List<Invoice>> getAll({String firmId = ''}) async {
    final rows = await _db.invoicesDao.getAllInvoices(firmId);
    return rows.map(InvoiceMapper.fromRow).toList();
  }

  Future<Invoice?> getById(String id) async {
    final row = await _db.invoicesDao.getInvoiceById(id);
    return row != null ? InvoiceMapper.fromRow(row) : null;
  }

  Future<List<Invoice>> getByClientId(String clientId) async {
    final rows = await _db.invoicesDao.getByClientId(clientId);
    return rows.map(InvoiceMapper.fromRow).toList();
  }

  Future<List<Invoice>> getByStatus(String status, {String firmId = ''}) async {
    final rows = await _db.invoicesDao.getByStatus(firmId, status);
    return rows.map(InvoiceMapper.fromRow).toList();
  }

  Future<List<Invoice>> search(String query, {String firmId = ''}) async {
    final rows = await _db.invoicesDao.searchInvoices(firmId, query);
    return rows.map(InvoiceMapper.fromRow).toList();
  }

  Future<void> upsert(Invoice invoice, {String firmId = ''}) async {
    await _db.invoicesDao.upsertInvoice(
      InvoiceMapper.toCompanion(invoice, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.invoicesDao.deleteInvoice(id);

  Stream<List<Invoice>> watchAll({String firmId = ''}) {
    return _db.invoicesDao
        .watchAllInvoices(firmId)
        .map((rows) => rows.map(InvoiceMapper.fromRow).toList());
  }
}

import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/billing/data/mappers/payment_mapper.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';

class PaymentLocalSource {
  const PaymentLocalSource(this._db);

  final AppDatabase _db;

  Future<List<PaymentRecord>> getAll({String firmId = ''}) async {
    final rows = await _db.invoicesDao.getAllPayments(firmId);
    return rows.map(PaymentMapper.fromRow).toList();
  }

  Future<PaymentRecord?> getById(String id) async {
    final row = await _db.invoicesDao.getPaymentById(id);
    return row != null ? PaymentMapper.fromRow(row) : null;
  }

  Future<List<PaymentRecord>> getByInvoiceId(String invoiceId) async {
    final rows = await _db.invoicesDao.getPaymentsByInvoiceId(invoiceId);
    return rows.map(PaymentMapper.fromRow).toList();
  }

  Future<void> upsert(PaymentRecord payment, {String firmId = ''}) async {
    await _db.invoicesDao.upsertPayment(
      PaymentMapper.toCompanion(payment, firmId: firmId),
    );
  }

  Future<void> delete(String id) => _db.invoicesDao.deletePayment(id);

  Stream<List<PaymentRecord>> watchByInvoiceId(String invoiceId) {
    return _db.invoicesDao
        .watchPaymentsByInvoiceId(invoiceId)
        .map((rows) => rows.map(PaymentMapper.fromRow).toList());
  }
}

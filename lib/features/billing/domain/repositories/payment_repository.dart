import 'package:ca_app/features/billing/domain/models/payment_record.dart';

abstract class PaymentRepository {
  Future<List<PaymentRecord>> getAll({String? firmId});
  Future<PaymentRecord?> getById(String id);
  Future<PaymentRecord> create(PaymentRecord payment);
  Future<void> delete(String id);
  Future<List<PaymentRecord>> getByInvoiceId(String invoiceId);
  Stream<List<PaymentRecord>> watchByInvoiceId(String invoiceId);
}

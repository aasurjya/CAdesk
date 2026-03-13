import 'package:ca_app/features/billing/domain/models/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAll({String? firmId});
  Future<Invoice?> getById(String id);
  Future<Invoice> create(Invoice invoice);
  Future<Invoice> update(Invoice invoice);
  Future<void> delete(String id);
  Future<List<Invoice>> getByClientId(String clientId);
  Future<List<Invoice>> getByStatus(InvoiceStatus status, {String? firmId});
  Future<List<Invoice>> search(String query, {String? firmId});
  Stream<List<Invoice>> watchAll({String? firmId});
}

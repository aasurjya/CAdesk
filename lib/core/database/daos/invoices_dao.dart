import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/invoices_table.dart';
import 'package:ca_app/core/database/tables/payments_table.dart';

part 'invoices_dao.g.dart';

@DriftAccessor(tables: [InvoicesTable, PaymentsTable])
class InvoicesDao extends DatabaseAccessor<AppDatabase>
    with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  // --- Invoices ---

  Future<List<InvoiceRow>> getAllInvoices(String firmId) =>
      (select(invoicesTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<InvoiceRow?> getInvoiceById(String id) =>
      (select(invoicesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<InvoiceRow>> getByClientId(String clientId) =>
      (select(invoicesTable)..where((t) => t.clientId.equals(clientId))).get();

  Future<List<InvoiceRow>> getByStatus(String firmId, String status) => (select(
    invoicesTable,
  )..where((t) => t.firmId.equals(firmId) & t.status.equals(status))).get();

  Future<List<InvoiceRow>> searchInvoices(String firmId, String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(invoicesTable)..where(
          (t) =>
              t.firmId.equals(firmId) &
              (t.clientName.lower().like(q) | t.invoiceNumber.lower().like(q)),
        ))
        .get();
  }

  Future<void> upsertInvoice(InvoicesTableCompanion invoice) =>
      into(invoicesTable).insertOnConflictUpdate(invoice);

  Future<void> deleteInvoice(String id) =>
      (delete(invoicesTable)..where((t) => t.id.equals(id))).go();

  Stream<List<InvoiceRow>> watchAllInvoices(String firmId) =>
      (select(invoicesTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<InvoiceRow>> getDirtyInvoices() =>
      (select(invoicesTable)..where((t) => t.isDirty)).get();

  Future<void> markInvoiceSynced(String id, DateTime syncedAt) =>
      (update(invoicesTable)..where((t) => t.id.equals(id))).write(
        InvoicesTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );

  // --- Payments ---

  Future<List<PaymentRow>> getAllPayments(String firmId) =>
      (select(paymentsTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<PaymentRow?> getPaymentById(String id) =>
      (select(paymentsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<PaymentRow>> getPaymentsByInvoiceId(String invoiceId) => (select(
    paymentsTable,
  )..where((t) => t.invoiceId.equals(invoiceId))).get();

  Future<void> upsertPayment(PaymentsTableCompanion payment) =>
      into(paymentsTable).insertOnConflictUpdate(payment);

  Future<void> deletePayment(String id) =>
      (delete(paymentsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<PaymentRow>> watchPaymentsByInvoiceId(String invoiceId) =>
      (select(
        paymentsTable,
      )..where((t) => t.invoiceId.equals(invoiceId))).watch();
}

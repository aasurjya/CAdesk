import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';
import 'package:ca_app/features/billing/data/repositories/mock_invoice_repository.dart';

void main() {
  group('MockInvoiceRepository', () {
    late MockInvoiceRepository repo;

    setUp(() {
      repo = MockInvoiceRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('getAll', () {
      test('returns all seeded invoices', () async {
        final all = await repo.getAll();
        expect(all.length, greaterThanOrEqualTo(5));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAll();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getById', () {
      test('returns invoice for valid ID', () async {
        final invoice = await repo.getById('inv-001');
        expect(invoice, isNotNull);
        expect(invoice!.id, 'inv-001');
      });

      test('returns null for unknown ID', () async {
        final invoice = await repo.getById('no-such-id');
        expect(invoice, isNull);
      });
    });

    group('create', () {
      test('creates invoice and returns it', () async {
        final newInvoice = Invoice(
          id: 'inv-new-001',
          invoiceNumber: 'INV-2026-TEST',
          clientId: 'client-test',
          clientName: 'Test Client',
          invoiceDate: DateTime(2026, 3, 1),
          dueDate: DateTime(2026, 4, 1),
          lineItems: const [
            LineItem(
              description: 'Test Service',
              hsn: '998231',
              quantity: 1,
              rate: 10000,
              taxableAmount: 10000,
              gstRate: 18,
              cgst: 900,
              sgst: 900,
              igst: 0,
              total: 11800,
            ),
          ],
          subtotal: 10000,
          totalGst: 1800,
          grandTotal: 11800,
          paidAmount: 0,
          balanceDue: 11800,
          status: InvoiceStatus.draft,
        );

        final created = await repo.create(newInvoice);
        expect(created.id, 'inv-new-001');
        expect(created.clientName, 'Test Client');

        final fetched = await repo.getById('inv-new-001');
        expect(fetched, isNotNull);
        expect(fetched!.invoiceNumber, 'INV-2026-TEST');
      });
    });

    group('update', () {
      test('updates existing invoice and returns updated invoice', () async {
        final existing = await repo.getById('inv-002');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: InvoiceStatus.paid);
        final result = await repo.update(updated);
        expect(result.status, InvoiceStatus.paid);

        final fetched = await repo.getById('inv-002');
        expect(fetched!.status, InvoiceStatus.paid);
      });

      test('throws StateError for non-existent invoice', () async {
        final ghost = Invoice(
          id: 'ghost-inv',
          invoiceNumber: 'INV-GHOST',
          clientId: 'c',
          clientName: 'Ghost Client',
          invoiceDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 2, 1),
          lineItems: const [],
          subtotal: 0,
          totalGst: 0,
          grandTotal: 0,
          paidAmount: 0,
          balanceDue: 0,
          status: InvoiceStatus.draft,
        );
        expect(() => repo.update(ghost), throwsA(isA<StateError>()));
      });
    });

    group('delete', () {
      test('deletes invoice so it no longer appears in getById', () async {
        final created = await repo.create(
          Invoice(
            id: 'inv-to-delete',
            invoiceNumber: 'INV-DEL',
            clientId: 'client-del',
            clientName: 'Delete Me',
            invoiceDate: DateTime(2026, 1, 1),
            dueDate: DateTime(2026, 2, 1),
            lineItems: const [],
            subtotal: 0,
            totalGst: 0,
            grandTotal: 0,
            paidAmount: 0,
            balanceDue: 0,
            status: InvoiceStatus.draft,
          ),
        );

        await repo.delete(created.id);
        final fetched = await repo.getById('inv-to-delete');
        expect(fetched, isNull);
      });

      test('delete on non-existent ID does not throw', () async {
        await expectLater(repo.delete('no-such-inv'), completes);
      });
    });

    group('getByClientId', () {
      test('returns invoices for a known client', () async {
        final results = await repo.getByClientId('3');
        expect(results, isNotEmpty);
        expect(results.every((inv) => inv.clientId == '3'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final results = await repo.getByClientId('unknown-client');
        expect(results, isEmpty);
      });
    });

    group('getByStatus', () {
      test('returns only paid invoices when filtering by paid', () async {
        final results = await repo.getByStatus(InvoiceStatus.paid);
        expect(results, isNotEmpty);
        expect(
          results.every((inv) => inv.status == InvoiceStatus.paid),
          isTrue,
        );
      });

      test('returns only overdue invoices when filtering by overdue', () async {
        final results = await repo.getByStatus(InvoiceStatus.overdue);
        expect(results, isNotEmpty);
        expect(
          results.every((inv) => inv.status == InvoiceStatus.overdue),
          isTrue,
        );
      });

      test('returns empty list for status with no matching invoices', () async {
        final results = await repo.getByStatus(InvoiceStatus.cancelled);
        expect(results, isEmpty);
      });
    });

    group('search', () {
      test('finds invoices matching invoice number substring', () async {
        final results = await repo.search('INV-2026-001');
        expect(results, isNotEmpty);
        expect(results.first.invoiceNumber, 'INV-2026-001');
      });

      test('finds invoices matching client name substring', () async {
        final results = await repo.search('mehta');
        expect(results, isNotEmpty);
        expect(
          results.any((inv) => inv.clientName.toLowerCase().contains('mehta')),
          isTrue,
        );
      });

      test('returns empty list for unknown query', () async {
        final results = await repo.search('xyznonexistent12345');
        expect(results, isEmpty);
      });
    });

    group('watchAll', () {
      test('emits a list after create', () async {
        final stream = repo.watchAll();
        final future = stream.first;

        await repo.create(
          Invoice(
            id: 'inv-stream-test',
            invoiceNumber: 'INV-STREAM',
            clientId: 'client-stream',
            clientName: 'Stream Client',
            invoiceDate: DateTime(2026, 1, 1),
            dueDate: DateTime(2026, 2, 1),
            lineItems: const [],
            subtotal: 0,
            totalGst: 0,
            grandTotal: 0,
            paidAmount: 0,
            balanceDue: 0,
            status: InvoiceStatus.draft,
          ),
        );

        final emitted = await future;
        expect(emitted.any((inv) => inv.id == 'inv-stream-test'), isTrue);
      });
    });
  });
}

/// Cross-module smoke tests — Phase 8 integration verification.
///
/// These tests validate that domain objects from different modules can work
/// together in a complete workflow at the domain layer (no UI, no DB).
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';

void main() {
  group('Cross-module smoke tests', () {
    // ---------------------------------------------------------------------------
    // 1. Client domain
    // ---------------------------------------------------------------------------
    group('Client domain', () {
      test('can create an individual client with all required fields', () {
        final client = Client(
          id: 'client-001',
          name: 'Rajesh Kumar',
          pan: 'ABCPK1234F',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime(2024, 4, 1),
          updatedAt: DateTime(2024, 4, 1),
          email: 'rajesh@example.com',
          phone: '9876543210',
        );

        expect(client.id, 'client-001');
        expect(client.name, 'Rajesh Kumar');
        expect(client.pan, 'ABCPK1234F');
        expect(client.clientType, ClientType.individual);
        expect(client.status, ClientStatus.active);
        expect(client.email, 'rajesh@example.com');
      });

      test('can create a company client', () {
        final client = Client(
          id: 'client-002',
          name: 'ABC Pvt Ltd',
          pan: 'AABCA1234K',
          clientType: ClientType.company,
          status: ClientStatus.active,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(client.clientType, ClientType.company);
        expect(client.name, 'ABC Pvt Ltd');
      });

      test('copyWith returns new immutable client', () {
        final original = Client(
          id: 'client-003',
          name: 'Original Name',
          pan: 'CCCPQ5678Z',
          clientType: ClientType.firm,
          status: ClientStatus.prospect,
          createdAt: DateTime(2024, 3, 15),
          updatedAt: DateTime(2024, 3, 15),
        );

        final updated = original.copyWith(
          status: ClientStatus.active,
          name: 'Updated Name',
        );

        // Original is unchanged (immutability)
        expect(original.status, ClientStatus.prospect);
        expect(original.name, 'Original Name');

        // Updated has new values
        expect(updated.status, ClientStatus.active);
        expect(updated.name, 'Updated Name');
        expect(updated.id, original.id);
        expect(updated.pan, original.pan);
      });

      test('ClientStatus enum has expected values', () {
        expect(
          ClientStatus.values,
          containsAll([
            ClientStatus.active,
            ClientStatus.inactive,
            ClientStatus.prospect,
          ]),
        );
      });

      test('ClientType enum has expected values', () {
        expect(
          ClientType.values,
          containsAll([
            ClientType.individual,
            ClientType.company,
            ClientType.firm,
            ClientType.llp,
          ]),
        );
      });

      test('ServiceType enum has expected values', () {
        expect(
          ServiceType.values,
          containsAll([
            ServiceType.itrFiling,
            ServiceType.gstFiling,
            ServiceType.tds,
            ServiceType.audit,
          ]),
        );
      });

      test('client PAN matches 10-character format', () {
        final client = Client(
          id: 'client-pan',
          name: 'PAN Test',
          pan: 'TTXPQ9876R',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime(2024, 4, 1),
          updatedAt: DateTime(2024, 4, 1),
        );

        expect(client.pan.length, 10);
        expect(client.pan, matches(r'^[A-Z]{5}[0-9]{4}[A-Z]$'));
      });
    });

    // ---------------------------------------------------------------------------
    // 2. Billing domain
    // ---------------------------------------------------------------------------
    group('Billing domain', () {
      Invoice makeInvoice({
        String id = 'inv-001',
        String clientId = 'client-001',
        InvoiceStatus status = InvoiceStatus.sent,
      }) {
        return Invoice(
          id: id,
          invoiceNumber: 'INV/2024-25/001',
          clientId: clientId,
          clientName: 'Test Client',
          invoiceDate: DateTime(2024, 4, 1),
          dueDate: DateTime(2024, 4, 30),
          lineItems: const [
            LineItem(
              description: 'ITR Filing AY 2024-25',
              hsn: '998231',
              quantity: 1,
              rate: 5000.0,
              taxableAmount: 5000.0,
              gstRate: 18,
              cgst: 450.0,
              sgst: 450.0,
              igst: 0.0,
              total: 5900.0,
            ),
          ],
          subtotal: 5000.0,
          totalGst: 900.0,
          grandTotal: 5900.0,
          paidAmount: 0.0,
          balanceDue: 5900.0,
          status: status,
        );
      }

      test('can create an invoice linked to a client', () {
        final invoice = makeInvoice();

        expect(invoice.clientId, 'client-001');
        expect(invoice.grandTotal, 5900.0);
        expect(invoice.status, InvoiceStatus.sent);
        expect(invoice.lineItems, hasLength(1));
      });

      test('invoice grand total equals subtotal + tax', () {
        final invoice = makeInvoice();

        expect(invoice.grandTotal, invoice.subtotal + invoice.totalGst);
      });

      test('InvoiceStatus enum has expected values', () {
        expect(
          InvoiceStatus.values,
          containsAll([
            InvoiceStatus.draft,
            InvoiceStatus.sent,
            InvoiceStatus.paid,
            InvoiceStatus.overdue,
          ]),
        );
      });

      test('copyWith returns new immutable invoice', () {
        final original = makeInvoice(status: InvoiceStatus.sent);
        final paid = original.copyWith(
          status: InvoiceStatus.paid,
          paidAmount: 5900.0,
          balanceDue: 0.0,
        );

        // Original unchanged
        expect(original.status, InvoiceStatus.sent);
        expect(original.paidAmount, 0.0);

        // Updated has new values
        expect(paid.status, InvoiceStatus.paid);
        expect(paid.paidAmount, 5900.0);
        expect(paid.balanceDue, 0.0);
        expect(paid.id, original.id);
      });
    });

    // ---------------------------------------------------------------------------
    // 3. Complete workflow: client → invoice → payment
    // ---------------------------------------------------------------------------
    group('Client → Invoice → Payment workflow', () {
      test('complete billing workflow', () {
        // Step 1: Onboard client
        final client = Client(
          id: 'workflow-client',
          name: 'Workflow Test Client',
          pan: 'WKFLW1234T',
          clientType: ClientType.individual,
          status: ClientStatus.active,
          createdAt: DateTime(2024, 4, 1),
          updatedAt: DateTime(2024, 4, 1),
          email: 'workflow@test.com',
        );
        expect(client.status, ClientStatus.active);

        // Step 2: Generate invoice for the client
        final invoice = Invoice(
          id: 'workflow-inv',
          invoiceNumber: 'INV/WORKFLOW/001',
          clientId: client.id,
          clientName: client.name,
          invoiceDate: DateTime(2024, 8, 1),
          dueDate: DateTime(2024, 8, 31),
          lineItems: const [
            LineItem(
              description: 'Tax Filing Services',
              hsn: '998231',
              quantity: 1,
              rate: 3000.0,
              taxableAmount: 3000.0,
              gstRate: 18,
              cgst: 270.0,
              sgst: 270.0,
              igst: 0.0,
              total: 3540.0,
            ),
          ],
          subtotal: 3000.0,
          totalGst: 540.0,
          grandTotal: 3540.0,
          paidAmount: 0.0,
          balanceDue: 3540.0,
          status: InvoiceStatus.sent,
        );

        expect(invoice.clientId, client.id);
        expect(invoice.clientName, client.name);
        expect(invoice.balanceDue, 3540.0);

        // Step 3: Mark as paid
        final paidInvoice = invoice.copyWith(
          status: InvoiceStatus.paid,
          paidAmount: 3540.0,
          balanceDue: 0.0,
        );

        expect(paidInvoice.status, InvoiceStatus.paid);
        expect(paidInvoice.balanceDue, 0.0);
        // Original immutable
        expect(invoice.status, InvoiceStatus.sent);
      });
    });
  });
}

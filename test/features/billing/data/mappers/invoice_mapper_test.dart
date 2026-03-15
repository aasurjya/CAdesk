import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/billing/data/mappers/invoice_mapper.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';

void main() {
  group('InvoiceMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'inv-001',
          'invoice_number': 'INV/2025-26/001',
          'client_id': 'client-001',
          'client_name': 'Rajesh Kumar',
          'gstin': '27ABCPS1234A1Z5',
          'invoice_date': '2025-04-01T00:00:00.000Z',
          'due_date': '2025-04-30T00:00:00.000Z',
          'subtotal': 10000.0,
          'total_gst': 1800.0,
          'grand_total': 11800.0,
          'paid_amount': 0.0,
          'balance_due': 11800.0,
          'status': 'draft',
          'is_recurring': false,
        };

        final invoice = InvoiceMapper.fromJson(json);

        expect(invoice.id, 'inv-001');
        expect(invoice.invoiceNumber, 'INV/2025-26/001');
        expect(invoice.clientId, 'client-001');
        expect(invoice.clientName, 'Rajesh Kumar');
        expect(invoice.gstin, '27ABCPS1234A1Z5');
        expect(invoice.subtotal, 10000.0);
        expect(invoice.totalGst, 1800.0);
        expect(invoice.grandTotal, 11800.0);
        expect(invoice.paidAmount, 0.0);
        expect(invoice.balanceDue, 11800.0);
        expect(invoice.status, InvoiceStatus.draft);
        expect(invoice.isRecurring, isFalse);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'inv-002',
          'invoice_number': 'INV/2025-26/002',
          'client_id': 'client-002',
          'client_name': 'Mehta & Sons',
          'invoice_date': '2025-04-01T00:00:00.000Z',
          'due_date': '2025-04-30T00:00:00.000Z',
          'subtotal': 5000.0,
          'total_gst': 900.0,
          'grand_total': 5900.0,
          'paid_amount': 0.0,
          'balance_due': 5900.0,
          'status': 'sent',
        };

        final invoice = InvoiceMapper.fromJson(json);

        expect(invoice.gstin, isNull);
        expect(invoice.paymentDate, isNull);
        expect(invoice.paymentMethod, isNull);
        expect(invoice.remarks, isNull);
        expect(invoice.recurringFrequency, isNull);
      });

      test('defaults status to draft for unknown status', () {
        final json = {
          'id': 'inv-003',
          'invoice_number': 'INV/003',
          'client_id': 'c1',
          'client_name': 'Test',
          'invoice_date': '2025-04-01T00:00:00.000Z',
          'due_date': '2025-04-30T00:00:00.000Z',
          'subtotal': 1000.0,
          'total_gst': 180.0,
          'grand_total': 1180.0,
          'paid_amount': 0.0,
          'balance_due': 1180.0,
          'status': 'unknownStatus',
        };

        final invoice = InvoiceMapper.fromJson(json);
        expect(invoice.status, InvoiceStatus.draft);
      });

      test('parses recurring frequency when present', () {
        final json = {
          'id': 'inv-004',
          'invoice_number': 'INV/004',
          'client_id': 'c1',
          'client_name': 'Test',
          'invoice_date': '2025-04-01T00:00:00.000Z',
          'due_date': '2025-04-30T00:00:00.000Z',
          'subtotal': 1000.0,
          'total_gst': 180.0,
          'grand_total': 1180.0,
          'paid_amount': 0.0,
          'balance_due': 1180.0,
          'status': 'sent',
          'is_recurring': true,
          'recurring_frequency': 'monthly',
        };

        final invoice = InvoiceMapper.fromJson(json);
        expect(invoice.isRecurring, isTrue);
        expect(invoice.recurringFrequency, RecurringFrequency.monthly);
      });

      test('parses payment_date when present', () {
        final json = {
          'id': 'inv-005',
          'invoice_number': 'INV/005',
          'client_id': 'c1',
          'client_name': 'Test',
          'invoice_date': '2025-04-01T00:00:00.000Z',
          'due_date': '2025-04-30T00:00:00.000Z',
          'subtotal': 1000.0,
          'total_gst': 180.0,
          'grand_total': 1180.0,
          'paid_amount': 1180.0,
          'balance_due': 0.0,
          'status': 'paid',
          'payment_date': '2025-04-15T00:00:00.000Z',
          'payment_method': 'NEFT',
        };

        final invoice = InvoiceMapper.fromJson(json);
        expect(invoice.paymentDate, isNotNull);
        expect(invoice.paymentMethod, 'NEFT');
      });

      test('handles all InvoiceStatus values', () {
        for (final status in InvoiceStatus.values) {
          final json = {
            'id': 'inv-status-${status.name}',
            'invoice_number': 'INV/${status.name}',
            'client_id': 'c1',
            'client_name': 'Test',
            'invoice_date': '2025-04-01T00:00:00.000Z',
            'due_date': '2025-04-30T00:00:00.000Z',
            'subtotal': 1000.0,
            'total_gst': 180.0,
            'grand_total': 1180.0,
            'paid_amount': 0.0,
            'balance_due': 1180.0,
            'status': status.name,
          };
          final invoice = InvoiceMapper.fromJson(json);
          expect(invoice.status, status);
        }
      });

      test('handles all RecurringFrequency values', () {
        for (final freq in RecurringFrequency.values) {
          final json = {
            'id': 'inv-freq-${freq.name}',
            'invoice_number': 'INV/${freq.name}',
            'client_id': 'c1',
            'client_name': 'Test',
            'invoice_date': '2025-04-01T00:00:00.000Z',
            'due_date': '2025-04-30T00:00:00.000Z',
            'subtotal': 1000.0,
            'total_gst': 180.0,
            'grand_total': 1180.0,
            'paid_amount': 0.0,
            'balance_due': 1180.0,
            'status': 'sent',
            'is_recurring': true,
            'recurring_frequency': freq.name,
          };
          final invoice = InvoiceMapper.fromJson(json);
          expect(invoice.recurringFrequency, freq);
        }
      });

      test('defaults is_recurring to false when absent', () {
        final json = {
          'id': 'inv-006',
          'invoice_number': 'INV/006',
          'client_id': 'c1',
          'client_name': 'Test',
          'invoice_date': '2025-04-01T00:00:00.000Z',
          'due_date': '2025-04-30T00:00:00.000Z',
          'subtotal': 1000.0,
          'total_gst': 180.0,
          'grand_total': 1180.0,
          'paid_amount': 0.0,
          'balance_due': 1180.0,
          'status': 'draft',
        };
        final invoice = InvoiceMapper.fromJson(json);
        expect(invoice.isRecurring, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late Invoice sampleInvoice;

      setUp(() {
        sampleInvoice = Invoice(
          id: 'inv-json-001',
          invoiceNumber: 'INV/2025-26/JSON-001',
          clientId: 'client-json-001',
          clientName: 'Priya Nair',
          gstin: '27CNPPN5678P1Z5',
          invoiceDate: DateTime(2025, 4, 1),
          dueDate: DateTime(2025, 4, 30),
          lineItems: const [],
          subtotal: 20000.0,
          totalGst: 3600.0,
          grandTotal: 23600.0,
          paidAmount: 23600.0,
          balanceDue: 0.0,
          status: InvoiceStatus.paid,
          paymentDate: DateTime(2025, 4, 10),
          paymentMethod: 'UPI',
          remarks: 'Paid on time',
          isRecurring: false,
        );
      });

      test('includes all core fields', () {
        final json = InvoiceMapper.toJson(sampleInvoice);

        expect(json['id'], 'inv-json-001');
        expect(json['invoice_number'], 'INV/2025-26/JSON-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Priya Nair');
        expect(json['gstin'], '27CNPPN5678P1Z5');
        expect(json['subtotal'], 20000.0);
        expect(json['total_gst'], 3600.0);
        expect(json['grand_total'], 23600.0);
        expect(json['paid_amount'], 23600.0);
        expect(json['balance_due'], 0.0);
        expect(json['status'], 'paid');
        expect(json['payment_method'], 'UPI');
        expect(json['remarks'], 'Paid on time');
        expect(json['is_recurring'], isFalse);
      });

      test('serializes dates as ISO strings', () {
        final json = InvoiceMapper.toJson(sampleInvoice);
        expect(json['invoice_date'], startsWith('2025-04-01'));
        expect(json['due_date'], startsWith('2025-04-30'));
        expect(json['payment_date'], startsWith('2025-04-10'));
      });

      test('serializes null recurring_frequency as null', () {
        final json = InvoiceMapper.toJson(sampleInvoice);
        expect(json['recurring_frequency'], isNull);
      });

      test('serializes recurring_frequency when set', () {
        final recurringInvoice = sampleInvoice.copyWith(
          isRecurring: true,
          recurringFrequency: RecurringFrequency.quarterly,
        );
        final json = InvoiceMapper.toJson(recurringInvoice);
        expect(json['recurring_frequency'], 'quarterly');
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = InvoiceMapper.toJson(sampleInvoice);
        final restored = InvoiceMapper.fromJson(json);

        expect(restored.id, sampleInvoice.id);
        expect(restored.invoiceNumber, sampleInvoice.invoiceNumber);
        expect(restored.clientId, sampleInvoice.clientId);
        expect(restored.clientName, sampleInvoice.clientName);
        expect(restored.subtotal, sampleInvoice.subtotal);
        expect(restored.status, sampleInvoice.status);
        expect(restored.paymentMethod, sampleInvoice.paymentMethod);
      });
    });
  });
}

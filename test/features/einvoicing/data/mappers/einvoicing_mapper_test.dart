import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/einvoicing/data/mappers/einvoicing_mapper.dart';
import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';

void main() {
  group('EinvoicingMapper', () {
    // -------------------------------------------------------------------------
    // EinvoiceRecord
    // -------------------------------------------------------------------------
    group('recordFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'inv-001',
          'client_name': 'ABC Industries Pvt Ltd',
          'invoice_number': 'INV/2025/001',
          'buyer_name': 'XYZ Corp',
          'invoice_value': 118000.0,
          'gst_amount': 18000.0,
          'irn': 'IRN12345678901234567890123456789012345678901234567890',
          'status': 'Active',
          'window_type': '30-day',
          'days_remaining': 25,
          'invoice_date': '01/09/2025',
          'qr_generated': true,
        };

        final record = EinvoicingMapper.recordFromJson(json);

        expect(record.id, 'inv-001');
        expect(record.clientName, 'ABC Industries Pvt Ltd');
        expect(record.invoiceNumber, 'INV/2025/001');
        expect(record.buyerName, 'XYZ Corp');
        expect(record.invoiceValue, 118000.0);
        expect(record.gstAmount, 18000.0);
        expect(record.irn, 'IRN12345678901234567890123456789012345678901234567890');
        expect(record.status, 'Active');
        expect(record.windowType, '30-day');
        expect(record.daysRemaining, 25);
        expect(record.invoiceDate, '01/09/2025');
        expect(record.qrGenerated, true);
      });

      test('defaults status to Pending and windowType to 30-day when missing', () {
        final json = {
          'id': 'inv-002',
          'client_name': 'Test Corp',
          'invoice_number': 'INV/2025/002',
          'buyer_name': 'Buyer Ltd',
          'invoice_value': 50000.0,
          'gst_amount': 9000.0,
          'irn': 'IRN000',
          'days_remaining': 10,
          'invoice_date': '15/09/2025',
        };

        final record = EinvoicingMapper.recordFromJson(json);
        expect(record.status, 'Pending');
        expect(record.windowType, '30-day');
        expect(record.qrGenerated, false);
      });

      test('handles integer invoice_value as double', () {
        final json = {
          'id': 'inv-003',
          'client_name': '',
          'invoice_number': '',
          'buyer_name': '',
          'invoice_value': 100000,
          'gst_amount': 18000,
          'irn': '',
          'days_remaining': 5,
          'invoice_date': '01/01/2025',
        };

        final record = EinvoicingMapper.recordFromJson(json);
        expect(record.invoiceValue, 100000.0);
        expect(record.invoiceValue, isA<double>());
        expect(record.gstAmount, 18000.0);
      });
    });

    group('recordToJson', () {
      test('includes all fields and round-trips correctly', () {
        const record = EinvoiceRecord(
          id: 'inv-json-001',
          clientName: 'Ramesh Enterprises',
          invoiceNumber: 'RE/2025/100',
          buyerName: 'Government Department',
          invoiceValue: 250000.0,
          gstAmount: 45000.0,
          irn: 'IRN_FULL_64_CHAR_HASH_PLACEHOLDER_EXAMPLE_VALUE_HERE',
          status: 'Cancelled',
          windowType: '30-day',
          daysRemaining: 0,
          invoiceDate: '30/08/2025',
          qrGenerated: true,
        );

        final json = EinvoicingMapper.recordToJson(record);

        expect(json['id'], 'inv-json-001');
        expect(json['client_name'], 'Ramesh Enterprises');
        expect(json['invoice_number'], 'RE/2025/100');
        expect(json['invoice_value'], 250000.0);
        expect(json['gst_amount'], 45000.0);
        expect(json['status'], 'Cancelled');
        expect(json['qr_generated'], true);

        final restored = EinvoicingMapper.recordFromJson(json);
        expect(restored.id, record.id);
        expect(restored.clientName, record.clientName);
        expect(restored.invoiceValue, record.invoiceValue);
        expect(restored.qrGenerated, record.qrGenerated);
      });
    });

    // -------------------------------------------------------------------------
    // IrnBatch
    // -------------------------------------------------------------------------
    group('batchFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'batch-001',
          'client_name': 'Industrial Corp',
          'total_invoices': 50,
          'success_count': 45,
          'failed_count': 3,
          'pending_count': 2,
          'total_value': 12500.0,
          'processed_date': '01 Sep 2025',
          'batch_status': 'Partial',
        };

        final batch = EinvoicingMapper.batchFromJson(json);

        expect(batch.id, 'batch-001');
        expect(batch.clientName, 'Industrial Corp');
        expect(batch.totalInvoices, 50);
        expect(batch.successCount, 45);
        expect(batch.failedCount, 3);
        expect(batch.pendingCount, 2);
        expect(batch.totalValue, 12500.0);
        expect(batch.processedDate, '01 Sep 2025');
        expect(batch.batchStatus, 'Partial');
      });

      test('defaults batchStatus to Processing when missing', () {
        final json = {
          'id': 'batch-002',
          'client_name': '',
          'total_invoices': 10,
          'success_count': 0,
          'failed_count': 0,
          'pending_count': 10,
          'total_value': 500.0,
          'processed_date': '02 Sep 2025',
        };

        final batch = EinvoicingMapper.batchFromJson(json);
        expect(batch.batchStatus, 'Processing');
      });

      test('handles integer total_value as double', () {
        final json = {
          'id': 'batch-003',
          'client_name': '',
          'total_invoices': 5,
          'success_count': 5,
          'failed_count': 0,
          'pending_count': 0,
          'total_value': 8000,
          'processed_date': '03 Sep 2025',
          'batch_status': 'Completed',
        };

        final batch = EinvoicingMapper.batchFromJson(json);
        expect(batch.totalValue, 8000.0);
        expect(batch.totalValue, isA<double>());
      });
    });

    group('batchToJson', () {
      test('includes all fields and round-trips correctly', () {
        const batch = IrnBatch(
          id: 'batch-json-001',
          clientName: 'XYZ Manufacturing',
          totalInvoices: 100,
          successCount: 98,
          failedCount: 2,
          pendingCount: 0,
          totalValue: 45000.0,
          processedDate: '05 Sep 2025',
          batchStatus: 'Completed',
        );

        final json = EinvoicingMapper.batchToJson(batch);

        expect(json['id'], 'batch-json-001');
        expect(json['client_name'], 'XYZ Manufacturing');
        expect(json['total_invoices'], 100);
        expect(json['success_count'], 98);
        expect(json['failed_count'], 2);
        expect(json['pending_count'], 0);
        expect(json['total_value'], 45000.0);
        expect(json['processed_date'], '05 Sep 2025');
        expect(json['batch_status'], 'Completed');

        final restored = EinvoicingMapper.batchFromJson(json);
        expect(restored.id, batch.id);
        expect(restored.totalInvoices, batch.totalInvoices);
        expect(restored.successCount, batch.successCount);
        expect(restored.batchStatus, batch.batchStatus);
      });
    });
  });
}

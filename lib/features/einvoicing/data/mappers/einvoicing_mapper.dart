import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';

/// Converts between [EinvoiceRecord] / [IrnBatch] and JSON maps.
class EinvoicingMapper {
  const EinvoicingMapper._();

  static EinvoiceRecord recordFromJson(Map<String, dynamic> json) {
    return EinvoiceRecord(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      invoiceNumber: json['invoice_number'] as String,
      buyerName: json['buyer_name'] as String,
      invoiceValue: (json['invoice_value'] as num).toDouble(),
      gstAmount: (json['gst_amount'] as num).toDouble(),
      irn: json['irn'] as String,
      status: json['status'] as String? ?? 'Pending',
      windowType: json['window_type'] as String? ?? '30-day',
      daysRemaining: (json['days_remaining'] as num).toInt(),
      invoiceDate: json['invoice_date'] as String,
      qrGenerated: json['qr_generated'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> recordToJson(EinvoiceRecord record) {
    return {
      'id': record.id,
      'client_name': record.clientName,
      'invoice_number': record.invoiceNumber,
      'buyer_name': record.buyerName,
      'invoice_value': record.invoiceValue,
      'gst_amount': record.gstAmount,
      'irn': record.irn,
      'status': record.status,
      'window_type': record.windowType,
      'days_remaining': record.daysRemaining,
      'invoice_date': record.invoiceDate,
      'qr_generated': record.qrGenerated,
    };
  }

  static IrnBatch batchFromJson(Map<String, dynamic> json) {
    return IrnBatch(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      totalInvoices: (json['total_invoices'] as num).toInt(),
      successCount: (json['success_count'] as num).toInt(),
      failedCount: (json['failed_count'] as num).toInt(),
      pendingCount: (json['pending_count'] as num).toInt(),
      totalValue: (json['total_value'] as num).toDouble(),
      processedDate: json['processed_date'] as String,
      batchStatus: json['batch_status'] as String? ?? 'Processing',
    );
  }

  static Map<String, dynamic> batchToJson(IrnBatch batch) {
    return {
      'id': batch.id,
      'client_name': batch.clientName,
      'total_invoices': batch.totalInvoices,
      'success_count': batch.successCount,
      'failed_count': batch.failedCount,
      'pending_count': batch.pendingCount,
      'total_value': batch.totalValue,
      'processed_date': batch.processedDate,
      'batch_status': batch.batchStatus,
    };
  }
}

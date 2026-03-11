import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/einvoice_record.dart';
import '../../domain/models/irn_batch.dart';

// ---------------------------------------------------------------------------
// Mock data — E-Invoice Records
// ---------------------------------------------------------------------------

final List<EinvoiceRecord> _mockEinvoiceRecords = [
  const EinvoiceRecord(
    id: 'einv-001',
    clientName: 'Reliance Retail Ventures Ltd',
    invoiceNumber: 'INV-2025-0234',
    buyerName: 'Avenue Supermarts Ltd',
    invoiceValue: 1250000,
    gstAmount: 225000,
    irn: 'a4f3c8d1e9b2f7a6c0d5e8f1a3b6c9d2e5f8a1b4c7d0e3f6a9b2c5d8e1f4a7b0',
    status: 'Generated',
    windowType: '3-day',
    daysRemaining: 2,
    invoiceDate: '09 Mar 2026',
    qrGenerated: true,
  ),
  const EinvoiceRecord(
    id: 'einv-002',
    clientName: 'Tata Steel Ltd',
    invoiceNumber: 'INV-2025-0891',
    buyerName: 'Jindal Steel & Power Ltd',
    invoiceValue: 4750000,
    gstAmount: 570000,
    irn: 'b7e2a9f4c1d8e5f2a0c3d6e9f2a5b8c1d4e7f0a3b6c9d2e5f8a1b4c7d0e3f6a9',
    status: 'Generated',
    windowType: '3-day',
    daysRemaining: 1,
    invoiceDate: '10 Mar 2026',
    qrGenerated: true,
  ),
  const EinvoiceRecord(
    id: 'einv-003',
    clientName: 'Infosys BPM Limited',
    invoiceNumber: 'INV-2025-1102',
    buyerName: 'HDFC Bank Ltd',
    invoiceValue: 850000,
    gstAmount: 153000,
    irn: 'c9d4b1f6a3e0c7d4b1f8a5c2d9b6e3f0a7c4d1b8e5f2a9c6d3b0e7f4a1c8d5b2',
    status: 'Pending',
    windowType: '30-day',
    daysRemaining: 18,
    invoiceDate: '20 Feb 2026',
    qrGenerated: false,
  ),
  const EinvoiceRecord(
    id: 'einv-004',
    clientName: 'Mahindra & Mahindra Ltd',
    invoiceNumber: 'INV-2025-0677',
    buyerName: 'Maruti Suzuki India Ltd',
    invoiceValue: 9800000,
    gstAmount: 1764000,
    irn: 'd2e7a4f1c8b5e2f9a6c3d0e7f4a1b8c5d2e9f6a3b0c7d4e1f8a5b2c9d6e3f0a7',
    status: 'Overdue',
    windowType: '3-day',
    daysRemaining: -4,
    invoiceDate: '04 Mar 2026',
    qrGenerated: false,
  ),
  const EinvoiceRecord(
    id: 'einv-005',
    clientName: 'Sun Pharma Industries Ltd',
    invoiceNumber: 'INV-2025-0445',
    buyerName: 'Apollo Hospitals Enterprise Ltd',
    invoiceValue: 325000,
    gstAmount: 39000,
    irn: 'e5f0c7d4a1b8e5f2c9d6a3b0e7f4c1d8a5b2e9f6c3d0a7b4e1f8c5d2a9b6e3f0',
    status: 'Generated',
    windowType: '30-day',
    daysRemaining: 12,
    invoiceDate: '28 Feb 2026',
    qrGenerated: true,
  ),
  const EinvoiceRecord(
    id: 'einv-006',
    clientName: 'Wipro Technologies Ltd',
    invoiceNumber: 'INV-2025-1567',
    buyerName: 'Cognizant Technology Solutions',
    invoiceValue: 2100000,
    gstAmount: 378000,
    irn: 'f8a3c0d7b4e1f8a5c2d9b6e3f0a7c4d1b8e5f2a9c6d3b0e7f4a1c8d5b2e9f6c3',
    status: 'Overdue',
    windowType: '3-day',
    daysRemaining: -2,
    invoiceDate: '06 Mar 2026',
    qrGenerated: false,
  ),
  const EinvoiceRecord(
    id: 'einv-007',
    clientName: 'Larsen & Toubro Ltd',
    invoiceNumber: 'INV-2025-0312',
    buyerName: 'National Highways Authority of India',
    invoiceValue: 15600000,
    gstAmount: 2808000,
    irn: 'a1b6c3d0e7f4a1b8c5d2e9f6a3b0c7d4e1f8a5b2c9d6e3f0a7b4c1d8e5f2a9b6',
    status: 'Cancelled',
    windowType: '3-day',
    daysRemaining: 0,
    invoiceDate: '01 Mar 2026',
    qrGenerated: false,
  ),
  const EinvoiceRecord(
    id: 'einv-008',
    clientName: 'Bajaj Auto Ltd',
    invoiceNumber: 'INV-2025-0789',
    buyerName: 'Hero MotoCorp Ltd',
    invoiceValue: 680000,
    gstAmount: 81600,
    irn: 'b4c9d6e3f0a7b4c1d8e5f2a9b6c3d0e7f4a1b8c5d2e9f6a3b0c7d4e1f8a5b2c9',
    status: 'Pending',
    windowType: '30-day',
    daysRemaining: 7,
    invoiceDate: '10 Feb 2026',
    qrGenerated: false,
  ),
  const EinvoiceRecord(
    id: 'einv-009',
    clientName: 'ITC Limited',
    invoiceNumber: 'INV-2025-2001',
    buyerName: 'Hindustan Unilever Ltd',
    invoiceValue: 4200000,
    gstAmount: 504000,
    irn: 'c7d2e9f6a3b0c7d4e1f8a5b2c9d6e3f0a7b4c1d8e5f2a9b6c3d0e7f4a1b8c5d2',
    status: 'Generated',
    windowType: '30-day',
    daysRemaining: 25,
    invoiceDate: '14 Feb 2026',
    qrGenerated: true,
  ),
  const EinvoiceRecord(
    id: 'einv-010',
    clientName: 'Adani Ports & SEZ Ltd',
    invoiceNumber: 'INV-2025-0556',
    buyerName: 'Container Corporation of India',
    invoiceValue: 7350000,
    gstAmount: 882000,
    irn: 'd0e5f2a9b6c3d0e7f4a1b8c5d2e9f6a3b0c7d4e1f8a5b2c9d6e3f0a7b4c1d8e5',
    status: 'Overdue',
    windowType: '3-day',
    daysRemaining: -7,
    invoiceDate: '28 Feb 2026',
    qrGenerated: false,
  ),
];

// ---------------------------------------------------------------------------
// Mock data — IRN Batches
// ---------------------------------------------------------------------------

final List<IrnBatch> _mockIrnBatches = [
  const IrnBatch(
    id: 'batch-001',
    clientName: 'Reliance Retail Ventures Ltd',
    totalInvoices: 450,
    successCount: 448,
    failedCount: 2,
    pendingCount: 0,
    totalValue: 1842.50,
    processedDate: '11 Mar 2026',
    batchStatus: 'Completed',
  ),
  const IrnBatch(
    id: 'batch-002',
    clientName: 'Tata Steel Ltd',
    totalInvoices: 120,
    successCount: 87,
    failedCount: 15,
    pendingCount: 18,
    totalValue: 6540.00,
    processedDate: '10 Mar 2026',
    batchStatus: 'Partial',
  ),
  const IrnBatch(
    id: 'batch-003',
    clientName: 'Mahindra & Mahindra Ltd',
    totalInvoices: 250,
    successCount: 0,
    failedCount: 0,
    pendingCount: 250,
    totalValue: 2890.75,
    processedDate: '11 Mar 2026',
    batchStatus: 'Processing',
  ),
  const IrnBatch(
    id: 'batch-004',
    clientName: 'Wipro Technologies Ltd',
    totalInvoices: 85,
    successCount: 0,
    failedCount: 85,
    pendingCount: 0,
    totalValue: 374.20,
    processedDate: '09 Mar 2026',
    batchStatus: 'Failed',
  ),
  const IrnBatch(
    id: 'batch-005',
    clientName: 'ITC Limited',
    totalInvoices: 500,
    successCount: 500,
    failedCount: 0,
    pendingCount: 0,
    totalValue: 5125.80,
    processedDate: '08 Mar 2026',
    batchStatus: 'Completed',
  ),
  const IrnBatch(
    id: 'batch-006',
    clientName: 'Adani Ports & SEZ Ltd',
    totalInvoices: 65,
    successCount: 58,
    failedCount: 3,
    pendingCount: 4,
    totalValue: 925.40,
    processedDate: '10 Mar 2026',
    batchStatus: 'Partial',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Exposes the full list of e-invoice records.
final allEinvoiceRecordsProvider = Provider<List<EinvoiceRecord>>((ref) {
  return _mockEinvoiceRecords;
});

/// Exposes the full list of IRN batches.
final allIrnBatchesProvider = Provider<List<IrnBatch>>((ref) {
  return _mockIrnBatches;
});

/// Notifier that holds the currently selected invoice status filter.
class SelectedStatusNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Selects [status] as the active filter; pass null to clear.
  void select(String? status) => state = status;
}

/// Provider for the currently selected invoice status filter.
final selectedInvoiceStatusProvider =
    NotifierProvider<SelectedStatusNotifier, String?>(
  SelectedStatusNotifier.new,
);

/// Returns [allEinvoiceRecordsProvider] filtered by [selectedInvoiceStatusProvider].
final filteredEinvoiceRecordsProvider = Provider<List<EinvoiceRecord>>((ref) {
  final all = ref.watch(allEinvoiceRecordsProvider);
  final status = ref.watch(selectedInvoiceStatusProvider);
  if (status == null) {
    return all;
  }
  return all.where((r) => r.status == status).toList();
});

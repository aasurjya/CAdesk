import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';
import 'package:ca_app/features/einvoicing/domain/repositories/einvoicing_repository.dart';

/// In-memory mock implementation of [EinvoicingRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockEinvoicingRepository implements EinvoicingRepository {
  static const List<EinvoiceRecord> _seedRecords = [
    EinvoiceRecord(
      id: 'einv-001',
      clientName: 'Tata Steel Ltd',
      invoiceNumber: 'INV-2026-0234',
      buyerName: 'JSPL Corporation',
      invoiceValue: 4850000,
      gstAmount: 873000,
      irn: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
      status: 'Generated',
      windowType: '3-day',
      daysRemaining: 2,
      invoiceDate: '11 Mar 2026',
      qrGenerated: true,
    ),
    EinvoiceRecord(
      id: 'einv-002',
      clientName: 'Tata Steel Ltd',
      invoiceNumber: 'INV-2026-0198',
      buyerName: 'Hindalco Industries',
      invoiceValue: 2100000,
      gstAmount: 378000,
      irn: 'b2c3d4e5f6b2c3d4e5f6b2c3d4e5f6b2c3d4e5f6b2c3d4e5f6b2c3d4e5f6b2c3',
      status: 'Generated',
      windowType: '30-day',
      daysRemaining: 18,
      invoiceDate: '25 Feb 2026',
      qrGenerated: true,
    ),
    EinvoiceRecord(
      id: 'einv-003',
      clientName: 'Infosys Ltd',
      invoiceNumber: 'INV-2026-0056',
      buyerName: 'TCS Global',
      invoiceValue: 750000,
      gstAmount: 135000,
      irn: 'c3d4e5f6c3d4e5f6c3d4e5f6c3d4e5f6c3d4e5f6c3d4e5f6c3d4e5f6c3d4e5f6',
      status: 'Cancelled',
      windowType: '30-day',
      daysRemaining: 0,
      invoiceDate: '01 Feb 2026',
      qrGenerated: false,
    ),
  ];

  static const List<IrnBatch> _seedBatches = [
    IrnBatch(
      id: 'batch-001',
      clientName: 'Tata Steel Ltd',
      totalInvoices: 50,
      successCount: 48,
      failedCount: 2,
      pendingCount: 0,
      totalValue: 24250.0,
      processedDate: '11 Mar 2026',
      batchStatus: 'Completed',
    ),
    IrnBatch(
      id: 'batch-002',
      clientName: 'Infosys Ltd',
      totalInvoices: 30,
      successCount: 30,
      failedCount: 0,
      pendingCount: 0,
      totalValue: 9800.0,
      processedDate: '10 Mar 2026',
      batchStatus: 'Completed',
    ),
    IrnBatch(
      id: 'batch-003',
      clientName: 'Sharma & Associates',
      totalInvoices: 15,
      successCount: 5,
      failedCount: 0,
      pendingCount: 10,
      totalValue: 1250.0,
      processedDate: '14 Mar 2026',
      batchStatus: 'Processing',
    ),
  ];

  final List<EinvoiceRecord> _records = List.of(_seedRecords);
  final List<IrnBatch> _batches = List.of(_seedBatches);

  @override
  Future<String> insertRecord(EinvoiceRecord record) async {
    _records.add(record);
    return record.id;
  }

  @override
  Future<List<EinvoiceRecord>> getAllRecords() async =>
      List.unmodifiable(_records);

  @override
  Future<List<EinvoiceRecord>> getRecordsByStatus(String status) async =>
      List.unmodifiable(_records.where((r) => r.status == status).toList());

  @override
  Future<List<EinvoiceRecord>> getRecordsByClient(String clientName) async =>
      List.unmodifiable(
        _records.where((r) => r.clientName == clientName).toList(),
      );

  @override
  Future<bool> updateRecord(EinvoiceRecord record) async {
    final idx = _records.indexWhere((r) => r.id == record.id);
    if (idx == -1) return false;
    final updated = List<EinvoiceRecord>.of(_records)..[idx] = record;
    _records
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteRecord(String id) async {
    final before = _records.length;
    _records.removeWhere((r) => r.id == id);
    return _records.length < before;
  }

  @override
  Future<String> insertBatch(IrnBatch batch) async {
    _batches.add(batch);
    return batch.id;
  }

  @override
  Future<List<IrnBatch>> getAllBatches() async => List.unmodifiable(_batches);

  @override
  Future<List<IrnBatch>> getBatchesByStatus(String batchStatus) async =>
      List.unmodifiable(
        _batches.where((b) => b.batchStatus == batchStatus).toList(),
      );

  @override
  Future<bool> updateBatch(IrnBatch batch) async {
    final idx = _batches.indexWhere((b) => b.id == batch.id);
    if (idx == -1) return false;
    final updated = List<IrnBatch>.of(_batches)..[idx] = batch;
    _batches
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteBatch(String id) async {
    final before = _batches.length;
    _batches.removeWhere((b) => b.id == id);
    return _batches.length < before;
  }
}

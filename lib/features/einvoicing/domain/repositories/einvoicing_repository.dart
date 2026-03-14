import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';

/// Abstract contract for e-invoicing data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class EinvoicingRepository {
  /// Insert a new [EinvoiceRecord] and return its generated ID.
  Future<String> insertRecord(EinvoiceRecord record);

  /// Retrieve all e-invoice records.
  Future<List<EinvoiceRecord>> getAllRecords();

  /// Retrieve records filtered by [status].
  Future<List<EinvoiceRecord>> getRecordsByStatus(String status);

  /// Retrieve records for a specific [clientName].
  Future<List<EinvoiceRecord>> getRecordsByClient(String clientName);

  /// Update an existing [EinvoiceRecord]. Returns true on success.
  Future<bool> updateRecord(EinvoiceRecord record);

  /// Delete the record identified by [id]. Returns true on success.
  Future<bool> deleteRecord(String id);

  /// Insert a new [IrnBatch] and return its generated ID.
  Future<String> insertBatch(IrnBatch batch);

  /// Retrieve all IRN batches.
  Future<List<IrnBatch>> getAllBatches();

  /// Retrieve batches filtered by [batchStatus].
  Future<List<IrnBatch>> getBatchesByStatus(String batchStatus);

  /// Update an existing [IrnBatch]. Returns true on success.
  Future<bool> updateBatch(IrnBatch batch);

  /// Delete the batch identified by [id]. Returns true on success.
  Future<bool> deleteBatch(String id);
}

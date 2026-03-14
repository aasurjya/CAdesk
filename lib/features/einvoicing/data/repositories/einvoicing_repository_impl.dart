import 'package:ca_app/features/einvoicing/data/datasources/einvoicing_local_source.dart';
import 'package:ca_app/features/einvoicing/data/datasources/einvoicing_remote_source.dart';
import 'package:ca_app/features/einvoicing/data/mappers/einvoicing_mapper.dart';
import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';
import 'package:ca_app/features/einvoicing/domain/repositories/einvoicing_repository.dart';

/// Real implementation of [EinvoicingRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class EinvoicingRepositoryImpl implements EinvoicingRepository {
  const EinvoicingRepositoryImpl({required this.remote, required this.local});

  final EinvoicingRemoteSource remote;
  final EinvoicingLocalSource local;

  @override
  Future<String> insertRecord(EinvoiceRecord record) async {
    try {
      final json = await remote.insertRecord(
        EinvoicingMapper.recordToJson(record),
      );
      final created = EinvoicingMapper.recordFromJson(json);
      await local.insertRecord(created);
      return created.id;
    } catch (_) {
      return local.insertRecord(record);
    }
  }

  @override
  Future<List<EinvoiceRecord>> getAllRecords() async {
    try {
      final jsonList = await remote.fetchAllRecords();
      final records = jsonList.map(EinvoicingMapper.recordFromJson).toList();
      for (final r in records) {
        await local.insertRecord(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getAllRecords();
    }
  }

  @override
  Future<List<EinvoiceRecord>> getRecordsByStatus(String status) async {
    try {
      final all = await getAllRecords();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    } catch (_) {
      final all = await local.getAllRecords();
      return List.unmodifiable(all.where((r) => r.status == status).toList());
    }
  }

  @override
  Future<List<EinvoiceRecord>> getRecordsByClient(String clientName) async {
    try {
      final all = await getAllRecords();
      return List.unmodifiable(
        all.where((r) => r.clientName == clientName).toList(),
      );
    } catch (_) {
      final all = await local.getAllRecords();
      return List.unmodifiable(
        all.where((r) => r.clientName == clientName).toList(),
      );
    }
  }

  @override
  Future<bool> updateRecord(EinvoiceRecord record) async {
    try {
      await remote.updateRecord(
        record.id,
        EinvoicingMapper.recordToJson(record),
      );
      await local.updateRecord(record);
      return true;
    } catch (_) {
      return local.updateRecord(record);
    }
  }

  @override
  Future<bool> deleteRecord(String id) async {
    try {
      await remote.deleteRecord(id);
      await local.deleteRecord(id);
      return true;
    } catch (_) {
      return local.deleteRecord(id);
    }
  }

  @override
  Future<String> insertBatch(IrnBatch batch) async {
    try {
      final json = await remote.insertBatch(
        EinvoicingMapper.batchToJson(batch),
      );
      final created = EinvoicingMapper.batchFromJson(json);
      await local.insertBatch(created);
      return created.id;
    } catch (_) {
      return local.insertBatch(batch);
    }
  }

  @override
  Future<List<IrnBatch>> getAllBatches() async {
    try {
      final jsonList = await remote.fetchAllBatches();
      final batches = jsonList.map(EinvoicingMapper.batchFromJson).toList();
      for (final b in batches) {
        await local.insertBatch(b);
      }
      return List.unmodifiable(batches);
    } catch (_) {
      return local.getAllBatches();
    }
  }

  @override
  Future<List<IrnBatch>> getBatchesByStatus(String batchStatus) async {
    try {
      final all = await getAllBatches();
      return List.unmodifiable(
        all.where((b) => b.batchStatus == batchStatus).toList(),
      );
    } catch (_) {
      final all = await local.getAllBatches();
      return List.unmodifiable(
        all.where((b) => b.batchStatus == batchStatus).toList(),
      );
    }
  }

  @override
  Future<bool> updateBatch(IrnBatch batch) async {
    try {
      await remote.updateBatch(batch.id, EinvoicingMapper.batchToJson(batch));
      await local.updateBatch(batch);
      return true;
    } catch (_) {
      return local.updateBatch(batch);
    }
  }

  @override
  Future<bool> deleteBatch(String id) async {
    try {
      await remote.deleteBatch(id);
      await local.deleteBatch(id);
      return true;
    } catch (_) {
      return local.deleteBatch(id);
    }
  }
}

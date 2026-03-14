import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/einvoicing/data/repositories/mock_einvoicing_repository.dart';
import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';

void main() {
  late MockEinvoicingRepository repo;

  setUp(() {
    repo = MockEinvoicingRepository();
  });

  group('MockEinvoicingRepository - EinvoiceRecord', () {
    test('getAllRecords returns non-empty seeded list', () async {
      final records = await repo.getAllRecords();
      expect(records, isNotEmpty);
    });

    test('getRecordsByStatus filters correctly', () async {
      final records = await repo.getRecordsByStatus('Generated');
      for (final r in records) {
        expect(r.status, 'Generated');
      }
    });

    test('getRecordsByClient filters correctly', () async {
      final records = await repo.getRecordsByClient('Tata Steel Ltd');
      for (final r in records) {
        expect(r.clientName, 'Tata Steel Ltd');
      }
    });

    test('insertRecord adds entry and returns id', () async {
      final record = EinvoiceRecord(
        id: 'einv-new-001',
        clientName: 'New Client Ltd',
        invoiceNumber: 'INV-2026-0001',
        buyerName: 'Buyer Corp',
        invoiceValue: 100000,
        gstAmount: 18000,
        irn: 'a' * 64,
        status: 'Generated',
        windowType: '30-day',
        daysRemaining: 25,
        invoiceDate: '01 Mar 2026',
        qrGenerated: true,
      );
      final id = await repo.insertRecord(record);
      expect(id, 'einv-new-001');

      final all = await repo.getAllRecords();
      expect(all.any((r) => r.id == 'einv-new-001'), isTrue);
    });

    test('updateRecord updates status and returns true', () async {
      final all = await repo.getAllRecords();
      final first = all.first;
      final updated = first.copyWith(status: 'Cancelled');
      final success = await repo.updateRecord(updated);
      expect(success, isTrue);

      final refetched = await repo.getAllRecords();
      final found = refetched.firstWhere((r) => r.id == first.id);
      expect(found.status, 'Cancelled');
    });

    test('updateRecord returns false for non-existent id', () async {
      final ghost = EinvoiceRecord(
        id: 'non-existent-einv',
        clientName: 'Ghost',
        invoiceNumber: 'INV-GHOST',
        buyerName: 'Nobody',
        invoiceValue: 0,
        gstAmount: 0,
        irn: 'z' * 64,
        status: 'Pending',
        windowType: '30-day',
        daysRemaining: 0,
        invoiceDate: '01 Jan 2020',
        qrGenerated: false,
      );
      final success = await repo.updateRecord(ghost);
      expect(success, isFalse);
    });

    test('deleteRecord removes entry and returns true', () async {
      final all = await repo.getAllRecords();
      final target = all.first;
      final deleted = await repo.deleteRecord(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllRecords();
      expect(remaining.any((r) => r.id == target.id), isFalse);
    });

    test('deleteRecord returns false for non-existent id', () async {
      final deleted = await repo.deleteRecord('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockEinvoicingRepository - IrnBatch', () {
    test('getAllBatches returns non-empty seeded list', () async {
      final batches = await repo.getAllBatches();
      expect(batches, isNotEmpty);
    });

    test('getBatchesByStatus filters correctly', () async {
      final batches = await repo.getBatchesByStatus('Completed');
      for (final b in batches) {
        expect(b.batchStatus, 'Completed');
      }
    });

    test('insertBatch adds entry and returns id', () async {
      final batch = IrnBatch(
        id: 'batch-new-001',
        clientName: 'New Client',
        totalInvoices: 10,
        successCount: 8,
        failedCount: 1,
        pendingCount: 1,
        totalValue: 500.0,
        processedDate: '14 Mar 2026',
        batchStatus: 'Completed',
      );
      final id = await repo.insertBatch(batch);
      expect(id, 'batch-new-001');
    });

    test('updateBatch returns true on success', () async {
      final all = await repo.getAllBatches();
      final first = all.first;
      final updated = first.copyWith(batchStatus: 'Failed');
      final success = await repo.updateBatch(updated);
      expect(success, isTrue);
    });

    test('updateBatch returns false for non-existent id', () async {
      final ghost = IrnBatch(
        id: 'non-existent-batch',
        clientName: 'Ghost',
        totalInvoices: 0,
        successCount: 0,
        failedCount: 0,
        pendingCount: 0,
        totalValue: 0,
        processedDate: '01 Jan 2020',
        batchStatus: 'Failed',
      );
      final success = await repo.updateBatch(ghost);
      expect(success, isFalse);
    });

    test('deleteBatch removes entry and returns true', () async {
      final all = await repo.getAllBatches();
      final target = all.first;
      final deleted = await repo.deleteBatch(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllBatches();
      expect(remaining.any((b) => b.id == target.id), isFalse);
    });

    test('deleteBatch returns false for non-existent id', () async {
      final deleted = await repo.deleteBatch('no-such-id');
      expect(deleted, isFalse);
    });
  });
}

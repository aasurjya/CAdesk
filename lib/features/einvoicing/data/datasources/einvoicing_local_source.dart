import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';

/// Local (SQLite via Drift) data source for e-invoicing records and IRN batches.
///
/// Note: full DAO wiring is deferred until the einvoicing tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class EinvoicingLocalSource {
  const EinvoicingLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertRecord(EinvoiceRecord record) async => record.id;

  Future<List<EinvoiceRecord>> getAllRecords() async => const [];

  Future<bool> updateRecord(EinvoiceRecord record) async => false;

  Future<bool> deleteRecord(String id) async => false;

  Future<String> insertBatch(IrnBatch batch) async => batch.id;

  Future<List<IrnBatch>> getAllBatches() async => const [];

  Future<bool> updateBatch(IrnBatch batch) async => false;

  Future<bool> deleteBatch(String id) async => false;
}

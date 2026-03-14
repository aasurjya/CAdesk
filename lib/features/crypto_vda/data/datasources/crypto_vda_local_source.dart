import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';

/// Local (SQLite via Drift) data source for crypto/VDA data.
///
/// Note: full DAO wiring is deferred until the crypto_vda tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class CryptoVdaLocalSource {
  const CryptoVdaLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertTransaction(VdaTransaction tx) async => tx.id;

  Future<List<VdaTransaction>> getAllTransactions() async => const [];

  Future<bool> updateTransaction(VdaTransaction tx) async => false;

  Future<bool> deleteTransaction(String id) async => false;

  Future<VdaSummary?> getSummaryByClient(
    String clientId,
    String assessmentYear,
  ) async => null;

  Future<void> upsertSummary(VdaSummary summary) async {}
}

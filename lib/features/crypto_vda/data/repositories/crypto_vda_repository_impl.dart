import 'package:ca_app/features/crypto_vda/data/datasources/crypto_vda_local_source.dart';
import 'package:ca_app/features/crypto_vda/data/datasources/crypto_vda_remote_source.dart';
import 'package:ca_app/features/crypto_vda/data/mappers/crypto_vda_mapper.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';
import 'package:ca_app/features/crypto_vda/domain/repositories/crypto_vda_repository.dart';

/// Real implementation of [CryptoVdaRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class CryptoVdaRepositoryImpl implements CryptoVdaRepository {
  const CryptoVdaRepositoryImpl({required this.remote, required this.local});

  final CryptoVdaRemoteSource remote;
  final CryptoVdaLocalSource local;

  @override
  Future<String> insertTransaction(VdaTransaction transaction) async {
    try {
      final json = await remote.insertTransaction(
        CryptoVdaMapper.transactionToJson(transaction),
      );
      final created = CryptoVdaMapper.transactionFromJson(json);
      await local.insertTransaction(created);
      return created.id;
    } catch (_) {
      return local.insertTransaction(transaction);
    }
  }

  @override
  Future<List<VdaTransaction>> getAllTransactions() async {
    try {
      final jsonList = await remote.fetchAllTransactions();
      final txs = jsonList.map(CryptoVdaMapper.transactionFromJson).toList();
      for (final tx in txs) {
        await local.insertTransaction(tx);
      }
      return List.unmodifiable(txs);
    } catch (_) {
      return local.getAllTransactions();
    }
  }

  @override
  Future<List<VdaTransaction>> getTransactionsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchTransactionsByClient(clientId);
      final txs = jsonList.map(CryptoVdaMapper.transactionFromJson).toList();
      return List.unmodifiable(txs);
    } catch (_) {
      final all = await local.getAllTransactions();
      return List.unmodifiable(
        all.where((t) => t.clientId == clientId).toList(),
      );
    }
  }

  @override
  Future<bool> updateTransaction(VdaTransaction transaction) async {
    try {
      await remote.updateTransaction(
        transaction.id,
        CryptoVdaMapper.transactionToJson(transaction),
      );
      await local.updateTransaction(transaction);
      return true;
    } catch (_) {
      return local.updateTransaction(transaction);
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    try {
      await remote.deleteTransaction(id);
      await local.deleteTransaction(id);
      return true;
    } catch (_) {
      return local.deleteTransaction(id);
    }
  }

  @override
  Future<VdaSummary?> getSummaryByClient(
    String clientId,
    String assessmentYear,
  ) async {
    try {
      final json = await remote.fetchSummaryByClient(clientId, assessmentYear);
      if (json == null) return null;
      final summary = CryptoVdaMapper.summaryFromJson(json);
      await local.upsertSummary(summary);
      return summary;
    } catch (_) {
      return local.getSummaryByClient(clientId, assessmentYear);
    }
  }

  @override
  Future<void> upsertSummary(VdaSummary summary) async {
    try {
      await remote.upsertSummary(CryptoVdaMapper.summaryToJson(summary));
      await local.upsertSummary(summary);
    } catch (_) {
      await local.upsertSummary(summary);
    }
  }
}

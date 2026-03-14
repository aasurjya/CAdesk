import 'package:ca_app/features/transfer_pricing/data/datasources/tp_local_source.dart';
import 'package:ca_app/features/transfer_pricing/data/datasources/tp_remote_source.dart';
import 'package:ca_app/features/transfer_pricing/data/mappers/tp_transaction_mapper.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_transaction.dart';
import 'package:ca_app/features/transfer_pricing/domain/repositories/tp_transaction_repository.dart';

class TpRepositoryImpl implements TpTransactionRepository {
  const TpRepositoryImpl({required this.remote, required this.local});

  final TpRemoteSource remote;
  final TpLocalSource local;

  @override
  Future<void> insert(TpTransaction transaction) async {
    try {
      final json = await remote.insert(TpTransactionMapper.toJson(transaction));
      final created = TpTransactionMapper.fromJson(json);
      await local.insert(created);
    } catch (_) {
      await local.insert(transaction);
    }
  }

  @override
  Future<List<TpTransaction>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final txs = jsonList.map(TpTransactionMapper.fromJson).toList();
      for (final tx in txs) {
        await local.insert(tx);
      }
      return List.unmodifiable(txs);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<TpTransaction>> getByYear(String assessmentYear) async {
    try {
      final jsonList = await remote.fetchByYear(assessmentYear);
      final txs = jsonList.map(TpTransactionMapper.fromJson).toList();
      for (final tx in txs) {
        await local.insert(tx);
      }
      return List.unmodifiable(txs);
    } catch (_) {
      return local.getByYear(assessmentYear);
    }
  }

  @override
  Future<void> updateStatus(String id, TpStatus status) async {
    try {
      await remote.update(id, {'status': status.name});
    } catch (_) {
      // Remote failed — local updated below (offline-first)
    }
    await local.updateStatus(id, status);
  }

  @override
  Future<List<TpTransaction>> getByMethod(TpMethod method) async {
    try {
      final jsonList = await remote.fetchByMethod(method.name);
      final txs = jsonList.map(TpTransactionMapper.fromJson).toList();
      for (final tx in txs) {
        await local.insert(tx);
      }
      return List.unmodifiable(txs);
    } catch (_) {
      return local.getByMethod(method);
    }
  }
}

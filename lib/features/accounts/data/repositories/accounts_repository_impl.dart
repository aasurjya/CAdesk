import 'package:ca_app/features/accounts/data/datasources/accounts_local_source.dart';
import 'package:ca_app/features/accounts/data/datasources/accounts_remote_source.dart';
import 'package:ca_app/features/accounts/data/mappers/accounts_mapper.dart';
import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';
import 'package:ca_app/features/accounts/domain/repositories/accounts_repository.dart';

/// Real implementation of [AccountsRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class AccountsRepositoryImpl implements AccountsRepository {
  const AccountsRepositoryImpl({required this.remote, required this.local});

  final AccountsRemoteSource remote;
  final AccountsLocalSource local;

  @override
  Future<List<FinancialStatement>> getStatementsByClient(
    String clientId,
    String financialYear,
  ) async {
    try {
      final jsonList = await remote.fetchByClient(clientId, financialYear);
      final statements = jsonList.map(AccountsMapper.fromJson).toList();
      for (final s in statements) {
        await local.insertStatement(s);
      }
      return List.unmodifiable(statements);
    } catch (_) {
      return local.getByClient(clientId, financialYear);
    }
  }

  @override
  Future<FinancialStatement?> getStatementById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final statement = AccountsMapper.fromJson(json);
      await local.insertStatement(statement);
      return statement;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<String> insertStatement(FinancialStatement statement) async {
    try {
      final json = await remote.insert(AccountsMapper.toJson(statement));
      final inserted = AccountsMapper.fromJson(json);
      await local.insertStatement(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertStatement(statement);
    }
  }

  @override
  Future<bool> updateStatement(FinancialStatement statement) async {
    try {
      final json = await remote.update(
        statement.id,
        AccountsMapper.toJson(statement),
      );
      final updated = AccountsMapper.fromJson(json);
      await local.updateStatement(updated);
      return true;
    } catch (_) {
      return local.updateStatement(statement);
    }
  }

  @override
  Future<bool> deleteStatement(String id) async {
    try {
      await remote.delete(id);
      await local.deleteStatement(id);
      return true;
    } catch (_) {
      return local.deleteStatement(id);
    }
  }

  @override
  Future<List<FinancialStatement>> getAllStatements() async {
    try {
      final jsonList = await remote.fetchAll();
      final statements = jsonList.map(AccountsMapper.fromJson).toList();
      for (final s in statements) {
        await local.insertStatement(s);
      }
      return List.unmodifiable(statements);
    } catch (_) {
      return local.getAll();
    }
  }
}

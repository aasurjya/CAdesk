import 'package:ca_app/features/tds/data/datasources/tds_return_local_source.dart';
import 'package:ca_app/features/tds/data/datasources/tds_return_remote_source.dart';
import 'package:ca_app/features/tds/data/mappers/tds_return_mapper.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/repositories/tds_return_repository.dart';

class TdsReturnRepositoryImpl implements TdsReturnRepository {
  const TdsReturnRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final TdsReturnRemoteSource remote;
  final TdsReturnLocalSource local;
  final String firmId;

  @override
  Future<List<TdsReturn>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final returns = jsonList.map(TdsReturnMapper.fromJson).toList();
      for (final tdsReturn in returns) {
        await local.upsert(tdsReturn, firmId: effectiveFirmId);
      }
      return List.unmodifiable(returns);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<TdsReturn?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final tdsReturn = TdsReturnMapper.fromJson(json);
      await local.upsert(tdsReturn, firmId: firmId);
      return tdsReturn;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<TdsReturn> create(TdsReturn tdsReturn) async {
    final json = await remote.insert({
      ...TdsReturnMapper.toJson(tdsReturn),
      'firm_id': firmId,
    });
    final created = TdsReturnMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<TdsReturn> update(TdsReturn tdsReturn) async {
    final json = await remote.update(
      tdsReturn.id,
      TdsReturnMapper.toJson(tdsReturn),
    );
    final updated = TdsReturnMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<TdsReturn>> getByFinancialYear(
    String fy, {
    String? firmId,
  }) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchByFinancialYear(
        fy,
        firmId: effectiveFirmId,
      );
      final returns = jsonList.map(TdsReturnMapper.fromJson).toList();
      for (final tdsReturn in returns) {
        await local.upsert(tdsReturn, firmId: effectiveFirmId);
      }
      return List.unmodifiable(returns);
    } catch (_) {
      return local.getByFinancialYear(fy, firmId: effectiveFirmId);
    }
  }

  @override
  Future<List<TdsReturn>> getByDeductorId(String deductorId) async {
    try {
      final jsonList = await remote.fetchByDeductorId(deductorId);
      final returns = jsonList.map(TdsReturnMapper.fromJson).toList();
      for (final tdsReturn in returns) {
        await local.upsert(tdsReturn, firmId: firmId);
      }
      return List.unmodifiable(returns);
    } catch (_) {
      return local.getByDeductorId(deductorId);
    }
  }

  @override
  Stream<List<TdsReturn>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}

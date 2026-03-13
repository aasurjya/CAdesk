import 'package:ca_app/features/tds/data/datasources/tds_challan_local_source.dart';
import 'package:ca_app/features/tds/data/datasources/tds_challan_remote_source.dart';
import 'package:ca_app/features/tds/data/mappers/tds_challan_mapper.dart';
import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/repositories/tds_challan_repository.dart';

class TdsChallanRepositoryImpl implements TdsChallanRepository {
  const TdsChallanRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final TdsChallanRemoteSource remote;
  final TdsChallanLocalSource local;
  final String firmId;

  @override
  Future<List<TdsChallan>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final challans = jsonList.map(TdsChallanMapper.fromJson).toList();
      for (final challan in challans) {
        await local.upsert(challan, firmId: effectiveFirmId);
      }
      return List.unmodifiable(challans);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<TdsChallan?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final challan = TdsChallanMapper.fromJson(json);
      await local.upsert(challan, firmId: firmId);
      return challan;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<TdsChallan> create(TdsChallan challan) async {
    final json = await remote.insert({
      ...TdsChallanMapper.toJson(challan),
      'firm_id': firmId,
    });
    final created = TdsChallanMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<TdsChallan> update(TdsChallan challan) async {
    final json = await remote.update(
      challan.id,
      TdsChallanMapper.toJson(challan),
    );
    final updated = TdsChallanMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<TdsChallan>> getByDeductorId(String deductorId) async {
    try {
      final jsonList = await remote.fetchByDeductorId(deductorId);
      final challans = jsonList.map(TdsChallanMapper.fromJson).toList();
      for (final challan in challans) {
        await local.upsert(challan, firmId: firmId);
      }
      return List.unmodifiable(challans);
    } catch (_) {
      return local.getByDeductorId(deductorId);
    }
  }

  @override
  Stream<List<TdsChallan>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}

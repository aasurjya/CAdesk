import 'package:ca_app/features/gst/data/datasources/gst_return_local_source.dart';
import 'package:ca_app/features/gst/data/datasources/gst_return_remote_source.dart';
import 'package:ca_app/features/gst/data/mappers/gst_return_mapper.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';
import 'package:ca_app/features/gst/domain/repositories/gst_return_repository.dart';

class GstReturnRepositoryImpl implements GstReturnRepository {
  const GstReturnRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final GstReturnRemoteSource remote;
  final GstReturnLocalSource local;
  final String firmId;

  @override
  Future<List<GstReturn>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final returns = jsonList.map(GstReturnMapper.fromJson).toList();
      for (final gstReturn in returns) {
        await local.upsert(gstReturn, firmId: effectiveFirmId);
      }
      return List.unmodifiable(returns);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<List<GstReturn>> getByClientId(String clientId) async {
    try {
      final jsonList = await remote.fetchByClientId(clientId);
      final returns = jsonList.map(GstReturnMapper.fromJson).toList();
      for (final gstReturn in returns) {
        await local.upsert(gstReturn, firmId: firmId);
      }
      return List.unmodifiable(returns);
    } catch (_) {
      return local.getByClientId(clientId);
    }
  }

  @override
  Future<GstReturn?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final gstReturn = GstReturnMapper.fromJson(json);
      await local.upsert(gstReturn, firmId: firmId);
      return gstReturn;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<GstReturn> create(GstReturn gstReturn) async {
    final json = await remote.insert({
      ...GstReturnMapper.toJson(gstReturn),
      'firm_id': firmId,
    });
    final created = GstReturnMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<GstReturn> update(GstReturn gstReturn) async {
    final json = await remote.update(
      gstReturn.id,
      GstReturnMapper.toJson(gstReturn),
    );
    final updated = GstReturnMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<GstReturn>> getByPeriod(
    int month,
    int year, {
    String? firmId,
  }) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.getByPeriod(
        month,
        year,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(jsonList.map(GstReturnMapper.fromJson).toList());
    } catch (_) {
      return local.getByPeriod(month, year, firmId: effectiveFirmId);
    }
  }

  @override
  Stream<List<GstReturn>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}

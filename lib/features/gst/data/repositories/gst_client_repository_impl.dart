import 'package:ca_app/features/gst/data/datasources/gst_client_local_source.dart';
import 'package:ca_app/features/gst/data/datasources/gst_client_remote_source.dart';
import 'package:ca_app/features/gst/data/mappers/gst_client_mapper.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';
import 'package:ca_app/features/gst/domain/repositories/gst_client_repository.dart';

class GstClientRepositoryImpl implements GstClientRepository {
  const GstClientRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final GstClientRemoteSource remote;
  final GstClientLocalSource local;
  final String firmId;

  @override
  Future<List<GstClient>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final clients = jsonList.map(GstClientMapper.fromJson).toList();
      for (final client in clients) {
        await local.upsert(client, firmId: effectiveFirmId);
      }
      return List.unmodifiable(clients);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<GstClient?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final client = GstClientMapper.fromJson(json);
      await local.upsert(client, firmId: firmId);
      return client;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<GstClient?> getByGstin(String gstin) async {
    try {
      final json = await remote.getByGstin(gstin);
      if (json == null) return null;
      final client = GstClientMapper.fromJson(json);
      await local.upsert(client, firmId: firmId);
      return client;
    } catch (_) {
      return local.getByGstin(gstin);
    }
  }

  @override
  Future<GstClient> create(GstClient client) async {
    final json = await remote.insert({
      ...GstClientMapper.toJson(client),
      'firm_id': firmId,
    });
    final created = GstClientMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<GstClient> update(GstClient client) async {
    final json = await remote.update(client.id, GstClientMapper.toJson(client));
    final updated = GstClientMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<GstClient>> search(String query, {String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.search(query, firmId: effectiveFirmId);
      return List.unmodifiable(jsonList.map(GstClientMapper.fromJson).toList());
    } catch (_) {
      // Local search: filter by query across businessName, gstin, pan
      final all = await local.getAll(firmId: effectiveFirmId);
      final q = query.toLowerCase();
      return all
          .where(
            (c) =>
                c.businessName.toLowerCase().contains(q) ||
                (c.tradeName?.toLowerCase().contains(q) ?? false) ||
                c.gstin.toLowerCase().contains(q) ||
                c.pan.toLowerCase().contains(q),
          )
          .toList();
    }
  }

  @override
  Stream<List<GstClient>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}

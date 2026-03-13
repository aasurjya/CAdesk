import 'package:ca_app/features/clients/data/datasources/clients_local_source.dart';
import 'package:ca_app/features/clients/data/datasources/clients_remote_source.dart';
import 'package:ca_app/features/clients/data/mappers/client_mapper.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  const ClientRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final ClientsRemoteSource remote;
  final ClientsLocalSource local;
  final String firmId;

  @override
  Future<List<Client>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final clients = jsonList.map(ClientMapper.fromJson).toList();
      // Cache locally — write-through to Drift
      for (final client in clients) {
        await local.upsert(client, firmId: effectiveFirmId);
      }
      return List.unmodifiable(clients);
    } catch (_) {
      // Fallback to local cache on network failure
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<Client?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final client = ClientMapper.fromJson(json);
      await local.upsert(client, firmId: firmId);
      return client;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<Client> create(Client client) async {
    final json = await remote.insert({
      ...ClientMapper.toJson(client),
      'firm_id': firmId,
    });
    final created = ClientMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<Client> update(Client client) async {
    final json = await remote.update(client.id, ClientMapper.toJson(client));
    final updated = ClientMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<Client>> search(String query, {String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.search(query, firmId: effectiveFirmId);
      return List.unmodifiable(jsonList.map(ClientMapper.fromJson).toList());
    } catch (_) {
      return local.search(query, firmId: effectiveFirmId);
    }
  }

  @override
  Stream<List<Client>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}

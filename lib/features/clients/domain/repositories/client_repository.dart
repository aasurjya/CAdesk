import 'package:ca_app/features/clients/domain/models/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getAll({String? firmId});
  Future<Client?> getById(String id);
  Future<Client> create(Client client);
  Future<Client> update(Client client);
  Future<void> delete(String id);
  Future<List<Client>> search(String query, {String? firmId});
  Stream<List<Client>> watchAll({String? firmId});
}

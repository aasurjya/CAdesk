import 'package:ca_app/features/gst/domain/models/gst_client.dart';

abstract class GstClientRepository {
  Future<List<GstClient>> getAll({String? firmId});
  Future<GstClient?> getById(String id);
  Future<GstClient?> getByGstin(String gstin);
  Future<GstClient> create(GstClient client);
  Future<GstClient> update(GstClient client);
  Future<void> delete(String id);
  Future<List<GstClient>> search(String query, {String? firmId});
  Stream<List<GstClient>> watchAll({String? firmId});
}

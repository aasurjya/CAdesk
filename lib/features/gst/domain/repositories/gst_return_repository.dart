import 'package:ca_app/features/gst/domain/models/gst_return.dart';

abstract class GstReturnRepository {
  Future<List<GstReturn>> getAll({String? firmId});
  Future<List<GstReturn>> getByClientId(String clientId);
  Future<GstReturn?> getById(String id);
  Future<GstReturn> create(GstReturn gstReturn);
  Future<GstReturn> update(GstReturn gstReturn);
  Future<void> delete(String id);
  Future<List<GstReturn>> getByPeriod(int month, int year, {String? firmId});
  Stream<List<GstReturn>> watchAll({String? firmId});
}

import 'package:ca_app/features/tds/domain/models/tds_challan.dart';

abstract class TdsChallanRepository {
  Future<List<TdsChallan>> getAll({String? firmId});
  Future<TdsChallan?> getById(String id);
  Future<TdsChallan> create(TdsChallan challan);
  Future<TdsChallan> update(TdsChallan challan);
  Future<void> delete(String id);
  Future<List<TdsChallan>> getByDeductorId(String deductorId);
  Stream<List<TdsChallan>> watchAll({String? firmId});
}

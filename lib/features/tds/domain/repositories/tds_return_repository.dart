import 'package:ca_app/features/tds/domain/models/tds_return.dart';

abstract class TdsReturnRepository {
  Future<List<TdsReturn>> getAll({String? firmId});
  Future<TdsReturn?> getById(String id);
  Future<TdsReturn> create(TdsReturn tdsReturn);
  Future<TdsReturn> update(TdsReturn tdsReturn);
  Future<void> delete(String id);
  Future<List<TdsReturn>> getByFinancialYear(String fy, {String? firmId});
  Future<List<TdsReturn>> getByDeductorId(String deductorId);
  Stream<List<TdsReturn>> watchAll({String? firmId});
}

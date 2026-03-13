import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';

abstract class ItrFilingRepository {
  Future<List<ItrClient>> getAll({String? firmId});
  Future<ItrClient?> getById(String id);
  Future<ItrClient> create(ItrClient filing);
  Future<ItrClient> update(ItrClient filing);
  Future<void> delete(String id);
  Future<List<ItrClient>> search(String query, {String? firmId});
  Future<List<ItrClient>> getByAssessmentYear(String ay, {String? firmId});
  Stream<List<ItrClient>> watchAll({String? firmId});
}

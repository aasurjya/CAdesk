import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/repositories/itr_form_data_repository.dart';

/// In-memory implementation of [ItrFormDataRepository] for development/testing.
class InMemoryItrFormDataRepository implements ItrFormDataRepository {
  final Map<String, Itr1FormData> _itr1Store = {};

  @override
  Future<Itr1FormData?> getItr1Data(String jobId) async {
    return _itr1Store[jobId];
  }

  @override
  Future<void> saveItr1Data(String jobId, Itr1FormData data) async {
    _itr1Store[jobId] = data;
  }

  @override
  Future<void> deleteFormData(String jobId) async {
    _itr1Store.remove(jobId);
  }
}

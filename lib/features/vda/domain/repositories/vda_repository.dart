import 'package:ca_app/features/vda/domain/models/vda_record.dart';

abstract class VdaRepository {
  Future<void> insert(VdaRecord record);
  Future<List<VdaRecord>> getByClient(String clientId);
  Future<List<VdaRecord>> getByYear(String assessmentYear);
  Future<double> getTotalGainLoss(String clientId, String assessmentYear);
  Future<double> getTdsDeducted(String clientId, String assessmentYear);
  Future<void> delete(String id);
}

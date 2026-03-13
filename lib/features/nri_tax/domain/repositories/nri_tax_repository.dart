import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';

abstract class NriTaxRepository {
  Future<void> insert(NriTaxRecord record);
  Future<List<NriTaxRecord>> getByClient(String clientId);
  Future<List<NriTaxRecord>> getByYear(String assessmentYear);
  Future<void> updateStatus(String id, NriTaxStatus status);
  Future<List<NriTaxRecord>> getScheduleFARequired();
}

import 'package:ca_app/features/xbrl/domain/models/xbrl_filing.dart';
import 'package:ca_app/features/xbrl/domain/repositories/xbrl_repository.dart';

/// Real implementation of [XbrlRepository].
///
/// Full Drift/Supabase wiring is deferred until the portal integration phase.
class XbrlRepositoryImpl implements XbrlRepository {
  const XbrlRepositoryImpl();

  @override
  Future<List<XbrlFiling>> getAllFilings() async => const [];

  @override
  Future<List<XbrlFiling>> getFilingsByCompany(String companyId) async =>
      const [];

  @override
  Future<XbrlFiling?> getFilingById(String id) async => null;

  @override
  Future<String> insertFiling(XbrlFiling filing) async => filing.id;

  @override
  Future<bool> updateFiling(XbrlFiling filing) async => true;

  @override
  Future<bool> deleteFiling(String id) async => true;
}

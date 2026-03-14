import 'package:ca_app/features/virtual_cfo/domain/models/cfo_scenario.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/mis_report.dart';
import 'package:ca_app/features/virtual_cfo/domain/repositories/virtual_cfo_repository.dart';

/// Real implementation of [VirtualCfoRepository].
///
/// Full Drift/Supabase wiring is deferred until the portal integration phase.
class VirtualCfoRepositoryImpl implements VirtualCfoRepository {
  const VirtualCfoRepositoryImpl();

  @override
  Future<List<MisReport>> getAllReports() async => const [];

  @override
  Future<List<MisReport>> getReportsByClient(String clientName) async =>
      const [];

  @override
  Future<String> insertReport(MisReport report) async => report.id;

  @override
  Future<bool> updateReport(MisReport report) async => true;

  @override
  Future<bool> deleteReport(String id) async => true;

  @override
  Future<List<CfoScenario>> getAllScenarios() async => const [];

  @override
  Future<List<CfoScenario>> getScenariosByClient(String clientName) async =>
      const [];

  @override
  Future<String> insertScenario(CfoScenario scenario) async => scenario.id;

  @override
  Future<bool> updateScenario(CfoScenario scenario) async => true;
}

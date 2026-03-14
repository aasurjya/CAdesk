import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

/// Local (SQLite via Drift) data source for ESG reporting.
///
/// Note: full DAO wiring is deferred until the esg_reporting tables are added
/// to [AppDatabase]. This stub delegates gracefully so the repository layer
/// compiles while the database scaffold is pending.
class EsgReportingLocalSource {
  const EsgReportingLocalSource(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<String> insertDisclosure(EsgDisclosure disclosure) async =>
      disclosure.id;

  Future<List<EsgDisclosure>> getAllDisclosures() async => const [];

  Future<bool> updateDisclosure(EsgDisclosure disclosure) async => false;

  Future<bool> deleteDisclosure(String id) async => false;

  Future<String> insertCarbonMetric(CarbonMetric metric) async => metric.id;

  Future<List<CarbonMetric>> getAllCarbonMetrics() async => const [];

  Future<bool> updateCarbonMetric(CarbonMetric metric) async => false;

  Future<bool> deleteCarbonMetric(String id) async => false;
}

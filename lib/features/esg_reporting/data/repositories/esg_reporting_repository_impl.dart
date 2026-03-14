import 'package:ca_app/features/esg_reporting/data/datasources/esg_reporting_local_source.dart';
import 'package:ca_app/features/esg_reporting/data/datasources/esg_reporting_remote_source.dart';
import 'package:ca_app/features/esg_reporting/data/mappers/esg_reporting_mapper.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/repositories/esg_reporting_repository.dart';

/// Real implementation of [EsgReportingRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class EsgReportingRepositoryImpl implements EsgReportingRepository {
  const EsgReportingRepositoryImpl({required this.remote, required this.local});

  final EsgReportingRemoteSource remote;
  final EsgReportingLocalSource local;

  @override
  Future<String> insertDisclosure(EsgDisclosure disclosure) async {
    try {
      final json = await remote.insertDisclosure(
        EsgReportingMapper.disclosureToJson(disclosure),
      );
      final created = EsgReportingMapper.disclosureFromJson(json);
      await local.insertDisclosure(created);
      return created.id;
    } catch (_) {
      return local.insertDisclosure(disclosure);
    }
  }

  @override
  Future<List<EsgDisclosure>> getAllDisclosures() async {
    try {
      final jsonList = await remote.fetchAllDisclosures();
      final disclosures = jsonList
          .map(EsgReportingMapper.disclosureFromJson)
          .toList();
      for (final d in disclosures) {
        await local.insertDisclosure(d);
      }
      return List.unmodifiable(disclosures);
    } catch (_) {
      return local.getAllDisclosures();
    }
  }

  @override
  Future<List<EsgDisclosure>> getDisclosuresByStatus(String status) async {
    try {
      final all = await getAllDisclosures();
      return List.unmodifiable(all.where((d) => d.status == status).toList());
    } catch (_) {
      final all = await local.getAllDisclosures();
      return List.unmodifiable(all.where((d) => d.status == status).toList());
    }
  }

  @override
  Future<List<EsgDisclosure>> getDisclosuresByClient(String clientPan) async {
    try {
      final all = await getAllDisclosures();
      return List.unmodifiable(
        all.where((d) => d.clientPan == clientPan).toList(),
      );
    } catch (_) {
      final all = await local.getAllDisclosures();
      return List.unmodifiable(
        all.where((d) => d.clientPan == clientPan).toList(),
      );
    }
  }

  @override
  Future<bool> updateDisclosure(EsgDisclosure disclosure) async {
    try {
      await remote.updateDisclosure(
        disclosure.id,
        EsgReportingMapper.disclosureToJson(disclosure),
      );
      await local.updateDisclosure(disclosure);
      return true;
    } catch (_) {
      return local.updateDisclosure(disclosure);
    }
  }

  @override
  Future<bool> deleteDisclosure(String id) async {
    try {
      await remote.deleteDisclosure(id);
      await local.deleteDisclosure(id);
      return true;
    } catch (_) {
      return local.deleteDisclosure(id);
    }
  }

  @override
  Future<String> insertCarbonMetric(CarbonMetric metric) async {
    try {
      final json = await remote.insertCarbonMetric(
        EsgReportingMapper.metricToJson(metric),
      );
      final created = EsgReportingMapper.metricFromJson(json);
      await local.insertCarbonMetric(created);
      return created.id;
    } catch (_) {
      return local.insertCarbonMetric(metric);
    }
  }

  @override
  Future<List<CarbonMetric>> getAllCarbonMetrics() async {
    try {
      final jsonList = await remote.fetchAllCarbonMetrics();
      final metrics = jsonList.map(EsgReportingMapper.metricFromJson).toList();
      for (final m in metrics) {
        await local.insertCarbonMetric(m);
      }
      return List.unmodifiable(metrics);
    } catch (_) {
      return local.getAllCarbonMetrics();
    }
  }

  @override
  Future<List<CarbonMetric>> getCarbonMetricsByClient(String clientName) async {
    try {
      final all = await getAllCarbonMetrics();
      return List.unmodifiable(
        all.where((m) => m.clientName == clientName).toList(),
      );
    } catch (_) {
      final all = await local.getAllCarbonMetrics();
      return List.unmodifiable(
        all.where((m) => m.clientName == clientName).toList(),
      );
    }
  }

  @override
  Future<List<CarbonMetric>> getCarbonMetricsByYear(
    String reportingYear,
  ) async {
    try {
      final all = await getAllCarbonMetrics();
      return List.unmodifiable(
        all.where((m) => m.reportingYear == reportingYear).toList(),
      );
    } catch (_) {
      final all = await local.getAllCarbonMetrics();
      return List.unmodifiable(
        all.where((m) => m.reportingYear == reportingYear).toList(),
      );
    }
  }

  @override
  Future<bool> updateCarbonMetric(CarbonMetric metric) async {
    try {
      await remote.updateCarbonMetric(
        metric.id,
        EsgReportingMapper.metricToJson(metric),
      );
      await local.updateCarbonMetric(metric);
      return true;
    } catch (_) {
      return local.updateCarbonMetric(metric);
    }
  }

  @override
  Future<bool> deleteCarbonMetric(String id) async {
    try {
      await remote.deleteCarbonMetric(id);
      await local.deleteCarbonMetric(id);
      return true;
    } catch (_) {
      return local.deleteCarbonMetric(id);
    }
  }
}

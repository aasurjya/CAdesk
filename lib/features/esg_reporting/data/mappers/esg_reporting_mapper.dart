import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

/// Converts between [EsgDisclosure] / [CarbonMetric] and JSON maps.
class EsgReportingMapper {
  const EsgReportingMapper._();

  static EsgDisclosure disclosureFromJson(Map<String, dynamic> json) {
    final rawPendingItems = json['pending_items'];
    final pendingItems = rawPendingItems is List
        ? List<String>.from(rawPendingItems)
        : <String>[];

    return EsgDisclosure(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      clientPan: json['client_pan'] as String,
      disclosureType: json['disclosure_type'] as String,
      reportingYear: json['reporting_year'] as String,
      environmentScore: (json['environment_score'] as num).toDouble(),
      socialScore: (json['social_score'] as num).toDouble(),
      governanceScore: (json['governance_score'] as num).toDouble(),
      overallScore: (json['overall_score'] as num).toDouble(),
      status: json['status'] as String? ?? 'Draft',
      sebiCategory: json['sebi_category'] as String? ?? 'Voluntary',
      pendingItems: pendingItems,
    );
  }

  static Map<String, dynamic> disclosureToJson(EsgDisclosure disclosure) {
    return {
      'id': disclosure.id,
      'client_name': disclosure.clientName,
      'client_pan': disclosure.clientPan,
      'disclosure_type': disclosure.disclosureType,
      'reporting_year': disclosure.reportingYear,
      'environment_score': disclosure.environmentScore,
      'social_score': disclosure.socialScore,
      'governance_score': disclosure.governanceScore,
      'overall_score': disclosure.overallScore,
      'status': disclosure.status,
      'sebi_category': disclosure.sebiCategory,
      'pending_items': disclosure.pendingItems,
    };
  }

  static CarbonMetric metricFromJson(Map<String, dynamic> json) {
    return CarbonMetric(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      scope: json['scope'] as String,
      emissionsTonnes: (json['emissions_tonnes'] as num).toDouble(),
      reductionTargetPercent: (json['reduction_target_percent'] as num)
          .toDouble(),
      achievedPercent: (json['achieved_percent'] as num).toDouble(),
      reportingYear: json['reporting_year'] as String,
      unit: json['unit'] as String? ?? 'tCO2e',
    );
  }

  static Map<String, dynamic> metricToJson(CarbonMetric metric) {
    return {
      'id': metric.id,
      'client_name': metric.clientName,
      'scope': metric.scope,
      'emissions_tonnes': metric.emissionsTonnes,
      'reduction_target_percent': metric.reductionTargetPercent,
      'achieved_percent': metric.achievedPercent,
      'reporting_year': metric.reportingYear,
      'unit': metric.unit,
    };
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/esg_reporting/data/mappers/esg_reporting_mapper.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

void main() {
  group('EsgReportingMapper', () {
    // -------------------------------------------------------------------------
    // EsgDisclosure
    // -------------------------------------------------------------------------
    group('disclosureFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'esg-001',
          'client_name': 'Tata Consultancy Services',
          'client_pan': 'TCSPD1234A',
          'disclosure_type': 'BRSR',
          'reporting_year': 'FY 2024-25',
          'environment_score': 78.5,
          'social_score': 82.0,
          'governance_score': 90.0,
          'overall_score': 83.5,
          'status': 'Filed',
          'sebi_category': 'Listed Top 1000',
          'pending_items': ['Scope 3 data upload', 'Board resolution'],
        };

        final disclosure = EsgReportingMapper.disclosureFromJson(json);

        expect(disclosure.id, 'esg-001');
        expect(disclosure.clientName, 'Tata Consultancy Services');
        expect(disclosure.clientPan, 'TCSPD1234A');
        expect(disclosure.disclosureType, 'BRSR');
        expect(disclosure.reportingYear, 'FY 2024-25');
        expect(disclosure.environmentScore, 78.5);
        expect(disclosure.socialScore, 82.0);
        expect(disclosure.governanceScore, 90.0);
        expect(disclosure.overallScore, 83.5);
        expect(disclosure.status, 'Filed');
        expect(disclosure.sebiCategory, 'Listed Top 1000');
        expect(disclosure.pendingItems.length, 2);
        expect(disclosure.pendingItems[0], 'Scope 3 data upload');
      });

      test('defaults status to Draft and sebiCategory to Voluntary when missing', () {
        final json = {
          'id': 'esg-002',
          'client_name': '',
          'client_pan': '',
          'disclosure_type': 'Sustainability Report',
          'reporting_year': 'FY 2024-25',
          'environment_score': 0.0,
          'social_score': 0.0,
          'governance_score': 0.0,
          'overall_score': 0.0,
          'pending_items': <String>[],
        };

        final disclosure = EsgReportingMapper.disclosureFromJson(json);
        expect(disclosure.status, 'Draft');
        expect(disclosure.sebiCategory, 'Voluntary');
        expect(disclosure.pendingItems, isEmpty);
      });

      test('handles empty pending_items list', () {
        final json = {
          'id': 'esg-003',
          'client_name': 'ABC Ltd',
          'client_pan': 'ABCDE1234F',
          'disclosure_type': 'BRSR',
          'reporting_year': 'FY 2024-25',
          'environment_score': 65.0,
          'social_score': 70.0,
          'governance_score': 75.0,
          'overall_score': 70.0,
          'status': 'Under Review',
          'sebi_category': 'BRSR Core',
          'pending_items': <dynamic>[],
        };

        final disclosure = EsgReportingMapper.disclosureFromJson(json);
        expect(disclosure.pendingItems, isEmpty);
        expect(disclosure.status, 'Under Review');
      });

      test('handles null pending_items gracefully', () {
        final json = {
          'id': 'esg-004',
          'client_name': '',
          'client_pan': '',
          'disclosure_type': 'Carbon Disclosure',
          'reporting_year': 'FY 2023-24',
          'environment_score': 50.0,
          'social_score': 55.0,
          'governance_score': 60.0,
          'overall_score': 55.0,
          'status': 'Draft',
          'sebi_category': 'Voluntary',
          'pending_items': null,
        };

        final disclosure = EsgReportingMapper.disclosureFromJson(json);
        expect(disclosure.pendingItems, isEmpty);
      });

      test('handles integer scores and converts to double', () {
        final json = {
          'id': 'esg-005',
          'client_name': '',
          'client_pan': '',
          'disclosure_type': 'BRSR',
          'reporting_year': 'FY 2024-25',
          'environment_score': 80,
          'social_score': 85,
          'governance_score': 90,
          'overall_score': 85,
          'status': 'Published',
          'sebi_category': 'Listed Top 1000',
          'pending_items': <String>[],
        };

        final disclosure = EsgReportingMapper.disclosureFromJson(json);
        expect(disclosure.environmentScore, 80.0);
        expect(disclosure.environmentScore, isA<double>());
        expect(disclosure.overallScore, 85.0);
      });
    });

    group('disclosureToJson', () {
      test('includes all fields and round-trips correctly', () {
        const disclosure = EsgDisclosure(
          id: 'esg-json-001',
          clientName: 'Infosys Ltd',
          clientPan: 'INFOS1234B',
          disclosureType: 'Integrated Report',
          reportingYear: 'FY 2025-26',
          environmentScore: 88.5,
          socialScore: 91.0,
          governanceScore: 95.0,
          overallScore: 91.5,
          status: 'Published',
          sebiCategory: 'Listed Top 1000',
          pendingItems: ['Annual report upload'],
        );

        final json = EsgReportingMapper.disclosureToJson(disclosure);

        expect(json['id'], 'esg-json-001');
        expect(json['client_name'], 'Infosys Ltd');
        expect(json['disclosure_type'], 'Integrated Report');
        expect(json['environment_score'], 88.5);
        expect(json['overall_score'], 91.5);
        expect(json['status'], 'Published');
        expect((json['pending_items'] as List).length, 1);

        final restored = EsgReportingMapper.disclosureFromJson(json);
        expect(restored.id, disclosure.id);
        expect(restored.environmentScore, disclosure.environmentScore);
        expect(restored.pendingItems, disclosure.pendingItems);
      });
    });

    // -------------------------------------------------------------------------
    // CarbonMetric
    // -------------------------------------------------------------------------
    group('metricFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'carbon-001',
          'client_name': 'Steel Corp',
          'scope': 'Scope 1 (Direct)',
          'emissions_tonnes': 25000.5,
          'reduction_target_percent': 30.0,
          'achieved_percent': 15.0,
          'reporting_year': 'FY 2024-25',
          'unit': 'tCO2e',
        };

        final metric = EsgReportingMapper.metricFromJson(json);

        expect(metric.id, 'carbon-001');
        expect(metric.clientName, 'Steel Corp');
        expect(metric.scope, 'Scope 1 (Direct)');
        expect(metric.emissionsTonnes, 25000.5);
        expect(metric.reductionTargetPercent, 30.0);
        expect(metric.achievedPercent, 15.0);
        expect(metric.reportingYear, 'FY 2024-25');
        expect(metric.unit, 'tCO2e');
      });

      test('defaults unit to tCO2e when missing', () {
        final json = {
          'id': 'carbon-002',
          'client_name': '',
          'scope': 'Scope 2 (Electricity)',
          'emissions_tonnes': 500.0,
          'reduction_target_percent': 20.0,
          'achieved_percent': 10.0,
          'reporting_year': 'FY 2024-25',
        };

        final metric = EsgReportingMapper.metricFromJson(json);
        expect(metric.unit, 'tCO2e');
      });

      test('handles integer emissions as double', () {
        final json = {
          'id': 'carbon-003',
          'client_name': '',
          'scope': 'Scope 3 (Value Chain)',
          'emissions_tonnes': 10000,
          'reduction_target_percent': 25,
          'achieved_percent': 5,
          'reporting_year': 'FY 2024-25',
          'unit': 'tCO2e',
        };

        final metric = EsgReportingMapper.metricFromJson(json);
        expect(metric.emissionsTonnes, 10000.0);
        expect(metric.emissionsTonnes, isA<double>());
        expect(metric.reductionTargetPercent, 25.0);
      });
    });

    group('metricToJson', () {
      test('includes all fields and round-trips correctly', () {
        const metric = CarbonMetric(
          id: 'carbon-json-001',
          clientName: 'Chemical Industries',
          scope: 'Scope 1 (Direct)',
          emissionsTonnes: 8500.0,
          reductionTargetPercent: 40.0,
          achievedPercent: 18.5,
          reportingYear: 'FY 2025-26',
          unit: 'tCO2e',
        );

        final json = EsgReportingMapper.metricToJson(metric);

        expect(json['id'], 'carbon-json-001');
        expect(json['client_name'], 'Chemical Industries');
        expect(json['scope'], 'Scope 1 (Direct)');
        expect(json['emissions_tonnes'], 8500.0);
        expect(json['reduction_target_percent'], 40.0);
        expect(json['achieved_percent'], 18.5);
        expect(json['unit'], 'tCO2e');

        final restored = EsgReportingMapper.metricFromJson(json);
        expect(restored.id, metric.id);
        expect(restored.emissionsTonnes, metric.emissionsTonnes);
        expect(restored.reductionTargetPercent, metric.reductionTargetPercent);
        expect(restored.unit, metric.unit);
      });
    });
  });
}

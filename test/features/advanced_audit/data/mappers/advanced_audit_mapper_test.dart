import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/advanced_audit/data/mappers/advanced_audit_mapper.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';

void main() {
  group('AdvancedAuditMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'ae-001',
          'client_id': 'client-001',
          'client_name': 'ABC Corp',
          'audit_type': 'statutory',
          'financial_year': '2024-25',
          'assigned_partner': 'CA Mehta',
          'team_members': ['member1', 'member2'],
          'status': 'fieldwork',
          'start_date': '2025-04-01T00:00:00.000Z',
          'end_date': '2025-09-30T00:00:00.000Z',
          'report_due_date': '2025-10-31T00:00:00.000Z',
          'workpaper_count': 25,
          'findings_count': 3,
          'risk_level': 'medium',
        };

        final engagement = AdvancedAuditMapper.fromJson(json);

        expect(engagement.id, 'ae-001');
        expect(engagement.clientId, 'client-001');
        expect(engagement.clientName, 'ABC Corp');
        expect(engagement.auditType, AuditType.statutory);
        expect(engagement.financialYear, '2024-25');
        expect(engagement.assignedPartner, 'CA Mehta');
        expect(engagement.teamMembers, ['member1', 'member2']);
        expect(engagement.status, AuditStatus.fieldwork);
        expect(engagement.endDate, isNotNull);
        expect(engagement.workpaperCount, 25);
        expect(engagement.findingsCount, 3);
        expect(engagement.riskLevel, AuditRiskLevel.medium);
      });

      test('handles null end_date', () {
        final json = {
          'id': 'ae-002',
          'client_id': 'client-002',
          'client_name': 'XYZ Ltd',
          'audit_type': 'internal',
          'financial_year': '2024-25',
          'assigned_partner': '',
          'team_members': <String>[],
          'status': 'planning',
          'start_date': '2025-04-01T00:00:00.000Z',
          'report_due_date': '2025-10-31T00:00:00.000Z',
          'workpaper_count': 0,
          'findings_count': 0,
          'risk_level': 'low',
        };

        final engagement = AdvancedAuditMapper.fromJson(json);
        expect(engagement.endDate, isNull);
      });

      test('handles missing team_members with empty list', () {
        final json = {
          'id': 'ae-003',
          'client_id': 'c1',
          'client_name': '',
          'audit_type': 'bank',
          'financial_year': '2024-25',
          'assigned_partner': '',
          'status': 'planning',
          'start_date': '2025-01-01T00:00:00.000Z',
          'report_due_date': '2025-12-31T00:00:00.000Z',
          'workpaper_count': 0,
          'findings_count': 0,
          'risk_level': 'low',
        };

        final engagement = AdvancedAuditMapper.fromJson(json);
        expect(engagement.teamMembers, isEmpty);
      });

      test('defaults audit_type to statutory for unknown value', () {
        final json = {
          'id': 'ae-004',
          'client_id': 'c1',
          'client_name': '',
          'audit_type': 'unknownType',
          'financial_year': '',
          'assigned_partner': '',
          'team_members': <String>[],
          'status': 'planning',
          'start_date': '2025-01-01T00:00:00.000Z',
          'report_due_date': '2025-12-31T00:00:00.000Z',
          'workpaper_count': 0,
          'findings_count': 0,
          'risk_level': 'low',
        };

        final engagement = AdvancedAuditMapper.fromJson(json);
        expect(engagement.auditType, AuditType.statutory);
      });

      test('defaults risk_level to low for unknown value', () {
        final json = {
          'id': 'ae-005',
          'client_id': 'c1',
          'client_name': '',
          'audit_type': 'statutory',
          'financial_year': '',
          'assigned_partner': '',
          'team_members': <String>[],
          'status': 'planning',
          'start_date': '2025-01-01T00:00:00.000Z',
          'report_due_date': '2025-12-31T00:00:00.000Z',
          'workpaper_count': 0,
          'findings_count': 0,
          'risk_level': 'unknownRisk',
        };

        final engagement = AdvancedAuditMapper.fromJson(json);
        expect(engagement.riskLevel, AuditRiskLevel.low);
      });

      test('handles all AuditType values', () {
        for (final type in AuditType.values) {
          final json = {
            'id': 'ae-type-${type.name}',
            'client_id': 'c1',
            'client_name': '',
            'audit_type': type.name,
            'financial_year': '',
            'assigned_partner': '',
            'team_members': <String>[],
            'status': 'planning',
            'start_date': '2025-01-01T00:00:00.000Z',
            'report_due_date': '2025-12-31T00:00:00.000Z',
            'workpaper_count': 0,
            'findings_count': 0,
            'risk_level': 'low',
          };
          final engagement = AdvancedAuditMapper.fromJson(json);
          expect(engagement.auditType, type);
        }
      });
    });

    group('toJson', () {
      late AuditEngagement sampleEngagement;

      setUp(() {
        sampleEngagement = AuditEngagement(
          id: 'ae-json-001',
          clientId: 'client-json-001',
          clientName: 'Test Corp',
          auditType: AuditType.forensic,
          financialYear: '2024-25',
          assignedPartner: 'CA Joshi',
          teamMembers: const ['member-a', 'member-b', 'member-c'],
          status: AuditStatus.review,
          startDate: DateTime(2025, 5, 1),
          endDate: DateTime(2025, 10, 31),
          reportDueDate: DateTime(2025, 11, 30),
          workpaperCount: 50,
          findingsCount: 7,
          riskLevel: AuditRiskLevel.high,
        );
      });

      test('includes all fields', () {
        final json = AdvancedAuditMapper.toJson(sampleEngagement);

        expect(json['id'], 'ae-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Test Corp');
        expect(json['audit_type'], 'forensic');
        expect(json['financial_year'], '2024-25');
        expect(json['assigned_partner'], 'CA Joshi');
        expect(json['team_members'], ['member-a', 'member-b', 'member-c']);
        expect(json['status'], 'review');
        expect(json['workpaper_count'], 50);
        expect(json['findings_count'], 7);
        expect(json['risk_level'], 'high');
      });

      test('serializes dates as ISO strings', () {
        final json = AdvancedAuditMapper.toJson(sampleEngagement);
        expect(json['start_date'], startsWith('2025-05-01'));
        expect(json['end_date'], startsWith('2025-10-31'));
        expect(json['report_due_date'], startsWith('2025-11-30'));
      });

      test('serializes null end_date as null', () {
        final noEnd = AuditEngagement(
          id: 'ae-noend',
          clientId: 'c1',
          clientName: '',
          auditType: AuditType.statutory,
          financialYear: '',
          assignedPartner: '',
          teamMembers: const [],
          status: AuditStatus.planning,
          startDate: DateTime(2025, 1, 1),
          reportDueDate: DateTime(2025, 12, 31),
          workpaperCount: 0,
          findingsCount: 0,
          riskLevel: AuditRiskLevel.low,
        );
        final json = AdvancedAuditMapper.toJson(noEnd);
        expect(json['end_date'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = AdvancedAuditMapper.toJson(sampleEngagement);
        final restored = AdvancedAuditMapper.fromJson(json);

        expect(restored.id, sampleEngagement.id);
        expect(restored.clientId, sampleEngagement.clientId);
        expect(restored.auditType, sampleEngagement.auditType);
        expect(restored.teamMembers, sampleEngagement.teamMembers);
        expect(restored.status, sampleEngagement.status);
        expect(restored.riskLevel, sampleEngagement.riskLevel);
        expect(restored.workpaperCount, sampleEngagement.workpaperCount);
        expect(restored.findingsCount, sampleEngagement.findingsCount);
      });

      test('serializes empty team_members list', () {
        final noTeam = sampleEngagement.copyWith(teamMembers: []);
        final json = AdvancedAuditMapper.toJson(noTeam);
        expect(json['team_members'], isEmpty);
      });
    });
  });
}

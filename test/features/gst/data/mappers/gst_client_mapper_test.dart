import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gst/data/mappers/gst_client_mapper.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';

void main() {
  group('GstClientMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'gstc-001',
          'business_name': 'Sharma Industries Pvt Ltd',
          'trade_name': 'Sharma Industries',
          'gstin': '27ABCPS1234A1Z5',
          'pan': 'ABCPS1234A',
          'registration_type': 'regular',
          'state': 'Maharashtra',
          'state_code': '27',
          'returns_pending': ['GSTR-1', 'GSTR-3B'],
          'last_filed_date': '2025-04-10T00:00:00.000Z',
          'compliance_score': 85,
        };

        final client = GstClientMapper.fromJson(json);

        expect(client.id, 'gstc-001');
        expect(client.businessName, 'Sharma Industries Pvt Ltd');
        expect(client.tradeName, 'Sharma Industries');
        expect(client.gstin, '27ABCPS1234A1Z5');
        expect(client.pan, 'ABCPS1234A');
        expect(client.registrationType, GstRegistrationType.regular);
        expect(client.state, 'Maharashtra');
        expect(client.stateCode, '27');
        expect(client.returnsPending, ['GSTR-1', 'GSTR-3B']);
        expect(client.lastFiledDate, isNotNull);
        expect(client.complianceScore, 85);
      });

      test('handles null trade_name', () {
        final json = {
          'id': 'gstc-002',
          'business_name': 'Mehta Traders',
          'trade_name': null,
          'gstin': '27AABFM3456H1ZK',
          'pan': 'AABFM3456H',
          'registration_type': 'regular',
          'state': 'Gujarat',
          'state_code': '24',
          'returns_pending': [],
          'compliance_score': 90,
        };

        final client = GstClientMapper.fromJson(json);
        expect(client.tradeName, isNull);
        expect(client.lastFiledDate, isNull);
        expect(client.returnsPending, isEmpty);
      });

      test('defaults registration_type to regular for unknown value', () {
        final json = {
          'id': 'gstc-003',
          'business_name': 'Unknown Type Biz',
          'gstin': '27ABCDE1234F1Z5',
          'pan': 'ABCDE1234F',
          'registration_type': 'unknownType',
          'state': 'Delhi',
          'state_code': '07',
          'returns_pending': [],
          'compliance_score': 0,
        };

        final client = GstClientMapper.fromJson(json);
        expect(client.registrationType, GstRegistrationType.regular);
      });

      test('defaults compliance_score to 0 when absent', () {
        final json = {
          'id': 'gstc-004',
          'business_name': 'Minimal Biz',
          'gstin': '27ABCDE1234F1Z5',
          'pan': 'ABCDE1234F',
          'registration_type': 'composition',
          'state': 'Delhi',
          'state_code': '07',
          'returns_pending': [],
        };

        final client = GstClientMapper.fromJson(json);
        expect(client.complianceScore, 0);
      });

      test('handles null returns_pending as empty list', () {
        final json = {
          'id': 'gstc-005',
          'business_name': 'Test Biz',
          'gstin': '27ABCDE1234F1Z5',
          'pan': 'ABCDE1234F',
          'registration_type': 'regular',
          'state': 'Maharashtra',
          'state_code': '27',
          'returns_pending': null,
          'compliance_score': 50,
        };

        final client = GstClientMapper.fromJson(json);
        expect(client.returnsPending, isEmpty);
      });

      test('handles all GstRegistrationType values', () {
        for (final type in GstRegistrationType.values) {
          final json = {
            'id': 'gstc-type-${type.name}',
            'business_name': 'Test',
            'gstin': '27ABCDE1234F1Z5',
            'pan': 'ABCDE1234F',
            'registration_type': type.name,
            'state': 'Maharashtra',
            'state_code': '27',
            'returns_pending': [],
            'compliance_score': 0,
          };
          final client = GstClientMapper.fromJson(json);
          expect(client.registrationType, type);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late GstClient sampleClient;

      setUp(() {
        sampleClient = const GstClient(
          id: 'gstc-json-001',
          businessName: 'Priya Exports Pvt Ltd',
          tradeName: 'Priya Exports',
          gstin: '27CNPPN5678P1Z5',
          pan: 'CNPPN5678P',
          registrationType: GstRegistrationType.regular,
          state: 'Karnataka',
          stateCode: '29',
          returnsPending: ['GSTR-9'],
          complianceScore: 92,
        );
      });

      test('includes all fields', () {
        final json = GstClientMapper.toJson(sampleClient);

        expect(json['id'], 'gstc-json-001');
        expect(json['business_name'], 'Priya Exports Pvt Ltd');
        expect(json['trade_name'], 'Priya Exports');
        expect(json['gstin'], '27CNPPN5678P1Z5');
        expect(json['pan'], 'CNPPN5678P');
        expect(json['registration_type'], 'regular');
        expect(json['state'], 'Karnataka');
        expect(json['state_code'], '29');
        expect(json['returns_pending'], ['GSTR-9']);
        expect(json['compliance_score'], 92);
      });

      test('serializes null trade_name as null', () {
        const clientNoTrade = GstClient(
          id: 'gstc-notrade',
          businessName: 'Solo Trader',
          gstin: '27ABCDE1234F1Z5',
          pan: 'ABCDE1234F',
          registrationType: GstRegistrationType.composition,
          state: 'Delhi',
          stateCode: '07',
        );
        final json = GstClientMapper.toJson(clientNoTrade);
        expect(json['trade_name'], isNull);
      });

      test('serializes null last_filed_date as null', () {
        final json = GstClientMapper.toJson(sampleClient);
        expect(json['last_filed_date'], isNull);
      });

      test('serializes empty returns_pending as empty list', () {
        const clientEmpty = GstClient(
          id: 'gstc-empty',
          businessName: 'Compliant Biz',
          gstin: '27ABCDE1234F1Z5',
          pan: 'ABCDE1234F',
          registrationType: GstRegistrationType.regular,
          state: 'Maharashtra',
          stateCode: '27',
          returnsPending: [],
        );
        final json = GstClientMapper.toJson(clientEmpty);
        expect(json['returns_pending'], isEmpty);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = GstClientMapper.toJson(sampleClient);
        final restored = GstClientMapper.fromJson(json);

        expect(restored.id, sampleClient.id);
        expect(restored.businessName, sampleClient.businessName);
        expect(restored.tradeName, sampleClient.tradeName);
        expect(restored.gstin, sampleClient.gstin);
        expect(restored.pan, sampleClient.pan);
        expect(restored.registrationType, sampleClient.registrationType);
        expect(restored.state, sampleClient.state);
        expect(restored.complianceScore, sampleClient.complianceScore);
        expect(restored.returnsPending, sampleClient.returnsPending);
      });

      test('handles compliance score boundary values', () {
        const maxScore = GstClient(
          id: 'gstc-max',
          businessName: 'Perfect Biz',
          gstin: '27ABCDE1234F1Z5',
          pan: 'ABCDE1234F',
          registrationType: GstRegistrationType.regular,
          state: 'Maharashtra',
          stateCode: '27',
          complianceScore: 100,
        );
        final json = GstClientMapper.toJson(maxScore);
        expect(json['compliance_score'], 100);
      });
    });
  });
}

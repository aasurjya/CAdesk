import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ca_gpt/data/mappers/ca_gpt_mapper.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';

void main() {
  group('CaGptMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'query_id': 'qry-001',
          'question': 'What is the TDS rate for contractors u/s 194C?',
          'context': 'Client is a sole proprietor with annual payments of ₹15 lakh',
          'query_type': 'sectionLookup',
          'financial_year': 2025,
          'pan': 'ABCDE1234F',
          'timestamp': '2025-09-01T10:00:00.000Z',
        };

        final query = CaGptMapper.fromJson(json);

        expect(query.queryId, 'qry-001');
        expect(query.question, 'What is the TDS rate for contractors u/s 194C?');
        expect(query.context, 'Client is a sole proprietor with annual payments of ₹15 lakh');
        expect(query.queryType, QueryType.sectionLookup);
        expect(query.financialYear, 2025);
        expect(query.pan, 'ABCDE1234F');
      });

      test('handles null optional fields', () {
        final json = {
          'query_id': 'qry-002',
          'question': 'GST rate for construction services?',
          'query_type': 'rateQuery',
          'timestamp': '2025-09-01T10:00:00.000Z',
        };

        final query = CaGptMapper.fromJson(json);
        expect(query.context, isNull);
        expect(query.financialYear, isNull);
        expect(query.pan, isNull);
      });

      test('defaults query_type to sectionLookup for unknown value', () {
        final json = {
          'query_id': 'qry-003',
          'question': 'Test question',
          'query_type': 'unknownType',
          'timestamp': '2025-09-01T10:00:00.000Z',
        };

        final query = CaGptMapper.fromJson(json);
        expect(query.queryType, QueryType.sectionLookup);
      });

      test('handles all QueryType values', () {
        for (final type in QueryType.values) {
          final json = {
            'query_id': 'qry-type-${type.name}',
            'question': 'Test',
            'query_type': type.name,
            'timestamp': '2025-09-01T10:00:00.000Z',
          };
          final query = CaGptMapper.fromJson(json);
          expect(query.queryType, type);
        }
      });

      test('applies empty string default for missing question', () {
        final json = {
          'query_id': 'qry-004',
          'query_type': 'complianceCheck',
          'timestamp': '2025-09-01T10:00:00.000Z',
        };

        final query = CaGptMapper.fromJson(json);
        expect(query.question, '');
      });
    });

    group('toJson', () {
      late TaxQuery sampleQuery;

      setUp(() {
        sampleQuery = TaxQuery(
          queryId: 'qry-json-001',
          question: 'Is GST applicable on export of services?',
          context: 'Client provides IT services to US clients',
          queryType: QueryType.complianceCheck,
          financialYear: 2025,
          pan: 'PQRST5678G',
          timestamp: DateTime(2025, 9, 5, 14, 30),
        );
      });

      test('includes all fields', () {
        final json = CaGptMapper.toJson(sampleQuery);

        expect(json['query_id'], 'qry-json-001');
        expect(json['question'], 'Is GST applicable on export of services?');
        expect(json['context'], 'Client provides IT services to US clients');
        expect(json['query_type'], 'complianceCheck');
        expect(json['financial_year'], 2025);
        expect(json['pan'], 'PQRST5678G');
      });

      test('serializes timestamp as ISO string', () {
        final json = CaGptMapper.toJson(sampleQuery);
        expect(json['timestamp'], startsWith('2025-09-05'));
      });

      test('serializes null context and pan as null', () {
        final minQuery = TaxQuery(
          queryId: 'qry-min',
          question: 'Quick question?',
          queryType: QueryType.deadlineQuery,
          timestamp: DateTime(2025, 9, 1),
        );
        final json = CaGptMapper.toJson(minQuery);
        expect(json['context'], isNull);
        expect(json['financial_year'], isNull);
        expect(json['pan'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = CaGptMapper.toJson(sampleQuery);
        final restored = CaGptMapper.fromJson(json);

        expect(restored.queryId, sampleQuery.queryId);
        expect(restored.question, sampleQuery.question);
        expect(restored.context, sampleQuery.context);
        expect(restored.queryType, sampleQuery.queryType);
        expect(restored.financialYear, sampleQuery.financialYear);
        expect(restored.pan, sampleQuery.pan);
      });

      test('serializes all QueryType enum names correctly', () {
        for (final type in QueryType.values) {
          final query = sampleQuery.copyWith(queryType: type);
          final json = CaGptMapper.toJson(query);
          expect(json['query_type'], type.name);
        }
      });
    });
  });
}

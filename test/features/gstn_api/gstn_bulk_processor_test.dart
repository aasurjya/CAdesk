import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/domain/services/gstn_bulk_processor.dart';

void main() {
  late GstnBulkProcessor processor;
  late MockGstnRepository repo;

  setUp(() {
    processor = GstnBulkProcessor();
    repo = MockGstnRepository();
  });

  group('GstnBulkProcessor.bulkVerifyGstins', () {
    test('returns one result per GSTIN', () async {
      final gstins = ['29AABCT1332L000', '27AABCT1332L001', '33AABCT1332L002'];
      final results = await processor.bulkVerifyGstins(gstins, repo);
      expect(results.length, 3);
    });

    test('empty list returns empty results', () async {
      final results = await processor.bulkVerifyGstins([], repo);
      expect(results, isEmpty);
    });

    test('each result has matching gstin', () async {
      final gstins = ['29AABCT1332L000', '27AABCT1332L001'];
      final results = await processor.bulkVerifyGstins(gstins, repo);
      for (var i = 0; i < gstins.length; i++) {
        expect(results[i].gstin, gstins[i]);
      }
    });

    test('processes more than 20 GSTINs in batches', () async {
      // 25 GSTINs — should be processed in 2 batches (20 + 5)
      final gstins = List.generate(25, (i) {
        final padded = i.toString().padLeft(3, '0');
        return '29AABCT${padded}L000';
      });
      final results = await processor.bulkVerifyGstins(gstins, repo);
      expect(results.length, 25);
    });

    test('exactly 20 GSTINs processed in single batch', () async {
      final gstins = List.generate(20, (i) {
        final padded = i.toString().padLeft(3, '0');
        return '29AABCT${padded}L001';
      });
      final results = await processor.bulkVerifyGstins(gstins, repo);
      expect(results.length, 20);
    });

    test('invalid GSTIN included in results with invalid status', () async {
      final gstins = ['29AABCT1332L000', 'INVALID'];
      final results = await processor.bulkVerifyGstins(gstins, repo);
      expect(results.length, 2);
      final invalid = results.firstWhere((r) => r.gstin == 'INVALID');
      expect(invalid.isValid, isFalse);
    });
  });

  group('GstnBulkProcessor.bulkFilingStatusCheck', () {
    test('returns one status per GSTIN', () async {
      final gstins = ['29AABCT1332L000', '27AABCT1332L001'];
      final results = await processor.bulkFilingStatusCheck(
        gstins,
        'GSTR1',
        '032024',
        repo,
      );
      expect(results.length, 2);
    });

    test('empty list returns empty results', () async {
      final results = await processor.bulkFilingStatusCheck(
        [],
        'GSTR1',
        '032024',
        repo,
      );
      expect(results, isEmpty);
    });

    test('each result has correct period', () async {
      final gstins = ['29AABCT1332L000', '27AABCT1332L001'];
      final results = await processor.bulkFilingStatusCheck(
        gstins,
        'GSTR1',
        '032024',
        repo,
      );
      for (final status in results) {
        expect(status.period, '032024');
      }
    });

    test('processes more than 20 GSTINs in batches', () async {
      final gstins = List.generate(22, (i) {
        final padded = i.toString().padLeft(3, '0');
        return '29AABCT${padded}L002';
      });
      final results = await processor.bulkFilingStatusCheck(
        gstins,
        'GSTR1',
        '032024',
        repo,
      );
      expect(results.length, 22);
    });

    test('each result has matching gstin', () async {
      final gstins = ['29AABCT1332L000', '27AABCT1332L001'];
      final results = await processor.bulkFilingStatusCheck(
        gstins,
        'GSTR1',
        '032024',
        repo,
      );
      for (var i = 0; i < gstins.length; i++) {
        expect(results[i].gstin, gstins[i]);
      }
    });
  });
}

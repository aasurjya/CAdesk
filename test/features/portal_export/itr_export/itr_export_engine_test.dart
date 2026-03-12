import 'dart:convert';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_export_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItrExportEngine', () {
    group('detectItrType', () {
      test('detects Itr1FormData as itr1', () {
        final formData = Itr1FormData.empty();
        final type = ItrExportEngine.detectItrType(formData);
        expect(type, ItrType.itr1);
      });

      test('detects Itr2FormData as itr2', () {
        final formData = Itr2FormData.empty();
        final type = ItrExportEngine.detectItrType(formData);
        expect(type, ItrType.itr2);
      });

      test('throws ArgumentError for unknown form data type', () {
        expect(
          () => ItrExportEngine.detectItrType('unknown'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('computeChecksum', () {
      test('returns 64-character hex string', () {
        final checksum = ItrExportEngine.computeChecksum('{"test":true}');
        expect(checksum.length, 64);
        expect(RegExp(r'^[0-9a-f]+$').hasMatch(checksum), isTrue);
      });

      test('is deterministic', () {
        const payload = '{"ITR":"test"}';
        final c1 = ItrExportEngine.computeChecksum(payload);
        final c2 = ItrExportEngine.computeChecksum(payload);
        expect(c1, c2);
      });

      test('different payloads produce different checksums', () {
        final c1 = ItrExportEngine.computeChecksum('payload_one');
        final c2 = ItrExportEngine.computeChecksum('payload_two');
        expect(c1, isNot(c2));
      });
    });

    group('export', () {
      test('exports Itr1FormData and returns ItrExportResult', () {
        final formData = Itr1FormData.empty();
        final result = ItrExportEngine.export(formData, '2024-25');
        expect(result, isA<ItrExportResult>());
        expect(result.itrType, ItrType.itr1);
        expect(result.assessmentYear, '2024-25');
        expect(result.jsonPayload.isNotEmpty, isTrue);
        expect(result.checksum.length, 64);
        expect(result.exportedAt, isA<DateTime>());
      });

      test('exports Itr2FormData and returns ItrExportResult', () {
        final formData = Itr2FormData.empty();
        final result = ItrExportEngine.export(formData, '2024-25');
        expect(result, isA<ItrExportResult>());
        expect(result.itrType, ItrType.itr2);
        expect(result.assessmentYear, '2024-25');
        expect(result.jsonPayload.isNotEmpty, isTrue);
      });

      test('exported JSON is valid JSON', () {
        final formData = Itr1FormData.empty();
        final result = ItrExportEngine.export(formData, '2024-25');
        expect(() => jsonDecode(result.jsonPayload), returnsNormally);
      });

      test('exported JSON has top-level ITR key', () {
        final formData = Itr1FormData.empty();
        final result = ItrExportEngine.export(formData, '2024-25');
        final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
        expect(decoded.containsKey('ITR'), isTrue);
      });

      test('checksum matches payload', () {
        final formData = Itr1FormData.empty();
        final result = ItrExportEngine.export(formData, '2024-25');
        final expected = ItrExportEngine.computeChecksum(result.jsonPayload);
        expect(result.checksum, expected);
      });

      test('throws ArgumentError for unsupported form data', () {
        expect(
          () => ItrExportEngine.export('unsupported', '2024-25'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}

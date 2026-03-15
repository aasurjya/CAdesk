import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/documents/data/mappers/document_mapper.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

void main() {
  group('DocumentMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'doc-001',
          'client_id': 'client-001',
          'client_name': 'Rajesh Kumar',
          'title': 'ITR-1 FY 2024-25',
          'category': 'taxReturns',
          'file_type': 'pdf',
          'file_size': 204800,
          'uploaded_by': 'staff-001',
          'uploaded_at': '2025-07-20T10:00:00.000Z',
          'tags': ['itr', '2024-25'],
          'is_shared_with_client': true,
          'download_count': 3,
          'version': 2,
          'remarks': 'Filed on time',
        };

        final doc = DocumentMapper.fromJson(json);

        expect(doc.id, 'doc-001');
        expect(doc.clientId, 'client-001');
        expect(doc.clientName, 'Rajesh Kumar');
        expect(doc.title, 'ITR-1 FY 2024-25');
        expect(doc.category, DocumentCategory.taxReturns);
        expect(doc.fileType, DocumentFileType.pdf);
        expect(doc.fileSize, 204800);
        expect(doc.uploadedBy, 'staff-001');
        expect(doc.tags, ['itr', '2024-25']);
        expect(doc.isSharedWithClient, isTrue);
        expect(doc.downloadCount, 3);
        expect(doc.version, 2);
        expect(doc.remarks, 'Filed on time');
      });

      test('handles null optional fields with defaults', () {
        final json = {
          'id': 'doc-002',
          'client_id': 'client-002',
          'client_name': 'Mehta & Sons',
          'title': 'GST Certificate',
          'category': 'gstReturns',
          'file_type': 'pdf',
          'file_size': null,
          'uploaded_by': 'staff-002',
          'uploaded_at': '2025-08-01T00:00:00.000Z',
        };

        final doc = DocumentMapper.fromJson(json);
        expect(doc.fileSize, 0);
        expect(doc.tags, isEmpty);
        expect(doc.isSharedWithClient, isFalse);
        expect(doc.downloadCount, 0);
        expect(doc.version, 1);
        expect(doc.remarks, isNull);
      });

      test('defaults category to miscellaneous for unknown value', () {
        final json = {
          'id': 'doc-003',
          'client_id': 'c1',
          'client_name': 'Test',
          'title': 'Unknown Doc',
          'category': 'unknownCategory',
          'file_type': 'pdf',
          'file_size': 1024,
          'uploaded_by': 'staff-001',
          'uploaded_at': '2025-08-01T00:00:00.000Z',
        };

        final doc = DocumentMapper.fromJson(json);
        expect(doc.category, DocumentCategory.miscellaneous);
      });

      test('defaults file_type to pdf for unknown value', () {
        final json = {
          'id': 'doc-004',
          'client_id': 'c1',
          'client_name': 'Test',
          'title': 'Doc',
          'category': 'taxReturns',
          'file_type': 'unknownType',
          'file_size': 1024,
          'uploaded_by': 'staff-001',
          'uploaded_at': '2025-08-01T00:00:00.000Z',
        };

        final doc = DocumentMapper.fromJson(json);
        expect(doc.fileType, DocumentFileType.pdf);
      });

      test('handles null tags as empty list', () {
        final json = {
          'id': 'doc-005',
          'client_id': 'c1',
          'client_name': 'Test',
          'title': 'Doc',
          'category': 'taxReturns',
          'file_type': 'pdf',
          'file_size': 1024,
          'uploaded_by': 'staff-001',
          'uploaded_at': '2025-08-01T00:00:00.000Z',
          'tags': null,
        };

        final doc = DocumentMapper.fromJson(json);
        expect(doc.tags, isEmpty);
      });

      test('handles all DocumentCategory values', () {
        for (final category in DocumentCategory.values) {
          final json = {
            'id': 'doc-cat-${category.name}',
            'client_id': 'c1',
            'client_name': 'Test',
            'title': 'Doc',
            'category': category.name,
            'file_type': 'pdf',
            'file_size': 1024,
            'uploaded_by': 'staff-001',
            'uploaded_at': '2025-08-01T00:00:00.000Z',
          };
          final doc = DocumentMapper.fromJson(json);
          expect(doc.category, category);
        }
      });

      test('handles all DocumentFileType values', () {
        for (final fileType in DocumentFileType.values) {
          final json = {
            'id': 'doc-type-${fileType.name}',
            'client_id': 'c1',
            'client_name': 'Test',
            'title': 'Doc',
            'category': 'miscellaneous',
            'file_type': fileType.name,
            'file_size': 1024,
            'uploaded_by': 'staff-001',
            'uploaded_at': '2025-08-01T00:00:00.000Z',
          };
          final doc = DocumentMapper.fromJson(json);
          expect(doc.fileType, fileType);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late Document sampleDoc;

      setUp(() {
        sampleDoc = Document(
          id: 'doc-json-001',
          clientId: 'client-json-001',
          clientName: 'Priya Nair',
          title: 'Balance Sheet FY 2024-25',
          category: DocumentCategory.financialStatements,
          fileType: DocumentFileType.excel,
          fileSize: 51200,
          uploadedBy: 'staff-json-001',
          uploadedAt: DateTime(2025, 9, 1),
          tags: const ['balance-sheet', '2024-25'],
          isSharedWithClient: true,
          downloadCount: 5,
          version: 3,
          remarks: 'Audited',
        );
      });

      test('includes all fields', () {
        final json = DocumentMapper.toJson(sampleDoc);

        expect(json['id'], 'doc-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Priya Nair');
        expect(json['title'], 'Balance Sheet FY 2024-25');
        expect(json['category'], 'financialStatements');
        expect(json['file_type'], 'excel');
        expect(json['file_size'], 51200);
        expect(json['uploaded_by'], 'staff-json-001');
        expect(json['tags'], ['balance-sheet', '2024-25']);
        expect(json['is_shared_with_client'], isTrue);
        expect(json['download_count'], 5);
        expect(json['version'], 3);
        expect(json['remarks'], 'Audited');
      });

      test('serializes uploaded_at as ISO string', () {
        final json = DocumentMapper.toJson(sampleDoc);
        expect(json['uploaded_at'], startsWith('2025-09-01'));
      });

      test('serializes empty tags as empty list', () {
        final docNoTags = sampleDoc.copyWith(tags: []);
        final json = DocumentMapper.toJson(docNoTags);
        expect(json['tags'], isEmpty);
      });

      test('serializes null remarks as null', () {
        final docNoRemarks = sampleDoc.copyWith(remarks: null);
        // Manually create without remarks
        final doc = Document(
          id: 'doc-noremarks',
          clientId: 'c1',
          clientName: 'Test',
          title: 'Doc',
          category: DocumentCategory.miscellaneous,
          fileType: DocumentFileType.pdf,
          fileSize: 1024,
          uploadedBy: 'staff-001',
          uploadedAt: DateTime(2025, 9, 1),
        );
        final json = DocumentMapper.toJson(doc);
        expect(json['remarks'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = DocumentMapper.toJson(sampleDoc);
        final restored = DocumentMapper.fromJson(json);

        expect(restored.id, sampleDoc.id);
        expect(restored.clientId, sampleDoc.clientId);
        expect(restored.title, sampleDoc.title);
        expect(restored.category, sampleDoc.category);
        expect(restored.fileType, sampleDoc.fileType);
        expect(restored.fileSize, sampleDoc.fileSize);
        expect(restored.isSharedWithClient, sampleDoc.isSharedWithClient);
        expect(restored.downloadCount, sampleDoc.downloadCount);
        expect(restored.version, sampleDoc.version);
        expect(restored.remarks, sampleDoc.remarks);
      });

      test('fileSizeLabel returns correct unit for KB range', () {
        final doc = sampleDoc.copyWith(fileSize: 2048);
        expect(doc.fileSizeLabel, '2.0KB');
      });

      test('fileSizeLabel returns correct unit for bytes range', () {
        final doc = sampleDoc.copyWith(fileSize: 512);
        expect(doc.fileSizeLabel, '512B');
      });
    });
  });
}

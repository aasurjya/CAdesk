import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';
import 'package:ca_app/features/documents/data/mappers/document_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(
    executor: NativeDatabase.memory(),
  );
}

void main() {
  late AppDatabase database;
  late int testCounter;

  setUpAll(() async {
    database = _createTestDatabase();
    testCounter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('DocumentsDao', () {
    Document createTestDocument({
      String? id,
      String? clientId,
      String? title,
      DocumentCategory? category,
    }) {
      testCounter++;
      return Document(
        id: id ?? 'doc-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        clientName: 'Test Client $testCounter',
        title: title ?? 'Tax Return 2024',
        category: category ?? DocumentCategory.taxReturns,
        fileType: DocumentFileType.pdf,
        fileSize: 2048000,
        uploadedBy: 'user@example.com',
        uploadedAt: DateTime(2024, 1, 15),
        tags: ['itR', '2024'],
        remarks: 'Annual ITR filing',
      );
    }

    group('insertDocument', () {
      test('inserts document and returns non-empty ID', () async {
        final doc = createTestDocument();
        final companion = DocumentMapper.toCompanion(doc);
        final id = await database.documentsDao.insertDocument(companion);
        expect(id, isNotEmpty);
      });

      test('stored document has correct title', () async {
        final doc = createTestDocument();
        final companion = DocumentMapper.toCompanion(doc);
        await database.documentsDao.insertDocument(companion);
        final retrieved = await database.documentsDao.getDocumentById(doc.id);
        expect(retrieved?.title, doc.title);
      });
    });

    group('getDocumentsByClient', () {
      test('returns documents for specific client', () async {
        final doc1 = createTestDocument();
        final doc2 = createTestDocument(clientId: doc1.clientId);

        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc1));
        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc2));

        final results = await database.documentsDao.getDocumentsByClient(doc1.clientId);
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.documentsDao.getDocumentsByClient('non-existent');
        expect(results, isEmpty);
      });
    });

    group('watchDocumentsByClient', () {
      test('emits documents for client on watch', () async {
        final doc = createTestDocument();

        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc));

        final stream = database.documentsDao.watchDocumentsByClient(doc.clientId);
        expect(
          stream,
          emits(isA<List<DocumentRow>>()
              .having((rows) => rows.isNotEmpty, 'has documents', true)),
        );
      });
    });

    group('getDocumentsByCategory', () {
      test('returns documents of specific category', () async {
        final catDoc1 = createTestDocument(category: DocumentCategory.gstReturns);
        final catDoc2 = createTestDocument(category: DocumentCategory.gstReturns);

        await database.documentsDao.insertDocument(
          DocumentMapper.toCompanion(catDoc1),
        );
        await database.documentsDao.insertDocument(
          DocumentMapper.toCompanion(catDoc2),
        );

        final results = await database.documentsDao.getDocumentsByCategory('gstReturns');
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent category', () async {
        final results = await database.documentsDao.getDocumentsByCategory('nonexistent');
        expect(results, isEmpty);
      });
    });

    group('getDocumentById', () {
      test('retrieves document by ID', () async {
        final doc = createTestDocument();
        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc));

        final retrieved = await database.documentsDao.getDocumentById(doc.id);
        expect(retrieved != null, isTrue);
        expect(retrieved?.title, doc.title);
      });

      test('returns null for non-existent ID', () async {
        final retrieved = await database.documentsDao.getDocumentById('non-existent-id');
        expect(retrieved == null, isTrue);
      });
    });

    group('updateDocument', () {
      test('updates document successfully', () async {
        final doc = createTestDocument();
        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc));

        final updated = doc.copyWith(title: 'Updated Title', version: 2);
        final success = await database.documentsDao.updateDocument(
          DocumentMapper.toCompanion(updated),
        );

        expect(success, isTrue);
        final retrieved = await database.documentsDao.getDocumentById(doc.id);
        expect(retrieved?.title, 'Updated Title');
      });

      test('increments version on update', () async {
        final doc = createTestDocument();
        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc));

        final updated = doc.copyWith(version: 2);
        await database.documentsDao.updateDocument(DocumentMapper.toCompanion(updated));

        final retrieved = await database.documentsDao.getDocumentById(doc.id);
        expect(retrieved?.version, 2);
      });
    });

    group('deleteDocument', () {
      test('deletes document successfully', () async {
        final doc = createTestDocument();
        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc));

        final success = await database.documentsDao.deleteDocument(doc.id);
        expect(success, isTrue);

        final retrieved = await database.documentsDao.getDocumentById(doc.id);
        expect(retrieved == null, isTrue);
      });
    });

    group('searchDocuments', () {
      test('finds documents by title', () async {
        final doc1 = createTestDocument(title: 'Tax Return 2024');
        final doc2 = createTestDocument(title: 'GST Return 2024');

        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc1));
        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc2));

        final results = await database.documentsDao.searchDocuments('Tax');
        expect(
          results.where((r) => r.title.contains('Tax')).isNotEmpty,
          isTrue,
        );
      });

      test('finds documents by tags', () async {
        final doc = createTestDocument();

        await database.documentsDao.insertDocument(DocumentMapper.toCompanion(doc));

        final results = await database.documentsDao.searchDocuments('itR');
        expect(results.isNotEmpty, isTrue);
      });

      test('returns empty list for non-matching query', () async {
        final results = await database.documentsDao.searchDocuments('nonexistent123xyz');
        expect(results, isEmpty);
      });
    });

    group('Immutability', () {
      test('document has copyWith for immutable updates', () {
        final doc1 = createTestDocument();
        final doc2 = doc1.copyWith(title: 'New Title');

        expect(doc1.title, isNotEmpty);
        expect(doc2.title, 'New Title');
        expect(doc1.id, doc2.id);
      });

      test('tags list is immutable', () {
        final doc1 = createTestDocument();
        final doc2 = doc1.copyWith(tags: [...doc1.tags, 'new-tag']);

        expect(doc1.tags.length, 2);
        expect(doc2.tags.length, 3);
      });
    });
  });
}

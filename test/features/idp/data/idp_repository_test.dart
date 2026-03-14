import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/idp/domain/models/document_job.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';
import 'package:ca_app/features/idp/data/repositories/mock_idp_repository.dart';

void main() {
  group('MockIdpRepository', () {
    late MockIdpRepository repo;

    setUp(() {
      repo = MockIdpRepository();
    });

    // -----------------------------------------------------------------------
    // DocumentJob tests
    // -----------------------------------------------------------------------

    group('getDocumentJobs', () {
      test('returns seeded jobs', () async {
        final results = await repo.getDocumentJobs();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getDocumentJobs();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getDocumentJobsByStatus', () {
      test('returns only jobs with matching status', () async {
        final all = await repo.getDocumentJobs();
        final status = all.first.status;
        final results = await repo.getDocumentJobsByStatus(status);
        expect(results.every((j) => j.status == status), isTrue);
      });

      test('returns empty for non-existent status', () async {
        final results = await repo.getDocumentJobsByStatus(
          'no-such-status-xyz',
        );
        expect(results, isEmpty);
      });
    });

    group('getDocumentJobById', () {
      test('returns job for known id', () async {
        final all = await repo.getDocumentJobs();
        final id = all.first.id;
        final result = await repo.getDocumentJobById(id);
        expect(result, isNotNull);
        expect(result!.id, equals(id));
      });

      test('returns null for unknown id', () async {
        final result = await repo.getDocumentJobById('no-such-id');
        expect(result, isNull);
      });
    });

    group('insertDocumentJob', () {
      test('inserts and returns id', () async {
        final job = DocumentJob(
          id: 'test-job-001',
          clientName: 'Test Client',
          documentType: 'Form 16',
          fileName: 'form16_2025.pdf',
          status: 'Queued',
          confidenceScore: 0.0,
          totalFields: 20,
          extractedFields: 0,
          flaggedFields: 0,
          submittedDate: '14 Mar 2026',
          processingTime: 'pending',
        );
        final id = await repo.insertDocumentJob(job);
        expect(id, equals('test-job-001'));
      });

      test('inserted job is retrievable by id', () async {
        final job = DocumentJob(
          id: 'test-job-002',
          clientName: 'Another Client',
          documentType: '26AS',
          fileName: '26as_2025.pdf',
          status: 'Queued',
          confidenceScore: 0.0,
          totalFields: 15,
          extractedFields: 0,
          flaggedFields: 0,
          submittedDate: '14 Mar 2026',
          processingTime: 'pending',
        );
        await repo.insertDocumentJob(job);
        final result = await repo.getDocumentJobById('test-job-002');
        expect(result, isNotNull);
      });
    });

    group('updateDocumentJob', () {
      test('updates status and returns true', () async {
        final all = await repo.getDocumentJobs();
        final original = all.first;
        final updated = original.copyWith(status: 'Completed');
        final success = await repo.updateDocumentJob(updated);
        expect(success, isTrue);

        final after = await repo.getDocumentJobById(original.id);
        expect(after?.status, 'Completed');
      });

      test('returns false for non-existent id', () async {
        final ghost = DocumentJob(
          id: 'no-such-job',
          clientName: 'Ghost',
          documentType: 'Unknown',
          fileName: 'ghost.pdf',
          status: 'Queued',
          confidenceScore: 0.0,
          totalFields: 0,
          extractedFields: 0,
          flaggedFields: 0,
          submittedDate: '14 Mar 2026',
          processingTime: 'pending',
        );
        final success = await repo.updateDocumentJob(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteDocumentJob', () {
      test('deletes seeded job and returns true', () async {
        final all = await repo.getDocumentJobs();
        final id = all.first.id;
        final success = await repo.deleteDocumentJob(id);
        expect(success, isTrue);

        final after = await repo.getDocumentJobById(id);
        expect(after, isNull);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteDocumentJob('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // ExtractedField tests
    // -----------------------------------------------------------------------

    group('getExtractedFields', () {
      test('returns seeded fields', () async {
        final results = await repo.getExtractedFields();
        expect(results, isNotEmpty);
      });
    });

    group('getExtractedFieldsByJob', () {
      test('returns fields for known job', () async {
        final allFields = await repo.getExtractedFields();
        final jobId = allFields.first.jobId;
        final results = await repo.getExtractedFieldsByJob(jobId);
        expect(results.every((f) => f.jobId == jobId), isTrue);
      });

      test('returns empty for unknown job', () async {
        final results = await repo.getExtractedFieldsByJob('no-such-job');
        expect(results, isEmpty);
      });
    });

    group('updateExtractedField', () {
      test('applies correction and returns true', () async {
        final all = await repo.getExtractedFields();
        final original = all.first;
        final updated = original.copyWith(correctedValue: 'corrected-value');
        final success = await repo.updateExtractedField(updated);
        expect(success, isTrue);

        final after = await repo.getExtractedFields();
        final found = after.firstWhere((f) => f.id == original.id);
        expect(found.correctedValue, equals('corrected-value'));
      });

      test('returns false for non-existent id', () async {
        final ghost = ExtractedField(
          id: 'no-such-field',
          jobId: 'x',
          fieldName: 'Ghost Field',
          extractedValue: '0',
          confidence: 0.0,
          needsReview: false,
        );
        final success = await repo.updateExtractedField(ghost);
        expect(success, isFalse);
      });
    });
  });
}

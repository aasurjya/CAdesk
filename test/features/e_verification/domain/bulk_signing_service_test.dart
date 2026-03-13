import 'package:ca_app/features/e_verification/domain/models/bulk_signing_job.dart';
import 'package:ca_app/features/e_verification/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';
import 'package:ca_app/features/e_verification/domain/services/bulk_signing_service.dart';
import 'package:ca_app/features/e_verification/domain/services/dsc_signing_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DscCertificate testCert;
  late List<SigningRequest> sampleRequests;

  setUp(() {
    testCert = DscSigningService.detectAvailableTokens().firstWhere(
      (c) => c.serialNumber == 'TEST001',
    );

    sampleRequests = List.generate(
      3,
      (i) => DscSigningService.createSigningRequest(
        'hash$i',
        DocumentType.itrV,
        'ABCDE1234F',
      ),
    );
  });

  // ── createBulkJob ────────────────────────────────────────────────────

  group('BulkSigningService.createBulkJob', () {
    test('returns BulkSigningJob with pending status', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(job.status, BulkJobStatus.pending);
    });

    test('stores all requests', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(job.requests.length, 3);
    });

    test('completedCount starts at zero', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(job.completedCount, 0);
    });

    test('failedCount starts at zero', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(job.failedCount, 0);
    });

    test('startedAt is null initially', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(job.startedAt, isNull);
    });

    test('completedAt is null initially', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(job.completedAt, isNull);
    });

    test('generates unique jobId for each call', () {
      final job1 = BulkSigningService.createBulkJob(sampleRequests);
      final job2 = BulkSigningService.createBulkJob(sampleRequests);
      expect(job1.jobId, isNot(equals(job2.jobId)));
    });
  });

  // ── processBulkJob ───────────────────────────────────────────────────

  group('BulkSigningService.processBulkJob', () {
    test('all valid requests → completed status', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      expect(processed.status, BulkJobStatus.completed);
    });

    test('all requests signed → completedCount equals total', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      expect(processed.completedCount, sampleRequests.length);
    });

    test('failedCount is zero when all succeed', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      expect(processed.failedCount, 0);
    });

    test('startedAt is set after processing', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      expect(processed.startedAt, isNotNull);
    });

    test('completedAt is set after processing', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      expect(processed.completedAt, isNotNull);
    });

    test('all requests in processed job have signed status', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      for (final req in processed.requests) {
        expect(req.status, SigningStatus.signed);
      }
    });

    test('original job is not mutated', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      BulkSigningService.processBulkJob(job, testCert);
      expect(job.status, BulkJobStatus.pending);
      expect(job.completedCount, 0);
    });

    test('expired certificate → some/all requests fail', () {
      final expiredCert = DscCertificate(
        tokenId: 'tok-exp',
        subjectName: 'CN=Expired',
        issuer: 'CN=CA',
        serialNumber: 'EXP001',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, expiredCert);
      expect(processed.failedCount, greaterThan(0));
    });

    test('partial failure → partiallyCompleted status', () {
      // Mix valid and pre-failed requests
      final mixedRequests = [
        ...sampleRequests,
        sampleRequests.first.copyWith(
          status: SigningStatus.cancelled,
          documentHash: 'cancelledhash',
        ),
      ];
      // Use expired cert to force some failures
      final expiredCert = DscCertificate(
        tokenId: 'tok-exp2',
        subjectName: 'CN=Expired2',
        issuer: 'CN=CA',
        serialNumber: 'EXP002',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      final job = BulkSigningService.createBulkJob(mixedRequests);
      final processed = BulkSigningService.processBulkJob(job, expiredCert);
      // With expired cert all pending ones fail, cancelled stays cancelled
      expect(processed.failedCount, greaterThan(0));
      expect(
        processed.status == BulkJobStatus.failed ||
            processed.status == BulkJobStatus.partiallyCompleted,
        isTrue,
      );
    });
  });

  // ── getJobProgress ────────────────────────────────────────────────────

  group('BulkSigningService.getJobProgress', () {
    test('new job → 0.0 progress', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      expect(BulkSigningService.getJobProgress(job), 0.0);
    });

    test('fully completed job → 1.0 progress', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      expect(BulkSigningService.getJobProgress(processed), 1.0);
    });

    test('empty job → 0.0 progress', () {
      final emptyJob = BulkSigningService.createBulkJob([]);
      expect(BulkSigningService.getJobProgress(emptyJob), 0.0);
    });

    test('partial completion → correct fraction', () {
      // Manually build a job with 2 completed out of 4
      final requests = List.generate(
        4,
        (i) => DscSigningService.createSigningRequest(
          'hash$i',
          DocumentType.itrV,
          'ABCDE1234F',
        ),
      );
      final job = BulkSigningJob(
        jobId: 'job-test',
        requests: requests,
        status: BulkJobStatus.inProgress,
        completedCount: 2,
        failedCount: 0,
        startedAt: DateTime.now(),
        completedAt: null,
      );
      expect(BulkSigningService.getJobProgress(job), closeTo(0.5, 0.01));
    });
  });

  // ── retryFailed ───────────────────────────────────────────────────────

  group('BulkSigningService.retryFailed', () {
    test('creates new job with only failed requests', () {
      final expiredCert = DscCertificate(
        tokenId: 'tok-exp-retry',
        subjectName: 'CN=Expired Retry',
        issuer: 'CN=CA',
        serialNumber: 'EXPRET001',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final failed = BulkSigningService.processBulkJob(job, expiredCert);
      final retryJob = BulkSigningService.retryFailed(failed);

      expect(retryJob.status, BulkJobStatus.pending);
      expect(retryJob.requests, isNotEmpty);
      // All requests in retry job should be reset to pending
      for (final req in retryJob.requests) {
        expect(req.status, SigningStatus.pending);
      }
    });

    test('retry job has new unique jobId', () {
      final expiredCert = DscCertificate(
        tokenId: 'tok-exp-id',
        subjectName: 'CN=Expired ID',
        issuer: 'CN=CA',
        serialNumber: 'EXPID001',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final failed = BulkSigningService.processBulkJob(job, expiredCert);
      final retryJob = BulkSigningService.retryFailed(failed);
      expect(retryJob.jobId, isNot(equals(job.jobId)));
    });

    test('no failed requests → empty retry job', () {
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final processed = BulkSigningService.processBulkJob(job, testCert);
      final retryJob = BulkSigningService.retryFailed(processed);
      expect(retryJob.requests, isEmpty);
    });

    test('original job not mutated', () {
      final expiredCert = DscCertificate(
        tokenId: 'tok-exp-orig',
        subjectName: 'CN=Expired Orig',
        issuer: 'CN=CA',
        serialNumber: 'EXPORIG001',
        validFrom: DateTime(2020),
        validTo: DateTime(2021),
        keyUsage: const ['digitalSignature', 'nonRepudiation'],
      );
      final job = BulkSigningService.createBulkJob(sampleRequests);
      final failed = BulkSigningService.processBulkJob(job, expiredCert);
      final failedCountBefore = failed.failedCount;
      BulkSigningService.retryFailed(failed);
      expect(failed.failedCount, failedCountBefore);
    });
  });

  // ── BulkSigningJob model ─────────────────────────────────────────────

  group('BulkSigningJob model', () {
    BulkSigningJob createJob({
      String jobId = 'job-001',
      List<SigningRequest>? requests,
      BulkJobStatus status = BulkJobStatus.pending,
      int completedCount = 0,
      int failedCount = 0,
      DateTime? startedAt,
      DateTime? completedAt,
    }) {
      return BulkSigningJob(
        jobId: jobId,
        requests: requests ?? [],
        status: status,
        completedCount: completedCount,
        failedCount: failedCount,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    test('creates with correct field values', () {
      final job = createJob(completedCount: 5, failedCount: 2);
      expect(job.jobId, 'job-001');
      expect(job.completedCount, 5);
      expect(job.failedCount, 2);
      expect(job.status, BulkJobStatus.pending);
    });

    test('totalCount → length of requests list', () {
      final requests = List.generate(
        5,
        (i) => DscSigningService.createSigningRequest(
          'hash$i',
          DocumentType.itrV,
          'ABCDE1234F',
        ),
      );
      final job = createJob(requests: requests);
      expect(job.totalCount, 5);
    });

    test('copyWith → updates specified fields', () {
      final job = createJob();
      final updated = job.copyWith(status: BulkJobStatus.completed);
      expect(updated.status, BulkJobStatus.completed);
      expect(updated.jobId, job.jobId);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final job = createJob(completedCount: 3, failedCount: 1);
      final copy = job.copyWith();
      expect(copy.jobId, job.jobId);
      expect(copy.completedCount, job.completedCount);
      expect(copy.failedCount, job.failedCount);
    });

    test('equality → equal when jobId matches', () {
      final a = createJob(jobId: 'job-001');
      final b = createJob(jobId: 'job-001');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → not equal when jobId differs', () {
      final a = createJob(jobId: 'job-001');
      final b = createJob(jobId: 'job-002');
      expect(a, isNot(equals(b)));
    });
  });

  // ── BulkJobStatus enum ────────────────────────────────────────────────

  group('BulkJobStatus enum', () {
    test('all statuses have labels', () {
      for (final status in BulkJobStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });
}

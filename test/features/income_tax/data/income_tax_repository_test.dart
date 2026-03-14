import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/data/repositories/mock_itr_filing_repository.dart';

void main() {
  group('MockItrFilingRepository', () {
    late MockItrFilingRepository repo;

    setUp(() {
      repo = MockItrFilingRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('getAll', () {
      test('returns all seeded ITR filings', () async {
        final all = await repo.getAll();
        expect(all.length, greaterThanOrEqualTo(5));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAll();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });

    group('getById', () {
      test('returns filing for valid ID', () async {
        final filing = await repo.getById('mock-itr-001');
        expect(filing, isNotNull);
        expect(filing!.id, 'mock-itr-001');
        expect(filing.name, 'Rajesh Kumar Sharma');
      });

      test('returns null for unknown ID', () async {
        final filing = await repo.getById('no-such-id');
        expect(filing, isNull);
      });
    });

    group('create', () {
      test('creates filing and returns it', () async {
        const newFiling = ItrClient(
          id: 'new-itr-001',
          name: 'New Test Client',
          pan: 'ZZZZZ9999Z',
          aadhaar: '1234 5678 9012',
          email: 'new.client@email.com',
          phone: '+91 99999 00000',
          itrType: ItrType.itr1,
          assessmentYear: 'AY 2026-27',
          filingStatus: FilingStatus.pending,
          totalIncome: 500000,
          taxPayable: 12500,
          refundDue: 0,
        );

        final created = await repo.create(newFiling);
        expect(created.id, 'new-itr-001');
        expect(created.name, 'New Test Client');

        final fetched = await repo.getById('new-itr-001');
        expect(fetched, isNotNull);
        expect(fetched!.pan, 'ZZZZZ9999Z');
      });
    });

    group('update', () {
      test('updates existing filing and returns updated record', () async {
        final existing = await repo.getById('mock-itr-003');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(
          filingStatus: FilingStatus.filed,
          filedDate: DateTime(2026, 7, 31),
          acknowledgementNumber: 'ACK2026073100003',
        );
        final result = await repo.update(updated);
        expect(result.filingStatus, FilingStatus.filed);

        final fetched = await repo.getById('mock-itr-003');
        expect(fetched!.filingStatus, FilingStatus.filed);
        expect(fetched.acknowledgementNumber, 'ACK2026073100003');
      });

      test('throws StateError for non-existent filing', () async {
        const ghost = ItrClient(
          id: 'ghost-itr',
          name: 'Ghost Client',
          pan: 'GHOST1234G',
          aadhaar: '0000 0000 0000',
          email: 'ghost@email.com',
          phone: '+91 00000 00000',
          itrType: ItrType.itr1,
          assessmentYear: 'AY 2026-27',
          filingStatus: FilingStatus.pending,
          totalIncome: 0,
          taxPayable: 0,
          refundDue: 0,
        );
        expect(() => repo.update(ghost), throwsA(isA<StateError>()));
      });
    });

    group('delete', () {
      test('deletes filing so it no longer appears in getById', () async {
        const toDelete = ItrClient(
          id: 'itr-to-delete',
          name: 'Delete Me',
          pan: 'DELET1234D',
          aadhaar: '1111 2222 3333',
          email: 'delete@email.com',
          phone: '+91 11111 22222',
          itrType: ItrType.itr2,
          assessmentYear: 'AY 2025-26',
          filingStatus: FilingStatus.pending,
          totalIncome: 0,
          taxPayable: 0,
          refundDue: 0,
        );

        await repo.create(toDelete);
        await repo.delete('itr-to-delete');

        final fetched = await repo.getById('itr-to-delete');
        expect(fetched, isNull);
      });

      test('delete on non-existent ID does not throw', () async {
        await expectLater(repo.delete('no-such-itr'), completes);
      });
    });

    group('search', () {
      test('finds filing by name substring (case-insensitive)', () async {
        final results = await repo.search('rajesh');
        expect(results, isNotEmpty);
        expect(
          results.any((f) => f.name.toLowerCase().contains('rajesh')),
          isTrue,
        );
      });

      test('finds filing by PAN substring', () async {
        final results = await repo.search('ABCPS1234K');
        expect(results, isNotEmpty);
        expect(results.first.pan, 'ABCPS1234K');
      });

      test('finds filing by assessment year', () async {
        final results = await repo.search('AY 2026-27');
        expect(results, isNotEmpty);
        expect(results.every((f) => f.assessmentYear == 'AY 2026-27'), isTrue);
      });

      test('returns empty list for unknown query', () async {
        final results = await repo.search('xyznonexistent12345');
        expect(results, isEmpty);
      });
    });

    group('getByAssessmentYear', () {
      test('returns all filings for AY 2026-27', () async {
        final results = await repo.getByAssessmentYear('AY 2026-27');
        expect(results, isNotEmpty);
        expect(results.every((f) => f.assessmentYear == 'AY 2026-27'), isTrue);
      });

      test('returns empty list for unknown assessment year', () async {
        final results = await repo.getByAssessmentYear('AY 1990-91');
        expect(results, isEmpty);
      });
    });

    group('watchAll', () {
      test('emits a list after create', () async {
        final stream = repo.watchAll();
        final future = stream.first;

        await repo.create(
          const ItrClient(
            id: 'itr-stream-test',
            name: 'Stream Client',
            pan: 'STREA1234S',
            aadhaar: '9999 8888 7777',
            email: 'stream@email.com',
            phone: '+91 77777 88888',
            itrType: ItrType.itr4,
            assessmentYear: 'AY 2026-27',
            filingStatus: FilingStatus.inProgress,
            totalIncome: 800000,
            taxPayable: 10000,
            refundDue: 0,
          ),
        );

        final emitted = await future;
        expect(emitted.any((f) => f.id == 'itr-stream-test'), isTrue);
      });
    });
  });
}

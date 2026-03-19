import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/sync/backup_service.dart';

void main() {
  group('MockBackupService', () {
    late MockBackupService service;

    setUp(() {
      service = MockBackupService();
    });

    group('createBackup — success behaviour', () {
      test('createBackup returns a BackupResult', () async {
        final result = await service.createBackup();

        expect(result, isA<BackupResult>());
      });

      test('createBackup returns success == true', () async {
        final result = await service.createBackup();

        expect(result.success, isTrue);
      });

      test('createBackup result has non-null metadata', () async {
        final result = await service.createBackup();

        expect(result.metadata, isA<BackupMetadata>());
      });

      test('createBackup result metadata has BackupStatus.complete', () async {
        final result = await service.createBackup();

        expect(result.metadata.status, equals(BackupStatus.complete));
      });

      test('createBackup assigns a unique incremental id', () async {
        final r1 = await service.createBackup();
        final r2 = await service.createBackup();

        expect(r1.metadata.id, isNot(equals(r2.metadata.id)));
      });

      test('createBackup includes provided label in metadata', () async {
        final result = await service.createBackup(
          label: 'Pre-migration snapshot',
        );

        expect(result.metadata.label, equals('Pre-migration snapshot'));
      });

      test('createBackup uses simulated record count', () async {
        final customService = MockBackupService(simulatedRecordCount: 1234);
        final result = await customService.createBackup();

        expect(result.metadata.recordCount, equals(1234));
      });

      test('createBackup uses simulated size bytes', () async {
        final customService = MockBackupService(simulatedSizeBytes: 2048);
        final result = await customService.createBackup();

        expect(result.metadata.sizeBytes, equals(2048));
      });
    });

    group('listBackups', () {
      test('listBackups returns empty list when no backups created', () async {
        final backups = await service.listBackups();
        expect(backups, isEmpty);
      });

      test('listBackups returns list of BackupMetadata', () async {
        await service.createBackup();
        final backups = await service.listBackups();

        expect(backups, isA<List<BackupMetadata>>());
      });

      test(
        'listBackups returns one entry after one createBackup call',
        () async {
          await service.createBackup();
          final backups = await service.listBackups();

          expect(backups, hasLength(1));
        },
      );

      test('listBackups returns entries in newest-first order', () async {
        final r1 = await service.createBackup(label: 'first');
        final r2 = await service.createBackup(label: 'second');

        final backups = await service.listBackups();

        // newest first → second backup should be at index 0
        expect(backups[0].id, equals(r2.metadata.id));
        expect(backups[1].id, equals(r1.metadata.id));
      });

      test('listBackups returns multiple backups correctly', () async {
        await service.createBackup();
        await service.createBackup();
        await service.createBackup();

        final backups = await service.listBackups();
        expect(backups, hasLength(3));
      });

      test('listBackups returns an unmodifiable list', () async {
        await service.createBackup();
        final backups = await service.listBackups();

        expect(
          () => (backups as List).add(
            BackupMetadata(
              id: 'fake',
              createdAt: DateTime.now(),
              sizeBytes: 0,
              recordCount: 0,
              status: BackupStatus.complete,
            ),
          ),
          throwsA(anything),
        );
      });
    });

    group('restoreFromBackup', () {
      test(
        'restoreFromBackup completes without error for existing backup',
        () async {
          final result = await service.createBackup();
          final backupId = result.metadata.id;

          expect(() => service.restoreFromBackup(backupId), returnsNormally);
        },
      );

      test(
        'restoreFromBackup throws ArgumentError for unknown backupId',
        () async {
          await expectLater(
            service.restoreFromBackup('non_existent_id'),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'restoreFromBackup throws ArgumentError with descriptive message',
        () async {
          try {
            await service.restoreFromBackup('bad_id');
            fail('Expected ArgumentError');
          } on ArgumentError catch (e) {
            expect(e.message, contains('No backup found'));
          }
        },
      );

      test('restoreFromBackup is a no-op in mock (state unchanged)', () async {
        final result = await service.createBackup();
        await service.restoreFromBackup(result.metadata.id);

        // State should be unchanged — backup still in list.
        final backups = await service.listBackups();
        expect(backups, hasLength(1));
      });
    });

    group('MockBackupService — initial backups', () {
      test('initialBackups are available from the start', () async {
        final preloaded = BackupMetadata(
          id: 'preload_1',
          createdAt: DateTime(2024, 1, 1),
          sizeBytes: 1024,
          recordCount: 500,
          status: BackupStatus.complete,
        );
        final svc = MockBackupService(initialBackups: [preloaded]);
        final backups = await svc.listBackups();

        expect(backups, hasLength(1));
        expect(backups.first.id, equals('preload_1'));
      });

      test('restoreFromBackup works for initial backups', () async {
        final preloaded = BackupMetadata(
          id: 'preload_1',
          createdAt: DateTime(2024, 1, 1),
          sizeBytes: 1024,
          recordCount: 500,
          status: BackupStatus.complete,
        );
        final svc = MockBackupService(initialBackups: [preloaded]);

        expect(() => svc.restoreFromBackup('preload_1'), returnsNormally);
      });
    });

    group('BackupResult — factory constructors', () {
      test('BackupResult.success sets success to true', () {
        final meta = BackupMetadata(
          id: 'test',
          createdAt: DateTime.now(),
          sizeBytes: 0,
          recordCount: 0,
          status: BackupStatus.complete,
        );
        final result = BackupResult.success(meta);

        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('BackupResult.failure sets success to false and errorMessage', () {
        final meta = BackupMetadata(
          id: 'test',
          createdAt: DateTime.now(),
          sizeBytes: 0,
          recordCount: 0,
          status: BackupStatus.failed,
        );
        final result = BackupResult.failure(
          metadata: meta,
          errorMessage: 'Upload failed',
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, equals('Upload failed'));
      });
    });

    group('BackupMetadata — copyWith immutability', () {
      test('copyWith returns new instance with updated field', () {
        final original = BackupMetadata(
          id: 'bk_1',
          createdAt: DateTime(2024, 1, 1),
          sizeBytes: 1024,
          recordCount: 100,
          status: BackupStatus.complete,
        );
        final updated = original.copyWith(recordCount: 200);

        expect(updated.recordCount, equals(200));
        expect(updated.id, equals(original.id));
        expect(identical(original, updated), isFalse);
      });
    });

    group('BackupService — interface contract', () {
      test('MockBackupService implements BackupService', () {
        expect(service, isA<BackupService>());
      });

      test('createBackup is callable as BackupService method', () async {
        final BackupService contract = service;
        final result = await contract.createBackup();
        expect(result.success, isTrue);
      });

      test('listBackups is callable as BackupService method', () async {
        final BackupService contract = service;
        final backups = await contract.listBackups();
        expect(backups, isA<List<BackupMetadata>>());
      });

      test('restoreFromBackup is callable as BackupService method', () async {
        final BackupService contract = service;
        final result = await contract.createBackup();

        expect(
          () => contract.restoreFromBackup(result.metadata.id),
          returnsNormally,
        );
      });
    });
  });
}

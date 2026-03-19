import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:storage_client/src/fetch.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ca_app/core/sync/backup_service.dart';
import 'package:ca_app/core/sync/supabase_backup_service.dart';

// =============================================================================
// Fakes — record method calls without hitting real Supabase
// =============================================================================

/// Tracks calls and stores data for the fake storage layer.
class FakeStorageState {
  final List<UploadCall> uploadCalls = [];
  final List<String> downloadCalls = [];
  final List<String> removeCalls = [];
  final List<String> listCalls = [];

  /// Files that exist in the fake bucket, keyed by storage path.
  final Map<String, Uint8List> files = {};

  /// Metadata returned by [list] for each file.
  final List<FileObject> listResults = [];

  /// When set, [upload] will throw this error.
  Object? uploadError;

  /// When set, [download] will throw this error.
  Object? downloadError;

  void addFile(String path, Uint8List bytes) {
    files[path] = bytes;
  }
}

/// Records a single upload call's path and byte count.
class UploadCall {
  const UploadCall({required this.path, required this.sizeBytes});
  final String path;
  final int sizeBytes;
}

/// Helper to build a [FileObject] with all required fields filled.
FileObject _fileObject({
  required String name,
  String? id,
  String? createdAt,
  String? updatedAt,
  String? bucketId,
  Map<String, dynamic>? metadata,
}) {
  return FileObject(
    name: name,
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    bucketId: bucketId,
    owner: null,
    lastAccessedAt: null,
    metadata: metadata,
    buckets: null,
  );
}

/// Fake [StorageFileApi] that records calls to [FakeStorageState].
///
/// Uses [noSuchMethod] for unneeded methods so only the subset used by
/// [SupabaseBackupService] needs explicit implementations.
class FakeStorageFileApi extends StorageFileApi {
  FakeStorageFileApi(this._state) : super('', const {}, null, 0, _NoOpFetch());

  final FakeStorageState _state;

  @override
  Future<String> upload(
    String path,
    File file, {
    FileOptions fileOptions = const FileOptions(),
    int? retryAttempts,
    StorageRetryController? retryController,
  }) async {
    _state.uploadCalls.add(
      UploadCall(path: path, sizeBytes: await file.length()),
    );
    if (_state.uploadError != null) {
      throw _state.uploadError!; // ignore: only_throw_errors
    }
    _state.files[path] = await file.readAsBytes();
    return path;
  }

  @override
  Future<Uint8List> download(String path, {TransformOptions? transform}) async {
    _state.downloadCalls.add(path);
    if (_state.downloadError != null) {
      throw _state.downloadError!; // ignore: only_throw_errors
    }
    final bytes = _state.files[path];
    if (bytes == null) {
      throw StorageException('Object not found: $path');
    }
    return bytes;
  }

  @override
  Future<List<FileObject>> remove(List<String> paths) async {
    _state.removeCalls.addAll(paths);
    final removed = <FileObject>[];
    for (final path in paths) {
      _state.files.remove(path);
      removed.add(_fileObject(name: path));
    }
    return removed;
  }

  @override
  Future<List<FileObject>> list({
    String? path,
    SearchOptions searchOptions = const SearchOptions(),
  }) async {
    _state.listCalls.add(path ?? '');
    return _state.listResults;
  }
}

/// Placeholder for the [Fetch] dependency that [StorageFileApi] requires.
///
/// None of its methods are called because every method used by the service
/// is overridden in [FakeStorageFileApi].
class _NoOpFetch extends Fetch {
  _NoOpFetch() : super();
}

/// Fake [SupabaseStorageClient] that returns a [FakeStorageFileApi].
class FakeSupabaseStorageClient extends SupabaseStorageClient {
  FakeSupabaseStorageClient(this._state) : super('', {});

  final FakeStorageState _state;

  @override
  StorageFileApi from(String id) => FakeStorageFileApi(_state);
}

/// Fake [SupabaseClient] that provides a fake storage client.
class FakeSupabaseClient extends SupabaseClient {
  FakeSupabaseClient(this._storageClient)
    : super('https://fake.supabase.co', 'fake-anon-key');

  final FakeSupabaseStorageClient _storageClient;

  @override
  SupabaseStorageClient get storage => _storageClient;
}

// =============================================================================
// Test helpers
// =============================================================================

const _testFirmId = 'firm_abc123';
final _fixedNow = DateTime.utc(2026, 3, 17, 14, 30, 22);

/// Creates a [SupabaseBackupService] wired to fakes with a temp directory
/// containing a dummy database file.
Future<_TestHarness> _createHarness({
  int maxBackups = kDefaultMaxBackups,
  bool createDbFile = true,
}) async {
  final tempDir = await Directory.systemTemp.createTemp('backup_test_');
  final dbFile = File('${tempDir.path}/$kDatabaseFilename');
  if (createDbFile) {
    await dbFile.writeAsBytes(
      List<int>.generate(1024, (i) => i % 256),
      flush: true,
    );
  }

  final state = FakeStorageState();
  final storageClient = FakeSupabaseStorageClient(state);
  final supabaseClient = FakeSupabaseClient(storageClient);

  final config = BackupServiceConfig(
    firmId: _testFirmId,
    maxBackups: maxBackups,
  );

  final service = SupabaseBackupService(
    supabaseClient: supabaseClient,
    appDocsDirProvider: () async => tempDir,
    config: config,
    nowProvider: () => _fixedNow,
  );

  return _TestHarness(
    service: service,
    state: state,
    tempDir: tempDir,
    dbFile: dbFile,
    config: config,
  );
}

class _TestHarness {
  const _TestHarness({
    required this.service,
    required this.state,
    required this.tempDir,
    required this.dbFile,
    required this.config,
  });

  final SupabaseBackupService service;
  final FakeStorageState state;
  final Directory tempDir;
  final File dbFile;
  final BackupServiceConfig config;

  Future<void> dispose() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  group('formatBackupTimestamp', () {
    test('formats a UTC DateTime as yyyyMMdd_HHmmss', () {
      final dt = DateTime.utc(2026, 3, 17, 9, 5, 3);
      expect(formatBackupTimestamp(dt), equals('20260317_090503'));
    });

    test('pads single-digit month, day, hour, minute, second', () {
      final dt = DateTime.utc(2026, 1, 2, 3, 4, 5);
      expect(formatBackupTimestamp(dt), equals('20260102_030405'));
    });

    test('converts local DateTime to UTC before formatting', () {
      final local = DateTime(2026, 6, 15, 23, 59, 59);
      final result = formatBackupTimestamp(local);
      // The exact string depends on the local timezone, but it should
      // produce a valid 15-character timestamp.
      expect(result.length, equals(15));
      expect(result.contains('_'), isTrue);
    });
  });

  group('parseBackupPath', () {
    test('parses a valid backup path', () {
      final result = parseBackupPath('firm_abc/20260317_143022.db');
      expect(result, isNotNull);
      expect(result!.firmId, equals('firm_abc'));
      expect(result.timestamp, equals('20260317_143022'));
    });

    test('returns null for path without .db extension', () {
      expect(parseBackupPath('firm_abc/20260317_143022.txt'), isNull);
    });

    test('returns null for path with insufficient segments', () {
      expect(parseBackupPath('20260317_143022.db'), isNull);
    });

    test('handles deeply nested paths', () {
      final result = parseBackupPath('a/b/firm_x/20260101_000000.db');
      expect(result, isNotNull);
      expect(result!.firmId, equals('firm_x'));
    });
  });

  group('BackupServiceConfig', () {
    test('uses default values when not specified', () {
      const config = BackupServiceConfig(firmId: 'test');
      expect(config.maxBackups, equals(kDefaultMaxBackups));
      expect(config.databaseFilename, equals(kDatabaseFilename));
      expect(config.bucket, equals(kBackupBucket));
    });

    test('accepts custom values', () {
      const config = BackupServiceConfig(
        firmId: 'custom',
        maxBackups: 10,
        databaseFilename: 'custom.db',
        bucket: 'custom-bucket',
      );
      expect(config.firmId, equals('custom'));
      expect(config.maxBackups, equals(10));
      expect(config.databaseFilename, equals('custom.db'));
      expect(config.bucket, equals('custom-bucket'));
    });
  });

  group('SupabaseBackupService', () {
    group('implements BackupService', () {
      test('is a BackupService', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);
        expect(harness.service, isA<BackupService>());
      });
    });

    group('createBackup', () {
      test('returns success when DB file exists', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup();

        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
      });

      test(
        'uploads to correct storage path: {firmId}/{timestamp}.db',
        () async {
          final harness = await _createHarness();
          addTearDown(harness.dispose);

          await harness.service.createBackup();

          expect(harness.state.uploadCalls, hasLength(1));
          final uploadPath = harness.state.uploadCalls.first.path;
          expect(
            uploadPath,
            equals('$_testFirmId/${formatBackupTimestamp(_fixedNow)}.db'),
          );
        },
      );

      test('metadata has correct firmId-based id', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup();
        final expectedPath =
            '$_testFirmId/${formatBackupTimestamp(_fixedNow)}.db';

        expect(result.metadata.id, equals(expectedPath));
      });

      test('metadata has correct createdAt timestamp', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup();

        expect(result.metadata.createdAt, equals(_fixedNow));
      });

      test('metadata has correct sizeBytes from DB file', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup();

        expect(result.metadata.sizeBytes, equals(1024));
      });

      test('metadata includes the optional label', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup(
          label: 'Pre-migration',
        );

        expect(result.metadata.label, equals('Pre-migration'));
      });

      test('metadata status is complete on success', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup();

        expect(result.metadata.status, equals(BackupStatus.complete));
      });

      test('returns failure when DB file does not exist', () async {
        final harness = await _createHarness(createDbFile: false);
        addTearDown(harness.dispose);

        final result = await harness.service.createBackup();

        expect(result.success, isFalse);
        expect(result.metadata.status, equals(BackupStatus.failed));
        expect(result.errorMessage, contains('Database file not found'));
      });

      test('returns failure when upload throws', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);
        harness.state.uploadError = Exception('Network timeout');

        final result = await harness.service.createBackup();

        expect(result.success, isFalse);
        expect(result.metadata.status, equals(BackupStatus.failed));
        expect(result.errorMessage, contains('Backup failed'));
      });

      test(
        'uploads correct number of bytes (temp copy, not live DB)',
        () async {
          final harness = await _createHarness();
          addTearDown(harness.dispose);

          await harness.service.createBackup();

          expect(harness.state.uploadCalls, hasLength(1));
          expect(harness.state.uploadCalls.first.sizeBytes, equals(1024));
        },
      );

      test('cleans up temp file after successful upload', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        await harness.service.createBackup();

        // Verify no stale temp directories linger with our timestamp.
        final sysTemp = Directory.systemTemp;
        final tempDirs = sysTemp.listSync().whereType<Directory>().where(
          (d) => d.path.contains('ca_backup_'),
        );
        for (final dir in tempDirs) {
          final files = dir.listSync().whereType<File>().where(
            (f) => f.path.contains(formatBackupTimestamp(_fixedNow)),
          );
          expect(
            files,
            isEmpty,
            reason: 'Temp backup file should be deleted after upload',
          );
        }
      });
    });

    group('restoreFromBackup', () {
      test('downloads the specified backup from Supabase', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        const backupPath = '$_testFirmId/20260317_143022.db';
        final fakeBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        harness.state.addFile(backupPath, fakeBytes);

        await harness.service.restoreFromBackup(backupPath);

        expect(harness.state.downloadCalls, contains(backupPath));
      });

      test('overwrites the live database file', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        const backupPath = '$_testFirmId/20260317_143022.db';
        final fakeBytes = Uint8List.fromList([42, 43, 44]);
        harness.state.addFile(backupPath, fakeBytes);

        await harness.service.restoreFromBackup(backupPath);

        final restoredBytes = await harness.dbFile.readAsBytes();
        expect(restoredBytes, equals([42, 43, 44]));
      });

      test('throws ArgumentError for non-existent backup', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        await expectLater(
          harness.service.restoreFromBackup('no/such/file.db'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError with descriptive message', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        try {
          await harness.service.restoreFromBackup('no/such/file.db');
          fail('Expected ArgumentError');
        } on ArgumentError catch (e) {
          expect(e.message, contains('Backup not found'));
        }
      });
    });

    group('listBackups', () {
      test('queries Supabase Storage with the firmId path', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        await harness.service.listBackups();

        expect(harness.state.listCalls, contains(_testFirmId));
      });

      test('returns empty list when no backups exist', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final backups = await harness.service.listBackups();

        expect(backups, isEmpty);
      });

      test('returns BackupMetadata for each .db file', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        harness.state.listResults.addAll([
          _fileObject(
            name: '20260317_100000.db',
            id: '1',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 2048},
          ),
          _fileObject(
            name: '20260316_090000.db',
            id: '2',
            createdAt: '2026-03-16T09:00:00Z',
            updatedAt: '2026-03-16T09:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
        ]);

        final backups = await harness.service.listBackups();

        expect(backups, hasLength(2));
      });

      test('filters out non-.db files', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        harness.state.listResults.addAll([
          _fileObject(
            name: '20260317_100000.db',
            id: '1',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 2048},
          ),
          _fileObject(
            name: 'readme.txt',
            id: '2',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
          ),
        ]);

        final backups = await harness.service.listBackups();

        expect(backups, hasLength(1));
        expect(backups.first.id, contains('.db'));
      });

      test('sorts backups newest first', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        harness.state.listResults.addAll([
          _fileObject(
            name: '20260315_080000.db',
            id: '1',
            createdAt: '2026-03-15T08:00:00Z',
            updatedAt: '2026-03-15T08:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 512},
          ),
          _fileObject(
            name: '20260317_100000.db',
            id: '2',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 2048},
          ),
        ]);

        final backups = await harness.service.listBackups();

        expect(backups.first.createdAt.isAfter(backups.last.createdAt), isTrue);
      });

      test('returns an unmodifiable list', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        harness.state.listResults.add(
          _fileObject(
            name: '20260317_100000.db',
            id: '1',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
        );

        final backups = await harness.service.listBackups();

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

    group('pruneOldBackups', () {
      test('does nothing when backup count <= maxBackups', () async {
        final harness = await _createHarness(maxBackups: 5);
        addTearDown(harness.dispose);

        harness.state.listResults.addAll([
          _fileObject(
            name: '20260317_100000.db',
            id: '1',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
          _fileObject(
            name: '20260316_090000.db',
            id: '2',
            createdAt: '2026-03-16T09:00:00Z',
            updatedAt: '2026-03-16T09:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
        ]);

        final deletedCount = await harness.service.pruneOldBackups();

        expect(deletedCount, equals(0));
        expect(harness.state.removeCalls, isEmpty);
      });

      test('deletes oldest backups when count > maxBackups', () async {
        final harness = await _createHarness(maxBackups: 2);
        addTearDown(harness.dispose);

        harness.state.listResults.addAll([
          _fileObject(
            name: '20260317_100000.db',
            id: '1',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
          _fileObject(
            name: '20260316_090000.db',
            id: '2',
            createdAt: '2026-03-16T09:00:00Z',
            updatedAt: '2026-03-16T09:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
          _fileObject(
            name: '20260315_080000.db',
            id: '3',
            createdAt: '2026-03-15T08:00:00Z',
            updatedAt: '2026-03-15T08:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 512},
          ),
          _fileObject(
            name: '20260314_070000.db',
            id: '4',
            createdAt: '2026-03-14T07:00:00Z',
            updatedAt: '2026-03-14T07:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 256},
          ),
        ]);

        final deletedCount = await harness.service.pruneOldBackups();

        expect(deletedCount, equals(2));
        expect(harness.state.removeCalls, hasLength(2));
        expect(
          harness.state.removeCalls,
          containsAll([
            '$_testFirmId/20260315_080000.db',
            '$_testFirmId/20260314_070000.db',
          ]),
        );
      });

      test('keeps exactly maxBackups entries', () async {
        final harness = await _createHarness(maxBackups: 1);
        addTearDown(harness.dispose);

        harness.state.listResults.addAll([
          _fileObject(
            name: '20260317_100000.db',
            id: '1',
            createdAt: '2026-03-17T10:00:00Z',
            updatedAt: '2026-03-17T10:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 2048},
          ),
          _fileObject(
            name: '20260316_090000.db',
            id: '2',
            createdAt: '2026-03-16T09:00:00Z',
            updatedAt: '2026-03-16T09:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 1024},
          ),
          _fileObject(
            name: '20260315_080000.db',
            id: '3',
            createdAt: '2026-03-15T08:00:00Z',
            updatedAt: '2026-03-15T08:00:00Z',
            bucketId: kBackupBucket,
            metadata: {'size': 512},
          ),
        ]);

        final deletedCount = await harness.service.pruneOldBackups();

        // 3 total, maxBackups=1 -> delete 2
        expect(deletedCount, equals(2));
      });

      test('returns 0 when no backups exist', () async {
        final harness = await _createHarness();
        addTearDown(harness.dispose);

        final deletedCount = await harness.service.pruneOldBackups();

        expect(deletedCount, equals(0));
      });
    });
  });
}

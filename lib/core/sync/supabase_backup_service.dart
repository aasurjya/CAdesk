import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ca_app/core/sync/backup_service.dart';

/// Default number of recent backups to retain when pruning.
const int kDefaultMaxBackups = 5;

/// Supabase Storage bucket used for database backups.
const String kBackupBucket = 'backups';

/// Default local database filename.
const String kDatabaseFilename = 'ca_app.db';

/// Provides access to the application-documents directory.
///
/// Extracted as a typedef so tests can inject a fake without depending on
/// `path_provider` (which requires a running Flutter engine).
typedef AppDocsDirProvider = Future<Directory> Function();

/// Generates a UTC timestamp string for backup file names.
///
/// Format: `yyyyMMdd_HHmmss` (e.g. `20260317_143022`).
String formatBackupTimestamp(DateTime dt) {
  final utc = dt.toUtc();
  return '${utc.year}'
      '${utc.month.toString().padLeft(2, '0')}'
      '${utc.day.toString().padLeft(2, '0')}'
      '_'
      '${utc.hour.toString().padLeft(2, '0')}'
      '${utc.minute.toString().padLeft(2, '0')}'
      '${utc.second.toString().padLeft(2, '0')}';
}

/// Parses a backup storage path into its components.
///
/// Expected format: `{firmId}/{timestamp}.db`
/// Returns `null` if the path does not match the expected pattern.
({String firmId, String timestamp})? parseBackupPath(String storagePath) {
  final segments = storagePath.split('/');
  if (segments.length < 2) return null;

  final filename = segments.last;
  if (!filename.endsWith('.db')) return null;

  final firmId = segments[segments.length - 2];
  final timestamp = filename.replaceAll('.db', '');
  return (firmId: firmId, timestamp: timestamp);
}

/// Immutable configuration for [SupabaseBackupService].
class BackupServiceConfig {
  const BackupServiceConfig({
    required this.firmId,
    this.maxBackups = kDefaultMaxBackups,
    this.databaseFilename = kDatabaseFilename,
    this.bucket = kBackupBucket,
  });

  /// Identifies the CA firm — backups are stored under `{bucket}/{firmId}/`.
  final String firmId;

  /// Maximum number of recent backups to keep; older ones are pruned.
  final int maxBackups;

  /// Name of the SQLite database file inside the app-documents directory.
  final String databaseFilename;

  /// Supabase Storage bucket name.
  final String bucket;
}

/// Real [BackupService] implementation backed by Supabase Storage.
///
/// Each CA firm's backups are stored under `backups/{firmId}/{timestamp}.db`.
/// The service copies the live SQLite file to a temp location before upload
/// so the live database is never read while being transferred.
///
/// Constructor dependencies are injected so that every I/O boundary can be
/// replaced in tests:
/// - [supabaseClient] — the authenticated Supabase client
/// - [appDocsDirProvider] — resolves the app-documents path
/// - [nowProvider] — returns the current [DateTime] (for deterministic tests)
class SupabaseBackupService implements BackupService {
  SupabaseBackupService({
    required SupabaseClient supabaseClient,
    required AppDocsDirProvider appDocsDirProvider,
    required BackupServiceConfig config,
    DateTime Function()? nowProvider,
  }) : _client = supabaseClient,
       _appDocsDirProvider = appDocsDirProvider,
       _config = config,
       _nowProvider = nowProvider ?? DateTime.now;

  final SupabaseClient _client;
  final AppDocsDirProvider _appDocsDirProvider;
  final BackupServiceConfig _config;
  final DateTime Function() _nowProvider;

  // ---------------------------------------------------------------------------
  // BackupService API
  // ---------------------------------------------------------------------------

  @override
  Future<BackupResult> createBackup({String? label}) async {
    final now = _nowProvider();
    final timestamp = formatBackupTimestamp(now);
    final storagePath = _storagePath(timestamp);

    try {
      // 1. Locate the live database file.
      final dbFile = await _resolveDatabaseFile();
      if (!dbFile.existsSync()) {
        return BackupResult.failure(
          metadata: _metadata(
            id: storagePath,
            createdAt: now,
            sizeBytes: 0,
            label: label,
            status: BackupStatus.failed,
          ),
          errorMessage: 'Database file not found: ${dbFile.path}',
        );
      }

      // 2. Copy to a temp file so the live DB is not read during upload.
      final tempFile = await _copyToTemp(dbFile, timestamp);

      try {
        final sizeBytes = await tempFile.length();

        // 3. Upload to Supabase Storage.
        await _client.storage
            .from(_config.bucket)
            .upload(
              storagePath,
              tempFile,
              fileOptions: const FileOptions(upsert: true),
            );

        return BackupResult.success(
          _metadata(
            id: storagePath,
            createdAt: now,
            sizeBytes: sizeBytes,
            label: label,
          ),
        );
      } finally {
        // 4. Clean up the temp copy regardless of success/failure.
        await _deleteSilently(tempFile);
      }
    } on Object catch (e) {
      return BackupResult.failure(
        metadata: _metadata(
          id: storagePath,
          createdAt: now,
          sizeBytes: 0,
          label: label,
          status: BackupStatus.failed,
        ),
        errorMessage: 'Backup failed: $e',
      );
    }
  }

  @override
  Future<void> restoreFromBackup(String backupId) async {
    // Validate the backup exists by attempting to download it.
    final bytes = await _downloadBackup(backupId);

    // Write to a temp file so the caller can replace the live DB.
    final tempDir = await Directory.systemTemp.createTemp('ca_restore_');
    final restoreFile = File(p.join(tempDir.path, 'restore.db'));
    await restoreFile.writeAsBytes(bytes, flush: true);

    // Copy the restored file over the live database.
    final dbFile = await _resolveDatabaseFile();
    await restoreFile.copy(dbFile.path);

    // Clean up.
    await _deleteSilently(restoreFile);
    await tempDir.delete(recursive: true);
  }

  @override
  Future<List<BackupMetadata>> listBackups() async {
    final prefix = '${_config.firmId}/';
    final objects = await _client.storage
        .from(_config.bucket)
        .list(path: _config.firmId);

    final backups = <BackupMetadata>[];

    for (final obj in objects) {
      if (!obj.name.endsWith('.db')) continue;

      final storagePath = '$prefix${obj.name}';
      final parsed = parseBackupPath(storagePath);
      if (parsed == null) continue;

      backups.add(
        BackupMetadata(
          id: storagePath,
          createdAt: DateTime.tryParse(obj.updatedAt ?? '') ?? DateTime.now(),
          sizeBytes: obj.metadata?['size'] as int? ?? 0,
          recordCount: 0, // Not tracked at the storage level.
          status: BackupStatus.complete,
        ),
      );
    }

    // Sort newest first.
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(backups);
  }

  /// Deletes old backups keeping only the latest [BackupServiceConfig.maxBackups].
  ///
  /// Returns the number of backups deleted.
  Future<int> pruneOldBackups() async {
    final allBackups = await listBackups();
    if (allBackups.length <= _config.maxBackups) return 0;

    // allBackups is already sorted newest-first.
    final toDelete = allBackups.sublist(_config.maxBackups);
    final paths = toDelete.map((b) => b.id).toList();

    await _client.storage.from(_config.bucket).remove(paths);
    return toDelete.length;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the Supabase Storage path for a backup with the given [timestamp].
  String _storagePath(String timestamp) => '${_config.firmId}/$timestamp.db';

  /// Resolves the local SQLite database [File].
  Future<File> _resolveDatabaseFile() async {
    final appDir = await _appDocsDirProvider();
    return File(p.join(appDir.path, _config.databaseFilename));
  }

  /// Copies [source] to a temporary file named with [timestamp].
  Future<File> _copyToTemp(File source, String timestamp) async {
    final tempDir = await Directory.systemTemp.createTemp('ca_backup_');
    final dest = p.join(tempDir.path, '$timestamp.db');
    return source.copy(dest);
  }

  /// Downloads the backup identified by [storagePath].
  ///
  /// Throws [ArgumentError] if the file does not exist.
  Future<List<int>> _downloadBackup(String storagePath) async {
    try {
      final bytes = await _client.storage
          .from(_config.bucket)
          .download(storagePath);
      return bytes;
    } on StorageException catch (e) {
      throw ArgumentError.value(
        storagePath,
        'backupId',
        'Backup not found: ${e.message}',
      );
    }
  }

  /// Convenience to build [BackupMetadata] with sensible defaults.
  BackupMetadata _metadata({
    required String id,
    required DateTime createdAt,
    required int sizeBytes,
    String? label,
    BackupStatus status = BackupStatus.complete,
  }) => BackupMetadata(
    id: id,
    createdAt: createdAt,
    sizeBytes: sizeBytes,
    recordCount: 0,
    status: status,
    label: label,
  );

  /// Deletes [file] ignoring errors (best-effort cleanup).
  Future<void> _deleteSilently(File file) async {
    try {
      if (file.existsSync()) {
        await file.delete();
      }
    } on Object {
      // Best-effort cleanup — swallowing is intentional here.
    }
  }
}

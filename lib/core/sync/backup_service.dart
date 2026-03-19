/// Completion status of a cloud backup.
enum BackupStatus { complete, partial, failed }

/// Immutable metadata record for a single backup.
class BackupMetadata {
  const BackupMetadata({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    required this.recordCount,
    required this.status,
    this.label,
  });

  /// Unique backup identifier (opaque; assigned by the storage layer).
  final String id;

  /// Wall-clock time when the backup was created.
  final DateTime createdAt;

  /// Total size of the backup artifact in bytes.
  final int sizeBytes;

  /// Number of database records captured in the backup.
  final int recordCount;

  /// Outcome status of the backup operation.
  final BackupStatus status;

  /// Optional human-readable label (e.g. "Pre-migration snapshot").
  final String? label;

  BackupMetadata copyWith({
    String? id,
    DateTime? createdAt,
    int? sizeBytes,
    int? recordCount,
    BackupStatus? status,
    String? label,
  }) {
    return BackupMetadata(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      recordCount: recordCount ?? this.recordCount,
      status: status ?? this.status,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupMetadata &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, createdAt, status);

  @override
  String toString() =>
      'BackupMetadata(id: $id, status: ${status.name}, '
      'records: $recordCount, size: ${sizeBytes}B)';
}

/// Immutable result of a [BackupService.createBackup] call.
class BackupResult {
  const BackupResult({
    required this.metadata,
    required this.success,
    this.errorMessage,
  });

  /// Metadata for the backup that was created (even on partial failure).
  final BackupMetadata metadata;

  /// `true` when the backup completed with [BackupStatus.complete].
  final bool success;

  /// Detail of any error that occurred; `null` on success.
  final String? errorMessage;

  /// Convenience constructor for a successful backup.
  factory BackupResult.success(BackupMetadata metadata) =>
      BackupResult(metadata: metadata, success: true);

  /// Convenience constructor for a failed backup.
  factory BackupResult.failure({
    required BackupMetadata metadata,
    required String errorMessage,
  }) => BackupResult(
    metadata: metadata,
    success: false,
    errorMessage: errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupResult &&
        other.metadata == metadata &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(metadata, success);
}

/// Contract for cloud backup and restore operations.
///
/// Implementations should export the local SQLite database, upload it to
/// cloud storage (e.g. Supabase Storage or Google Drive), and record the
/// resulting [BackupMetadata].
abstract class BackupService {
  /// Creates a full export of the local database and uploads it.
  ///
  /// Returns a [BackupResult] describing whether the backup succeeded and
  /// the [BackupMetadata] for the new snapshot.
  Future<BackupResult> createBackup({String? label});

  /// Restores the local database from the backup identified by [backupId].
  ///
  /// Throws [ArgumentError] if no backup with [backupId] exists.
  /// Throws [StateError] if the restore fails part-way through.
  Future<void> restoreFromBackup(String backupId);

  /// Returns metadata for all available backups, newest first.
  Future<List<BackupMetadata>> listBackups();
}

/// Mock implementation of [BackupService] for testing and development.
///
/// - [createBackup] always succeeds and returns a synthetic [BackupMetadata].
/// - [restoreFromBackup] is a no-op (logs the call).
/// - [listBackups] returns the in-memory list of backups created so far.
class MockBackupService implements BackupService {
  MockBackupService({
    List<BackupMetadata>? initialBackups,
    this.simulatedRecordCount = 5000,
    this.simulatedSizeBytes = 1024 * 512,
  }) : _backups = initialBackups != null
           ? List<BackupMetadata>.of(initialBackups)
           : [];

  final List<BackupMetadata> _backups;
  int _idCounter = 1;

  /// Simulated record count for newly created backups.
  final int simulatedRecordCount;

  /// Simulated size in bytes for newly created backups.
  final int simulatedSizeBytes;

  @override
  Future<BackupResult> createBackup({String? label}) async {
    final meta = BackupMetadata(
      id: 'mock_backup_${_idCounter++}',
      createdAt: DateTime.now(),
      sizeBytes: simulatedSizeBytes,
      recordCount: simulatedRecordCount,
      status: BackupStatus.complete,
      label: label,
    );
    _backups.insert(0, meta); // newest first
    return BackupResult.success(meta);
  }

  @override
  Future<void> restoreFromBackup(String backupId) async {
    final exists = _backups.any((b) => b.id == backupId);
    if (!exists) {
      throw ArgumentError.value(
        backupId,
        'backupId',
        'No backup found with id "$backupId"',
      );
    }
    // No-op in mock — real implementation would overwrite local DB.
  }

  @override
  Future<List<BackupMetadata>> listBackups() async {
    return List.unmodifiable(_backups);
  }
}

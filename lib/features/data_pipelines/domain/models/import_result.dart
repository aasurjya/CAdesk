import 'package:ca_app/features/data_pipelines/domain/models/broker_transaction.dart';
import 'package:ca_app/features/data_pipelines/domain/models/import_error.dart';

/// Source of the import — maps to the originating broker or RTA system.
enum ImportSource {
  zerodha,
  upstox,
  iciciDirect,
  hdfcSec,
  angelOne,
  cams,
  kfintech,
  nsdl,
  cdsl,
}

/// Immutable result of a single import operation.
///
/// Captures both successfully parsed [transactions] and any [errors] encountered
/// so callers can report partial success to users without losing good data.
class ImportResult {
  const ImportResult({
    required this.importId,
    required this.source,
    required this.importedAt,
    required this.totalRecords,
    required this.successCount,
    required this.errorCount,
    required this.errors,
    required this.transactions,
  });

  /// Unique identifier for this import run (UUID v4 or timestamp-based).
  final String importId;

  /// Source system for this import.
  final ImportSource source;

  /// Timestamp when the import was initiated.
  final DateTime importedAt;

  /// Total number of data rows in the source file (excluding the header).
  final int totalRecords;

  /// Number of rows successfully parsed into [transactions].
  final int successCount;

  /// Number of rows that failed parsing (recorded in [errors]).
  final int errorCount;

  /// List of parse errors encountered, one per bad row.
  final List<ImportError> errors;

  /// Successfully parsed broker transactions.
  final List<BrokerTransaction> transactions;

  /// Returns a new [ImportResult] with specified fields replaced.
  ImportResult copyWith({
    String? importId,
    ImportSource? source,
    DateTime? importedAt,
    int? totalRecords,
    int? successCount,
    int? errorCount,
    List<ImportError>? errors,
    List<BrokerTransaction>? transactions,
  }) {
    return ImportResult(
      importId: importId ?? this.importId,
      source: source ?? this.source,
      importedAt: importedAt ?? this.importedAt,
      totalRecords: totalRecords ?? this.totalRecords,
      successCount: successCount ?? this.successCount,
      errorCount: errorCount ?? this.errorCount,
      errors: errors ?? this.errors,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImportResult) return false;
    if (other.importId != importId) return false;
    if (other.source != source) return false;
    if (other.importedAt != importedAt) return false;
    if (other.totalRecords != totalRecords) return false;
    if (other.successCount != successCount) return false;
    if (other.errorCount != errorCount) return false;
    if (other.errors.length != errors.length) return false;
    if (other.transactions.length != transactions.length) return false;
    for (var i = 0; i < errors.length; i++) {
      if (other.errors[i] != errors[i]) return false;
    }
    for (var i = 0; i < transactions.length; i++) {
      if (other.transactions[i] != transactions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    importId,
    source,
    importedAt,
    totalRecords,
    successCount,
    errorCount,
    Object.hashAll(errors),
    Object.hashAll(transactions),
  );
}

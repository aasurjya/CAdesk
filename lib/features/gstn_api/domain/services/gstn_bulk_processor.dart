import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';

/// Handles bulk GSTN operations by batching requests within the GSTN API limit.
///
/// The GSTN portal enforces a maximum of 20 GSTINs per API call.
/// All methods respect this constraint by splitting large lists into
/// sequential batches and collecting results preserving input order.
class GstnBulkProcessor {
  static const int _batchSize = 20;

  /// Verifies multiple GSTINs in batches of [_batchSize].
  ///
  /// Results are returned in the same order as [gstins].
  Future<List<GstnVerificationResult>> bulkVerifyGstins(
    List<String> gstins,
    GstnRepository repo,
  ) async {
    if (gstins.isEmpty) return const [];

    final results = <GstnVerificationResult>[];
    final batches = _splitIntoBatches(gstins);

    for (final batch in batches) {
      final batchResults = await Future.wait(
        batch.map((gstin) => repo.verifyGstin(gstin)),
      );
      results.addAll(batchResults);
    }

    return List.unmodifiable(results);
  }

  /// Fetches filing status for multiple GSTINs in batches of [_batchSize].
  ///
  /// All GSTINs are checked for the same [returnType] and [period].
  /// Results are returned in the same order as [gstins].
  Future<List<GstnFilingStatus>> bulkFilingStatusCheck(
    List<String> gstins,
    String returnType,
    String period,
    GstnRepository repo,
  ) async {
    if (gstins.isEmpty) return const [];

    final results = <GstnFilingStatus>[];
    final batches = _splitIntoBatches(gstins);

    for (final batch in batches) {
      final batchResults = await Future.wait(
        batch.map((gstin) => repo.getFilingStatus(gstin, returnType, period)),
      );
      results.addAll(batchResults);
    }

    return List.unmodifiable(results);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Splits [items] into sub-lists of at most [_batchSize] elements.
  List<List<T>> _splitIntoBatches<T>(List<T> items) {
    final batches = <List<T>>[];
    for (var start = 0; start < items.length; start += _batchSize) {
      final end = (start + _batchSize).clamp(0, items.length);
      batches.add(items.sublist(start, end));
    }
    return batches;
  }
}

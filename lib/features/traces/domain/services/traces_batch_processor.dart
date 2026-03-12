import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
import 'package:ca_app/features/traces/domain/repositories/traces_repository.dart';

/// Stateless utility that batches TRACES API operations into chunks of 50,
/// matching the TRACES portal's per-request PAN limit.
///
/// All methods are pure functions over the [TracesRepository] interface —
/// no state is mutated and each call is independent.
class TracesBatchProcessor {
  const TracesBatchProcessor();

  /// Maximum number of PANs per TRACES API request.
  static const int _chunkSize = 50;

  // ── PAN Verification ────────────────────────────────────────────────────

  /// Verify [pans] in batches of [_chunkSize] using [repo].
  ///
  /// The returned list preserves the same order as [pans].
  /// Returns an empty list when [pans] is empty.
  Future<List<TracesPanVerification>> batchVerifyPans(
    List<String> pans,
    TracesRepository repo,
  ) async {
    if (pans.isEmpty) return const [];

    final results = <TracesPanVerification>[];
    for (var offset = 0; offset < pans.length; offset += _chunkSize) {
      final chunk = pans.skip(offset).take(_chunkSize).toList();
      for (final pan in chunk) {
        final verification = await repo.verifyPan(pan);
        results.add(verification);
      }
    }
    return results;
  }

  // ── Bulk Form 16 ────────────────────────────────────────────────────────

  /// Submit Form 16 download requests for [pans] in batches of [_chunkSize].
  ///
  /// Each PAN generates one [TracesForm16Request]. The returned list preserves
  /// the input order.  Returns an empty list when [pans] is empty.
  Future<List<TracesForm16Request>> batchRequestForm16(
    String tan,
    List<String> pans,
    int financialYear,
    TracesRepository repo,
  ) async {
    if (pans.isEmpty) return const [];

    final results = <TracesForm16Request>[];
    for (var offset = 0; offset < pans.length; offset += _chunkSize) {
      final chunk = pans.skip(offset).take(_chunkSize).toList();
      final chunkResults = await repo.requestBulkForm16(
        tan,
        financialYear,
        chunk,
      );
      results.addAll(chunkResults);
    }
    return results;
  }

  // ── Progress Computation ─────────────────────────────────────────────────

  /// Compute overall progress for a batch of Form 16 requests as a value
  /// between 0.0 (nothing done) and 1.0 (all complete).
  ///
  /// Statuses mapped to their weight (fraction of total work):
  /// - [Form16RequestStatus.submitted]  → 0.0
  /// - [Form16RequestStatus.processing] → 0.5
  /// - [Form16RequestStatus.available]  → 1.0
  /// - [Form16RequestStatus.downloaded] → 1.0
  /// - [Form16RequestStatus.failed]     → 1.0 (failed = terminal, no retry)
  ///
  /// Returns 0.0 for an empty [requests] list.
  double computeBatchProgress(List<TracesForm16Request> requests) {
    if (requests.isEmpty) return 0.0;

    var totalWeight = 0.0;
    for (final req in requests) {
      totalWeight += _statusWeight(req.status);
    }
    return totalWeight / requests.length;
  }

  double _statusWeight(Form16RequestStatus status) {
    switch (status) {
      case Form16RequestStatus.submitted:
        return 0.0;
      case Form16RequestStatus.processing:
        return 0.5;
      case Form16RequestStatus.available:
      case Form16RequestStatus.downloaded:
      case Form16RequestStatus.failed:
        return 1.0;
    }
  }
}

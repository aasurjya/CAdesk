import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/repositories/gstn_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final gstnRepositoryProvider = Provider<GstnRepository>((ref) {
  return MockGstnRepository();
});

// ---------------------------------------------------------------------------
// API quota usage
// ---------------------------------------------------------------------------

/// Immutable snapshot of GSTN API quota usage.
class GstnApiQuota {
  const GstnApiQuota({required this.used, required this.total});

  final int used;
  final int total;

  int get remaining => total - used;
  double get usagePercent => total > 0 ? used / total : 0;
}

final gstnApiQuotaProvider =
    NotifierProvider<GstnApiQuotaNotifier, GstnApiQuota>(
      GstnApiQuotaNotifier.new,
    );

class GstnApiQuotaNotifier extends Notifier<GstnApiQuota> {
  @override
  GstnApiQuota build() {
    return const GstnApiQuota(used: 342, total: 1000);
  }

  void incrementUsage() {
    state = GstnApiQuota(used: state.used + 1, total: state.total);
  }
}

// ---------------------------------------------------------------------------
// GSTIN search
// ---------------------------------------------------------------------------

final gstinSearchQueryProvider =
    NotifierProvider<GstinSearchQueryNotifier, String>(
      GstinSearchQueryNotifier.new,
    );

class GstinSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final gstinSearchResultProvider =
    NotifierProvider<
      GstinSearchResultNotifier,
      AsyncValue<GstnVerificationResult?>
    >(GstinSearchResultNotifier.new);

class GstinSearchResultNotifier
    extends Notifier<AsyncValue<GstnVerificationResult?>> {
  @override
  AsyncValue<GstnVerificationResult?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> search(String gstin) async {
    if (gstin.length != 15) {
      state = AsyncValue.error(
        'GSTIN must be exactly 15 characters',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repo = ref.read(gstnRepositoryProvider);
      final result = await repo.verifyGstin(gstin);
      ref.read(gstnApiQuotaProvider.notifier).incrementUsage();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

// ---------------------------------------------------------------------------
// Filing status
// ---------------------------------------------------------------------------

final gstnFilingStatusProvider =
    NotifierProvider<GstnFilingStatusNotifier, AsyncValue<GstnFilingStatus?>>(
      GstnFilingStatusNotifier.new,
    );

class GstnFilingStatusNotifier extends Notifier<AsyncValue<GstnFilingStatus?>> {
  @override
  AsyncValue<GstnFilingStatus?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> checkStatus(
    String gstin,
    String returnType,
    String period,
  ) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(gstnRepositoryProvider);
      final result = await repo.getFilingStatus(gstin, returnType, period);
      ref.read(gstnApiQuotaProvider.notifier).incrementUsage();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ---------------------------------------------------------------------------
// GSTR-2B fetch
// ---------------------------------------------------------------------------

final gstr2bResultProvider =
    NotifierProvider<Gstr2bResultNotifier, AsyncValue<Gstr2bFetchResult?>>(
      Gstr2bResultNotifier.new,
    );

class Gstr2bResultNotifier extends Notifier<AsyncValue<Gstr2bFetchResult?>> {
  @override
  AsyncValue<Gstr2bFetchResult?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> fetch(String gstin, String period) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(gstnRepositoryProvider);
      final result = await repo.fetchGstr2b(gstin, period);
      ref.read(gstnApiQuotaProvider.notifier).incrementUsage();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

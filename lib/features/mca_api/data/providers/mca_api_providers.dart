import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/mca_api/data/mock_mca_repository.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_filing_history.dart';
import 'package:ca_app/features/mca_api/domain/repositories/mca_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final mcaRepositoryProvider = Provider<McaRepository>((ref) {
  return const MockMcaRepository();
});

// ---------------------------------------------------------------------------
// Company search
// ---------------------------------------------------------------------------

final mcaCompanySearchProvider =
    NotifierProvider<McaCompanySearchNotifier, AsyncValue<McaCompanyLookup?>>(
      McaCompanySearchNotifier.new,
    );

class McaCompanySearchNotifier extends Notifier<AsyncValue<McaCompanyLookup?>> {
  @override
  AsyncValue<McaCompanyLookup?> build() {
    return const AsyncValue.data(null);
  }

  /// Search by CIN (if it matches CIN pattern) or by company name.
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.error(
        'Please enter a CIN or company name',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mcaRepositoryProvider);
      final isCin = RegExp(
        r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$',
      ).hasMatch(query.toUpperCase());

      final result = isCin
          ? await repo.lookupByCin(query.toUpperCase())
          : await repo.searchByName(query);

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

// ---------------------------------------------------------------------------
// CIN lookup (dedicated)
// ---------------------------------------------------------------------------

final mcaCinLookupProvider =
    NotifierProvider<McaCinLookupNotifier, AsyncValue<McaCompanyLookup?>>(
      McaCinLookupNotifier.new,
    );

class McaCinLookupNotifier extends Notifier<AsyncValue<McaCompanyLookup?>> {
  @override
  AsyncValue<McaCompanyLookup?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> lookup(String cin) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mcaRepositoryProvider);
      final result = await repo.lookupByCin(cin);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ---------------------------------------------------------------------------
// Director search
// ---------------------------------------------------------------------------

final mcaDirectorSearchProvider =
    NotifierProvider<McaDirectorSearchNotifier, AsyncValue<McaDirectorLookup?>>(
      McaDirectorSearchNotifier.new,
    );

class McaDirectorSearchNotifier
    extends Notifier<AsyncValue<McaDirectorLookup?>> {
  @override
  AsyncValue<McaDirectorLookup?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> search(String din) async {
    if (din.length != 8 || !RegExp(r'^[0-9]{8}$').hasMatch(din)) {
      state = AsyncValue.error(
        'DIN must be exactly 8 digits',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mcaRepositoryProvider);
      final result = await repo.lookupDirector(din);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

// ---------------------------------------------------------------------------
// Filing history / compliance status
// ---------------------------------------------------------------------------

final mcaFilingHistoryProvider =
    NotifierProvider<McaFilingHistoryNotifier, AsyncValue<McaFilingHistory?>>(
      McaFilingHistoryNotifier.new,
    );

class McaFilingHistoryNotifier extends Notifier<AsyncValue<McaFilingHistory?>> {
  @override
  AsyncValue<McaFilingHistory?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> fetch(String cin) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mcaRepositoryProvider);
      final result = await repo.getFilingHistory(cin);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

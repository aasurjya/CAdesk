import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/crypto_vda/data/mock/vda_mock_data.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_summary.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_tax_overview.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/domain/services/vda_tax_calculator.dart';

// Re-export so callers can import a single file for everything they need.
export 'package:ca_app/features/crypto_vda/domain/models/vda_tax_overview.dart';
export 'package:ca_app/features/crypto_vda/domain/services/vda_tax_calculator.dart';

// ---------------------------------------------------------------------------
// Core data providers
// ---------------------------------------------------------------------------

/// All VDA transactions.
final allVdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  return List.unmodifiable(mockVdaTransactions);
});

/// Backward-compatible alias for [allVdaTransactionsProvider].
final vdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  return ref.watch(allVdaTransactionsProvider);
});

/// All VDA client summaries.
final vdaSummariesProvider = Provider<List<VdaSummary>>((ref) {
  return List.unmodifiable(mockVdaSummaries);
});

/// Computed Schedule VDA summary for a given [clientId].
final vdaScheduleSummaryProvider =
    Provider.family<VdaScheduleSummary, String>((
  Ref ref,
  String clientId,
) {
  final List<VdaTransaction> txns = ref
      .watch(allVdaTransactionsProvider)
      .where((VdaTransaction t) => t.clientId == clientId)
      .toList();
  return VdaTaxCalculator.computeScheduleVda(txns);
});

// ---------------------------------------------------------------------------
// Filter / selection providers
// ---------------------------------------------------------------------------

/// Selected client filter. Null means all clients.
final selectedVdaClientProvider =
    NotifierProvider<SelectedVdaClientNotifier, String?>(
  SelectedVdaClientNotifier.new,
);

class SelectedVdaClientNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected asset type filter. Null means all types.
final selectedAssetTypeProvider =
    NotifierProvider<SelectedAssetTypeNotifier, VdaAssetType?>(
  SelectedAssetTypeNotifier.new,
);

class SelectedAssetTypeNotifier extends Notifier<VdaAssetType?> {
  @override
  VdaAssetType? build() => null;

  void update(VdaAssetType? value) => state = value;
}

/// Selected transaction type filter. Null means all types.
final selectedTransactionTypeProvider =
    NotifierProvider<SelectedTransactionTypeNotifier, VdaTransactionType?>(
  SelectedTransactionTypeNotifier.new,
);

class SelectedTransactionTypeNotifier extends Notifier<VdaTransactionType?> {
  @override
  VdaTransactionType? build() => null;

  void update(VdaTransactionType? value) => state = value;
}

/// Currently selected tab index on the crypto VDA screen.
final selectedVdaTabProvider =
    NotifierProvider<SelectedVdaTabNotifier, int>(SelectedVdaTabNotifier.new);

class SelectedVdaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

// ---------------------------------------------------------------------------
// Derived / computed providers
// ---------------------------------------------------------------------------

/// Transactions filtered by client, asset type, and transaction type.
final filteredVdaTransactionsProvider = Provider<List<VdaTransaction>>((ref) {
  final List<VdaTransaction> all = ref.watch(vdaTransactionsProvider);
  final String? client = ref.watch(selectedVdaClientProvider);
  final VdaAssetType? assetType = ref.watch(selectedAssetTypeProvider);
  final VdaTransactionType? txnType =
      ref.watch(selectedTransactionTypeProvider);

  return List.unmodifiable(
    all.where((VdaTransaction t) {
      final bool matchesClient = client == null || t.clientId == client;
      final bool matchesAsset = assetType == null || t.assetType == assetType;
      final bool matchesTxn = txnType == null || t.transactionType == txnType;
      return matchesClient && matchesAsset && matchesTxn;
    }),
  );
});

/// Unique client names for the filter dropdown.
final vdaClientNamesProvider =
    Provider<List<({String id, String name})>>((ref) {
  final List<VdaTransaction> all = ref.watch(vdaTransactionsProvider);
  final Set<String> seen = <String>{};
  final List<({String id, String name})> result =
      <({String id, String name})>[];

  for (final VdaTransaction t in all) {
    if (seen.add(t.clientId)) {
      result.add((id: t.clientId, name: t.clientName));
    }
  }
  return List.unmodifiable(result);
});

/// Aggregate tax overview across all clients.
final vdaTaxOverviewProvider = Provider<VdaTaxOverview>((ref) {
  final List<VdaSummary> summaries = ref.watch(vdaSummariesProvider);

  double totalGains = 0;
  double totalLosses = 0;
  double totalTax = 0;
  double totalTds = 0;
  double totalShortfall = 0;
  int violationCount = 0;

  for (final VdaSummary s in summaries) {
    totalGains += s.totalGains;
    totalLosses += s.totalLosses;
    totalTax += s.taxLiability;
    totalTds += s.tdsCollected;
    totalShortfall += s.tdsShortfall;
    if (s.hasLossRestrictionViolation) {
      violationCount++;
    }
  }

  return VdaTaxOverview(
    totalGains: totalGains,
    totalLosses: totalLosses,
    totalTaxLiability: totalTax,
    totalTdsCollected: totalTds,
    totalTdsShortfall: totalShortfall,
    lossRestrictionViolations: violationCount,
  );
});

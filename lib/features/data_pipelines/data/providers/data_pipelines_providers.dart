import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/data_pipeline.dart';
import '../../domain/models/broker_feed.dart';

// ---------------------------------------------------------------------------
// Mock data - Data Pipelines
// ---------------------------------------------------------------------------

final List<DataPipeline> _mockPipelines = [
  DataPipeline(
    id: 'dp-001',
    name: 'Form 16 Bulk Import',
    sourceType: PipelineSourceType.form16,
    status: PipelineStatus.active,
    lastSync: DateTime(2026, 3, 10, 9, 30),
    recordsProcessed: 342,
    errorCount: 0,
    nextSync: DateTime(2026, 3, 10, 21, 30),
    clientCount: 58,
  ),
  DataPipeline(
    id: 'dp-002',
    name: 'Form 26AS / AIS Sync',
    sourceType: PipelineSourceType.form26as,
    status: PipelineStatus.active,
    lastSync: DateTime(2026, 3, 10, 8, 0),
    recordsProcessed: 1204,
    errorCount: 3,
    nextSync: DateTime(2026, 3, 11, 8, 0),
    clientCount: 124,
    errorMessage: '3 PAN mismatches detected',
  ),
  DataPipeline(
    id: 'dp-003',
    name: 'Zerodha Capital Gains',
    sourceType: PipelineSourceType.zerodha,
    status: PipelineStatus.active,
    lastSync: DateTime(2026, 3, 10, 7, 15),
    recordsProcessed: 876,
    errorCount: 0,
    nextSync: DateTime(2026, 3, 10, 19, 15),
    clientCount: 45,
  ),
  DataPipeline(
    id: 'dp-004',
    name: 'CAMS MF Statements',
    sourceType: PipelineSourceType.cams,
    status: PipelineStatus.error,
    lastSync: DateTime(2026, 3, 9, 14, 0),
    recordsProcessed: 0,
    errorCount: 1,
    clientCount: 72,
    errorMessage: 'API authentication failed — credentials expired',
  ),
  DataPipeline(
    id: 'dp-005',
    name: 'Tally Accounting Data',
    sourceType: PipelineSourceType.tally,
    status: PipelineStatus.active,
    lastSync: DateTime(2026, 3, 10, 6, 0),
    recordsProcessed: 2150,
    errorCount: 0,
    nextSync: DateTime(2026, 3, 11, 6, 0),
    clientCount: 31,
  ),
  DataPipeline(
    id: 'dp-006',
    name: 'KFintech Mutual Funds',
    sourceType: PipelineSourceType.kfintech,
    status: PipelineStatus.paused,
    lastSync: DateTime(2026, 3, 7, 10, 0),
    recordsProcessed: 540,
    errorCount: 0,
    clientCount: 38,
  ),
  DataPipeline(
    id: 'dp-007',
    name: 'Zoho Books Integration',
    sourceType: PipelineSourceType.zohoBooks,
    status: PipelineStatus.pending,
    lastSync: DateTime(2026, 3, 8, 12, 0),
    recordsProcessed: 98,
    errorCount: 0,
    nextSync: DateTime(2026, 3, 10, 18, 0),
    clientCount: 12,
  ),
  DataPipeline(
    id: 'dp-008',
    name: 'Groww Portfolio Sync',
    sourceType: PipelineSourceType.groww,
    status: PipelineStatus.active,
    lastSync: DateTime(2026, 3, 10, 7, 45),
    recordsProcessed: 415,
    errorCount: 2,
    nextSync: DateTime(2026, 3, 10, 19, 45),
    clientCount: 27,
    errorMessage: '2 transaction records missing cost basis',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - Broker Feeds
// ---------------------------------------------------------------------------

final List<BrokerFeed> _mockBrokerFeeds = [
  BrokerFeed(
    id: 'bf-001',
    broker: BrokerName.zerodha,
    clientName: 'Ramesh Kumar Agarwal',
    status: BrokerFeedStatus.synced,
    lastFetch: DateTime(2026, 3, 10, 7, 15),
    capitalGainsCount: 14,
    totalTransactions: 87,
    pan: 'ABCPK1234D',
    accountId: 'ZR91234',
  ),
  BrokerFeed(
    id: 'bf-002',
    broker: BrokerName.cams,
    clientName: 'Sunita Priya Sharma',
    status: BrokerFeedStatus.failed,
    lastFetch: DateTime(2026, 3, 9, 14, 0),
    capitalGainsCount: 0,
    totalTransactions: 0,
    pan: 'DFGPS5678F',
    accountId: 'CAMS-56789',
  ),
  BrokerFeed(
    id: 'bf-003',
    broker: BrokerName.groww,
    clientName: 'Anjali Mehta',
    status: BrokerFeedStatus.synced,
    lastFetch: DateTime(2026, 3, 10, 7, 45),
    capitalGainsCount: 6,
    totalTransactions: 43,
    pan: 'HJLAM2345G',
    accountId: 'GRW-43210',
  ),
  BrokerFeed(
    id: 'bf-004',
    broker: BrokerName.kfintech,
    clientName: 'Vikram Singh Rathore',
    status: BrokerFeedStatus.stale,
    lastFetch: DateTime(2026, 3, 7, 10, 0),
    capitalGainsCount: 9,
    totalTransactions: 61,
    pan: 'KLPVR6789H',
    accountId: 'KFT-78901',
  ),
  BrokerFeed(
    id: 'bf-005',
    broker: BrokerName.angelOne,
    clientName: 'Pradeep Nair',
    status: BrokerFeedStatus.syncing,
    lastFetch: DateTime(2026, 3, 10, 9, 0),
    capitalGainsCount: 0,
    totalTransactions: 29,
    pan: 'MNQPN3456J',
    accountId: 'AO-23456',
  ),
  BrokerFeed(
    id: 'bf-006',
    broker: BrokerName.karvy,
    clientName: 'Meena Rajagopalan',
    status: BrokerFeedStatus.synced,
    lastFetch: DateTime(2026, 3, 10, 8, 30),
    capitalGainsCount: 11,
    totalTransactions: 55,
    pan: 'PQRMR7890K',
    accountId: 'KRV-34567',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All data pipelines.
final dataPipelinesProvider = Provider<List<DataPipeline>>(
  (_) => List.unmodifiable(_mockPipelines),
);

/// All broker feeds.
final brokerFeedsProvider = Provider<List<BrokerFeed>>(
  (_) => List.unmodifiable(_mockBrokerFeeds),
);

/// Selected pipeline status filter.
final pipelineStatusFilterProvider =
    NotifierProvider<PipelineStatusFilterNotifier, PipelineStatus?>(
      PipelineStatusFilterNotifier.new,
    );

class PipelineStatusFilterNotifier extends Notifier<PipelineStatus?> {
  @override
  PipelineStatus? build() => null;

  void update(PipelineStatus? value) => state = value;
}

/// Data pipelines filtered by selected status.
final filteredPipelinesProvider = Provider<List<DataPipeline>>((ref) {
  final status = ref.watch(pipelineStatusFilterProvider);
  final all = ref.watch(dataPipelinesProvider);
  if (status == null) return all;
  return all.where((p) => p.status == status).toList();
});

/// Data pipelines summary statistics.
final dataPipelinesSummaryProvider = Provider<DataPipelinesSummary>((ref) {
  final pipelines = ref.watch(dataPipelinesProvider);
  final now = DateTime(2026, 3, 10);

  final totalPipelines = pipelines.length;
  final activePipelines = pipelines
      .where((p) => p.status == PipelineStatus.active)
      .length;
  final errorPipelines = pipelines
      .where((p) => p.status == PipelineStatus.error)
      .length;
  final todayStart = DateTime(now.year, now.month, now.day);
  final totalRecordsToday = pipelines
      .where(
        (p) =>
            p.status == PipelineStatus.active && p.lastSync.isAfter(todayStart),
      )
      .fold<int>(0, (sum, p) => sum + p.recordsProcessed);

  return DataPipelinesSummary(
    totalPipelines: totalPipelines,
    activePipelines: activePipelines,
    errorPipelines: errorPipelines,
    totalRecordsToday: totalRecordsToday,
  );
});

// ---------------------------------------------------------------------------
// Summary data class
// ---------------------------------------------------------------------------

class DataPipelinesSummary {
  const DataPipelinesSummary({
    required this.totalPipelines,
    required this.activePipelines,
    required this.errorPipelines,
    required this.totalRecordsToday,
  });

  final int totalPipelines;
  final int activePipelines;
  final int errorPipelines;
  final int totalRecordsToday;
}
